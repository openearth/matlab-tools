%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Write command to copy folder in linux

function copy_folder_linux(fpath_o,fpath_d,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'top_folder',true);

parse(parin,varargin{:});

top_folder=parin.Results.top_folder;

%% CALC

str_folder='';
if ~top_folder
    str_folder='*';
end

%add last filesep if not there
if ~strcmp(fpath_o(end),filesep)
    fpath_o=strcat(fpath_o,filesep);
end

sprintf('cp -r %s%s %s',linuxify(fpath_o),str_folder,linuxify(fpath_d))

end %function
