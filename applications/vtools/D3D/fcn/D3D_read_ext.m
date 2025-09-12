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

function stru_out=D3D_read_ext(fpath)

warning('use `D3D_io_input`')

[fdir,fname,fext]=fileparts(fpath);
fpath_mod=fullfile(fdir,sprintf('%s_mod%s',fname,fext));
copyfile_check(fpath,fpath_mod);

fid_r=fopen(fpath,'r');
fid_w=fopen(fpath_mod,'w');

while ~feof(fid_r)
    lin=fgets(fid_r);
    if contains(lower(lin),lower('quantity')) %this is very poor. If a filename has `quantity` in the name, it will break. 
        fprintf(fid_w,'[a] \r\n');
    end
    fprintf(fid_w,lin);
end

fclose(fid_r);
fclose(fid_w);

stru_out=delft3d_io_sed(fpath_mod); %there are repeated blocks, so we cannot use dflowfm_io_mdu

delete(fpath_mod);

end %function
