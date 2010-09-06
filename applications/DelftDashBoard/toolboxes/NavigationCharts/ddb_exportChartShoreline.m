function ddb_exportChartShoreline(handles)

iac=handles.Toolbox(tb).ActiveDatabase;
ii=handles.Toolbox(tb).ActiveChart;
fname=handles.Toolbox(tb).Charts(iac).Box(ii).Name;

[filename, pathname, filterindex] = uiputfile('*.ldb', 'Select Ldb File',[fname '.ldb']);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end

    wb=waitbox('Exporting Ldb File ...');

    orisys.Name='WGS 84';
    orisys.Type='geographic';

    newsys=handles.ScreenParameters.CoordinateSystem;

    s=handles.Toolbox(tb).Layers;

    fn=fieldnames(s);
    nf=length(fn);

    npol=0;

    for i=1:nf
        n=length(s.(fn{i}));
        for j=1:n
            if isfield(s.(fn{i})(j),'Type')
                if ~isempty(lower(s.(fn{i})(j).Type))
                    switch(lower(s.(fn{i})(j).Type))
                        case{'polygon'}
                            if isfield(s.(fn{i})(j),'Outer')
                                np=length(s.(fn{i})(j).Outer);
                                for k=1:np
                                    x=s.(fn{i})(j).Outer(k).Coordinates(:,1);
                                    y=s.(fn{i})(j).Outer(k).Coordinates(:,2);
                                end
                                switch(fn{i})
                                    case{'LNDARE'}
                                        x(isnan(y))=NaN;
                                        y(isnan(x))=NaN;
                                        [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                                        npol=npol+1;
                                        xpol{npol}=x;
                                        ypol{npol}=y;
                                end
                            end
                            if isfield(s.(fn{i})(j),'Inner')
                                np=length(s.(fn{i})(j).Inner);
                                for k=1:np
                                    x=s.(fn{i})(j).Inner(k).Coordinates(:,1);
                                    y=s.(fn{i})(j).Inner(k).Coordinates(:,2);
                                end
                                switch(fn{i})
                                    case{'LNDARE'}
                                        x(isnan(y))=NaN;
                                        y(isnan(x))=NaN;
                                        [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                                        npol=npol+1;
                                        xpol{npol}=x;
                                        ypol{npol}=y;
                                end
                            end
                            %                     case{'point'}
                            %                         x=s.(fn{i})(j).Coordinates(:,1);
                            %                         y=s.(fn{i})(j).Coordinates(:,2);
                            %                         plt=plot(x,y,'.');hold on;
                            %                         set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','k');
                            %                         set(plt,'Tag','NavigationChartLayer','UserData',fn{i});
                            %                         if s.(fn{i})(j).Plot
                            %                             set(plt,'Visible','on');
                            %                         else
                            %                             set(plt,'Visible','off');
                            %                         end
                            %                     case{'polyline'}
                            %                         x=s.(fn{i})(j).Coordinates(:,1);
                            %                         y=s.(fn{i})(j).Coordinates(:,2);
                            %                         plt=plot(x,y,'k');hold on;
                            %                         set(plt,'Tag','NavigationChartLayer','UserData',fn{i});
                            %                         if s.(fn{i})(j).Plot
                            %                             set(plt,'Visible','on');
                            %                         else
                            %                             set(plt,'Visible','off');
                            %                         end
                            %                     case{'multipoint'}
                            %                         x=s.(fn{i})(j).Coordinates(:,1);
                            %                         y=s.(fn{i})(j).Coordinates(:,2);
                            %                         sz=zeros(size(x))+5;
                            %                         c=-s.(fn{i})(j).Coordinates(:,3);
                            %                         sc=scatter(x,y,sz,c,'filled');hold on;
                            %                         set(sc,'Tag','NavigationChartLayer','UserData',fn{i});
                            %                         if s.(fn{i})(j).Plot
                            %                             set(sc,'Visible','on');
                            %                         else
                            %                             set(sc,'Visible','off');
                            %                         end
                    end
                end
            end
        end
    end

    fid=fopen(filename,'wt');
    for j=1:npol
        xpol{j}(isnan(xpol{j}))=-999.0;
        ypol{j}(isnan(ypol{j}))=-999.0;
        np=length(xpol{j});
        fprintf(fid,'%s\n',['BL' num2str(j,'%0.5i')]);
        fprintf(fid,'%s\n',[num2str(np) ' ' num2str(2)]);
        for k=1:np
            fprintf(fid,'%16.8e %16.8e\n',xpol{j}(k),ypol{j}(k));
        end
    end
    fclose(fid);

    close(wb);

end
