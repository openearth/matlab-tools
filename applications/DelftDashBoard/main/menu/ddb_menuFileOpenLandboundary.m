function handles=ddb_menuFileOpenLandboundary(handles)

[filename, pathname, filterindex] = uigetfile('*.ldb', 'Select ldb file');

if pathname~=0
    h=findobj(gcf,'Tag','LandBoundary');
    if ~isempty(h)
        delete(h);
    end
    [x,y]=landboundary('read',[pathname filename]);
    z=zeros(size(x))+5000;
    plt=plot3(x,y,z,'k');hold on;
    set(plt,'Tag','LandBoundary','HitTest','off');
end
