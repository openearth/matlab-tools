%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18082 $
%$Date: 2022-05-27 16:38:11 +0200 (Fri, 27 May 2022) $
%$Author: chavarri $
%$Id: gdm_load_time_simdef.m 18082 2022-05-27 14:38:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_time_simdef.m $
%

function copy_files_in_folder(fpath_dir,fpath_in)

%fprintf('I am here: %s \n',pwd)
inc=readcell(fpath_in,'delimiter',';');

nf=size(inc,1);
for kf=1:nf
    [~,fname,fext]=fileparts(inc{kf,1});
    fpath_dest=fullfile(fpath_dir,sprintf('%s%s',fname,fext));
    copyfile_check(inc{kf,1 },fpath_dest);
end

end %function