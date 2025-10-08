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
mdu_struct=struct()

mdu_struct.general.program = 'D-Flow FM'; 
mdu_struct.general.version = '';
mdu_struct.general.fileversion = 1.09;
mdu_struct.general.filetype = 'modelDef'; 
mdu_struct.general.autostart = 0;
mdu_struct.geometry.netfile = 'tmp_net.nc';  
mdu_struct.geometry.removesmalllinkstrsh = 0;  %do not remove small flow links. The quality of the grid depends on you.
mdu_struct.geometry.cosphiutrsh = 1; %do not remove small flow links. The quality of the grid depends on you.
mdu_struct.time.refdate = '20000101';
mdu_struct.time.tunit = 'S';
mdu_struct.time.tstart = 0;
mdu_struct.time.tstop = 1;
mdu_struct.time.dtinit = 1;
mdu_struct.time.dtuser = 1;
mdu_struct.time.dtmax = 1;

addOptional(parin,'fdir_work',fullfile(pwd,'tmp_grd2map'));
addOptional(parin,'fpath_exe','c:\Program Files\Deltares\Delft3D FM Suite 2024.03 HM\plugins\DeltaShell.Dimr\kernels\x64\bin\run_dimr.bat');
addOptional(parin,'fpath_map',fullfile(pwd,sprintf('%s_map.nc',fname_grd)));
addOptional(parin,'fdir_work_erase',true);
addOptional(parin,'mdu_struct',mdu_struct);

parse(parin,varargin{:});

fdir_work=parin.Results.fdir_work;
fpath_exe=parin.Results.fpath_exe;
fpath_map=parin.Results.fpath_map;
fdir_work_erase=parin.Results.fdir_work_erase;

if isfield(parin.Results, 'mdu_struct'); 
    chapters = fieldnames(parin.Results.mdu_struct); 
    for c = 1:length(chapters); 
        chapter = chapters{c}; 
        keywords = fieldnames(parin.Results.mdu_struct.(chapter));
        for k = 1:length(keywords);
            keyword=keywords{k};
            mdu_struct.(lower(chapter)).(lower(keyword)) = parin.Results.mdu_struct.(chapter).(keyword);
        end
    end
end 


%% CALC

%create work directoy
mkdir_check(fdir_work);

%copy grid to working directory
fpath_grd_copy=fullfile(fdir_work,'tmp_net.nc');
copyfile_check(fpath_grd,fpath_grd_copy,1);

chapters = fieldnames(mdu_struct); 
for c = 1:length(chapters); 
    chapter = chapters{c}; 
    keywords = fieldnames(mdu_struct.(chapter));
    for k = 1:length(keywords);
        keyword=keywords{k};
        keyword_value=mdu_struct.(chapter).(keyword);
        if ischar(keyword_value); 
            if exist(keyword_value) == 2; 
                tmp_file=fullfile(fdir_work, filenameext(keyword_value)); 
                copyfile_check(keyword_value,tmp_file,1);
                mdu_struct.(chapter).(keyword)=filenameext(keyword_value);  % rename file
            end
        end
    end
end 

%create mdu file
fpath_mdu=fullfile(fdir_work,'tmp.mdu');
mdufile(fpath_mdu,mdu_struct);

%create xml file
fpath_xml=fullfile(fdir_work,'dimr_config.xml');
D3D_dimr_config(fpath_xml,'tmp.mdu',1)
% xmlfile(fpath_xml);

%execute
D3D_run_dimr(fdir_work,'fpath_exe',fpath_exe);

%copy map
fpath_map_loc=fullfile(fdir_work,'DFM_OUTPUT_tmp','tmp_map.nc');
copyfile_check(fpath_map_loc,fpath_map,1);

%erase mdu
if fdir_work_erase
    if strcmp(fdir_work,pwd)==0
        erase_directory(fdir_work);
    end
end

end %function

%%
%% FUNCTIONS
%%

function mdufile(fpath_mdu,mdu_struct)

fid=fopen(fpath_mdu,'w');

chapters = fieldnames(mdu_struct); 
for c = 1:length(chapters); 
    chapter = chapters{c}; 
    keywords = fieldnames(mdu_struct.(chapter));
    fprintf(fid,'[%s]\r\n', chapter);
    for k = 1:length(keywords);
        keyword=keywords{k};
        mdu_struct.(chapter).(keyword);
        if ischar(mdu_struct.(chapter).(keyword))
            fprintf(fid,'%-33s = %-20s \r\n', keyword, mdu_struct.(chapter).(keyword));
        elseif isinteger(mdu_struct.(chapter).(keyword))
            fprintf(fid,'%-33s = %i \r\n', keyword, mdu_struct.(chapter).(keyword));
        elseif isreal(mdu_struct.(chapter).(keyword))
            fprintf(fid,'%-33s = %f \r\n', keyword, mdu_struct.(chapter).(keyword));
        end
    end
end

fclose(fid);

end %mdufile

%%

% function xmlfile(fpath_xml)
% 
% fid=fopen(fpath_xml,'w');
% 
% fprintf(fid,'<?xml version="1.0" encoding="iso-8859-1"?>                                                                                                                                                                                        \r\n');
% fprintf(fid,'<dimrConfig xmlns="http://schemas.deltares.nl/dimrConfig" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.deltares.nl/dimrConfig http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">\r\n');
% fprintf(fid,'    <documentation>                                                                                                                                                                                                                \r\n');
% fprintf(fid,'        <fileVersion>1.00</fileVersion>                                                                                                                                                                                            \r\n');
% fprintf(fid,'        <createdBy>Deltares, Sobek3 To D-Flow FM converter, version 1.17</createdBy>                                                                                                                                               \r\n');
% fprintf(fid,'        <creationDate>2019-12-03 15:33</creationDate>                                                                                                                                                                              \r\n');
% fprintf(fid,'    </documentation>                                                                                                                                                                                                               \r\n');
% fprintf(fid,'    <control>                                                                                                                                                                                                                      \r\n');
% fprintf(fid,'        <start name="myNameDFlowFM"/>                                                                                                                                                                                              \r\n');
% fprintf(fid,'    </control>                                                                                                                                                                                                                     \r\n');
% fprintf(fid,'    <component name="myNameDFlowFM">                                                                                                                                                                                               \r\n');
% fprintf(fid,'        <library>dflowfm</library>                                                                                                                                                                                                 \r\n');
% fprintf(fid,'        <workingDir>.</workingDir>                                                                                                                                                                                                 \r\n');
% fprintf(fid,'        <inputFile>tmp.mdu</inputFile>                                                                                                                                                                                          \r\n');
% fprintf(fid,'    </component>                                                                                                                                                                                                                   \r\n');
% fprintf(fid,'</dimrConfig>                                                                                                                                                                                                                      \r\n');
% 
% fclose(fid);
% 
% end %xmlfile