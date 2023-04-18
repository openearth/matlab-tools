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
%reads files from a reference folder
%
%INPUT:
%   -
%
%OUTPUT:
%   -

function [path_file,mdf,runid]=D3D_read_sim_folder(path_ref)
dire_ref=dir(path_ref);
nf=numel(dire_ref);

path_file={};
kfs=1;
runid='';

if numel(nf)==0
    error('There are no files here: %s',path_ref)
end

for kf=1:nf
    if ~dire_ref(kf).isdir
        [~,~,ext]=fileparts(dire_ref(kf).name);
        if any(strcmp(ext,{'.dat','.def'}))
            
        else
            path_file{kfs,1}=fullfile(dire_ref(kf).folder,dire_ref(kf).name);
            path_file{kfs,2}=dire_ref(kf).name;
            switch ext
                case {'.mdf','.mdu'}
                    [~,runid]=fileparts(path_file{kfs,1});
                    mdf=D3D_io_input('read',path_file{kfs,1});
            end
            kfs=kfs+1;
        end
    end
end
