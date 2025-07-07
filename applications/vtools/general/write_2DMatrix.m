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

function write_2DMatrix(file_name,matrix,varargin)

%% SIZE

nx=size(matrix,2);
ny=size(matrix,1);

%% PARSE
parin=inputParser;

num_str_def=repmat('%0.15E*delim*',1,nx);
addOptional(parin,'num_str',NaN);
addOptional(parin,'check_existing',1) %Old. Keep for backward compatibility.
addOptional(parin,'overwrite',NaN)
addOptional(parin,'delimiter',' ')
addOptional(parin,'add_header',0)

parse(parin,varargin{:});

num_str=parin.Results.num_str;
check_existing=parin.Results.check_existing;
delimiter=parin.Results.delimiter;
add_header=parin.Results.add_header;
overwrite=parin.Results.overwrite;

if isnan(num_str)
    num_str=num_str_def;
    num_str(end-6:end)=''; %remove last delimiter
    num_str=strrep(num_str,'*delim*',delimiter); %add new
end
% if isspace(num_str(end))==0
%     num_str=[num_str,' '];
% end

if ~isnan(overwrite)
    check_existing=~overwrite;
end

%% CALC

    %check if the file already exists
if exist(file_name,'file') && check_existing
    error('You are trying to overwrite a file!')
end

%first write local
fname_dest=file_name;
file_name=fullfile(pwd,now_chr);

messageOut(NaN,sprintf('Start writing file: %s',file_name))
if add_header
    fileID_out=fopen_add_header(file_name,'w');
else
    fileID_out=fopen(file_name,'w');
end
write_str_x=strcat(num_str,'\n'); %string to write in x

for ky=1:ny
    fprintf(fileID_out,write_str_x,matrix(ky,:));
end

fclose(fileID_out);
messageOut(NaN,sprintf('Finished writing file: %s',file_name))

%copy to destination
copyfile_check(file_name,fname_dest);
delete(file_name);

end %function
