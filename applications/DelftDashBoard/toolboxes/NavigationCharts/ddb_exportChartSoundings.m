function ddb_exportChartSoundings(handles)

iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeChart;
fname=handles.Toolbox(tb).Input.charts(iac).box(ii).Name;

[filename, pathname, filterindex] = uiputfile('*.xyz', 'Select XYZ File',[fname '_soundings.xyz']);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end

    wb=waitbox('Exporting XYZ file ...');

    orisys.name='WGS 84';
    orisys.type='geographic';

    newsys=handles.screenParameters.coordinateSystem;

    s=handles.Toolbox(tb).Input.layers;

    fn=fieldnames(s);
    nf=length(fn);

    npol=0;

    np=0;
    pnts=[];
    for i=1:nf
        n=length(s.(fn{i}));
        for j=1:n
            if isfield(s.(fn{i})(j),'Type')
                if ~isempty(lower(s.(fn{i})(j).Type))
                    switch(lower(s.(fn{i})(j).Type))
                        case{'multipoint'}
                            pnts=[pnts;s.(fn{i})(j).Coordinates];
                    end
                end
            end
        end
    end

    x=pnts(:,1);
    y=pnts(:,2);
    z=pnts(:,3);
    
    [x,y]=ddb_coordConvert(x,y,orisys,newsys);

    fid=fopen(filename,'wt');
    for j=1:size(pnts,1)
        fprintf(fid,'%16.8e %16.8e %16.8e\n',x(j),y(j),z(j));
    end
    fclose(fid);

    close(wb);

end
