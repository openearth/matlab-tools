function [h,ok]=newGUI(xmldir,xmlfile,hin,varargin)

iconFile=[];
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'iconfile'}
                iconFile=varargin{i+1};
        end
    end
end

hin.ok=1;

setTempHandles(hin);

xml=xml_load([xmldir xmlfile]);

tag='testje';

s=readUIElementsXML(xml,xmldir,tag,[],[]);

sz(1)=str2double(xml.width);
sz(2)=str2double(xml.height);

if ~isempty(iconFile)
    figh=MakeNewWindow(xml.title,sz,'modal','iconfile',iconFile);
else
    figh=MakeNewWindow(xml.title,sz,'modal');
end

addUIElements(figh,s.elements,'getfcn',@getTempHandles,'setfcn',@setTempHandles);

set(figh,'CloseRequestFcn',@closefig);

uiwait;

delete(figh);

h=getTempHandles;

if ~h.ok
    h=hin;
    ok=0;
else
    ok=1;
end

h=rmfield(h,'ok');    

%% Clear temprary handles
h0=[];
setTempHandles(h0);

function closefig(hObject,eventdata)
uiresume;
