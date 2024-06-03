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
%Write string in a cell array to file.

function writetxt(fname_destiny,data,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% CALC

%check if the file already exists
if check_existing && exist(fname_destiny,'file')>0
    error('You are trying to overwrite a file!')
end

%write in local
fname_local=fullfile(pwd,now_chr);

%write
fileID_out=fopen(fname_local,'w');
fprintf(fileID_out,'%s\r\n',data{:});
fclose(fileID_out);
messageOut(NaN,sprintf('file written %s',fname_local));

%copy
copyfile_check(fname_local,fname_destiny);
delete(fname_local);

end %function
