function ddb_plotChartLayers(handles)

s=handles.Toolbox(tb).Layers;
p=handles.Toolbox(tb).PlotLayer;

orisys.Name='WGS 84';
orisys.Type='geographic';
newsys=handles.ScreenParameters.CoordinateSystem;

h=findobj(gcf,'Tag','NavigationChartLayer');
if ~isempty(h)
    delete(h);
end

fn=fieldnames(s);
nf=length(fn);

for i=1:nf
    n=length(s.(fn{i}));
    iplot=p.(fn{i});
    if iplot>-1
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
                                x(isnan(y))=NaN;
                                y(isnan(x))=NaN;
                                [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                                ptch=patch(x,y,'y');hold on;
                                set(ptch,'Tag','NavigationChartLayer','UserData',fn{i});
                            end
                            if isfield(s.(fn{i})(j),'Inner')
                                np=length(s.(fn{i})(j).Inner);
                                for k=1:np
                                    x=s.(fn{i})(j).Inner(k).Coordinates(:,1);
                                    y=s.(fn{i})(j).Inner(k).Coordinates(:,2);
                                end
                                x(isnan(y))=NaN;
                                y(isnan(x))=NaN;
                                [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                                ptch=patch(x,y,'y');hold on;
                                set(ptch,'Tag','NavigationChartLayer','UserData',fn{i});
                            end
                            if iplot
                                set(ptch,'Visible','on');
                            else
                                set(ptch,'Visible','off');
                            end
                        case{'point'}
                            x=s.(fn{i})(j).Coordinates(:,1);
                            y=s.(fn{i})(j).Coordinates(:,2);
                            [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                            plt=plot(x,y,'.');hold on;
                            set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','k');
                            set(plt,'Tag','NavigationChartLayer','UserData',fn{i});
                            if iplot
                                set(plt,'Visible','on');
                            else
                                set(plt,'Visible','off');
                            end
                        case{'polyline'}
                            x=s.(fn{i})(j).Coordinates(:,1);
                            y=s.(fn{i})(j).Coordinates(:,2);
                            [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                            plt=plot(x,y,'k');hold on;
                            set(plt,'Tag','NavigationChartLayer','UserData',fn{i});
                            if iplot
                                set(plt,'Visible','on');
                            else
                                set(plt,'Visible','off');
                            end
                        case{'multipoint'}
                            x=s.(fn{i})(j).Coordinates(:,1);
                            y=s.(fn{i})(j).Coordinates(:,2);
                            [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                            sz=zeros(size(x))+5;
                            c=-s.(fn{i})(j).Coordinates(:,3);
                            sc=scatter(x,y,sz,c,'filled');hold on;
                            set(sc,'Tag','NavigationChartLayer','UserData',fn{i});
                            if iplot
                                set(sc,'Visible','on');
                            else
                                set(sc,'Visible','off');
                            end
                    end
                end
                %                 if isfield(s.(fn{i})(j),'OBJNAM')
                %                     name=['  ' s.(fn{i})(j).OBJNAM];
                %                     if ~isempty(name)
                %                         xt=mean(x);
                %                         yt=mean(y);
                %                         tx=text(xt,yt,name);
                %                         set(tx,'FontSize',6);
                %                         set(tx,'Tag','NavigationChartLayer','UserData',fn{i});
                %                         if s.(fn{i})(j).Plot
                %                             set(tx,'Visible','on');
                %                         else
                %                             set(tx,'Visible','off');
                %                         end
                %                     end
                %                 end
            end
        end
    end
end

