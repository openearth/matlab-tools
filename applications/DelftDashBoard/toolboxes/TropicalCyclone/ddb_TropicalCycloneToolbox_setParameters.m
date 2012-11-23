function ddb_TropicalCycloneToolbox_setParameters(varargin)
%DDB_TROPICALCYCLONETOOLBOX_SETPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TropicalCycloneToolbox_setParameters(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TropicalCycloneToolbox_setParameters
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotTropicalCyclone('activate');
    handles=getHandles;
    % setUIElements('tropicalcyclonepanel.parameters');
    if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
        ddb_giveWarning('text','The Tropical Cyclone Toolbox currently only works for geographic coordinate systems!');
    end
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'computecyclone'}
            computeCyclone;
        case{'drawtrack'}
            drawTrack;
        case{'edittracktable'}
            editTrackTable;
        case{'loaddata'}
            loadDataFile;
        case{'savedata'}
            saveDataFile;
        case{'importtrack'}
            importTrack;
        case{'selectquadrantoption'}
            selectQuadrantOption;
        case{'selectbasinoption'}
            selectBasinOption;
        case{'downloadtrack'}
            downloadTrackData;
    end
end

%%
function drawTrack
handles=getHandles;

xmldir=handles.Toolbox(tb).xmlDir;
xmlfile='TropicalCyclone.initialtrackparameters.xml';

