classdef mtestfunction<handle
    
    properties
        completename
        functionname
        filename
        htmlfilename
        
        type
        
        children
        parents
        functioncode
        startline
        endline
        runnablelines
        canrunlist
        didrunlist
        neverrunlist
        coverage
        
        executedlines
        
        isrecursive
        totalrecursivetime
        numcalls
        totaltime
        html
        
        mlockedflag
        mfileflag
        pfileflag
        filteredfileflag
        badlistingdisplaymode
        moresubfunctionsinfileflag
    end
    properties (Hidden=true)
        ftItem
        targetHash
    end
    
    methods
        function obj = mtestfunction(profileInfo,idx)
            if nargin<1
                return
            end
            if isfield(profileInfo,'FunctionTable')
                obj.ftItem = profileInfo.FunctionTable(idx);
            else
                error('MtestFunction:WrongInput','First input argument needs to be the result of a call to profile(''info'')');
            end
            
            for iobj = 1:length(obj)
                obj.completename = obj.ftItem.CompleteName;
                obj.filename = obj.ftItem.FileName;
                obj.functionname = obj.ftItem.FunctionName;
                obj.filename = obj.ftItem.FileName;
                obj.type = obj.ftItem.Type;
                obj.totaltime = obj.ftItem.TotalTime;
                obj.totalrecursivetime = obj.ftItem.TotalRecursiveTime;
                obj.executedlines = obj.ftItem.ExecutedLines;
                obj.isrecursive = obj.ftItem.IsRecursive;
                obj.numcalls = obj.ftItem.NumCalls;
                obj.children = obj.ftItem.Children;
                obj.parents = obj.ftItem.Parents;
                
                % Build up function name target list from the children table
                obj.targetHash = [];
                for n = 1:length(obj.ftItem.Children)
                    targetName = profileInfo.FunctionTable(obj.ftItem.Children(n).Index).FunctionName;
                    % Don't link to Opaque-functions with dots in the name
                    if ~any(targetName=='.') && ~any(targetName=='@')
                        % Build a hashtable for the target strings
                        % Ensure that targetName is a legal MATLAB identifier.
                        targetName = regexprep(targetName,'^([a-z_A-Z0-9]*[^a-z_A-Z0-9])+','');
                        if ~isempty(targetName) && targetName(1) ~= '_'
                            obj.targetHash.(targetName) = obj.ftItem.Children(n).Index;
                        end
                    end
                end
                
                % M-functions, M-scripts, and M-subfunctions are the only file types we can
                % list. If the file is mlocked, we can't display it.
                obj.mlockedflag = mislocked(obj.ftItem.FileName);
                obj.mfileflag = 1;
                obj.pfileflag = 0;
                obj.filteredfileflag = false;
                if (isempty(regexp(obj.ftItem.Type,'^M-','once')) || ...
                        strcmp(obj.ftItem.Type,'M-anonymous-function') || ...
                        isempty(obj.ftItem.FileName) || ...
                        obj.mlockedflag)
                    obj.mfileflag = 0;
                else
                    % Make sure it's not a P-file
                    if ~isempty(regexp(obj.ftItem.FileName,'\.p$','once'))
                        obj.pfileflag = 1;
                        % Replace ".p" string with ".m" string.
                        fullName = regexprep(obj.ftItem.FileName,'\.p$','.m');
                        % Make sure the M-file corresponding to the P-file exists
                        if ~exist(fullName,'file')
                            obj.mfileflag = 0;
                        end
                    else
                        fullName = obj.ftItem.FileName;
                    end
                end
                
                obj.badlistingdisplaymode = false;
                if obj.mfileflag
                    f = mtestfunction.oetgetmcode(fullName);
                    
                    if isempty(obj.ftItem.ExecutedLines) && obj.ftItem.NumCalls > 0
                        % If the executed lines array is empty but the number of calls
                        % is not 0 then the body of this function must have been filtered
                        % for some reason.  We do not want to display the M-code in this
                        % case.
                        f = [];
                        obj.filteredfileflag = true;
                    elseif length(f) < obj.ftItem.ExecutedLines(end,1)
                        % This is a simple (non-comprehensive) test to see if the file has been
                        % altered since it was profiled. The variable f contains every line of
                        % the file, and ExecutedLines points to those line numbers. If
                        % ExecutedLines points to lines outside that range, something is wrong.
                        obj.badlistingdisplaymode = true;
                    end
                end
                if obj.mfileflag && ~obj.filteredfileflag
                    % Calculate beginning and ending lines for the current function
                    
                    runnableLineIndex = callstats('file_lines',obj.ftItem.FileName);
                    runnableLines = zeros(size(f));
                    runnableLines(runnableLineIndex) = runnableLineIndex;
                    
                    % oetgetmcode and callstats don't necessarily agree on line counting
                    % (particularly when analyzing a p-coded file).  Force consistency
                    % of the array dimensions to prevent error (g462077).
                    if length(runnableLines) > length(f)
                        runnableLines = runnableLines(1:length(f));
                    end
                    
                    % FunctionName takes one of several forms:
                    % 1. foo
                    % 2. foo>bar
                    % 3. foo1\private\foo2
                    % 4. foo1/private/foo2>bar
                    %
                    % We need to strip off everything except for the very last \w+ string
                    
                    fname = regexp(obj.ftItem.FunctionName,'(\w+)$','tokens','once');
                    
                    strc = getcallinfo(fullName,'normal',f);
                    fcnList = {strc.name};
                    fcnIdx = find(strcmp(fcnList,fname)==1);
                    
                    if length(fcnIdx) > 1
                        % In rare situations, two nested functions can have exactly the
                        % same name twice in the same file. In these situations, I will
                        % default to the first occurrence.
                        fcnIdx = fcnIdx(1);
                        warning('MATLAB:profiler:FunctionAppearsMoreThanOnce', ...
                            'Function name %s appears more than once in this file.\nOnly the first occurrence is being displayed.', ...
                            fname{1});
                    end
                    
                    if isempty(fcnIdx)
                        % ANONYMOUS FUNCTIONS
                        % If we can't find the function name on the list of functions
                        % and subfunctions, assume this is an anonymous
                        % function. Just display the entire file in this case.
                        obj.startline = 1;
                        obj.endline = length(f);
                        lineMask = (obj.startline:obj.endline)';
                    else
                        obj.startline = strc(fcnIdx).firstline;
                        obj.endline = strc(fcnIdx).lastline;
                        lineMask = strc(fcnIdx).linemask;
                    end
                    
                    obj.runnablelines = runnableLines .* lineMask;
                    
                    obj.moresubfunctionsinfileflag = 0;
                    if obj.endline < length(f)
                        obj.moresubfunctionsinfileflag = 1;
                    end
                    obj.functioncode = f;
                    
                    linelist = (1:length(f))';
                    obj.canrunlist = find(linelist(obj.startline:obj.endline)==runnableLines(obj.startline:obj.endline)) + obj.startline - 1;
                    obj.didrunlist = obj.ftItem.ExecutedLines(:,1);
                    obj.neverrunlist = find(runnableLines(obj.startline:obj.endline)==0);
                    obj.coverage = nan;
                    if ~isempty(obj.canrunlist)
                        obj.coverage = 100*length(obj.didrunlist)/length(obj.canrunlist);
                    end
                end
            end
        end
        function functionCoverage2html(obj,varargin)
            s = cell(1,1);
            s{1} = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
            s{2} = '<html xmlns="http://www.w3.org/1999/xhtml">';
            s{3} = '<head>';
            s{end+1} = sprintf('<title>Function details for %s</title>', obj.functionname);
            s{end+1} = '<link type="text/css" href="script/css/jquery-ui-1.7.2.custom.css" rel="stylesheet" />';
            s{end+1} = '<link type="text/css" href="script/css/FunctionCoverage.css" rel="stylesheet" />';
            s{end+1} = '<script type="text/javascript" src="script/js/jquery-1.3.2.min.js"></script>';
            s{end+1} = '<script type="text/javascript" src="script/js/jquery-ui-1.7.2.custom.min.js"></script>';
            s{end+1} = '<script type="text/javascript" src="script/js/matlab2accordion.js"></script>';
            s{end+1} = '</head>';
            s{end+1} = '<body>';
            
            %% Summary info
            s{end+1} = ['<div class="ui-widget-header ui-state-active ui-corner-all"><h4>' obj.functionname '</h4></div><br/>'];
            
            if obj.pfileflag && ~obj.mfileflag
                s{end+1} =['<p><span class="warning">', sprintf('This is a P-file for which there is no corresponding M-file'), '</span></p>'];
            end
            
            if obj.mlockedflag
                s{end+1} = sprintf(['<p><span class="warning">This function has been mlocked. Results may be incomplete ' ...
                    'or inaccurate.</span></p>']);
            end
            
            didChange = callstats('has_changed',obj.completename);
            if didChange
                s{end+1} = sprintf(['<p><span class="warning">This function changed during profiling ' ...
                    'or before generation of this report. Results may be incomplete ' ...
                    'or inaccurate.</span></p>']);
            end
            
            hiliteOption = 'coverage';
            
            %
            %% begin coverage section
            %
            
            s{end+1} = '<div class="ui-widget-content ui-corner-all">';
            s{end+1} = ['<strong>', sprintf('Coverage results'), '</strong><br/>'];
            
            if ~obj.mfileflag || obj.filteredfileflag
                s{end+1} = sprintf('No M-code to display');
            else
                
                s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
                s{end+1} = ['<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">', sprintf('Total lines in function'), '</td>'];
                s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', obj.endline-obj.startline+1);
                s{end+1} = ['<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">', sprintf('Non-code lines (comments, blank lines)'), '</td>'];
                s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(obj.neverrunlist));
                s{end+1} = ['<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">', sprintf('Code lines (lines that can run)'), '</td>'];
                s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(obj.canrunlist));
                s{end+1} = ['<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">', sprintf('Code lines that did run'), '</td>'];
                s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(obj.didrunlist));
                s{end+1} = ['<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">', sprintf('Code lines that did not run'), '</td>'];
                s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(setdiff(obj.canrunlist,obj.didrunlist)));
                s{end+1} = ['<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">', sprintf('Coverage (did run/can run)'), '</td>'];
                if isempty(obj.coverage) || isnan(obj.coverage)
                    s{end+1} = sprintf('<td class="td-linebottomrt">N/A</td></tr>');
                else
                    s{end+1} = sprintf('<td class="td-linebottomrt">%4.2f %%</td></tr>', obj.coverage);
                end
                s{end+1} = '</table>';
                
            end
            s{end+1} = '</div><br/>';
            
            % --------------------------------------------------
            % End Coverage section
            % --------------------------------------------------
            
            % --------------------------------------------------
            %% File listing
            % --------------------------------------------------
            % Make a lookup table to speed index identification
            % The executedLines table is as long as the file and stores the index
            % value for every executed line.
            
            % check if the file changed in some major way
            
            if obj.badlistingdisplaymode
                s{end+1} = sprintf('<p><span class="warning">This file was modified during or after profiling.  Function listing disabled.</span></p>');
            end
            
            
            s{end+1} = '<div class="ui-widget-content ui-corner-all" style="overflow:auto;">';
            s{end+1} = sprintf('<strong>Function listing</strong><br/>');
            
            if ~obj.mfileflag || obj.filteredfileflag
                s{end+1} = sprintf('No M-code to display');
            else
                
                executedLines = zeros(length(obj.functioncode),1);
                executedLines(obj.executedlines(:,1)) = 1:size(obj.executedlines,1);
                
                % Enumerate all alphanumeric values for later use in linking code
                alphanumericList = ['a':'z' 'A':'Z' '0':'9' '_'];
                alphanumericArray = zeros(1,128);
                alphanumericArray(alphanumericList) = 1;
                
                ftok = xmtok(obj.functioncode);
                
                [bgColorCode,bgColorTable,textColorCode,textColorTable] = mtestfunction.makeColorTables( ...
                    obj.functioncode,hiliteOption, obj.ftItem, ftok, obj.startline, obj.endline, executedLines, obj.runnablelines,...
                    [], []);
                
                % --------------------------------------------------
                s{end+1} = '<pre>';
                
                % Display column headers across the top
                s{end+1} = ['<span style="color: #FF0000; font-weight: bold; text-decoration: none">  time</span> ',...
                    '<span style="color: #0000FF; font-weight: bold; text-decoration: none">  calls</span> ',...
                    '<span style="font-weight: bold; text-decoration: none">line</span><br/>'];
                
                % Cycle through all the lines
                for n = obj.startline:obj.endline
                    linestr = [];
                    lineIdx = executedLines(n);
                    if lineIdx>0,
                        callsPerLine = obj.executedlines(lineIdx,2);
                        timePerLine = obj.executedlines(lineIdx,3);
                    else
                        timePerLine = 0;
                        callsPerLine = 0;
                    end
                    
                    % Display the mlint message if necessary
                    color = bgColorTable{bgColorCode(n)};
                    textColor = textColorTable{textColorCode(n)};
                    
                    % Modify text so that < and > don't cause problems
                    if n > length(obj.functioncode)    % insurance
                        codeLine = '';    % file must have changed
                    else
                        codeLine = code2html(obj.functioncode{n});
                    end
                    
                    % Display the time
                    if timePerLine > 0.01,
                        linestr = cat(2,linestr,sprintf('<span style="color: #FF0000"> %5.2f </span>', ...
                            timePerLine));
                    elseif timePerLine > 0
                        linestr = cat(2,linestr,'<span style="color: #FF0000">&lt; 0.01 </span>');
                    else
                        linestr = cat(2,linestr,'       ');
                    end
                    
                    % Display the number of calls
                    if callsPerLine > 0,
                        linestr = cat(2,linestr,sprintf('<span style="color: #0000FF">%7d </span>', ...
                            callsPerLine));
                    else
                        linestr = cat(2,linestr,'        ');
                    end
                    
                    % Display the line number
                    if callsPerLine > 0
                        linestr = cat(2,linestr,sprintf('<span style="color: #000000; font-weight: bold"><a>%4d</a></span> ', ...
                            n));
                    else
                        linestr = cat(2,linestr,sprintf('<span style="color: #A0A0A0">%4d</span> ', n));
                    end
                    
                    if callsPerLine > 0
                        % Need to add a space to the end to make sure the last
                        % character is an identifier.
                        codeLine = [codeLine ' '];
                        % Use state machine to substitute in linking code
                        codeLineOut = '';
                        
                        state = 'between';
                        
                        substr = [];
                        for m = 1:length(codeLine),
                            ch = codeLine(m);
                            % Deal with the line with identifiers and Japanese comments .
                            % 128 characters are from 0 to 127 in ASCII
                            if abs(ch)>127
                                alphanumeric = 0;
                            else
                                alphanumeric = alphanumericArray(ch);
                            end
                            
                            switch state
                                case 'identifier'
                                    if alphanumeric,
                                        substr = [substr ch];
                                    else
                                        state = 'between';
                                        if isfield(obj.targetHash,substr)
                                            substr = sprintf('%s', substr);
                                        end
                                        codeLineOut = [codeLineOut substr ch]; %#ok<*AGROW>
                                    end
                                case 'between'
                                    if alphanumeric,
                                        substr = ch;
                                        state = 'identifier';
                                    else
                                        codeLineOut = [codeLineOut ch]; %#ok<AGROW>
                                    end
                                otherwise
                                    
                                    error('MATLAB:profiler:UnexpectedState','Unknown case %s', state);
                                    
                            end
                        end
                        codeLine = codeLineOut;
                    end
                    
                    % Display the line
                    linestr = cat(2,linestr,sprintf('<span style="color: %s; background: %s;">%s</span>', ...
                        textColor, color, codeLine));
                    
                    s{end+1} = linestr;
                end
                
                s{end+1} = '</pre>';
                if obj.moresubfunctionsinfileflag
                    s{end+1} = sprintf('<p><p>Other subfunctions in this file are not included in this listing.');
                end
            end
            s{end+1} = '</div>';
            
            % --------------------------------------------------
            % End file list section
            % --------------------------------------------------
            %% EOF
            s{end+1} = '</body>';
            s{end+1} = '</html>';
            %% prepare output
            obj.html = s';
        end
        function publishCoverage(obj,varargin)
            if isempty(obj.html)
                obj.functionCoverage2html;
            end
            
            if isempty(obj.htmlfilename)
                [pt fn] = fileparts(obj.functionname);
                obj.htmlfilename = fullfile(cd,mtestfunction.constructfilename([fn '_coverage.html']));
            end
            
            fid = fopen(obj.htmlfilename,'w');
            fprintf(fid,'%s\n',obj.html{:});
            fclose(fid);
            
            if any(strcmpi(varargin,'show'))
                winopen(obj.htmlfilename);
            end
        end
    end
    methods (Static=true)
        function textCellArray = oetgetmcode(filename, bufferSize)
            %OETGETMCODE  Returns a cell array of the text in a file
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   varargout = oetgetmcode(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   varargout =
            %
            %   Example
            %   oetgetmcode
            %
            %   See also
            
            %% Copyright notice
            %
            % This is a copy of a private Mathworks function!!! (getmcode)
            %
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
            % Created: 18 Sep 2009
            % Created with Matlab version: 7.8.0.347 (R2009a)
            
            % $Id$
            % $Date$
            % $Author$
            % $Revision$
            % $HeadURL$
            % $Keywords: $
            
            %% Begin
            
            if nargin < 2
                bufferSize = 10000;
            end
            
            fid = fopen(filename,'r');
            if fid < 0
                error('MATLAB:codetools:fileReadError','Unable to read file %s', filename)
            end
            % Now check for bytes with value zero.  For performance reasons,
            % scan a maximum of 10,000 bytes.  Prevent any "interpretation"
            % of data by reading uint8s and keeping them in that form.
            data = fread(fid,10000,'uint8=>uint8');
            isbinary = any(data==0);
            if isbinary
                fclose(fid);
                error('MATLAB:codetools:getmcode',...
                    'File contains binary data: %s',filename);
            end
            % No binary data found.  Reset the file pointer to the beginning of
            % the file and scan the text.
            fseek(fid,0,'bof');
            try
                txt = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',bufferSize);
                fclose(fid);
                textCellArray = txt{1};
            catch exception
                %If the bufferSize is too small, textscan will throw an exception
                %in that case, just increase the buffer size and try again.
                fclose(fid);
                if strcmp(exception.identifier,'MATLAB:textscan:BufferOverflow')
                    textCellArray = getmcode(filename, bufferSize * 100);
                else
                    rethrow(exception)
                end
            end
        end
        function [bgColorCode,bgColorTable,textColorCode,textColorTable] = makeColorTables( ...
                f, hiliteOption, ftItem, ftok, startLine, endLine, executedLines, ...
                runnableLines, mlintstrc, maxNumCalls)
            
            % Take a first pass through the lines to figure out the line color
            bgColorCode = ones(length(f),1);
            textColorCode = ones(length(f),1);
            textColorTable = {'#228B22','#000000','#A0A0A0'};
            
            % Ten shades of green
            memColorTable = { '#FFFFFF' '#00FF00' '#00EE00' '#00DD00' '#00CC00' ...
                '#00BB00' '#00AA00' '#009900' '#008800' '#007700'};
            
            switch hiliteOption
                case 'time'
                    % Ten shades of red
                    bgColorTable = {'#FFFFFF','#FFF0F0','#FFE2E2','#FFD4D4', '#FFC6C6', ...
                        '#FFB8B8','#FFAAAA','#FF9C9C','#FF8E8E','#FF8080'};
                    key_data_field = 1;
                case 'numcalls'
                    % Ten shades of blue
                    bgColorTable = {'#FFFFFF','#F5F5FF','#ECECFF','#E2E2FF', '#D9D9FF', ...
                        '#D0D0FF','#C6C6FF','#BDBDFF','#B4B4FF','#AAAAFF'};
                case 'coverage'
                    bgColorTable = {'#FFFFFF','#E0E0FF'};
                case 'noncoverage'
                    bgColorTable = {'#FFFFFF','#E0E0E0'};
                case 'mlint'
                    bgColorTable = {'#FFFFFF','#FFE0A0'};
                    
                case 'allocated memory'
                    bgColorTable = memColorTable;
                    key_data_field = 2;
                    
                case 'freed memory'
                    bgColorTable = memColorTable;
                    key_data_field = 3;
                    
                case 'peak memory'
                    bgColorTable = memColorTable;
                    key_data_field = 4;
                    
                case 'none'
                    bgColorTable = {'#FFFFFF'};
                otherwise
                    error('MATLAB:profiler:UnknownHiliteOption', 'hiliteOption %s unknown', hiliteOption);
            end
            
            maxData(1) = max(ftItem.ExecutedLines(:,3));
            if mtestfunction.hasMemoryData(ftItem)
                % if len > 3 then we must have memory data available
                maxData(2) = max(ftItem.ExecutedLines(:,4));
                maxData(3) = max(ftItem.ExecutedLines(:,5));
                maxData(4) = max(ftItem.ExecutedLines(:,6));
            end
            
            for n = startLine:endLine
                
                if ftok(n) == 0
                    % Non-code line, comment or empty. Color is green
                    textColorCode(n) = 1;
                elseif ftok(n) < n
                    % This is a continuation line. Make it the same color
                    % as the originating line
                    bgColorCode(n) = bgColorCode(ftok(n));
                    textColorCode(n) = textColorCode(ftok(n));
                else
                    % This is a new executable line
                    lineIdx = executedLines(n);
                    
                    if (strcmp(hiliteOption,'time') || ...
                            strcmp(hiliteOption,'allocated memory') || ...
                            strcmp(hiliteOption,'freed memory') || ...
                            strcmp(hiliteOption,'peak memory'))
                        
                        if lineIdx > 0
                            textColorCode(n) = 2;
                            if ftItem.ExecutedLines(lineIdx,key_data_field+2) > 0
                                dataPerLine = ftItem.ExecutedLines(lineIdx,key_data_field+2);
                                ratioData = dataPerLine/maxData(key_data_field);
                                bgColorCode(n) = ceil(10*ratioData);
                            else
                                % The amount of time (or memory) spent on the line was negligible
                                bgColorCode(n) = 1;
                            end
                        else
                            % The line was not executed
                            textColorCode(n) = 3;
                            bgColorCode(n) = 1;
                        end
                        
                    elseif strcmp(hiliteOption,'numcalls')
                        
                        if lineIdx > 0
                            textColorCode(n) = 2;
                            if ftItem.ExecutedLines(lineIdx,2)>0;
                                callsPerLine = ftItem.ExecutedLines(lineIdx,2);
                                ratioNumCalls = callsPerLine/maxNumCalls;
                                bgColorCode(n) = ceil(10*ratioNumCalls);
                            else
                                % This line was not called
                                bgColorCode(n) = 1;
                            end
                        else
                            % The line was not executed
                            textColorCode(n) = 3;
                            bgColorCode(n) = 1;
                        end
                        
                    elseif strcmp(hiliteOption,'coverage')
                        
                        if lineIdx > 0
                            textColorCode(n) = 2;
                            bgColorCode(n) = 2;
                        else
                            % The line was not executed
                            textColorCode(n) = 3;
                            bgColorCode(n) = 1;
                        end
                        
                    elseif strcmp(hiliteOption,'noncoverage')
                        
                        % If the line did execute or it is a
                        % non-breakpointable line, then it should not be
                        % flagged
                        if (lineIdx > 0) || (runnableLines(n) == 0)
                            textColorCode(n) = 2;
                            bgColorCode(n) = 1;
                        else
                            % The line was not executed
                            textColorCode(n) = 2;
                            bgColorCode(n) = 2;
                        end
                        
                    elseif strcmp(hiliteOption,'mlint')
                        
                        if any([mlintstrc.line]==n)
                            bgColorCode(n) = 2;
                            textColorCode(n) = 2;
                        else
                            bgColorCode(n) = 1;
                            if lineIdx > 0
                                textColorCode(n) = 2;
                            else
                                % The line was not executed
                                textColorCode(n) = 3;
                            end
                        end
                        
                    elseif strcmp(hiliteOption,'none')
                        
                        if lineIdx > 0
                            textColorCode(n) = 2;
                        else
                            % The line was not executed
                            textColorCode(n) = 3;
                        end
                        
                    end
                end
            end
        end
        function b = hasMemoryData(s)
            % Does this profiler data structure have memory profiling information in it?
            b = (isfield(s, 'PeakMem') || ...
                (isfield(s, 'FunctionTable') && isfield(s.FunctionTable, 'PeakMem')));
        end
        function fnm = constructfilename(filename)
            % It's important that the ampersand run first in this list, otherwise the
            % subsequent substitutions (which contain ampersands) will break.
            filename = strrep(filename,'&','_');
            filename = strrep(filename,'<','_');
            filename = strrep(filename,'>','_');
            fnm = filename;
        end
    end
end