%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19676 $
%$Date: 2024-06-17 21:37:30 +0200 (Mon, 17 Jun 2024) $
%$Author: chavarri $
%$Id: fig_his_sal_01.m 19676 2024-06-17 19:37:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_his_sal_01.m $
%
%Compute xlim and ylim for a 1D plot such that it fits the domain we want given the
%data we have.
%
%INPUT:
%

function [xlims,ylims]=xlim_ylim(xlims,ylims,x_v,val)

%% PARSE

%convert input to cell arrays 
[val,nv]=convert_to_cell(val,1);
[x_v,~ ]=convert_to_cell(x_v,nv);

%check dimensions
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

        bol=xloc>xlims(1) & xloc<xlims(2);

        min_max_loc=[min(vloc(bol)),max(vloc(bol))];

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

%% CHECK

check_nan(xlim)
check_nan(ylim)

end %function 

%%
%% FUNCTIONS
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
