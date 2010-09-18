function fig=makeGUI(fname)

s=xml_load(fname);

fig=MakeNewWindow_st(s.name,str2num(s.size),'modal');

for i=1:length(s.elements)
    
    el=s.elements(i).element;
    
    if ~isfield(el,'string')
        el.string=' ';
    end

    uic=uicontrol('Style',el.type,'Position',str2num(el.position),'String',el.string,'Tag',el.tag); 

    if isfield(el,'callback')
        set(uic,'Callback',str2func(el.callback));
    end

    if isfield(el,'variable')
        set(uic,'Callback',editVariable(el.variable,uic));
    end
    
end

function editVariable(varname,handle)

global b

b.(varname)=get(handle,'String');

