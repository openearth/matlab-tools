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