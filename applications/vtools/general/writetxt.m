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
function writetxt(file_name,data,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% CALC

%check if the file already exists
if check_existing && exist(file_name,'file')>0
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
for kl=1:numel(data)
%     fprintf(fileID_out,'%s \n',data{kl,1});
    fprintf(fileID_out,'%s\r\n',data{kl,1});
end

messageOut(NaN,sprintf('file written %s',file_name));
fclose(fileID_out);
