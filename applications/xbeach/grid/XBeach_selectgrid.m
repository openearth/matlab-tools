function XB = XBeach_selectgrid(X, Y, Z, varargin)
%XBEACH_SELECTGRID  One line description goes here.
%
%   Please note:
%   deepval and dryval are both considered as positive. In addition, it is
%   assumed that the reference level is in between the deepval and dryval
%   level
%
%   Syntax:
%   varargout = XBeach_selectgrid(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   XBeach_selectgrid
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Dano Roelvink / Ap van Dongeren / C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 03 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% default Input section
OPT = struct(...
    'manual', true,...
    'plot', true,...
    'WL_t', 0,...
    'xori', 0,...
    'yori', 0,...
    'alfa', 0,...
    'dx', 2,...
    'dy', 2,...
    'dryval', 10,...
    'maxslp', .2,...
    'seaslp', .02,...
    'deepval', 10,...
    'dxmax', 20,...
    'dxmin', 2,...
    'dymax', 50,...
    'dymin', 10,...
    'finepart', 0.3,...
    'posdwn', 1,...
    'polygon', [],...
    'bathy', {{[] [] []}});

% check whether XB-structure is given as input
XBid = find(cellfun(@isstruct, varargin));
if ~isempty(XBid)
    XB = varargin{XBid};
    varargin(XBid) = [];
end
try %#ok<TRYNC>
    % the functions keyword_value and CreateEmptyXBeachVar are available in OpenEarthTools
    OPT = setProperty(OPT, varargin{:});
    if ~exist('XB', 'var')
        XB = CreateEmptyXBeachVar;
    end
catch
    if ~isempty(varargin)
        warning(['Properties ' sprintf('"%s" ', varargin{1:2:end}) 'have not been set']) %#ok<WNTAG>
    end
end

if isempty(OPT.polygon)
    OPT.manual = true;
else
    [xi yi] = deal(OPT.polygon(1,:), OPT.polygon(2,:));
end

% modify deepval and dryval to make them correspond with posdwm (and so,
% with Z)
OPT.deepval = OPT.posdwn * abs(OPT.deepval);
OPT.dryval = -OPT.posdwn * abs(OPT.dryval);



if OPT.manual
    figure;
    scatter(OPT.bathy{1}, OPT.bathy{2}, 5, OPT.bathy{3}, 'filled');
    colorbar;
    hold on
    xn = max(max(X));
    yn = max(max(Y));
    plot([0 xn xn 0 0],[0 0 yn yn 0],'r-')
    axis ([0 xn 0 yn]);axis equal
    % Select polygon to include in bathy
    % Loop, picking up the points.
    disp('Select polygon to include in bathy')
    disp('Left mouse button picks points.')
    disp('Right mouse button picks last point.')
    [xi yi]=select_oblique_rectangle
end

% Interpolate to grid
in = inpolygon(X, Y, xi, yi);
Z(~in) = NaN;

if OPT.plot
    figure;
    if ~isvector(X)
        surf(X, Y, Z);
        shading interp;
        colorbar
    else
        plot(X, Z)
    end
end

% Extrapolate to sides
[nX nY] = size(X);
if any(isnan(Z))
    for i = 1:nX
        for j = floor(nY/2):nY
            %         if j == nY
            %             dbstopcurrent
            %         end
            %         dbclear all
            if isnan(Z(i,j))
                Z(i,j) = Z(i,j-1);
            end
        end
        for j = floor(nY/2)-1:-1:1
            if isnan(Z(i,j))
                Z(i,j) = Z(i,j+1);
            end
        end
    end
    for j = 1:nY
        % Extrapolate to land
        for i = floor(nX/2):nX
            if isnan(Z(i,j));
                Z(i,j) = OPT.posdwn * max(OPT.posdwn*Z(i-1,j)-OPT.maxslp*OPT.dx, OPT.posdwn*OPT.dryval);
            end
        end
        % Extrapolate to sea
        for i = floor(nX/2):-1:1
            if isnan(Z(i,j));
                Z(i,j) = OPT.posdwn * min(OPT.posdwn*Z(i+1,j)+OPT.seaslp*OPT.dx, OPT.posdwn*OPT.deepval);
            end
        end
    end
end

if OPT.plot
    figure;
    if ~isvector(X)
        surf(X, Y, Z);
        shading interp;
        colorbar
    else
        plot(X, Z)
    end
end

%% x-grid
xnew = X(:,1);
d0 = min(OPT.WL_t) + mean(OPT.posdwn*Z(1,:)); % mean depth at seaward boundary
i = 1; % start at seaward boundary

while xnew(i)<X(end,1);
    % interpolate for each y the corresponding z with the newly
    % chosen x value
    znew = interp2(X', Y', Z', repmat(xnew(i), 1, nY), Y(1,:));
    d = min(OPT.WL_t) + min(OPT.posdwn*znew);
    dxnew = max(OPT.dxmax * sqrt(max(d,.1)/d0), OPT.dxmin);
    i = i+1;
    xnew(i) = xnew(i-1)+dxnew;
end
xnew(i+1:end) = [];
%{
figure
plot(xnew, ones(size(xnew)), 'o',...
[X(end) X(end)], [0 2], '--')
xlabel('x [m]')
%}
nxnew = length(xnew); % number of grid points in x direction

%% y-grid
ynew = Y(1,:);
yrefine = [0 0.5-OPT.finepart/2 0.5+OPT.finepart/2 1]*Y(1,end);
dyrefine = [OPT.dymax OPT.dymin OPT.dymin  OPT.dymax];
i = 1;
while ynew(i) < Y(1,end);
    dynew = interp1(yrefine, dyrefine, ynew(i));
    i = i+1;
    ynew(i) = ynew(i-1) + dynew;
end
ynew(i+1:end) = [];
%{
figure
plot(yrefine, dyrefine, '-',...
 ynew, [diff(ynew) dyrefine(end)], 'o',...
 [Y(end) Y(end)], dyrefine(end-1:end), '--')
ylabel('dy [m]')
xlabel('y [m]')
%}
nynew = length(ynew); % number of grid points in y direction

%% plot grid
Xnew = repmat(xnew, 1, nynew);
Ynew = repmat(ynew, nxnew, 1);
Znew = interp2(X', Y', Z', Xnew, Ynew);

% prevent NaNs at the boundaries
Znew(end,:) = Znew(end-1,:);
Znew(:,end) = Znew(:, end-1);

% figure
% pcolor(Xnew,Ynew,Znew);axis equal

XB.Input.xInitial = Xnew;
XB.Input.yInitial = Ynew;
XB.Input.zInitial = Znew;

XB.settings.Grid = struct(...
    'nx', nxnew-1,...
    'ny', nynew-1,...
    'vardx', 1,...
    'depfile', '',...
    'xfile', '',...
    'yfile', '',...
    'dx', OPT.dx,...
    'dy', OPT.dy,...
    'xori', OPT.xori,...
    'yori', OPT.yori,...
    'alfa', OPT.alfa*180/pi,...
    'posdwn', -1);



% fi=fopen('bathy.dep','wt');
% for j=1:nynew
%     fprintf(fi,'%7.3f ',Znew(:,j));
%     fprintf(fi,'\n');
% end
% fclose(fi);
% 
% fi=fopen('x.dep','wt');
% for j=1:nynew
%     fprintf(fi,'%7.3f ',Xnew(:,j));
%     fprintf(fi,'\n');
% end
% fclose(fi);
% 
% fi=fopen('y.dep','wt');
% for j=1:nynew
%     fprintf(fi,'%7.3f ',Ynew(:,j));
%     fprintf(fi,'\n');
% end
% fclose(fi);
% 
% fi=fopen('griddata.txt','wt');
% fprintf(fi,'nx      = %3i \n',nxnew-1);
% fprintf(fi,'ny      = %3i \n',nynew-1);
% fprintf(fi,'dx      = %6.1f \n',OPT.dx);
% fprintf(fi,'dy      = %6.1f \n',OPT.dy);
% fprintf(fi,'xori    = %10.2f \n',xori);
% fprintf(fi,'yori    = %10.2f \n',yori);
% fprintf(fi,'alfa    = %10.2f \n',alfa*180/pi);
% fprintf(fi,'depfile = bathy.dep \n');
% fprintf(fi,'vardx   = 1 \n');
% fprintf(fi,'xfile = x.dep \n');
% fprintf(fi,'yfile = y.dep \n');
% fprintf(fi,'posdwn  = -1 \n');
% fclose(fi);
