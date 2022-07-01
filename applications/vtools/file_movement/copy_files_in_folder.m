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
%

function copy_files_in_folder(fpath_dir,fpath_in)

%fprintf('I am here: %s \n',pwd)
inc=readcell(fpath_in,'delimiter',';');

nf=size(inc,1);
for kf=1:nf
    if inc{kf,1}==0; continue; end
    [~,fname,fext]=fileparts(inc{kf,2});
    fpath_dest=fullfile(fpath_dir,inc{kf,3},sprintf('%s%s',fname,fext));
    if ~(exist(fullfile(fpath_dir,inc{kf,3}))==7)
        mkdir(fullfile(fpath_dir,inc{kf,3}));
    end
    copyfile_check(inc{kf,2},fpath_dest);
end

end %function