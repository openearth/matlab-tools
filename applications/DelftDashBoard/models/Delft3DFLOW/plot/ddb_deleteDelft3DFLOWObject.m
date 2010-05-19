function ddb_deleteDelft3DFLOWObject(id,tag,callback)

ddb_setWindowButtonMotionFcn;
set(gcf,'windowbuttondownfcn',{@Click,id,tag,callback});
set(gcf,'windowbuttonupfcn',[]);

%%
function Click(src,eventdata,id,tag,callback)

h=gco;

usd=get(gco,'UserData');
tg=get(gco,'Tag');

if  strcmpi(tg,tag)
    if usd(1)==id
        feval(callback,usd(2));
    end
end
