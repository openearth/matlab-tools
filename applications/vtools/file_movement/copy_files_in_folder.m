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