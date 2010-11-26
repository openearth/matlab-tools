classdef MTestUtils
    
    methods (Static = true)
        function jclass = javaclass(mtype, ndims)
            % Return java.lang.Class instance for MatLab type.
            %
            % Input arguments:
            % mtype:
            %    the MatLab name of the type for which to return the java.lang.Class
            %    instance
            % ndims:
            %    the number of dimensions of the MatLab data type
            %
            % See also: class
            
            % Copyright 2009-2010 Levente Hunyadi
            
            validateattributes(mtype, {'char'}, {'nonempty','row'});
            if nargin < 2
                ndims = 0;
            else
                validateattributes(ndims, {'numeric'}, {'nonnegative','integer','scalar'});
            end
            
            if ndims == 1 && strcmp(mtype, 'char');  % a character vector converts into a string
                jclassname = 'java.lang.String';
            elseif ndims > 0
                jclassname = javaarrayclass(mtype, ndims);
            else
                % The static property .class applied to a Java type returns a string in
                % MatLab rather than an instance of java.lang.Class. For this reason,
                % use a string and java.lang.Class.forName to instantiate a
                % java.lang.Class object; the syntax java.lang.Boolean.class will not
                % do so.
                switch mtype
                    case 'logical'  % logical vaule (true or false)
                        jclassname = 'java.lang.Boolean';
                    case 'char'  % a singe character
                        jclassname = 'java.lang.Character';
                    case {'int8','uint8'}  % 8-bit signed and unsigned integer
                        jclassname = 'java.lang.Byte';
                    case {'int16','uint16'}  % 16-bit signed and unsigned integer
                        jclassname = 'java.lang.Short';
                    case {'int32','uint32'}  % 32-bit signed and unsigned integer
                        jclassname = 'java.lang.Integer';
                    case {'int64','uint64'}  % 64-bit signed and unsigned integer
                        jclassname = 'java.lang.Long';
                    case 'single'  % single-precision floating-point number
                        jclassname = 'java.lang.Float';
                    case 'double'  % double-precision floating-point number
                        jclassname = 'java.lang.Double';
                    case 'cellstr'  % a single cell or a character array
                        jclassname = 'java.lang.String';
                    otherwise
                        error('java:javaclass:InvalidArgumentValue', ...
                            'MatLab type "%s" is not recognized or supported in Java.', mtype);
                end
            end
            % Note: When querying a java.lang.Class object by name with the method
            % jclass = java.lang.Class.forName(jclassname);
            % MatLab generates an error. For the Class.forName method to work, MatLab
            % requires class loader to be specified explicitly.
            jclass = java.lang.Class.forName(jclassname, true, java.lang.Thread.currentThread().getContextClassLoader());
        end
        function infoout = mergeprofileinfo(varargin)
            %MERGEPROFILEINFO  Merges info structures from the profile function.
            %
            %   This function combines the information of multiple profile info structs.
            %
            %   Syntax:
            %   infoout = mergeprofileinfo(info1,info2)
            %
            %   Input:
            %   info1/info2 - profile information structs obtained with profile('info').
            %
            %   Output:
            %   infoout     - combined information of info1 and info2.
            %
            %   See also profile
            
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
            % Created: 18 Sep 2009
            % Created with Matlab version: 7.8.0.347 (R2009a)
            
            % $Id$
            % $Date$
            % $Author$
            % $Revision$
            % $HeadURL$
            % $Keywords: $
            
            %% Take first info input as basis
            infoout = varargin{1};
            
            for iprofinf = 2:length(varargin)
                info2 = varargin{iprofinf};
                if isempty(info2) || isempty(info2.FunctionTable)
                    continue;
                end
                %% Add functionnames of second info
                for ifunc = 1:length(info2.FunctionTable)
                    funcid = strcmp({infoout.FunctionTable.CompleteName},info2.FunctionTable(ifunc).CompleteName);
                    if all(~funcid)
                        % Enter info that does not depend on other functions
                        infoout.FunctionTable(end+1).CompleteName = info2.FunctionTable(ifunc).CompleteName;
                        infoout.FunctionTable(end).Type = info2.FunctionTable(ifunc).Type;
                        infoout.FunctionTable(end).NumCalls = info2.FunctionTable(ifunc).NumCalls;
                        infoout.FunctionTable(end).IsRecursive = info2.FunctionTable(ifunc).IsRecursive;
                        infoout.FunctionTable(end).FunctionName = info2.FunctionTable(ifunc).FunctionName;
                        infoout.FunctionTable(end).FileName = info2.FunctionTable(ifunc).FileName;
                        infoout.FunctionTable(end).TotalRecursiveTime = info2.FunctionTable(ifunc).TotalRecursiveTime;
                        infoout.FunctionTable(end).PartialData = info2.FunctionTable(ifunc).PartialData;
                        infoout.FunctionTable(end).TotalTime = info2.FunctionTable(ifunc).TotalTime;
                        infoout.FunctionTable(end).ExecutedLines = info2.FunctionTable(ifunc).ExecutedLines;
                    else
                        % update info that does not depend on other functions
                        infoout.FunctionTable(funcid).NumCalls = infoout.FunctionTable(funcid).NumCalls + info2.FunctionTable(ifunc).NumCalls;
                        infoout.FunctionTable(funcid).TotalTime = infoout.FunctionTable(funcid).TotalTime + info2.FunctionTable(ifunc).TotalTime;
                        infoout.FunctionTable(funcid).TotalRecursiveTime = infoout.FunctionTable(funcid).TotalRecursiveTime + info2.FunctionTable(ifunc).TotalRecursiveTime;
                        for ilns = 1:size(info2.FunctionTable(ifunc).ExecutedLines,1)
                            lninf = info2.FunctionTable(ifunc).ExecutedLines(ilns,:);
                            id = infoout.FunctionTable(funcid).ExecutedLines(:,1)==lninf(1);
                            if any(id)
                                infoout.FunctionTable(funcid).ExecutedLines(id,2) = infoout.FunctionTable(funcid).ExecutedLines(id,2) + lninf(2);
                                infoout.FunctionTable(funcid).ExecutedLines(id,3) = infoout.FunctionTable(funcid).ExecutedLines(id,3) + lninf(3);
                            else
                                infoout.FunctionTable(funcid).ExecutedLines(end+1,:) = lninf;
                                infoout.FunctionTable(funcid).ExecutedLines = sortrows(infoout.FunctionTable(funcid).ExecutedLines,1);
                            end
                        end
                    end
                end
                
                %% Add relations to children and Parents
                for ifunc = 1:length(info2.FunctionTable)
                    %% location of function in outstruct
                    funcid = strcmp({infoout.FunctionTable.CompleteName},info2.FunctionTable(ifunc).CompleteName);
                    
                    %% add link in childs
                    ch = info2.FunctionTable(ifunc).Children;
                    for ich = 1:length(ch)
                        chname = info2.FunctionTable(ch(ich).Index).CompleteName;
                        id = strcmp({infoout.FunctionTable.CompleteName},chname);
                        %% add to children
                        if ~isempty(infoout.FunctionTable(funcid).Children) && any([infoout.FunctionTable(funcid).Children.Index]==find(id))
                            tmpid = [infoout.FunctionTable(funcid).Children.Index]==find(id);
                            infoout.FunctionTable(funcid).Children(tmpid).NumCalls = ...
                                infoout.FunctionTable(funcid).Children(tmpid).NumCalls + ch(ich).NumCalls;
                            infoout.FunctionTable(funcid).Children(tmpid).TotalTime = ...
                                infoout.FunctionTable(funcid).Children(tmpid).TotalTime + ch(ich).TotalTime;
                        else
                            infoout.FunctionTable(funcid).Children(end+1) = struct(...
                                'Index',find(id),...
                                'NumCalls',ch(ich).NumCalls,...
                                'TotalTime',ch(ich).TotalTime);
                        end
                        
                        %% add parent info to child
                        prntsinfo2 = struct(...
                            'Index',[],...
                            'NumCalls',[]);
                        for ipar = 1:length(info2.FunctionTable(ch(ich).Index).Parents)
                            prntsinfo2(ipar).NumCalls = info2.FunctionTable(ch(ich).Index).Parents(ipar).NumCalls;
                            if islogical(info2.FunctionTable(ch(ich).Index).Parents(ipar).Index)
                                prntsinfo2(ipar).Index = find(info2.FunctionTable(ch(ich).Index).Parents(ipar).Index);
                            else
                                prntsinfo2(ipar).Index = info2.FunctionTable(ch(ich).Index).Parents(ipar).Index;
                            end
                        end
                        numcalls = prntsinfo2([prntsinfo2.Index]==ifunc).NumCalls;
                        if ~isempty(infoout.FunctionTable(id).Parents) && any(cellfun(@findifislogical,{infoout.FunctionTable(id).Parents.Index})==find(funcid))
                            prntid = find(cellfun(@findifislogical,{infoout.FunctionTable(id).Parents.Index})==find(funcid));
                            infoout.FunctionTable(id).Parents(prntid).NumCalls = infoout.FunctionTable(id).Parents(prntid).NumCalls + numcalls;
                        else
                            infoout.FunctionTable(id).Parents(end+1) = struct(...
                                'Index',funcid,...
                                'NumCalls',numcalls);
                        end
                    end
                end
            end
        end
        function evalinemptyworkspace(str)
            setappdata(0,'emptyworkspaceevaluation',str);
            eval_fun();
            if isappdata(0,'emptyworkspaceevaluation')
                % the string in the evaluation probably also involves a call to evalinemptyworkspace. Therefore
                % the appdata is already removed.
                return;
            end
            rmappdata(0,'emptyworkspaceevaluation');
        end
        function [OPT, Set, Default] = setproperty(OPT, varargin)
            % SETPROPERTY  generic routine to set values in PropertyName-PropertyValue pairs
            %
            % Routine to set properties based on PropertyName-PropertyValue
            % pairs (aka <keyword,value> pairs). Can be used in any function
            % where PropertyName-PropertyValue pairs are used.
            %
            % syntax:
            % [OPT Set Default] = setproperty(OPT, varargin{:})
            %  OPT              = setproperty(OPT, 'PropertyName', PropertyValue,...)
            %  OPT              = setproperty(OPT, OPT2)
            %
            % input:
            % OPT      = structure in which fieldnames are the keywords and the values are the defaults
            % varargin = series of PropertyName-PropertyValue pairs to set
            % OPT2     = is a structure with the same fields as OPT.
            %
            %            Internally setproperty translates OPT2 into a set of
            %            PropertyName-PropertyValue pairs (see example below) as in:
            %            OPT2    = struct( 'propertyName1', 1,...
            %                              'propertyName2', 2);
            %            varcell = reshape([fieldnames(OPT2)'; struct2cell(OPT2)'], 1, 2*length(fieldnames(OPT2)));
            %            OPT     = setproperty(OPT, varcell{:});
            %
            % output:
            % OPT     = structure, similar to the input argument OPT, with possibly
            %           changed values in the fields
            % Set     = structure, similar to OPT, values are true where OPT has been
            %           set (and possibly changed)
            % Default = structure, similar to OPT, values are true where the values of
            %           OPT are equal to the original OPT
            %
            % Example:
            %
            % +------------------------------------------->
            % function y = dosomething(x,'debug',1)
            % OPT.debug  = 0;
            % OPT        = setproperty(OPT, varargin{:});
            % y          = x.^2;
            % if OPT.debug; plot(x,y);pause; end
            % +------------------------------------------->
            %
            % See also: VARARGIN, STRUCT, MERGESTRUCTS
            
            %% Copyright notice
            %   --------------------------------------------------------------------
            %   Copyright (C) 2009 Delft University of Technology
            %       C.(Kees) den Heijer
            %
            %       C.denHeijer@TUDelft.nl
            %
            %       Faculty of Civil Engineering and Geosciences
            %       P.O. Box 5048
            %       2600 GA Delft
            %       The Netherlands
            %
            %   This library is free software; you can redistribute it and/or
            %   modify it under the terms of the GNU Lesser General Public
            %   License as published by the Free Software Foundation; either
            %   version 2.1 of the License, or (at your option) any later version.
            %
            %   This library is distributed in the hope that it will be useful,
            %   but WITHOUT ANY WARRANTY; without even the implied warranty of
            %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
            %   Lesser General Public License for more details.
            %
            %   You should have received a copy of the GNU Lesser General Public
            %   License along with this library; if not, write to the Free Software
            %   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
            %   USA
            %   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
            %   --------------------------------------------------------------------
            
            % This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
            % OpenEarthTools is an online collaboration to share and manage data and
            % programming tools in an open source, version controlled environment.
            % Sign up to recieve regular updates of this function, and to contribute
            % your own tools.
            
            %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
            % Created: 26 Feb 2009
            % Created with Matlab version: 7.4.0.287 (R2007a)
            
            % $Id$
            % $Date$
            % $Author$
            % $Revision$
            % $HeadURL$
            % $Keywords: $
            
            %% First try out variant
            if exist('oetsettings.m','file')
                [OPT, Set, Default] = setproperty(OPT, varargin{:});
                return;
            end
            
            %% input
            PropertyNames = fieldnames(OPT); % read PropertyNames from structure fieldnames
            
            if length(varargin) == 1
                % to prevent errors when this function is called as
                % "OPT = setproperty(OPT, varargin);" instead of
                % "OPT = setproperty(OPT, varargin{:})"
                if isstruct(varargin{1})
                    OPT2     = varargin{1};
                    varargin = reshape([fieldnames(OPT2)'; struct2cell(OPT2)'], 1, 2*length(fieldnames(OPT2)));
                else
                    varargin = varargin{1};
                end
            end
            
            % Set is similar to OPT, initially all fields are false
            Set = cell2struct(repmat({false}, size(PropertyNames)), PropertyNames);
            % Default is similar to OPT, initially all fields are true
            Default = cell2struct(repmat({true}, size(PropertyNames)), PropertyNames);
            
            if isempty(varargin)
                % No need to set anything
                return
            end
            %% keyword,value loop
            [i0 iend] = deal(1, length(varargin)); % specify index of first and last element of varargin to search for keyword/value pairs
            for iargin = i0:2:iend
                PropertyName = varargin{iargin};
                if any(strcmp(PropertyNames, PropertyName))
                    % set option
                    if ~isequalwithequalnans(OPT.(PropertyName), varargin{iargin+1})
                        % only renew property value if it really changes
                        OPT.(PropertyName) = varargin{iargin+1};
                        % indicate that this field is non-default now
                        Default.(PropertyName) = false;
                    end
                    % indicate that this field is set
                    Set.(PropertyName) = true;
                elseif any(strcmpi(PropertyNames, PropertyName))
                    % set option, but give warning that PropertyName is not totally correct
                    realPropertyName = PropertyNames(strcmpi(PropertyNames, PropertyName));
                    if ~isequalwithequalnans(OPT.(realPropertyName{1}), varargin{iargin+1})
                        % only renew property value if it really changes
                        OPT.(realPropertyName{1}) = varargin{iargin+1};
                        % indicate that this field is non-default now
                        Default.(PropertyName) = false;
                    end
                    % indicate that this field is set
                    Set.(realPropertyName{1}) = true;
                    warning([upper(mfilename) ':PropertyName'], ['Could not find an exact (case-sensitive) match for ''' PropertyName '''. ''' realPropertyName{1} ''' has been used instead.'])
                elseif ischar(PropertyName)
                    % PropertyName unknown, maybe hidden (when working with classes.....):
                    try
                        if ~isequalwithequalnans(OPT.(PropertyName), varargin{iargin+1})
                            % only renew property value if it really changes
                            OPT.(PropertyName) = varargin{iargin+1};
                            % indicate that this field is non-default now
                            Default.(PropertyName) = false;
                        end
                        % indicate that this field is set
                        Set.(PropertyName) = true;
                    catch
                        error([upper(mfilename) ':UnknownPropertyName'], ['PropertyName "' PropertyName '" is not valid'])
                    end
                else
                    % no char found where PropertyName expected
                    error([upper(mfilename) ':UnknownPropertyName'], 'PropertyName should be char')
                end
            end
            
        end
        function filescell = listfiles(basedir,extension,recursive)
            filescell = [];
            if recursive
                drs = strread(genpath(basedir),'%s',-1,'delimiter',';');
                drs(~cellfun(@isempty,strfind(drs,'.svn')))=[];
                for idirs = 1:length(drs)
                    tempstruct = dir(fullfile(drs{idirs},['*.' extension]));
                    if ~isempty(tempstruct)
                        dr = fullfile(basedir,strrep(drs{idirs},basedir,''));
                        newfiles = cell(length(tempstruct),2);
                        newfiles(:,1) = {dr};
                        newfiles(:,2) = {tempstruct.name}';
                        filescell = cat(1,filescell,newfiles);
                    end
                end
            else
                tplflsstruct = dir(fullfile(basedir,'*.tpl'));
                filescell = cell(length(tplflsstruct),2);
                filescell(:,2) = {tplflsstruct.name}';
                filescell(:,1) = {obj.targetdir};
            end
        end
        function varargout = whichx(inputstr)
            %WHICHX   file search within matlab search path using wildcards
            %   For example, WHICHX *.m lists all the M-files in the matlab search paths.
            %
            %   D = WHICHX('*.m') returns the results in an M-by-1
            %   structure with the fields:
            %       name  -- filename
            %       date  -- modification date
            %       bytes -- number of bytes allocated to the file
            %       isdir -- 1 if name is a directory and 0 if not%
            %       path  -- directory
            %
            %   See also  WHICH, DIR, MATLABPATH.
            
            % Autor: Elmar Tarajan [MCommander@gmx.de]
            % Version: 2.2
            % Date: 2006/01/12 09:10:05
            
            if nargin == 0
                help('whichx')
                return
            end% if
            %
            if ispc
                tmp = eval(['{''' strrep(matlabpath,';',''',''') '''}']);
            elseif isunix
                tmp = eval(['{''' strrep(matlabpath,':',''',''') '''}']);
            else
                error('plattform doesn''t supported')
            end% if
            %
            if ~any(strcmpi(tmp,cd))
                tmp = [tmp {cd}];
            end% if
            %
            output = [];
            for i=tmp
                tmp = dir(fullfile(char(i),inputstr));
                if ~isempty(tmp)
                    for j=1:length(tmp)
                        tmp(j).path = fullfile(char(i),tmp(j).name);
                    end% for
                    output = [output;tmp];
                end% if
            end% for
            %
            if nargout==0
                if ~isempty(output)
                    if usejava('jvm')
                        out = [];
                        h = [];
                        for i=1:length(output)
                            %
                            if ~mod(i,200)
                                if ishandle(h)
                                    waitbar(i/length(output),h,sprintf('%.0f%%',(i*100)/length(output)))
                                elseif isempty(h)
                                    h = waitbar(i/length(output),'','Name',sprintf('Please wait... %d files are founded.',length(output)));
                                else
                                    return
                                end% if
                                drawnow
                            end% if
                            %
                            [p f e] = fileparts(output(i).path);
                            p = strrep([p filesep],[filesep filesep],filesep);
                            e = strrep(['.' e],'..','.');
                            fl = strrep(output(i).path,'''','''''');
                            switch lower(e)
                                case '.m'
                                    out = [out sprintf('<a href="matlab: %s">run</a> <a href="matlab:cd(''%s'')">cd</a> %s<a href="matlab:edit(''%s'')">%s%s</a>\n', f, p, p, fl, f, e)];
                                case {'.asv' '.cdr' '.rtw' '.tmf' '.tlc' '.c' '.h' '.ads' '.adb'}
                                    out = [out sprintf('    <a href="matlab:cd(''%s'')">cd</a> %s<a href="matlab:open(''%s'')">%s%s</a>\n', p, p, fl, f, e)];
                                case '.mat'
                                    out = [out sprintf('    <a href="matlab:cd(''%s'')">cd</a> %s<a href="matlab:load(''%s'');disp([''%s loaded''])">%s%s</a>\n', p, p, fl, fl, f, e)];
                                case '.fig'
                                    out = [out sprintf('    <a href="matlab:cd(''%s'')">cd</a> %s<a href="matlab:guide(''%s'')">%s%s</a>\n', p, p, fl, f, e)];
                                case '.p'
                                    out = [out sprintf('<a href="matlab: %s">run</a> <a href="matlab:cd(''%s'')">cd</a> %s\n', f, p, fl)];
                                case '.mdl'
                                    out = [out sprintf('    <a href="matlab:cd(''%s'')">cd</a> %s<a href="matlab:open(''%s'')">%s%s</a>\n', p, p, fl, f, e)];
                                otherwise
                                    if output(i).isdir
                                        out = [out sprintf('    <a href="matlab:cd(''%s'')">cd</a> %s\n', [p f], output(i).path)];
                                    else
                                        out = [out sprintf('    <a href="matlab:cd(''%s'')">cd</a> %s<a href="matlab:try;winopen(''%s'');catch;disp(lasterr);end">%s%s</a>\n', p, p, fl, f, e)];
                                    end% if
                            end% switch
                        end% for
                        close(h)
                        disp(char(out));
                    else
                        disp(char(output.path));
                    end% if
                else
                    disp(['''' inputstr '''' ' not found.'])
                end% if
            else
                varargout{1} = output;
            end% if
        end
    end
end

function outputArray = findifislogical(inputArray)
outputArray = inputArray;
if islogical(inputArray)
    outputArray = find(inputArray);
end
end

function eval_fun()
eval(getappdata(0,'emptyworkspaceevaluation'));
end

function jclassname = javaarrayclass(mtype, ndims)
% Returns the type qualifier for a multidimensional Java array.

switch mtype
    case 'logical'  % logical array of true and false values
        jclassid = 'Z';
    case 'char'  % character array
        jclassid = 'C';
    case {'int8','uint8'}  % 8-bit signed and unsigned integer array
        jclassid = 'B';
    case {'int16','uint16'}  % 16-bit signed and unsigned integer array
        jclassid = 'S';
    case {'int32','uint32'}  % 32-bit signed and unsigned integer array
        jclassid = 'I';
    case {'int64','uint64'}  % 64-bit signed and unsigned integer array
        jclassid = 'J';
    case 'single'  % single-precision floating-point number array
        jclassid = 'F';
    case 'double'  % double-precision floating-point number array
        jclassid = 'D';
    case 'cellstr'  % cell array of strings
        jclassid = 'Ljava.lang.String;';
    otherwise
        error('java:javaclass:InvalidArgumentValue', ...
            'MatLab type "%s" is not recognized or supported in Java.', mtype);
end
jclassname = [repmat('[',1,ndims), jclassid];
end