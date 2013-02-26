function s = xml2struct(varargin)
%XML2STRUCT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   s = xml2struct(fname)
%
%   Input:
%   fname =
%
%   Output:
%   s     =
%
%   Example
%   xml2struct
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% Writes xml data to Matlab structure

filename=[];
xml=[];
includeattributes=0;
structuretype=1;

if nargin==1
    % Assuming input argument is filename
    filename=varargin{1};
else
    for ii=1:length(varargin)
        if ischar(varargin{ii})
            switch lower(varargin{ii})
                case{'filename'}
                    filename=varargin{ii+1};
                case{'xml'}
                    xml=varargin{ii+1};
                case{'includeattributes'}
                    includeattributes=1;
                case{'structuretype'}
                    structuretype=varargin{ii+1};
            end
        end
    end
end

if ~isempty(filename)
    node=parseXML('filename',filename);
else
    node=parseXML('xml',xml);
end

s=node2struct(node,includeattributes,structuretype);

function s=node2struct(node,includeattributes,structuretype)

s=[];

for ii=1:length(node.Children)
    
    child=node.Children(ii);
    
    if (length(child.Children)==1 && isempty(child.Data)) || (isempty(child.Children) && ~isempty(child.Attributes))
        
        % Must be and end node

        name=nocolon(child.Name);
        if ~isempty(child.Children)
            val=child.Children.Data;
        else
            val=[];
        end
        
        attributes=getAttributes(child);
        if ~isempty(val)
            % Try to convert data to correct type
            if ~isempty(attributes)
                if isfield(attributes,'type')
                    switch lower(attributes.type)
                        case{'int','real'}
                            val=str2num(val);
                    end
                end
            end
        end
        
        k=1;
        if isfield(s,name)
            % s.(name) has already been set
            if ischar(s.(name))
                k=2;
            else
                k=length(s.(name))+1;
            end
        end
        
        if includeattributes
            s.(name)(k).(name)=val;
            if ~isempty(attributes)
                s.(name)(k).ATTRIBUTES=attributes;
            end
        else
            if structuretype==1
                s.(name)(k).(name)=val;
            else
                if ischar(val) || isempty(val)
                    if k==1
                        s.(name)=val;
                    elseif k==2
                        orival=s.(name);
                        s.(name)=[];
                        s.(name){1}=orival;
                        s.(name){2}=val;
                    else
                        s.(name){k}=val;
                    end
                else
                    s.(name)(k)=val;
                end
            end
        end
        
    else
        
        % Next node
        
        s0=node2struct(child,includeattributes,structuretype);
        
        if ~isempty(s0)
            name=nocolon(child.Name);
            k=1;
            if isfield(s,name)
                % Field already exists
                k=length(s.(name))+1;
            end
            if structuretype==1
                s.(name)(k).(name)=s0;
                if includeattributes
                    attributes=getAttributes(child);
                    if ~isempty(attributes)
                        s.(name)(k).ATTRIBUTES=attributes;
                    end
                end
            else
                fldnames=fieldnames(s0);
                for j=1:length(fldnames)
                    s.(name)(k).(fldnames{j})=s0.(fldnames{j});
                end                
                if includeattributes
                    attributes=getAttributes(child);
                    if ~isempty(attributes)
                        s.(name)(k).ATTRIBUTES=attributes;
                    end
                end
            end
        end
    end
end

%%
function str=nocolon(str)
n=find(str==':');
if ~isempty(n)
    n1=n(end)+1;
    n2=length(str);
%     if length(n)>1
%         n2=n(2)-1;
%     end        
    str=str(n1:n2);
end

%%
function attributes=getAttributes(child)

attributes=[];
if ~isempty(child.Attributes)
    for ii=1:length(child.Attributes)
        name=nocolon(child.Attributes(ii).Name);
        attributes.(name)=child.Attributes(ii).Value;
    end
end

%%
function theStruct = parseXML(varargin)

filename=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'filename'}
                filename=varargin{ii+1};
            case{'xml'}
                xml=varargin{ii+1};
        end
    end
end

if ~isempty(filename)
    % PARSEXML Convert XML file to a MATLAB structure.
    try
        tree = xmlread(filename);
    catch
        error('Failed to read XML file %s.',filename);
    end
else
    tree=xml;
end



% Recurse over child nodes. This could run into problems
% with very deeply nested trees.
try
%profile on
    theStruct = parseChildNodes(tree);
%    profile viewer
catch
    error('Unable to parse XML file %s.',filename);
end


% ----- Subfunction PARSECHILDNODES -----
function children = parseChildNodes(theNode)
% Recurse over node children.
children = [];
if hasChildNodes(theNode)
    childNodes = getChildNodes(theNode);
    numChildNodes = getLength(childNodes);
    allocCell = cell(1, numChildNodes);
    
    children = struct(             ...
        'Name', allocCell, 'Attributes', allocCell,    ...
        'Data', allocCell, 'Children', allocCell);
    
    n=0;
    for count = 1:numChildNodes
        theChild = item(childNodes,count-1);
        nodeStruct = makeStructFromNode(theChild);
        if ~isempty(nodeStruct)
            n=n+1;
            children(n) = nodeStruct;
        end
    end
end

% ----- Subfunction MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.

name=char(getNodeName(theNode));

attributes=parseAttributes(theNode);
children=parseChildNodes(theNode);
nodeStruct = struct(                        ...
    'Name', name,       ...
    'Attributes', attributes,  ...
    'Data', '',                              ...
    'Children', children);

nodeStruct.Data=[];

if isempty(children)
    try
        text = toCharArray(getTextContent(theNode))';
        if isempty(deblank(text))
            text='';
        end
        nodeStruct.Data = text;
    end
end

if isempty(nodeStruct.Attributes) && isempty(nodeStruct.Data) && isempty(nodeStruct.Children)
    nodeStruct=[];
end

% ----- Subfunction PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
% Create attributes structure.

attributes = [];
if hasAttributes(theNode)
    theAttributes = theNode.getAttributes;
    numAttributes = getLength(theAttributes);
    allocCell = cell(1, numAttributes);
    attributes = struct('Name', allocCell, 'Value', ...
        allocCell);
    
    for count = 1:numAttributes
        attrib = theAttributes.item(count-1);
        attributes(count).Name = char(attrib.getName);
        attributes(count).Value = char(attrib.getValue);
    end
end
