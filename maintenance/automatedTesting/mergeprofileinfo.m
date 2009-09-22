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
            if ~isempty(infoout.FunctionTable(id).Parents) && any([infoout.FunctionTable(id).Parents.Index]==find(funcid))
                prntid = find([infoout.FunctionTable(id).Parents.Index]==find(funcid));
                infoout.FunctionTable(id).Parents(prntid).NumCalls = infoout.FunctionTable(id).Parents(prntid).NumCalls + numcalls;
            else
                infoout.FunctionTable(id).Parents(end+1) = struct(...
                    'Index',funcid,...
                    'NumCalls',numcalls);
            end
        end
    end
end