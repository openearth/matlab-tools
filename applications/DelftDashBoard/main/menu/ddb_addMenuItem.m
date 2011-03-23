function handles=ddb_addMenuItem(handles,menu1,menu2,varargin)

sep='off';
chk='off';
enab='on';
longname=[];
callback=[];
argin=[];
tag=[];


HandleName=menu2;

n=nargin-3;
for i=1:n
    if ischar(varargin{i})
        switch lower(varargin{i}),
            case{'callback'}
                callback=varargin{i+1};
            case{'separator'}
                sep=varargin{i+1};
            case{'checked'}
                chk=varargin{i+1};
            case{'handlename'}
                HandleName=varargin{i+1};
            case{'enable'}
                enab=varargin{i+1};
            case{'longname'}
                longname=varargin{i+1};
            case{'argin'}
                argin=varargin{i+1};
            case{'tag'}
                tag=varargin{i+1};
        end
    end
end

%h=findobj(gcf,'Type','uimenu','Label',menu1);
h=findobj(gcf,'Type','uimenu','Tag',['menu' menu1]);

if isempty(longname)
    lab=menu2;
else
    lab=longname;
end

if ~isempty(argin)
    g=uimenu(h,'Label',lab,'Callback',{callback,argin},'Separator',sep,'Checked',chk,'Enable',enab);
else
    g=uimenu(h,'Label',lab,'Callback',callback,'Separator',sep,'Checked',chk,'Enable',enab);
end

menu1=strrep(menu1,' ','');
menu1=strrep(menu1,'.','');
menu1=strrep(menu1,'-','');
menu1=strrep(menu1,'/','');
HandleName=strrep(HandleName,' ','');
HandleName=strrep(HandleName,'.','');
HandleName=strrep(HandleName,'-','');
HandleName=strrep(HandleName,'/','');
HandleName=strrep(HandleName,'(','');
HandleName=strrep(HandleName,')','');

handles.GUIHandles.Menu.(menu1).Main=h;
handles.GUIHandles.Menu.(menu1).(HandleName)=g;

tg=['menu' menu1 HandleName];
set(g,'Tag',tg);

