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
%creates a map file from a grid file

function D3D_grd2map(fpath_grd,varargin)

%% PARSE

[~,fname_grd]=fileparts(fpath_grd);

parin=inputParser;

addOptional(parin,'fdir_work',fullfile(pwd,'tmp_grd2map'));
addOptional(parin,'fpath_exe','c:\Program Files\Deltares\Delft3D FM Suite 2024.03 HM\plugins\DeltaShell.Dimr\kernels\x64\bin\run_dimr.bat');
addOptional(parin,'fpath_map',fullfile(pwd,sprintf('%s_map.nc',fname_grd)));

parse(parin,varargin{:});

fdir_work=parin.Results.fdir_work;
fpath_exe=parin.Results.fpath_exe;
fpath_map=parin.Results.fpath_map;

%% CALC

%create work directoy
mkdir_check(fdir_work);

%copy grid to working directory
fpath_grd_copy=fullfile(fdir_work,'tmp_net.nc');
copyfile_check(fpath_grd,fpath_grd_copy,1);

%create mdu file
fpath_mdu=fullfile(fdir_work,'tmp.mdu');
mdufile(fpath_mdu);

%create xml file
fpath_xml=fullfile(fdir_work,'dimr_config.xml');
xmlfile(fpath_xml);

%execute
fdir_now=pwd;
cd(fdir_work)
if ~exist(fpath_exe,'file')
    error('There is no <run_dimr.bat> here: %s',fpath_exe)
end
% [status]=system(sprintf('call "%s" "%s"',fpath_exe,fpath_xml));
[status]=system(sprintf('call "%s"',fpath_exe)); %for some reason the execute does not work when the path has a space, although it did before. If default name is <dimr_config> is used, there is no ptoblem. 
cd(fdir_now);
if status~=0
    error('something went wrong when executing')
end

%copy map
fpath_map_loc=fullfile(fdir_work,'DFM_OUTPUT_tmp','tmp_map.nc');
copyfile_check(fpath_map_loc,fpath_map,1);

%erase mdu
if strcmp(fdir_work,fdir_now)==0
    erase_directory(fdir_work);
end

end %function

%%
%% FUNCTIONS
%%

function mdufile(fpath_mdu)

fid=fopen(fpath_mdu,'w');

fprintf(fid,'[General]                                                  \r\n');
fprintf(fid,'Program                           = D-Flow FM              \r\n');
fprintf(fid,'Version                           =                        \r\n');
fprintf(fid,'fileVersion                       = 1.09                   \r\n');
fprintf(fid,'fileType                          = modelDef               \r\n');
fprintf(fid,'AutoStart                         = 0                      \r\n');
fprintf(fid,'                                                           \r\n');
fprintf(fid,'[geometry]                                                 \r\n');
fprintf(fid,'NetFile                           = tmp_net.nc             \r\n');  
fprintf(fid,'Removesmalllinkstrsh              = 0                      \r\n');  %do not remove small flow links. The quality of the grid depends on you.
fprintf(fid,'                                                           \r\n');
fprintf(fid,'[time]                                                     \r\n');
fprintf(fid,'RefDate                           = 20000101               \r\n');
fprintf(fid,'Tunit                             = S                      \r\n');
fprintf(fid,'TStart                            = 0                      \r\n');
fprintf(fid,'TStop                             = 1                      \r\n');
fprintf(fid,'DtInit                            = 1                      \r\n');
fprintf(fid,'DtUser                            = 1                      \r\n');

fclose(fid);

end %mdufile

%%

function xmlfile(fpath_xml)

fid=fopen(fpath_xml,'w');

fprintf(fid,'<?xml version="1.0" encoding="iso-8859-1"?>                                                                                                                                                                                        \r\n');
fprintf(fid,'<dimrConfig xmlns="http://schemas.deltares.nl/dimrConfig" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.deltares.nl/dimrConfig http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">\r\n');
fprintf(fid,'    <documentation>                                                                                                                                                                                                                \r\n');
fprintf(fid,'        <fileVersion>1.00</fileVersion>                                                                                                                                                                                            \r\n');
fprintf(fid,'        <createdBy>Deltares, Sobek3 To D-Flow FM converter, version 1.17</createdBy>                                                                                                                                               \r\n');
fprintf(fid,'        <creationDate>2019-12-03 15:33</creationDate>                                                                                                                                                                              \r\n');
fprintf(fid,'    </documentation>                                                                                                                                                                                                               \r\n');
fprintf(fid,'    <control>                                                                                                                                                                                                                      \r\n');
fprintf(fid,'        <start name="myNameDFlowFM"/>                                                                                                                                                                                              \r\n');
fprintf(fid,'    </control>                                                                                                                                                                                                                     \r\n');
fprintf(fid,'    <component name="myNameDFlowFM">                                                                                                                                                                                               \r\n');
fprintf(fid,'        <library>dflowfm</library>                                                                                                                                                                                                 \r\n');
fprintf(fid,'        <workingDir>.</workingDir>                                                                                                                                                                                                 \r\n');
fprintf(fid,'        <inputFile>tmp.mdu</inputFile>                                                                                                                                                                                          \r\n');
fprintf(fid,'    </component>                                                                                                                                                                                                                   \r\n');
fprintf(fid,'</dimrConfig>                                                                                                                                                                                                                      \r\n');

fclose(fid);

end %xmlfile