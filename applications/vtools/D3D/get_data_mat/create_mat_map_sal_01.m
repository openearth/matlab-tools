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

function create_mat_map_sal_01(fid_log,in_plot_loc,simdef)

if ~in_plot_loc.do
    messageOut(fid_log,'Not doing ''fig_map_sal_01''')
    return
end
messageOut(fid_log,'Start ''fig_map_sal_01''')

fpath_mat=simdef.file.mat.map_sal_01;

if exist(fpath_mat,'file')==2
    messageOut(fid_log,'Mat-file already exist.')
    return
end
messageOut(fid_log,'Mat-file does not exist. Reading.')

%load grid for number of layers
load(simdef.file.mat.grd,'gridInfo')
fpath_map=simdef.file.map;

time_dnum=get_time_dnum(fpath_map,in_plot_loc.tim);
save(simdef.file.mat.map_sal_01_tim,'time_dnum');

if isnan(in_plot_loc.layer)
    layer=gridInfo.no_layers;
else
    layer=in_plot_loc.layer;
end

% nt=numel(time_dnum);
nt=numel(time_dnum)-1; %if the simulation does not finish the last one may not be in all partitions. 
np=size(gridInfo.face_nodes_x,2);
data_map_sal_01=NaN(nt,np);
for kt=1:nt
    %TO DO: save temporary files and join at the end 
    data_map=EHY_getMapModelData(fpath_map,'varName','sal','t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'layer',layer,'disp',0);
    data_map_sal_01(kt,:)=data_map.val;
    messageOut(fid_log,sprintf('Reading map_sal_01 %4.2f %%',kt/nt*100));
end
save_check(fpath_mat,'data_map_sal_01');

end %function