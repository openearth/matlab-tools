function h=UIControlEdit(val,pos,struct1,i1,struct2,i2,par,i3,inptype,txtstr)

switch(lower(inptype))
    case{'string'}
        h = uicontrol(gcf,'Style','edit','String',val,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        usd.Type='string';
    case{'real','integer'}
        h = uicontrol(gcf,'Style','edit','String',num2str(val),'BackgroundColor',[1 1 1],'HorizontalAlignment','right');
        usd.Type='real';
end

set(h,'Tag','UIControl','Position',pos);

usd.Struct1=struct1;
usd.Struct2=struct2;
usd.Par=par;
usd.Index1=i1;
usd.Index2=i2;
usd.Index3=i3;

set(h,'UserData',usd);
set(h, 'Callback',{@Edit_Callback});

if ~isempty(txtstr)
    tx=uicontrol(gcf,'Style','text','String',txtstr,'Position',[1 1 200 20],'HorizontalAlignment','right','Tag','UIControl');
    ext=get(tx,'Extent');
    postxt=[pos(1)-ext(3)-5 pos(2)-4 ext(3) 20];
    set(tx,'Position',postxt);
end

%%
function Edit_Callback(hObject,eventdata)

handles=getHandles;

str=get(hObject,'String');

usd=get(hObject,'UserData');

struct1=usd.Struct1;
struct2=usd.Struct2;
par=usd.Par;
i1=usd.Index1;
i2=usd.Index2;
i3=usd.Index3;
tp=usd.Type;

switch(lower(tp))
    case{'string'}
        if ~isempty(struct2)
            if iscell(handles.(struct1)(i1).(struct2)(i2).(par))
                handles.(struct1).(struct2).(par){i3}=str;
            else
                handles.(struct1)(i1).(struct2)(i2).(par)=str;
            end
        else
            if iscell(handles.(struct1)(i1).(par))
                handles.(struct1)(i1).(par){i3}=str;
            else
                handles.(struct1)(i1).(par)=str;
            end 
        end            
    case{'real','integer'}
        if ~isempty(struct2)
            handles.(struct1)(i1).(struct2)(i2).(par)(i3)=str2double(str);
        else
            handles.(struct1)(i1).(par)(i3)=str2double(str);
        end            
end

setHandles(handles);

