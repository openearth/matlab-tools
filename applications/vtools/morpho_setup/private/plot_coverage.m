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
%

function plot_coverage(pol,etab_cen,fpath_rkm,fdir_fig,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'type',1,@isnumeric);

parse(parin,varargin{:});

type_plot=parin.Results.type;

tol_x=2000;
tol_y=2000;

fid_log=NaN;
do_debug=1;

%% CALC

% 204514.187500,429127.000000,862.00_BR,862.000000 
rkm_plot=readcell(fpath_rkm,'Delimiter',',');
nrkm=size(rkm_plot,1);

fpath_mat_tmp=fullfile(pwd,'centroids.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug
    messageOut(fid_log,'Start finding centroids');
    [xpol_cen,ypol_cen]=centroid_polygons(pol);

    pol_nan=polcell2nan(pol.xy.XY); %right call?
    if do_debug
        save(fpath_mat_tmp,'xpol_cen','ypol_cen','pol_nan')
    end
else
    messageOut(fid_log,'Start loading centroids');
    load(fpath_mat_tmp,'xpol_cen','ypol_cen','pol_nan')
end

%%

han.fig=figure;
set(han.fig,'paperunits','centimeters','paperposition',[0,0,14,14],'visible',0)

hold on
plot(pol_nan(:,1),pol_nan(:,2))
switch type_plot
    case 1 %nan vs. no-nan
        bol_cov=~isnan(etab_cen);
        scatter(xpol_cen(bol_cov),ypol_cen(bol_cov),10,'g','filled')
        scatter(xpol_cen(~bol_cov),ypol_cen(~bol_cov),10,'r','filled')
    case 2 %index number
        np=max(etab_cen);
        cmap=repmat(brewermap(9,'set1'),ceil(np/9),1);

        for kp=1:np
            bol_cov=etab_cen==kp;
            scatter(xpol_cen(bol_cov),ypol_cen(bol_cov),10,cmap(kp,:),'filled');
        end
end
for krkm=1:nrkm
    text(rkm_plot{krkm,1},rkm_plot{krkm,2},strrep(rkm_plot{krkm,3},'_','\_'));
end %krkm

for krkm=1:nrkm
    xlim([rkm_plot{krkm,1}-tol_x,rkm_plot{krkm,1}+tol_x]);
    ylim([rkm_plot{krkm,2}-tol_y,rkm_plot{krkm,2}+tol_y]);

    fpath_fig=fullfile(fdir_fig,sprintf('%s.png',rkm_plot{krkm,3}));
    print(han.fig,fpath_fig,'-dpng','-r300');
    messageOut(NaN,sprintf('Figure printed: %s',fpath_fig)) 
end %krkm

close(han.fig);

end %function