h=handles.Toolbox(tb).Input;
[h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

if ok
    
    handles.Toolbox(tb).Input=h;
    
    setInstructions({'','Click on map to draw cyclone track','Use right-click to end cyclone track'});
    
    handles=deleteCycloneTrack(handles);
    
    ddb_zoomOff;
    
    gui_polyline('draw','Tag','cyclonetrack','Marker','o','createcallback',@ddb_changeCycloneTrack,'changecallback',@ddb_changeCycloneTrack, ...
        'rightclickcallback',@ddb_selectCyclonePoint,'closed',0);
    
    setHandles(handles);
    
end

%%
function selectQuadrantOption

handles=getHandles;

if strcmpi(handles.Toolbox(tb).Input.quadrantOption,'uniform')
    handles.Toolbox(tb).Input.quadrant=1;
end

handles=ddb_setTrackTableValues(handles);

setHandles(handles);

%%
function selectQuadrant

handles=getHandles;
handles=ddb_setTrackTableValues(handles);
setHandles(handles);

function selectBasinOption

%  Retrieve the current handles data structure.
handles = getHandles;

%  Retrieve the handles of the TC radio buttons.
hall = findobj(gcf,'Tag','radioallbasins');   % All
hnear = findobj(gcf,'Tag','radionearbasin');  % Nearest

%  Check which basin option was selected.
if (handles.Toolbox(tb).Input.whichTCBasinOption == 1)
    %  All basins -- unset Nearest 
    set(hnear, 'Value', 0);
else
    %  Nearest basin -- unset All
    set(hall, 'Value', 0);
end

%  Check whether the TC basins are to be displayed.
if (handles.Toolbox(tb).Input.showTCBasins == 1)
    %  One or more basins will be displayed, so load polygon data.
    handles = ddb_selectTropicalCycloneBasins(handles);
else
    %  One or more basins will be turned off, so "turn off" the polygon data.
    handles = ddb_selectTropicalCycloneBasins(handles);
end

%  Update the TC widgets within the GUI.

%  Store the current handles data structure.
setHandles(handles);

function loadDataFile

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.cyc', 'Select Cyclone File','');

if filename==0
    return
end;

filename=[pathname filename];

handles.Toolbox(tb).Input.cycloneFile=[pathname filename];
handles=ddb_readCycloneFile(handles,filename);

handles.Toolbox(tb).Input.quadrant=1;

handles=ddb_setTrackTableValues(handles);

handles=deleteCycloneTrack(handles);

setHandles(handles);

ddb_plotCycloneTrack;

%%
function saveDataFile

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.cyc', 'Select Cyclone File','');
if filename==0
    return
end
filename=[pathname filename];
handles.Toolbox(tb).Input.cycloneFile=filename;
setHandles(handles);
ddb_saveCycloneFile(handles,filename);

%%
function downloadTrackData

handles=getHandles;

switch lower(handles.Toolbox(tb).Input.downloadLocation)
    case{'unisysbesttracks'}
        web http://weather.unisys.com/hurricane -browser
    case{'jtwcbesttracks'}
        web http://www.usno.navy.mil/NOOC/nmfc-ph/RSS/jtwc/best_tracks/ -browser
    case{'jtwccurrentcyclones'}
        web http://www.usno.navy.mil/JTWC/ -browser
    case{'jtwccurrenttracks', 'nhccurrenttracks'}
        %  JTWC current TC warning file(s) or NHC current forecast/advisory
        %  file(s):
        
        %  Check whether the user wants to check certain basins.
        %  First, check whether the user has chosen to display basin
        %  polygons.
        if (isempty(handles.Toolbox(tb).Input.TCBasinName))
            %  The user has not chosen to display basins, so prompt for
            %  whether to select one or more basins.
            [indx,isok] = listdlg('PromptString',char('Select one or more TC basin(s)', 'to check for warnings:'),...
                'ListSize',[160,70],'Name','TC Basins','ListString',handles.Toolbox(tb).Input.knownTCBasinName);
            
            %  Check the user's response.
            if (isok ~= 0)
                %  The user responded with a selection, so update the
                %  pertinent parameters.
                handles.Toolbox(tb).Input.TCBasinName = handles.Toolbox(tb).Input.knownTCBasinName(indx);
                handles.Toolbox(tb).Input.TCBasinNameAbbrev = handles.Toolbox(tb).Input.knownTCBasinNameAbbrev(indx);
            end
        end
        
        %  Now, build the '--region' option to the download scripts.
        region_option = get_basin_option(handles.Toolbox(tb).Input.TCBasinNameAbbrev);
        
        %  Prompt for a storm name if so desired.
        iflag = 1;
        m_t = '';  % Empty string
        storm_name = get_user_storm_name(iflag, handles.Toolbox(tb).Input.TCStormName,m_t,m_t);
        
        %  Store the storm name if one was entered.
        if (~isempty(storm_name))
            handles.Toolbox(tb).Input.TCStormName = storm_name;
            %  Build a Perl script command to download the file by name
            cmd = [which('check_tc_files.pl') ' --name ' storm_name ...
                ' ' region_option ' --data_dir ' handles.tropicalCycloneDir];
        else
            %  Build a Perl script command to download all available files
            cmd = [which('check_tc_files.pl') ' ' region_option ' --data_dir ' handles.tropicalCycloneDir];
        end
        
        %  Invoke the download command using a system() call.
        [status,result] = system(cmd);
        
        %  Check the status of the command.
        if (status == 0)
            %  The command was successful, so continue.
            %  Determine the name of the track file(s) based on data type (i.e., TC center).
            if (strcmp(handles.Toolbox(tb).Input.downloadLocation, 'jtwccurrenttracks'))
                %  JTWC
                [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = ...
                regexp(result,'web\.txt was moved to ([A-Z]{3,4})\/(wp[0-9]{4}web_[0-9]{12}\.txt*)');
                %  Define the file format conversion script name.
                sname = 'parse_jtwc_warning.pl';  % Script name
                prog = which(sname);              % Full path name of script
            else
                %  NHC
                [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = ...
                regexp(result,'[acew][tp][0-9]\.txt was moved to ([A-Z]{3,4})\/(wt[a-z]{2}[0-9]{2}\.[a-z]{4}\.tcm\.[ace][tp][0-9]_[0-9]{12}\.txt*)')
                %  Define the file format conversion script name.
                sname = 'read_fcst_advisory.pl';  % Script name
                prog = which(sname);              % Full path name of script
            end
                
            %  Check whether the file format conversion script was located.
            if (isempty(prog))
                %  Script was not found, so issue a warning message and
                %  return to calling routine.
                ddb_giveWarning('text',['ERROR: Cannot find the TC file conversion script ' sname '.']);
                return;
            end
            
            %  Determine the number of track files.
            nf = size(tokenStr,2);
            
            %  Loop over track files to reformat.
            for k = 1:nf
                %  Define the present file name from the output of the download script.
                txtfile = [handles.tropicalCycloneDir filesep char(tokenStr{k}{1}) filesep char(tokenStr{k}{2})];
                trkfile = strrep(txtfile, '.txt', '.trk');
                
                %  Invoke another Perl script to convert to .trk format.
                %  First, create the command string using the correct
                %  script and current file names.
                cmd = [prog ' ' txtfile ' wes.inp ' trkfile ' ' int2str(handles.Toolbox(tb).Input.nrRadialBins) ...
                    ' ' int2str(handles.Toolbox(tb).Input.nrDirectionalBins) ' ' ...
                    int2str(handles.Toolbox(tb).Input.radius)];
                
                %  Execute the command with a system() call.
                [status2,result] = system(cmd);

                %  Check the status of this last command.
                if (status2 == 0)
                    %  The command was successful, so continue.
                    %  Store the present track file name.
                    handles.Toolbox(tb).Input.TCTrackFile{k} = trkfile;
                    
                else
                    disp([' WARNING: Unable to convert the format of the TC file:' 10 txtfile 10 ...
                    '; the command was:' 10 cmd 10]);
                end
            end  % for k...
        else
            %  The download command was unsuccessful, so issue a warning
            %  message.
            ddb_giveWarning('text', ['ERROR: The TC warning file download command failed: ' result]);
        end  % if (status....
%end  % switch lower(handles....

end

%%
function importTrack

handles=getHandles;

iflag=0;

switch lower(handles.Toolbox(tb).Input.importFormat)
    case{'unisysbesttrack'}
        ext='dat';
        prefix = '';
    case{'jtwccurrenttrack', 'nhccurrenttrack'}
        %  This assumes that JTWC or NHC current track(s) have been 'JTWCCurrentTrack','NHCCurrentTrack'
        %  converted from their native format; cf. subfunc. downloadTrackData.
        ext = 'trk';
        prefix = handles.tropicalCycloneDir;
        %  Prompt for a storm name if so desired.
        iflag = 2;
        %storm_name = get_user_storm_name(iflag, handles.Toolbox(tb).Input.TCTrackFileStormName);
        storm_name = get_user_storm_name(iflag, handles.Toolbox(tb).Input.TCTrackFileStormName,...
            lower(handles.Toolbox(tb).Input.importFormat),handles.tropicalCycloneDir);
        iflag = 0;
        filename = 0;
            
        %  Set the basin(s) to check based on which data set was
        %  selected.
        if (strcmp(lower(handles.Toolbox(tb).Input.importFormat), 'jtwccurrenttrack'))
            %  JTWC -- currently, this data set is from the Western
            %  Pacific.
            region = '--region sh,wp';
            %  Define the file format conversion script name.
            sname = 'parse_jtwc_warning.pl';  % Script name
            cprog = which(sname);             % Full path name of script
            prefix = [prefix 'JTWC' filesep];
        elseif (strcmp(lower(handles.Toolbox(tb).Input.importFormat), 'nhccurrenttrack'))
            %  NHC -- Atlantic, Central Pacific, Eastern Pac.
            %  Define the file format conversion script name.
            sname = 'read_fcst_advisory.pl';  % Script name
            cprog = which(sname);              % Full path name of script
            region = '--region at,cp,ep';
            prefix = [prefix 'NHC' filesep];
        end
        
        %  Store the storm name if one was entered, and get a list of files for storms of that name.
        if (~isempty(storm_name))
            handles.Toolbox(tb).Input.TCStormName = storm_name;
            handles.Toolbox(tb).Input.TCTrackFileStormName = storm_name;
            
            %  Here, run something such as find_tc_files_byname.pl
            sname1 = 'find_tc_files_byname.pl';
            prog = which(sname1);
                
            %  Check whether the file find & format conversion scripts were located.
            if (isempty(prog))
                ddb_giveWarning('text',['ERROR: Cannot find the TC storm name script ' sname1 '.']);
                return;
            end
            if (isempty(cprog))
                ddb_giveWarning('text',['ERROR: Cannot find the TC format conversion script ' sname '.']);
                return;
            end
            
            %  Create the name finding command.
            cmd = [prog ' ' storm_name ' --data_dir '  handles.tropicalCycloneDir ' ' region];
            %  Execute the command using a system() call.
            [status,result] = system(cmd);
            %  Evaluate the results.
            if (~isempty(regexp(result, 'ERROR', 'match')))
                %  No files for the given storm name were found; issue a
                %  message and continue to browse for files.
                giveWarning('text',['No files were found for the storm ' upper(storm_name) '.'])
            else
                %  At least one file was found, so continue processing the
                %  file name search results.
                %  Split the standard output into separate lines.
                lines = regexp(result, '\n', 'split');
                nl = size(lines,2);  %  Number of lines
                fname = {};
                j = 0;
                %  Loop over lines in the program output...
                for ii = 1:nl
                    %  Find a string that ends in ".txt".
                    m = regexp(lines{ii}, '.*_[0-9]{12}\.txt', 'match');
                    %  If such a string has been found, then it corresponds
                    %  to a file name; process this file name.
                    if (~isempty(m))
                          %  Check whether the .trk file corresponding to this
                        %  .txt file exists.
                        if (exist(strrep(char(m),'.txt','.trk'),'file'))
                            j = j + 1;
                            fname(j) = strrep(m,'.txt','.trk');
                        else
                            %  The .trk file corresponding to this .txt
                            %  file has not been created; do so now.
                            %  Invoke another Perl script to convert to .trk format.
                            %  First, create the command string using the correct
                            %  script and current file names.
                            cmd2 = [cprog ' ' char(m) ' wes.inp ' strrep(char(m),'.txt','.trk') ' '...
                                int2str(handles.Toolbox(tb).Input.nrRadialBins) ...
                            ' ' int2str(handles.Toolbox(tb).Input.nrDirectionalBins) ' '...
                            int2str(handles.Toolbox(tb).Input.radius)];
                        
                            %  Execute the command with a system() call.
                            disp([' NOTE: Performing a format conversion on the TC warning file ' char(m)]);
                            [status2,result2] = system(cmd2);
                        
                            %  Check the status of this last command.
                            if (status2 == 0)
                                %  The command was successful, so continue.
                                %  Store the present track file name.
                                j = j + 1;
                                fname(j) = strrep(m,'.txt','.trk');
                            else
                                disp([' WARNING: Unable to convert the format of the TC file:' 10 char(m) 10 ...
                                'the command was:' 10 cmd2 10]);
                            end
                        end
                    end
                end
                %  Check whether any track files were found for the
                %  selected storm name.
                if (~isempty(fname))
                    %  Track files were found, so prompt the user to select
                    %  one to import.
                    [indx,isok] = listdlg('PromptString',['Select a file for the storm ' upper(storm_name) ':'],...
                        'Name','TC File','ListString',fname,'listsize',[400,200],'selectionmode','single');
                    if (~isempty(indx) && isok == 1)
                        %  The user made a selection, so break the full
                        %  path name into path and file name.
                        iflag = size(fname,2);
                        [pathname,filename,extn] = fileparts(fname{indx});
                        pathname = [pathname filesep];  % Append the file separator character.
                        filename = [filename extn];     % Append the file extension.
                        handles.Toolbox(tb).Input.TCTrackFile = fname{indx};  % Store the file name.
                        %  Update the data structure & the text box
                        setHandles(handles);
                        % setUIElement('tropicalcyclonepanel.parameters.selectedtrackfile');
                    end
                else
                    %  No files for the given storm name were found; issue a
                    %  message and continue to browse for files.
                    giveWarning('text',['No existing track (.trk) files were found by the storm name program for the storm ' upper(storm_name) '.'])
                end
            end
        end
        
    otherwise
        ext='*';
        prefix = '';
end

%  Browse for a file if one hadn't been selected.

if (iflag == 0)
    [filename, pathname, filterindex] = uigetfile([prefix '*.' ext], 'Select Data File','');
end
if filename==0
    return
else
    %  Store the file name.
    handles.Toolbox(tb).Input.TCTrackFile = fullfile(pathname, filename);
    %  Update the data structure.
    setHandles(handles);
    %  Update the text box.
	% setUIElement('tropicalcyclonepanel.parameters.selectedtrackfile');
end

%  Format type flag.
itype = 0;  % Default = 0; set to 1 for JTWC or NHC current tracks.

%  Default background pressure (millibars); cf. NAVO SP-68, Table 29, p.
%  402, or Pond & Pickard (1981), Introductory Dynamic Oceanography (2nd ed.),
%  Appendix 2, p. 229.
BG_Pres = 1013.25;
bg_press_Pa = BG_Pres * 100;  % Same, in Pa
try
    
    switch lower(handles.Toolbox(tb).Input.importFormat)
        case{'jtwcbesttrack'}
            tc=readBestTrackJTWC([pathname filename]);
            handles.Toolbox(tb).Input.method=2;
            handles.Toolbox(tb).Input.quadrantOption='perquadrant';
        case{'unisysbesttrack'}
            tc=readBestTrackUnisys([pathname filename]);
            handles.Toolbox(tb).Input.method=4;
            handles.Toolbox(tb).Input.quadrantOption='uniform';
        case{'jtwccurrenttrack', 'nhccurrenttrack'}
            %  JTWC, NHC current tracks in generic .trk format:
            tc=ddb_readGenericTrackFile([pathname filename]);
            handles.Toolbox(tb).Input.method=tc.method;
            handles.Toolbox(tb).Input.quadrantOption=tc.quadrantOption;
            itype = 1;
        otherwise
            giveWarning('text','Sorry, present import format not supported!');
            return
    end
       
    handles.Toolbox(tb).Input.quadrant=1;
    
    nt=length(tc.time);
    
    % Set dummy values
    handles.Toolbox(tb).Input.trackT=zeros([nt 1]);
    handles.Toolbox(tb).Input.trackX=zeros([nt 1]);
    handles.Toolbox(tb).Input.trackY=zeros([nt 1]);
    handles.Toolbox(tb).Input.trackVMax=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackPDrop=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackRMax=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackR100=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackR65=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackR50=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackR35=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackA=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackB=zeros([nt 4])-999;
    
    k=0;
    for it=1:nt
        
        %        if (tc(it).r34(1))>=0
        
        k=k+1;
        
        handles.Toolbox(tb).Input.trackT(k)=tc.time(it);
        handles.Toolbox(tb).Input.trackX(k)=tc.lon(it);
        handles.Toolbox(tb).Input.trackY(k)=tc.lat(it);
        if isfield(tc,'vmax')
            handles.Toolbox(tb).Input.trackVMax(k,1:4)=tc.vmax(it,:);
        end
        if isfield(tc,'p')
            if (itype == 0)
                %  Modified to use a better value for background atm.
                %  pressure (RSL, 16 Dec 2011)
                %handles.Toolbox(tb).Input.trackPDrop(k,1:4)=[101200 101200 101200 101200] - tc.p(it,:);
                handles.Toolbox(tb).Input.trackPDrop(k,1:4)=[bg_press_Pa bg_press_Pa bg_press_Pa bg_press_Pa] - tc.p(it,:);
            else
                %  JTWC, NHC current warning files: pressure drop is
                %  calculated by the parsing script(s).
                handles.Toolbox(tb).Input.trackPDrop(k,1:4) = tc.p(it,:);
            end
        end
        if isfield(tc,'rmax')
            handles.Toolbox(tb).Input.trackRMax(k,1:4)=tc.rmax(it,:);
        end
        if isfield(tc,'a')
            handles.Toolbox(tb).Input.trackA(k,1:4)=tc.a(it,:);
        end
        if isfield(tc,'b')
            handles.Toolbox(tb).Input.trackB(k,1:4)=tc.b(it,:);
        end
        
        if isfield(tc,'r34')
            handles.Toolbox(tb).Input.trackR35(k,1)=tc.r34(it,1);
            handles.Toolbox(tb).Input.trackR35(k,2)=tc.r34(it,2);
            handles.Toolbox(tb).Input.trackR35(k,3)=tc.r34(it,3);
            handles.Toolbox(tb).Input.trackR35(k,4)=tc.r34(it,4);
        elseif isfield(tc,'r35')
            %  See ddb_readGenericTrackFile.m
            handles.Toolbox(tb).Input.trackR35(k,1)=tc.r35(it,1);
            handles.Toolbox(tb).Input.trackR35(k,2)=tc.r35(it,2);
            handles.Toolbox(tb).Input.trackR35(k,3)=tc.r35(it,3);
            handles.Toolbox(tb).Input.trackR35(k,4)=tc.r35(it,4);
        end
        
        if isfield(tc,'r50')
            handles.Toolbox(tb).Input.trackR50(k,1)=tc.r50(it,1);
            handles.Toolbox(tb).Input.trackR50(k,2)=tc.r50(it,2);
            handles.Toolbox(tb).Input.trackR50(k,3)=tc.r50(it,3);
            handles.Toolbox(tb).Input.trackR50(k,4)=tc.r50(it,4);
        end
        
        if isfield(tc,'r64')
            handles.Toolbox(tb).Input.trackR65(k,1)=tc.r64(it,1);
            handles.Toolbox(tb).Input.trackR65(k,2)=tc.r64(it,2);
            handles.Toolbox(tb).Input.trackR65(k,3)=tc.r64(it,3);
            handles.Toolbox(tb).Input.trackR65(k,4)=tc.r64(it,4);
        elseif isfield(tc, 'r65')
            %  See ddb_readGenericTrackFile.m
            handles.Toolbox(tb).Input.trackR65(k,1)=tc.r65(it,1);
            handles.Toolbox(tb).Input.trackR65(k,2)=tc.r65(it,2);
            handles.Toolbox(tb).Input.trackR65(k,3)=tc.r65(it,3);
            handles.Toolbox(tb).Input.trackR65(k,4)=tc.r65(it,4);
        end
        
        if isfield(tc,'r100')
            handles.Toolbox(tb).Input.trackR100(k,1)=tc.r100(it,1);
            handles.Toolbox(tb).Input.trackR100(k,2)=tc.r100(it,2);
            handles.Toolbox(tb).Input.trackR100(k,3)=tc.r100(it,3);
            handles.Toolbox(tb).Input.trackR100(k,4)=tc.r100(it,4);
        end
        
        %     end
    end
    
    if k>0
        
        handles.Toolbox(tb).Input.nrTrackPoints=k;
        handles.Toolbox(tb).Input.name=tc.name;
        
        handles=ddb_setTrackTableValues(handles);
        
        setHandles(handles);
        
        ddb_plotCycloneTrack;
        
    end
    
catch
    ddb_giveWarning('text','An error occured while reading cyclone data');
end

%%
function computeCyclone

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.spw', 'Select Spiderweb File','');
if filename==0
    return
else
    try
        wb = waitbox('Generating Spiderweb Wind Field ...');%pause(0.1);
        handles=ddb_computeCyclone(handles,filename);
        close(wb);
        setHandles(handles);
    catch
        close(wb);
        giveWarning('text','An error occured while generating spiderweb wind file');
    end
end

%%
function handles=deleteCycloneTrack(handles)
try
    delete(handles.Toolbox(tb).Input.trackhandle);
end
handles.Toolbox(tb).Input.trackhandle=[];

%%
function storm_name = get_user_storm_name(iflag,current_name,region_code,tc_dir)
%*******************************************************************************
%
%  get_user_storm_name
%
%  This Matlab function interactively prompts the user for whether to
%  obtain tropical cyclone (TC) files for all available storms or for a
%  specific storm.  If the user chooses to obtain files for a specific
%  storm, the user is interactively prompted to enter the storm name.  The
%  name (or an empty string) is returned to the calling routine.  This
%  function is used to prompt for either file downloads or browsing local
%  files.  It is (initially, at least) intended for use with the NRL TC
%  scripts for accessing and extracting NHC and JTWC TC bulletins.
%
%  Syntax: storm_name = get_user_storm_name(iflag,current_name,region_code,tc_dir)
%  where:  storm_name is the returned text string,
%          iflag is a flag indicating which type of action: 1 for
%          downloading or 2 for browsing local files,
%          current_name is the current storm name (initially blank),
%          region_code is a string denoting with import option was chosen, and
%          tc_dir is the TC warning file local directory.
%
%  Calls: [No external routines are used.]
%
%  Called by: downloadTrackData (subfunction), importTrack (subfunction)
%
%  Revision History:
%  17 Jan 2012  Initial coding.  R.S. Linzell, QNA/NRL Code 7322
%  18 Jan 2012  Added help content & comments; changed the inner IF block
%               checking for whether the user entered a name, from a nested
%               IF block to a single block.  (RSL)
%  20 Jan 2012  Changed the storm name prompt to indicate case
%               insensitivity, and changed the title of the storm name
%               prompt; added new input parameter, 'current_name', and
%               modified the inputdlg() call to use this new parameter.
%               (RSL)
%  25 Jan 2012  Added code to provide a list of all known storm names from
%               the presently available local warning files, and to prompt
%               the user to chose from that list of known storm names;
%               added 'region_code' and 'tc_dir' to the input parameter
%               list to support the new known name list prompt code;
%               updated the help content.  (RSL)
%
%*******************************************************************************

%  Initialize the output parameter (storm name text string).
storm_name = '';

%  Determine which prompt is to be issued.
if (iflag == 1)
    %  Downloading from the web.
    resp = questdlg('Download all files or those for a specific storm?', 'TC Files to Download', ...
        'All', 'Specific', 'Cancel', 'Specific');
elseif (iflag == 2)
    %  Browse local (already downloaded) files. 
    resp = questdlg('Browse downloaded files or search for a specific storm?', 'TC Files to Import', ...
        'Browse', 'Specific', 'Cancel', 'Specific');
    
    %  Check whether the user wants to specify a storm name.
    if (strcmp(resp, 'Specific'))
        %  This is the case, so attempt to get a list of storm names from
        %  the current local files.
        if (~isempty(region_code) && ~isempty(tc_dir))
            if (strcmp(region_code, 'jtwccurrenttrack'))
                %  JTWC
                %  Build the storm names file name.
                storm_file_name = [tc_dir filesep 'JTWC' filesep 'storm_names_jtwc.txt'];
            elseif (strcmp(region_code, 'nhccurrenttrack'))
                %  NHC
                %  Build the storm names file name.
                storm_file_name = [tc_dir filesep 'NHC' filesep 'storm_names_nhc.txt'];
            end
            
            %  Check whether the storm name file exists.
            if (exist(storm_file_name,'file'))
                %  It does exist, so open & read it.
                fid = fopen(storm_file_name, 'r');
                data = textscan(fid, '%s');  %  Read the text fields
                fclose(fid);
                %  Convert from a cell array to a char array.
                snames = char(data{:});
                %  Check whether the data were present & correctly read.
                if (~isempty(snames))
                    %  They were, so prompt the user to select a name.
                    [indx,isok] = listdlg('liststring',[data{:};{'None of the Above'}],...
                        'SelectionMode','single','promptstring',...
                        char('Select a storm name from the','currently available local files:'),...
                        'name','Storm Name Selection');
                    %  Check whether a valid selection was made.
                    if (isok == 1)
                        %  A selection was made, so check which name was
                        %  selected.  If "None of the Above" was chosen,
                        %  the user will be prompted to enter a name below.
                        if (indx <= length(snames))
                            %  A valid name selection was made.  Store the chosen
                            %  name and return to the caller.
                            storm_name = strtrim(snames(indx,:));
                            return;
                        end
                    else
                        %  The user canceled, so return with the blank name
                        return;
                    end
                end
            end
        end
    end
end

%  Check whether the user wants to specify a storm name.
if (strcmp(resp, 'Specific'))
    %  The user does want to specify a storm name, so prompt for one.
    resp2 = inputdlg('Enter the storm name (upper, lower, or mixed case):', 'Enter Storm Name',1,{current_name});
    %  Check whether the user entered a string.
    if (~isempty(resp2) && ~isempty(char(resp2)))
        %  The user did enter something, so convert from a cell array to a
        %  character array.
        storm_name = char(resp2);
    end
end

return;

function tc_basin_str = get_basin_option(basin_list)
%*******************************************************************************
%
%  get_basin_option
%
%  This Matlab function builds a text string consisting of tropical cyclone (TC)
%  basin abbreviations.  It is (initially, at least) intended for use with
%  the NRL TC scripts for accessing and extracting NHC and JTWC TC bulletins.
%
%  Syntax: tc_basin_str = get_basin_option(basin_list)
%  where:  tc_basin_str is the returned text string, and
%          basin_list is a cell array of TC basin abbreviations.
%
%  Calls: [No external routines are used.]
%
%  Called by: downloadTrackData (subfunction)
%
%  Revision History:
%  18 Jan 2012  Initial coding.  R.S. Linzell, QNA/NRL Code 7322
%
%*******************************************************************************

%  Initialize the output parameter (basin list text string).
tc_basin_str = '';

%  Check whether the basin list is not empty and contains fewer than four
%  elements.  If this is NOT the case, then all basins are to be checked,
%  and the text string would be empty.
if (~isempty(basin_list) && length(basin_list) < 4)
	%  User selected 1 to 3 basins, so build a basin option string.
    tc_basin_str = ['--region ' char(basin_list{1})];  % 1st basin
    %  Loop over the remaining basin abbreviations to build the basin
    %  option string.
	for k = 2:length(basin_list)
        tc_basin_str = [tc_basin_str ',' char(basin_list{k})];
    end
end

return;

