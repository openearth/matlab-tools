function h=newwind(xmldir,xmlfile,hin)

hin.ok=1;

setTempHandles(hin);

xml=xml_load([xmldir xmlfile]);

tag='testje';

s=readUIElementsXML(xml,xmldir,tag,[],[]);

sz(1)=str2double(xml.width);
sz(2)=str2double(xml.height);

figh=MakeNewWindow(xml.title,sz,'modal');

elements=addUIElements(figh,s.elements,'getfcn',@getTempHandles,'setfcn',@setTempHandles);

set(figh,'CloseRequestFcn',@closefig);

uiwait;

delete(figh);

h=getTempHandles;

if ~h.ok
    h=hin;
end

h=rmfield(h,'ok');    

%% Clear temprary handles
h0=[];
setTempHandles(h0);

function closefig(hObject,eventdata)
uiresume;
