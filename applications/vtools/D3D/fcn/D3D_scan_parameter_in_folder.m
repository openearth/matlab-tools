%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19511 $
%$Date: 2024-04-02 12:11:51 +0200 (Tue, 02 Apr 2024) $
%$Author: chavarri $
%$Id: D3D_gdm.m 19511 2024-04-02 10:11:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Scans for a parameter in a folder with simulations in it. 

function D3D_scan_parameter_in_folder(fpath_dir,param)

dire=dir(fpath_dir);
nd=numel(dire);
for kd=1:nd
    if any(strcmp(dire(kd).name,{'.','..'}))
        continue
    end
    fpath_dir_loc=fullfile(dire(kd).folder,dire(kd).name);
    fpath_mdf=check_if_simulation(fpath_dir_loc);
    if ~isempty(fpath_mdf)
        D3D_scan_parameter_in_mdf(fpath_mdf,param);
    end
end %kd

end %function

%%
%% FUNCTIONS
%%

function fpath_mdf=check_if_simulation(fpath_dir)

fpath_mdf='';
dire=dir(fpath_dir);
nd=numel(dire);
for kd=1:nd
    if strcmp(dire(kd).name,{'.','..'})
        continue
    end
    [~,~,ext]=fileparts(dire(kd).name);
    if any(strcmp(ext,{'.mdf','.mdu'}))
        fpath_mdf=fullfile(fpath_dir,dire(kd).name);
    end
end %kd

end %function