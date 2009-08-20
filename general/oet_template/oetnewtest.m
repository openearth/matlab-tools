function oetnewtest(varargin)
%OETNEWTEST    Create a new test file given the file or function name
%
%   Routine to create a new test including Credits and svn keywords.
%   Company, address, email and author are obtained using from the
%   application data with getlocalsettings.
%
%   Syntax:
%       oetnewtest('filename');
%       oetnewtest('functionname');
%       oetnewfun(..., 'PropertyName', PropertyValue,...)
%
%   Input:
%       'filename'    -   name of the test file (this should end with
%                         "_test.m" otherwise it is treated as a function
%                         name.
%       'functionname'-   Name of the function for which this file should
%                         provide a test.
%
%   PropertyNames:
%       'h1line'      -   One line description
%       'description' -   Detailed description of the test
%       'testname'    -   An alternate name for the test
%       'testcases'   -   Cell array of strings with names of the testcases
%                         you want to create.
%
%   Example:
%       oetnewtest('oetnewtest_test',...
%               'testcases', {'Case 1','Case 2','Case 3'});
%       oetnewtest
%
%   See also: oetnewfun, getlocalsettings, load_template

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
% Created: 12 Aug 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% defaults
OPT = getlocalsettings;

OPT.h1line      = 'One line description goes here';
OPT.description = 'More detailed description of the test goes here.';
OPT.publishdescription = '% Publishable code that describes the test.';
OPT.testname    = 'Name of the test goes here';
OPT.seeAlso     = '';
OPT.testcode    = '';
OPT.testpublishresult = ''; % To be used

OPT.testcases   = {'New testcase (change this name)'};
OPT.casedescription = '% A description of the testcase goes here.';
OPT.runcode     = ['% Write test script here' char(10) 'testresult = false;'];
OPT.publishcode  = '% Put code here to publish the results.';

OPT.code        = '';

FunctionName = 'Untitled_test';

%% treat input
i0 = 2;
if nargin > 1 && any(strcmp(fieldnames(OPT), varargin{1}))
    i0 = 1;
elseif nargin > 0
    FunctionName = varargin{1};
end
id = strfind(FunctionName,'_test');
if isempty(id)
    FunctionName = cat(2,FunctionName,'_test');
end

OPT = setProperty(OPT, varargin{i0:end});

if ischar(OPT.ADDRESS)
    OPT.ADDRESS = {OPT.ADDRESS};
end

%% Check existance of the file
if ~isempty(which(cat(2,FunctionName,'.m')))
    try
        %% Create mtest object
        t = mtest(FunctionName);
        
        %% Copy test variables to OPT
        tvars = {'testname','descriptioncode','h1line','description','seealso','runcode','publishcode'};
        optvars = {'testname','publishdescription','h1line','description','seeAlso','testcode','testpublishresult'};
        for ivar = 1:length(tvars)
            if ~isempty(t.(tvars{ivar}))
                OPT.(optvars{ivar}) = t.(tvars{ivar});
            end
        end
        OPT.publishdescription(~strncmp(OPT.publishdescription,'%',1))=[];
        if strcmp(OPT.publishdescription{1}(1),'%')
            OPT.publishdescription{1} = strtrim(OPT.publishdescription{1}(2:end));
        end
        
        %% Copy testcase vars to OPT
        optvars = {'testcases','casedescription','runcode','publishcode'};
        tvars = {'casename','description','runcode','publishcode'};
        OPT.casedescription = repmat({OPT.casedescription},1,length(t.testcases));
        OPT.runcode = repmat({OPT.runcode},1,length(t.testcases));
        OPT.publishcode = repmat({OPT.publishcode},1,length(t.testcases));
        for itc = 1:length(t.testcases)
            for ivar = 1:length(tvars)
                if ~isempty(t.testcases(itc).(tvars{ivar}))
                    OPT.(optvars{ivar}){itc} = t.testcases(itc).(tvars{ivar});
                end
            end
        end
        if isempty(t.testcases)
            OPT.testcases = [];
        end
        %% No code left
        OPT.code = [];
    catch me %#ok<NASGU>
        fid = fopen(cat(2,FunctionName,'.m'));
        OPT.code = cat(2,char(10),char(10),'%% Original code of ', FunctionName, '.m', char(10), fread(fid,'*char')');
        fclose(fid);
    end
end

%% read contents of template file
fid = fopen(which('oettesttemplate.m'));
str = fread(fid, '*char')';
fclose(fid);

%% replace keywords in template string
str = strrep(str, '$testname', OPT.testname);
publishdescription = OPT.publishdescription;
if iscell(publishdescription)
    publishdescription = sprintf('%s\n',publishdescription{:});
    publishdescription(end)=[];
end
if iscell(OPT.description)
    OPT.description = sprintf('%s\n',OPT.description{:});
    OPT.description(end)=[];
end
str = strrep(str, '$publishdescription', publishdescription);
if iscell(OPT.seeAlso)
    OPT.seeAlso = sprintf('%s ',OPT.seeAlso{:});
end
str = strrep(str, '$seeAlso', OPT.seeAlso);
[fpath fname] = fileparts(fullfile(cd, FunctionName));
str = strrep(str, '$filename', fname);
str = strrep(str, '$FILENAME', upper(fname));
str = strrep(str, '$description', OPT.description);
str = strrep(str, '$date(dd mmm yyyy)', datestr(now, 'dd mmm yyyy'));
str = strrep(str, '$date(yyyy)', datestr(now, 'yyyy'));
str = strrep(str, '$Company', OPT.COMPANY);
str = strrep(str, '$author', OPT.NAME);
str = strrep(str, '$email', OPT.EMAIL);
address = sprintf('%%       %s\n', OPT.ADDRESS{:});
address = address(1:end-1);
str = strrep(str, '%       $address', address);
str = strrep(str, '$version', version);
str = strrep(str, '$h1line', OPT.h1line);
if iscell(OPT.testpublishresult)
    OPT.testpublishresult = sprintf('%s\n',OPT.testpublishresult{:});
    OPT.testpublishresult(end)=[];
end 
str = strrep(str,'$publishresult',OPT.testpublishresult);

%% Check testcase names
if ~isempty(OPT.testcases) && ischar(OPT.testcases)
    OPT.testcases = {OPT.testcases};
end

%% Check if the testcase contents were filled
if ischar(OPT.casedescription)
    OPT.casedescription = repmat({OPT.casedescription},1,length(OPT.testcases));
end
if ischar(OPT.runcode)
    OPT.runcode = repmat({OPT.runcode},1,length(OPT.testcases));
end
if ischar(OPT.publishcode)
    OPT.publishcode = repmat({OPT.publishcode},1,length(OPT.testcases));
end

%% Identify begin and end of the testcasestrings
tcbegin = strfind(str,'%$begintestcases');
tcend = strfind(str,'%$endtestcases');

if ~isempty(OPT.testcases)
    %% build testcase string
    tcstring = buildtestcasestring(str(tcbegin+17:tcend-1),OPT);
    
    %% replace in str
    str = cat(2,str(1:strfind(str,'%$begintestcases')-1),tcstring);
    
    %% build test code
    if isempty(OPT.testcode)
        OPT.testcode = [];
        for itc = 1:length(OPT.testcases)
            OPT.testcode = cat(2,OPT.testcode,'testresult(', num2str(itc), ') = ', strrep(OPT.testcases{itc},' ','_'), ';', char(10));
        end
        OPT.testcode = cat(2,OPT.testcode,char(10),'testresult = all(testresult);');
    end
else
    str = str(1:strfind(str,'%$begintestcases')-1);
end
if iscell(OPT.testcode)
    OPT.testcode = sprintf('%s\n',OPT.testcode{:});
    OPT.testcode(end)=[];
end
str = strrep(str,'$testcode',OPT.testcode);

%% Append any other code
% If the file was not according to the correct format and mtest couldn't read it, the complete
% string is pasted behind the normal content.
if ~isempty(OPT.code)
    str = cat(2, str, OPT.code);
end

%% open new file in editor
com.mathworks.mlservices.MLEditorServices.newDocument(str)

end
function tcstr = buildtestcasestring(strtpl,OPT)
%% Build testcase string
tcstr = [];
for icase = 1:length(OPT.testcases)
    tempstr = strtpl;
    tempstr = strrep(tempstr,'$CaseNumber',num2str(icase));
    tempstr = strrep(tempstr,'$FunctionCaseName',strrep(OPT.testcases{icase},' ','_'));
    tempstr = strrep(tempstr,'$CaseName',OPT.testcases{icase});
    if iscell(OPT.casedescription{icase})
        OPT.casedescription{icase} = sprintf('%s\n',OPT.casedescription{icase}{:});
    end
    tempstr = strrep(tempstr,'$casedescription',OPT.casedescription{icase});
    if iscell(OPT.runcode{icase})
        OPT.runcode{icase} = sprintf('%s\n',OPT.runcode{icase}{:});
    end
    tempstr = strrep(tempstr,'$runcode',OPT.runcode{icase});
    if iscell(OPT.publishcode{icase})
        OPT.publishcode{icase} = sprintf('%s\n',OPT.publishcode{icase}{:});
    end
    tempstr = strrep(tempstr,'$resultscode',OPT.publishcode{icase});
    tcstr = cat(2,tcstr,tempstr);
end
end
