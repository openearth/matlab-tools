function ddb_exportChartContours(handles)

iac=handles.Toolbox(tb).ActiveDatabase;
ii=handles.Toolbox(tb).ActiveChart;
fname=handles.Toolbox(tb).Charts(iac).Box(ii).Name;

[filename, pathname, filterindex] = uiputfile('*.xyz', 'Select XYZ File',[fname '_contours.xyz']);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end

    wb=waitbox('Exporting XYZ File ...');

    orisys.Name='WGS 84';
    orisys.Type='geographic';

    newsys=handles.ScreenParameters.CoordinateSystem;

    s=handles.Toolbox(tb).Layers;

    ncnt=length(s.DEPCNT);
    
    pnts=[];
    for i=1:ncnt
        d=str2double(s.DEPCNT(i).VALDCO);
        x=s.DEPCNT(i).Coordinates(:,1);
        y=s.DEPCNT(i).Coordinates(:,2);
        z=zeros(size(x))+d;
        xyz=[x y z];
        pnts=[pnts;xyz];
    end

    x=pnts(:,1);
    y=pnts(:,2);
    z=pnts(:,3);
    
    [x,y]=ddb_coordConvert(x,y,orisys,newsys);

    fid=fopen(filename,'wt');
    for i=1:size(pnts,1)
        fprintf(fid,'%16.8e %16.8e %16.8e\n',x(i),y(i),z(i));
    end
    fclose(fid);

    close(wb);

end
