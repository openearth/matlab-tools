function tutorials2html(varargin)
%TUTORIALS2HTML  publishes all tutorials to html (including overview page).
%
%   This function finds all tutorials inside a toolbox and publishes the files to html. 
%   It also creates an overview page. It fills a template (tutorial_summary.html.tpl by default) and
%   publishes the results in an outputdir that can be specified. Default is the outputdir of the
%   tutorials in you local copy of OpenEarth.
%
%   Syntax:
%   tutorials2html(varargin)
%
%   Input:
%   varargin  =
%       TODO
%
%   Example
%   tutorials2html;
%
%   See also publish

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Lock workspace of this function
% Needed in case of clear all statements in tutorials...
% This prevents this workspace to be cleared whenever a clear all statement
% is given.
mlock;

%% process input
% maindir
maindir = openearthtoolsroot;
id = find(strcmpi(varargin,'maindir'));
if ~isempty(id)
    maindir = varargin{id+1};
end

% templatename
publishtemplate = which('mxdom2tutorialhtmllocal.xsl');
id = find(strcmpi(varargin,'publishtemplate'));
if ~isempty(id)
    publishtemplate = varargin{id+1};
end

summarytemplate = which('tutorial_summary.html.tpl');
id = find(strcmpi(varargin,'summarytemplate'));
if ~isempty(id)
    summarytemplate = varargin{id+1};
end

outputdir = fullfile(openearthtoolsroot,'tutorials');
id = find(strcmpi(varargin,'outputdir'));
if ~isempty(id)
    outputdir = varargin{id+1};
end

scriptdir = fullfile(fileparts(summarytemplate),'html','script');

summaryonly = false;
id = strcmpi(varargin,'nopublish');
if any(id)
    summaryonly = true;
end

show = false;
if any(strcmpi(varargin,'show'))
    show = true;
end

quiet = false;
if any(strcmpi(varargin,'quiet'))
    quiet = true;
end

%% Gather all tutorial m-files
% all directories
alldirs = sort(strread(genpath(maindir),'%s',-1,'delimiter',';'));
alldirs(~cellfun(@isempty,strfind(alldirs,'.svn')))=[];

% loop dirs and find "_tutorial"
tutorials = cell(size(alldirs,1),1);
for idr = 1:length(alldirs)
    fls = dir(fullfile(alldirs{idr},'*_tutorial*.m'));
    tutorials{idr} = {fls.name}';
end

% remove dirs from list that did not have a tutorial
id = ~cellfun(@isempty,tutorials);
alldirs(~id)=[];
tutorials(~id)=[];

[alldirsstripped sid] = sort(strrep(alldirs,openearthtoolsroot,''));
dirnamesseparated = cellfun(@strread,...
    alldirsstripped,...
    repmat({'%s'},size(alldirs)),...
    repmat({-1},size(alldirs)),...
    repmat({'delimiter'},size(alldirs)),...
    repmat({[filesep filesep]},size(alldirs)),...
    'UniformOutput',false);

%% publish tutorials (if not already published)
% target dirs
outputhtmldir = fullfile(outputdir,'html');

% create outputdir
if ~isdir(outputdir)
    mkdir(outputdir);
    mkdir(outputhtmldir);
end

% loop tutorials
cdtemp   = cd;
htmlref  = cell(size(alldirs));
title    = cell(size(alldirs));

%% publish options
vs = version;
if str2num(vs(1:3)) >= 7.4 %#ok<ST2NM>
    % This option is not available in previous versions. We use it to prevent matlab
    % from running the mfile in the base workspace. Versions prior to 7.4 will leave
    % all variables created by a tutorial in the base workspace.
    % publishopts
    publishopts = struct(...
        'maxOutputLines',15,...
        'format','html',...
        'stylesheet',publishtemplate,...
        'outputDir',outputhtmldir,...
        'catchError',true,...
        'useNewFigure',true);
else
    publishopts = struct(...
        'format','html',...
        'stylesheet',publishtemplate,...
        'outputDir',outputhtmldir,...
        'stopOnError',true,...
        'useNewFigure',true);
    if ~quiet
        disp('You are using a matlab version prior to 7.4. This version does not allow');
        disp('codeToEvaluate as an option for the publish function.');
        disp('  ');
        disp('As a consequence we could not prevent the publish function to leave all');
        disp('variables created during publishing in the base workspace. Be aware of this');
        disp('shortcoming of matlab.');
        disp(' ');
        disp('Furthermore error information will not be included in the published html file.');
    end
end

