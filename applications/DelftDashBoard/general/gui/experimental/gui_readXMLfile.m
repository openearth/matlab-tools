function xml=gui_readXMLfile(xmlfile,dr,varargin)
% Read UI xml file and store elements in structure xml

variableprefix=[];
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'variableprefix'}
                variableprefix=varargin{ii+1};
        end
    end
end

xml=[];

try
    xml=xml_load([dr filesep xmlfile]);
catch
    error(['Error in readGUIElementsXML. Could not load xml file ' dr elxml]);
end

if isfield(xml,'elements')
    % Top level file
    elements=xml.elements;
    lowerlevel=0;
else
    % Lower level file with just elements
    elements=xml;
    lowerlevel=1;
end

for k=1:length(elements)
    
    switch elements(k).element.style
        
        case{'tabpanel'}
            for j=1:length(elements(k).element.tabs)
                if isfield(elements(k).element.tabs(j).tab,'elements')
                    if ischar(elements(k).element.tabs(j).tab.elements)
                        % Elements in separate xml file
                        xmlfile2=elements(k).element.tabs(j).tab.elements;
                        newelements=gui_readXMLfile(xmlfile2,dr);
                        elements(k).element.tabs(j).tab.elements = newelements;
                    end
                end
            end
    end
    
end
if lowerlevel
    xml=elements;
else
    xml.elements=elements;
    % And now finish off xml structure
    xml=gui_fillXMLvalues(xml,'variableprefix',variableprefix);
end

