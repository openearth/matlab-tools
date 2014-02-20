function varargout=d3d2dflowfm_friction_trachytopes(varargin)
% Generate and write D-Flow FM trachytope *.aru from Delft3D definition
% d3d2dflowfm_trachytopes generate and write D-Flow FM roughness from
%         trachytopes distribution file (.aru) from space varying
%         d3d-flow roughness from trachytopes distribution file (.aru/.arv)
%
%         Input arguments:
%                1) Name of the delft3d grid file (*.grd)
%                2) Name of the delft3d friction from trachytope file (*.aru)
%                3) Name of the delft3d friction from trachytope file (*.arv)
%                4) Name of the dflowfm network file(*_net.nc)
%                5) Name of the dflowfm trachytope file(*.arl)
%
% See also: dflowfm_io_mdu dflowfm_io_xydata d3d2dflowfm_friction_xyz

filgrd         = varargin{1};
filaru         = varargin{2};
filarv         = varargin{3};
filnet         = varargin{4};
filarl         = varargin{5};

%
% Read the grid information
%

grid           = delft3d_io_grd('read',filgrd);
mmax           = grid.mmax;
nmax           = grid.nmax;
xcoor_u        = grid.u_full.x;
ycoor_u        = grid.u_full.y;
xcoor_v        = grid.v_full.x;
ycoor_v        = grid.v_full.y;

%
% Read the net information
%

GF = dflowfm.readNet(filnet);

%
% Get u/v grid points and find associated net link
%
L_u = zeros(nmax,mmax);
L_v = zeros(nmax,mmax);

for n = 1:nmax
    for m = 1:nmax;
        x_u = xcoor_u(n,m);
        y_u = ycoor_u(n,m);
        L_u(n,m) = find_net_link(x_u,y_u,GF);
        x_v = xcoor_v(n,m);
        y_v = ycoor_v(n,m);
        L_v(n,m) = find_net_link(x_v,y_v,GF);
    end
end

%
% Read associated .aru and arv. files
% 

S_u = delft3d_io_aru_arv('read',filaru);
S_v = delft3d_io_aru_arv('read',filarv);

%
% Create structure for .arl file 
% 

k = 1;
S_l.data{k}.comment = ['* Converted from Delft3D input files'];
L_all = {L_u,L_v};
cc = 0;
for T = [S_u, S_v]
    cc = cc + 1;
    LL = L_all{cc};
    k = k+1;
    S_l.data{k}.comment = ['* Based on ',T.filename];
    for j = 1:length(T.data);
        if (length(setdiff(lower(fieldnames(T.data{j})),{'comment'})) == 0);
            k = k+1;
            S_l.data{k}.comment = T.data{j}.comment;
        elseif (length(setdiff(lower(fieldnames(T.data{j})),{'n','m','definition','percentage'})) == 0);
            L = LL(T.data{j}.n,T.data{j}.m);
            if ~isnan(L)
                k = k+1;
                S_l.data{k}.definition = T.data{j}.definition;
                S_l.data{k}.percentage = T.data{j}.percentage;
                S_l.data{k}.nm = L;
            end
        elseif (length(setdiff(lower(fieldnames(T.data{j})),{'n1','m1','n2','m2','definition','percentage'})) == 0);
            for m = T.data{j}.m1:T.data{j}.m2
                for n = T.data{j}.n1:T.data{j}.n2
                    L = LL(n,m);
                    if ~isnan(L)
                        k = k+1;
                        S_l.data{k}.definition = T.data{j}.definition;
                        S_l.data{k}.percentage = T.data{j}.percentage;
                        S_l.data{k}.nm = L;
                    end
                end
            end
        end
        %end
    end
end

%
% Write structure to .arl file (reusing Delft3d routine)
% 
T = delft3d_io_aru_arv('write',filarl,S_l);

end

function found = isbetween(ax, ay, bx, by, cx, cy)
epsilon = 1e-8;
crossproduct = (cy - ay) * (bx - ax) - (cx - ax) * (by - ay);
found = 1;
if abs(crossproduct) > epsilon;
    found = 0;
end
dotproduct = (cx - ax) * (bx - ax) + (cy - ay)*(by - ay);
if dotproduct < 0
    found = 0;
end
squaredlengthba = (bx - ax)*(bx - ax) + (by - ay)*(by - ay);
if dotproduct > squaredlengthba
    found = 0;
end
end

function L = find_net_link(x,y,GF);
L = 0;
found = 0;
hold on;
while L < GF.cor.nLink
    L = L+1;
    nl = GF.cor.Link(:,L);
    xL = GF.cor.x(nl);
    yL = GF.cor.y(nl);
    if isbetween(xL(1),yL(1),xL(2),yL(2),x,y)
        found = 1;
        break
    end
end
if ((found == 0) || isnan(x) || isnan(y))
    L = NaN;
end
end