openfigs = findobj('Type','figure');
for idr = 1:length(alldirs)
    htmlref{idr} = cell(size(tutorials{idr}));
    for itutorials = 1:length(tutorials{idr})
        %% look for html files with the same name
        [dum tutorialname] = fileparts(tutorials{idr}{itutorials});
        htmlfilesthere = which([tutorialname '.html'],'-all');
        if strcmp(tutorialname(1),'_')
            htmlfilesthere = which([tutorialname(2:end) '.html'],'-all');
        end
        id = strncmp(htmlfilesthere,outputhtmldir,length(outputhtmldir));
        if summaryonly
            htmlref{idr}{itutorials} = htmlfilesthere{find(id,1,'first')};
            
            %% read first line
            fid = fopen(which(tutorialname));
            first_line = fgetl(fid);
            fclose(fid)
            title{idr}{itutorials} = first_line(3:end);
        else
            if all(id)
                %% publish file, it is not published yet
                
                %% Create tempdir
                tmpdir = tempname;
                mkdir(tmpdir);
                
                %% rename the file if the filename starts with _
                if strcmp(tutorialname(1),'_')
                    tutorialname = tutorialname(2:end);
                end
                copyfile(which(tutorials{idr}{itutorials}),fullfile(tmpdir,[tutorialname,'.m']));
                
                %% read first line to acquire name
                cd(tmpdir);
                fid = fopen(which(tutorialname));
                first_line = fgetl(fid);
                fclose(fid);
                title{idr}{itutorials} = first_line(4:end);
                
                %% publish options
                vs = version;
                if str2num(vs(1:3)) >= 7.4 %#ok<ST2NM>
                    % This option is not available in previous versions. We use it to prevent matlab
                    % from running the mfile in the base workspace. Versions prior to 7.4 will leave
                    % all variables created by a tutorial in the base workspace.
                    % publishopts
                    publishopts.codeToEvaluate = ['evalinemptyworkspace(''' tutorialname ';'');'];
                end

                %% save reference and publish
                htmlref{idr}{itutorials} = publish(tutorialname,publishopts);
                
                %% remove tempdir
                cd(cdtemp);
                rmdir(tmpdir,'s');
                
                %% show progress
                if ~quiet
                    disp([ 'finished publishing <a href="matlab:winopen(''' htmlref{idr}{itutorials} ''');">' title{idr}{itutorials} '</a>']);
                end
                newfigs = findobj('type','figure');
                close(newfigs(~ismember(newfigs,openfigs)));
            else
                %% copy html to outputhtmldir
                copyfile(htmlfilesthere{find(~id,1,'first')},fullfile(outputhtmldir,[tutorialname,'.html']));
                imagesindir = cat(1,...
                    dir(fullfile(fileparts(htmlfilesthere{find(~id,1,'first')}),'*.png')),...
                    dir(fullfile(fileparts(htmlfilesthere{find(~id,1,'first')}),'*.gif')),...
                    dir(fullfile(fileparts(htmlfilesthere{find(~id,1,'first')}),'*.bmp')),...
                    dir(fullfile(fileparts(htmlfilesthere{find(~id,1,'first')}),'*.tiff')));
                for iim = 1:length(imagesindir)
                    copyfile(fullfile(fileparts(htmlfilesthere{find(~id,1,'first')}),imagesindir(iim).name),...
                        fullfile(outputhtmldir,imagesindir(iim).name));
                end
                %% save reference
                htmlref{idr}{itutorials} = fullfile(outputhtmldir,[tutorialname,'.html']);
            end
        end
    end
end
cd(cdtemp);

%% Copy script files to html dir 
tmpdir = tempname;
copyfile(scriptdir,tmpdir,'f');
drs = strread(genpath(tmpdir),'%s',-1,'delimiter',';');
id = find(~cellfun(@isempty,strfind(drs,'.svn')));
for idr = 1:length(id)
    if isdir(drs{id(idr)})
        rmdir(drs{id(idr)},'s');
    end
end
copyfile(tmpdir,fullfile(outputhtmldir,'script'),'f');
rmdir(tmpdir,'s');

%% load template
fid = fopen(summarytemplate,'r');
str = fread(fid,'*char')';
fclose(fid);

%% Identify General and Application loops
returnid = strfind(str,char(10));

generalstr = str(min(returnid(returnid > strfind(str,'##BEGINGEN'))):...
    max(returnid(returnid < strfind(str,'##ENDGEN'))));

applicationstr = str(min(returnid(returnid > strfind(str,'##BEGINAPP'))):...
    max(returnid(returnid < strfind(str,'##ENDAPP'))));

%% identify general tutorials and application tutorials (m-files)
htmlref = htmlref(sid);
tutorials = tutorials(sid);

id = strncmp(alldirsstripped,'applications',length('applications'));
idgeneral = find(~id);
idapplications = find(id);

%% Fill template with general items
% strings for each file / folder
rtns = strfind(generalstr,char(10));
filestr = generalstr(min(rtns(rtns > min(strfind(generalstr,'##BEGINFILE')))):...
    max(rtns(rtns < min(strfind(generalstr,'##ENDFILE')))));
folderstr = generalstr(min(rtns(rtns > min(strfind(generalstr,'##BEGINFOLDER')))):...
    max(rtns(rtns < min(strfind(generalstr,'##ENDFOLDER')))));
rtns2 = strfind(folderstr,char(10));
fileinfolderstr = folderstr(min(rtns2(rtns2 > min(strfind(folderstr,'##BEGINFILE')))):...
    max(rtns2(rtns2 < min(strfind(folderstr,'##ENDFILE')))));

% loop strings and concatenate
genstr = [];
for idr = 1:length(idgeneral)
    dirid = idgeneral(idr);
    dirnames = strread(alldirsstripped{dirid},'%s',-1,'delimiter',[filesep filesep]);
    if length(dirnames) == 1
        filesstr = [];
        [tempnames sid] = sort(title{dirid});
        temphtml = htmlref{dirid}(sid); 
        for ifiles = 1:length(tutorials{dirid})
            [dum name] = fileparts(temphtml{ifiles});
            filesstr = cat(2,filesstr,...
                strrep(strrep(filestr,'#HTMLREF',['html/',name,'.html']),'#FILENAME',tempnames{ifiles}));
        end
        genstr = cat(2,genstr,filesstr);
    else
        newfstr = strrep(folderstr,'#FOLDERNAME',dirnames{end});
        newfilestr = [];
        [tempnames sid] = sort(title{dirid});
        temphtml = htmlref{dirid}(sid); 
        for ifiles = 1:length(tutorials{dirid})
            [dum name] = fileparts(temphtml{ifiles});
            newfilestr = cat(2,newfilestr,...
                strrep(strrep(fileinfolderstr,'#HTMLREF',['html/',name,'.html']),'#FILENAME',tempnames{ifiles}));
        end
        newfstr = strrep(newfstr,fileinfolderstr,newfilestr);
        genstr = cat(2,genstr,newfstr);
    end
end

% replace general template string in template
str = strrep(str,generalstr,genstr);

%% Fill applications
% identify folder and file template strings
rtns = strfind(applicationstr,char(10));
folderstr = applicationstr(min(rtns(rtns > min(strfind(applicationstr,'##BEGINFOLDER')))):...
    max(rtns(rtns < min(strfind(applicationstr,'##ENDFOLDER')))));
rtns2 = strfind(folderstr,char(10));
fileinfolderstr = folderstr(min(rtns2(rtns2 > min(strfind(folderstr,'##BEGINFILE')))):...
    max(rtns2(rtns2 < min(strfind(folderstr,'##ENDFILE')))));

nodenames = cell(size(dirnamesseparated));
for idr = 1:length(nodenames)
    if ismember(idr,idapplications)
        nodenames{idr} = dirnamesseparated{idr}{2};
    end
end
appnodes = nodenames(idapplications);
[dum dirorder] = sort(lower(appnodes));
appnodes = appnodes(dirorder);
apphtmlref = htmlref(idapplications);
apphtmlref = apphtmlref(dirorder);
apptitle = title(idapplications);
apptitle = apptitle(dirorder);

newappstr = [];
for idr = 1:length(appnodes)
    % fill application node
    newfstr = strrep(folderstr,'#FOLDERNAME',appnodes{idr});
    newfilestr = [];
    [temptitles sid] = sort(apptitle{idr});
    temphtmlref = apphtmlref{idr}(sid);
    for ifiles = 1:length(tutorials{dirid})
        [dum name] = fileparts(temphtmlref{ifiles});
        newfilestr = cat(2,newfilestr,...
            strrep(strrep(fileinfolderstr,'#HTMLREF',['html/',name,'.html']),'#FILENAME',temptitles{ifiles}));
    end
    newfstr = strrep(newfstr,fileinfolderstr,newfilestr);
    newappstr = cat(2,newappstr,newfstr);
end

% replace application template string with the one we made above
str = strrep(str,applicationstr,newappstr);

%% write output file
fid = fopen(fullfile(outputdir,'tutorial_summary.html'),'w');
fprintf(fid,'%s',str);
fclose(fid);

%% show result

if ~quiet
    disp(char(10));
    disp([ 'finished publishing. Click <a href="matlab:winopen(''' fullfile(outputdir,'tutorial_summary.html') ''');">here</a> for result']);
end

if show
    winopen(fullfile(outputdir,'tutorial_summary.html'));
end

%% unlock this file
munlock