function s=xml2struct(fname)
% Writes xml data to Matlab structure
% For use in CoSMoS

v=parseXML(fname);

s=getxmldata(v);

function s=getxmldata(v)
s=[];
for i=1:length(v.Children)
    vv=v.Children(i);
    if isempty(vv.Attributes) && ~isempty(vv.Children)
        n=0;
        for j=1:length(vv.Children)
            ch=vv.Children(j);
            s0=getxmldata(ch);
            if ~isempty(s0)
                n=n+1;
                s.(vv.Name)(n).(ch.Name)=s0;
            end
        end
    elseif ~isempty(vv.Children)
        if isempty(vv.Data)
            s0=getfinalnode(vv);
            fld=fieldnames(s0);
            fld=fld{1};
            s.(fld)=s0.(fld);
        end
    end
end

%%
function s=getfinalnode(v)
fldname=v.Name;
val=v.Children.Data;
typ=v.Attributes.Value;
s.(fldname).value=val;
s.(fldname).type=typ;

function theStruct = parseXML(filename)
% PARSEXML Convert XML file to a MATLAB structure.
try
   tree = xmlread(filename);
catch
   error('Failed to read XML file %s.',filename);
end

% Recurse over child nodes. This could run into problems 
% with very deeply nested trees.
try
   theStruct = parseChildNodes(tree);
catch
   error('Unable to parse XML file %s.',filename);
end


% ----- Subfunction PARSECHILDNODES -----
function children = parseChildNodes(theNode)
% Recurse over node children.
children = [];
if theNode.hasChildNodes
   childNodes = theNode.getChildNodes;
   numChildNodes = childNodes.getLength;
   allocCell = cell(1, numChildNodes);

   children = struct(             ...
      'Name', allocCell, 'Attributes', allocCell,    ...
      'Data', allocCell, 'Children', allocCell);

    for count = 1:numChildNodes
        theChild = childNodes.item(count-1);
        children(count) = makeStructFromNode(theChild);
    end
end

% ----- Subfunction MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.

nodeStruct = struct(                        ...
   'Name', char(theNode.getNodeName),       ...
   'Attributes', parseAttributes(theNode),  ...
   'Data', '',                              ...
   'Children', parseChildNodes(theNode));

if any(strcmp(methods(theNode), 'getData'))
   nodeStruct.Data = char(theNode.getData); 
else
   nodeStruct.Data = '';
end

% ----- Subfunction PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
% Create attributes structure.

attributes = [];
if theNode.hasAttributes
   theAttributes = theNode.getAttributes;
   numAttributes = theAttributes.getLength;
   allocCell = cell(1, numAttributes);
   attributes = struct('Name', allocCell, 'Value', ...
                       allocCell);

   for count = 1:numAttributes
      attrib = theAttributes.item(count-1);
      attributes(count).Name = char(attrib.getName);
      attributes(count).Value = char(attrib.getValue);
   end
end
