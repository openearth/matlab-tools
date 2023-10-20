%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18607 $
%$Date: 2022-12-08 08:02:01 +0100 (do, 08 dec 2022) $
%$Author: chavarri $
%$Id: gdm_parse_ylims.m 18607 2022-12-08 07:02:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_parse_ylims.m $
%
%

function stru_out=D3D_read_ext(fpath)

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
