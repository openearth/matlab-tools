function s = xml2struct(fname,varargin)

iopt=1;
iconvert=1;
includeattributes=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'structuretype'}
                iopt=varargin{ii+1};
            case{'convertdata'}
                iconvert=varargin{ii+1};
            case{'includeattributes'}
                includeattributes=varargin{ii+1};
        end
    end
end

tree = xmlread(fname);

theStruct = parseChildNodes(tree,iopt,iconvert,includeattributes);

fldnames=fieldnames(theStruct);

switch iopt
    case 1
        s=theStruct.(fldnames{1}).(fldnames{1});
    case 2
        s=theStruct.(fldnames{1});
end

% ----- Subfunction PARSECHILDNODES -----
function s = parseChildNodes(theNode,iopt,iconvert,includeattributes)
% Recurse over node children.
s=[];
childNodes = theNode.getChildNodes;
numChildNodes = childNodes.getLength;
for count = 1:numChildNodes
    theChild = childNodes.item(count-1);
    ngc=theChild.getChildNodes.getLength;
    if ngc==1
        nodename=char(theChild.getNodeName);
        v=char(theChild.item(0).getData);
        if iconvert
            if theChild.hasAttributes
                attrs=theChild.getAttributes;
                for iatt=1:attrs.getLength;
                    attr=attrs.item(iatt-1);
                    name=char(attr.getName);
                    switch name
                        case{'type'}
                            val=char(attr.getValue);
                            switch val
                                case{'int','real'}
                                    v=str2num(v);
                                case{'date'}
                                    v=datenum(v,'yyyymmdd HHMMSS');
                            end
                    end
                end
            end
        end
%         if strcmpi(nodename,'text')
%           shite=2
%         end
        if isfield(s,nodename)
            % Already exists
            if ~isstruct(s.(nodename))
                % Not a structure yet
                v0=s.(nodename);
                s=rmfield(s,nodename);
                s.(nodename)(1).(nodename)=v0;
            end                
            n=length(s.(nodename))+1;
            s.(nodename)(n).(nodename) = v;
        else
            s.(nodename) = v;
        end
    elseif ngc>1
        nodename=char(theChild.getNodeName);
        switch nodename
            case{'#comment','#document','#text'}
            otherwise
                if isfield(s,nodename)
                    n=length(s.(nodename))+1;
                else
                    n=1;
                end
                s0=parseChildNodes(theChild,iopt,iconvert,includeattributes);
                fldnames=fieldnames(s0);
                for ifld=1:length(fldnames)
                    switch iopt
                        case 1
                            s.(nodename)(n).(nodename).(fldnames{ifld}) = s0.(fldnames{ifld});
                        case 2
                            s.(nodename)(n).(fldnames{ifld}) = s0.(fldnames{ifld});
                    end
                end
        end
    end
end
