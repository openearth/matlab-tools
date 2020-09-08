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
function write_2DMatrix(file_name,matrix,~,~)

nx=size(matrix,2);
ny=size(matrix,1);

    %check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
write_str_x=strcat(repmat('%0.15E ',1,nx),'\n'); %string to write in x

for ky=1:ny
    fprintf(fileID_out,write_str_x,matrix(ky,:));
end

fclose(fileID_out);

end %function
