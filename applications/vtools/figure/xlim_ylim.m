%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Compute xlim and ylim for a 1D plot such that it fits the domain we want given the
%data we have.
%
%INPUT:
%

function [xlims,ylims]=xlim_ylim(xlims,ylims,x_v,val,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tolx',[0,0])
addOptional(parin,'toly',[0,0])

parse(parin,varargin{:})

tolx=parin.Results.tolx;
toly=parin.Results.toly;

%% PREPROCESS

[nv,x_v,val]=number_of_values(x_v,val);
 
[val,nv]=convert_to_cell(val,nv);
[x_v,~ ]=convert_to_cell(x_v,nv);

check_dimensions(x_v,val)

%% CALC

%If there is no xlim given, we take the minimum and maximum of available data. 
if ~isdatetime(xlims(1)) && ~isduration(xlims(1)) && isnan(xlims(1))
    xlims=[min([x_v{:}]),max([x_v{:}])];
end

if isnan(ylims(1))
    ylims=[Inf,-Inf];
    for kv=1:nv
        xloc=x_v{kv};
        vloc=val{kv};

        bol=xloc>=xlims(1) & xloc<=xlims(2);

        if ~any(bol)
            min_max_loc=[-inf,inf];
        else
            min_max_loc=[min(vloc(bol)),max(vloc(bol))];
        end

        ylims=[min([min_max_loc(1),ylims(1)]),max([min_max_loc(2),ylims(2)])];
    end
end
if any(isinf(ylims)) %all data is outside domain to plot
    ylims=[-1e-10,1e-10];
end

dy=diff(ylims);
if dy==0
    my=mean(ylims);
    ylims=ylims+abs(my/100)*[-1,1];
end

%% TOL

xlims=xlims+tolx;
ylims=ylims+toly;

xlims=check_diff(xlims);
ylims=check_diff(ylims);

%% CHECK

check_nan(xlims);
check_nan(ylims);

end %function 

%%
%% FUNCTIONS
%%

function [nv,x_v,val]=number_of_values(x_v,val)

%if matrices or vector, the output is [nx,nv]

if iscell(val)
    nv=numel(val);
elseif iscell(x_v)
    nv=numel(x_v);
else
    %val and x_v are both vector or matrices
    sx=size(x_v);
    if numel(sx)>2
        error('It cannot have more than 2 dimensions.')
    end

    %the number of lines is the size which is not equal to the size of x
    sv=size(val);
    if numel(sv)>2
        error('It cannot have more than 2 dimensions.')
    end
    bol_x=sx==sv;
    if sum(bol_x)==0
        error('The size of `val` does not match the size of `x`')
    elseif sum(bol_x)==2 %vectors or matrices which are the same size
        %check if any dimension is 1
        bol_1=sv==1;
        if sum(bol_1)==0 %matrices
            %we assume it is already correct in [nx,nv]
            nv=sv(2);
        else
            nv=1;
        end
    else %vector or matrices of different size. Search for the one which is equal
        nv=sv(~bol_x);
    end
    if bol_x(1)
        x_v=x_v';
        val=val';
    end
end

end %function

%%

function [x_v,nv]=convert_to_cell(x_v,nv)

if ~iscell(x_v)
    sv=size(x_v);
    if numel(sv)>2
        error('It cannot have more than 2 dimensions.')
    end
    if isvector(x_v)
        x_v=reshape(x_v,1,[]);
        x_v=repmat(x_v,nv,1);
    end
    x_vc=cell(nv,1);
    for kv=1:nv
        x_vc{kv}=x_v(kv,:);
    end
    x_v=x_vc;
end

%From here on, x_v and val are cell arrays.

nv=numel(x_v);

for kv=1:nv
    x_v{kv}=reshape(x_v{kv},1,[]);
end

%From here on, x_v and val are cell arrays with [1,np] vectors in it.

end %function

%%

function check_dimensions(x_v,val)

nx=numel(x_v);
nv=numel(val);

if nv~=nx
    error('Number of x vectors should be the same as number of val vectors.')
end

for kv=1:nv
    if numel(x_v{kv}) ~= numel(val{kv})
        error('Should have the same number of elements.')
    end
end

end %function

%%

function check_nan(xlims)

err=false;
if isdatetime(xlims(1)) || isduration(xlims(1))
    if any(isnat(xlims))
        err=true;
    end
else
    if  any(isnan(xlims)) || numel(xlims)>2
        err=true;
    end
end

if err
    error('Something is wrong.')
end

end %function

%%

function xlims=check_diff(xlims)

if diff(xlims)==0
    if isdatetime(xlims(1))
        xlims=xlims+days([-1,1]);
    else
        xlims=real(xlims+[-1,1].*abs(mean(xlims)/1000)+10.*[-eps,eps]);
    end
end

end %function