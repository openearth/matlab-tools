function ddb_clickObject(varargin)

for i=1:length(varargin)
    if ischar(varargin{i})
        switch(lower(varargin{i}))
            case{'tag'}
                tag=varargin{i+1};
            case{'callback'}
                callback=varargin{i+1};
        end
    end
end

ddb_setWindowButtonMotionFcn;
set(gcf,'windowbuttondownfcn',{@click,tag,callback});
set(gcf,'windowbuttonupfcn',[]);

%%
function click(src,eventdata,tag,callback)

tg=get(gco,'Tag');
if  strcmpi(tg,tag)
    feval(callback,gco);
end
