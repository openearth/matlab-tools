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
%bnd file creation

function [gridInfo]=D3D_plot_domain_number(fdir_sim,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ldb',{});
addOptional(parin,'fig_print',0);
addOptional(parin,'fig_path','');

parse(parin,varargin{:})

ldb=parin.Results.ldb;
fig_print=parin.Results.fig_print;
fig_path=parin.Results.fig_path;

%% PATHS

simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef);
fpath_map=simdef.file.map;

%% CALC

gridInfo=EHY_getGridInfo(fpath_map,{'XYcen','domain_number','face_nodes_xy'});

[domain_u,idx1,idx2]=unique(gridInfo.domain_number);
nu=numel(domain_u);

%change to random colormap
cmap=brewermap(9,'set1');
cmap=repmat(cmap,ceil(nu/9),1);
%this may not be needed!
% dn=gridInfo.domain_number;
% idx_o=rand(nu,1);
% [~,idx_o]=sort(idx_o);
% for ku=1:nu
%     bol_d=idx2==ku;
%     dn(bol_d)=idx_o(ku);
% end

%% PLOT

figure
hold on
EHY_plotMapModelData(gridInfo,gridInfo.domain_number)
colormap(cmap)
axis equal

%text
for ku=1:nu
    bol_d=idx2==ku;
    xm=mean(gridInfo.Xcen(bol_d));
    ym=mean(gridInfo.Ycen(bol_d));
    text(xm,ym,num2str(domain_u(ku)),'color','r')
end

%ldb
if ~isempty(ldb)
    ldb=D3D_read_ldb(fpath_ldb);
    nldb=numel(ldb);
    for kldb=1:nldb
        plot(ldb(kldb).cord(:,1),ldb(kldb).cord(:,2),'color','k','linewidth',1,'linestyle','-','marker','none')
    end
end

%% SAVE

if isempty(fig_path)
    fig_path=fullfile(fdir_sim,'figures','domain_number');
    mkdir_check(fig_path);
end

if any(fig_print==1)
    fpath_fig=fullfile(fig_path,'domain_number.fig');
    savefig(gcf,fpath_fig);
end

end %function