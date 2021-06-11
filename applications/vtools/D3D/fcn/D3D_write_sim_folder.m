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
%writes files from a reference folder
%
%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_write_sim_folder(path_sim_out,path_file,mdf)

nfs=size(path_file,1);

for kfs=1:nfs

    path_file_in=path_file{kfs,1};
    path_file_out=fullfile(path_sim_out,path_file{kfs,2});

    [~,~,ext]=fileparts(path_file_in);
    switch ext
        case {'.mdf','.mdu'}
            D3D_io_input('write',path_file_out,mdf);
        otherwise
            copyfile(path_file_in,path_file_out);
    end

end %kfs