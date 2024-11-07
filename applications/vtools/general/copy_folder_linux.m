%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19833 $
%$Date: 2024-10-14 10:49:42 +0200 (Mon, 14 Oct 2024) $
%$Author: chavarri $
%$Id: D3D_gdm.m 19833 2024-10-14 08:49:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
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
