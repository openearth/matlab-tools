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
%
%E.G.:
% copy_folder_linux('p:\studenten-riv\03_Work\220615_Yeditha','p:\studenten-riv-2024\03_Work\220615_Yeditha','exclude',{'*_map.nc','*_his.nc','*_rst.nc','*.dat','*.svn-base','*.svn'})

function copy_folder_linux(fpath_o,fpath_d,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'top_folder',true);
addOptional(parin,'exclude',cell(1,1));

parse(parin,varargin{:});

top_folder=parin.Results.top_folder;
exclude=parin.Results.exclude;

%% CALC

str_folder='';
if ~top_folder
    str_folder='*';
end

%add last filesep if not there
if ~strcmp(fpath_o(end),filesep)
    fpath_o=strcat(fpath_o,filesep);
end

if isempty(exclude{1,1})
    str=sprintf('cp -r %s%s %s',linuxify(fpath_o),str_folder,linuxify(fpath_d));
else
    ne=numel(exclude);
    str_exclude='';
    for ke=1:ne
        str_exclude=cat(2,str_exclude,sprintf('--exclude=''%s'' ',exclude{ke}));
    end
    str=sprintf('rsync -av %s %s%s %s',str_exclude,linuxify(fpath_o),str_folder,linuxify(fpath_d));
end

disp(str)

clipboard("copy",str);

end %function
