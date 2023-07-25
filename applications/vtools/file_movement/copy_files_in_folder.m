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
%Copy files specified in a file to a certain folder. 
%
%INPUT:
%	-fpath_dir = directory to place the figures [char]. If empty, use current location.
%	-fpath_in = full path to the file specifying the files to copy [char]
%		-column 1: copy (1) or do not copy (0) file. 
%		-column 2: full path to the figure to copy 
%		-column 3: relative file location in folder `fpath_dir`.
%
%		E.G. 
% 		1 ; p:\11208033-002-maas-mor-2d\04_models\40m_v2\lixhe_keizersveer\r006\figures\grid_01\01\rkm\grid_01_r006_rkm_grid_xlim_01.png ; ./01_grid
%
%
%OUTPUT:
%

function copy_files_in_folder(fpath_dir,fpath_in)

%% PARSE

if isempty(fpath_dir)
	fpath_dir=pwd;
end
	
%% CALC

%fprintf('I am here: %s \n',pwd)
inc=readcell(fpath_in,'delimiter',';');

nf=size(inc,1);
for kf=1:nf
    if inc{kf,1}==0; continue; end
%     if isfile(inc{kf,2})
        [~,fname,fext]=fileparts(inc{kf,2});
        if isempty(fname) %is file
            fpath_dest=fullfile(fpath_dir,inc{kf,3},sprintf('%s%s',fname,fext));
        else %is dir
            fpath_dest=fullfile(fpath_dir,inc{kf,3});
        end
        if ~(exist(fullfile(fpath_dir,inc{kf,3}))==7)
            mkdir(fullfile(fpath_dir,inc{kf,3}));
        end
        copyfile_check(inc{kf,2},fpath_dest);
%     elseif isdir(inc{kf,2})
%         copyfile_check(inc{kf,2},)
%     else
%         error('Not a file and not a dir: %s',inc{kf,2})
%     end
end

end %function