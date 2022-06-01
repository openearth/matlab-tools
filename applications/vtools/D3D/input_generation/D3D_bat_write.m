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

function D3D_bat_write(dire_sim,fpath_software,dimr_str,structure)

fid_bat=fopen(fullfile(dire_sim,'run.bat'),'w');
fprintf(fid_bat,'@ echo off \r\n');
switch structure
    case 1 %D3D4
        strsoft=sprintf('call %s\\x64\\dflow2d3d\\scripts\\run_dflow2d3d.bat %s',fpath_software,dimr_str);
    case 2 %FM
        strsoft=sprintf('call %s\\x64\\dimr\\scripts\\run_dimr.bat %s',fpath_software,dimr_str);
end
fprintf(fid_bat,'%s \r\n',strsoft); 
fprintf(fid_bat,'exit \r\n');
fclose(fid_bat);

%% sh

fid_bat=fopen(fullfile(dire_sim,'run.sh'),'w');
switch structure
    case 1 %D3D4
        strsoft_win=sprintf('%s\\lnx64\\bin\\submit_dflow2d3d.sh',fpath_software);
        strsoft=sprintf('%s -q normal-e3-c7 -m %s',linuxify(strsoft_win),dimr_str);
    case 2 %FM
        strsoft_win=sprintf('%s\\lnx64\\bin\\submit_dimr.sh',fpath_software);
        strsoft=sprintf('%s -m %s -d 9 -q normal-e3-c7',linuxify(strsoft_win),dimr_str);
end
fprintf(fid_bat,'%s \r\n',strsoft); 
fclose(fid_bat);

%     copyfile_check(fpath_bat_win{simdef.D3D.structure},dire_sim);
%     copyfile_check(fpath_bat_lin,dire_sim);

end %function