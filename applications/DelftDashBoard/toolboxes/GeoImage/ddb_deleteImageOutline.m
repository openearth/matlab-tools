function ddb_deleteImageOutline

h=findall(gca,'Tag','ImageOutline');

if ~isempty(h)
    usd=get(h(1),'userdata');
    sh=usd.SelectionHighlights;
    delete(sh);
    delete(h);
end
