%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_bc_lateral.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_bc_lateral.m $
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
for kf=1:nf
    if ~dire_ref(kf).isdir
        path_file{kfs,1}=fullfile(dire_ref(kf).folder,dire_ref(kf).name);
        path_file{kfs,2}=dire_ref(kf).name;
        [~,~,ext]=fileparts(path_file{kfs,1});
        switch ext
            case {'.mdf','.mdu'}
                [~,runid]=fileparts(path_file{kfs,1});
                mdf=D3D_io_input('read',path_file{kfs,1});
        end
        kfs=kfs+1;
    end
end
