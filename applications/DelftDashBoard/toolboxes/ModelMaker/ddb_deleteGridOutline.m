function ddb_deleteGridOutline

h=findall(gca,'Tag','GridOutline');

if ~isempty(h)
    usd=get(h,'userdata');
    try
        sh=usd.ch;
        delete(sh);
        delete(h);
    end
end
