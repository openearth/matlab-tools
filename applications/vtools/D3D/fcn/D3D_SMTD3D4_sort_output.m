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

function tim_dir=D3D_SMTD3D4_sort_output(fdir_output)

%sort output folders
dire_out=dir(fdir_output);
nf=numel(dire_out);
tim_dir=[];
for kf=1:nf
    if ~dire_out(kf).isdir; continue; end
    if strcmp(dire_out(kf).name,'.') || strcmp(dire_out(kf).name,'..'); continue; end
    tim_dir=cat(1,tim_dir,str2double(strrep(dire_out(kf).name,'.min','')));
end
tim_dir=sort(tim_dir);

end