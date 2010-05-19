function ddb_plotS57(fname)

load(fname);

fn=fieldnames(s.Layers);
nf=length(fn);

for i=1:nf
    n=length(s.Layers.(fn{i}));
    for j=1:n
        if isfield(s.Layers.(fn{i})(j),'Type')
            if ~isempty(lower(s.Layers.(fn{i})(j).Type))
                switch(lower(s.Layers.(fn{i})(j).Type))
                    case{'polygon'}
                        if isfield(s.Layers.(fn{i})(j),'Outer')
                            np=length(s.Layers.(fn{i})(j).Outer);
                            for k=1:np
                                x=s.Layers.(fn{i})(j).Outer(k).Coordinates(:,1);
                                y=s.Layers.(fn{i})(j).Outer(k).Coordinates(:,2);
                            end
                            switch(fn{i})
                                case{'LNDARE'}
                                    x(isnan(y))=NaN;
                                    y(isnan(x))=NaN;
                                    ptch=patch(x,y,'y');hold on;
%                                     set(ptch,'EdgeColor','none','FaceColor',[0.7 0.8 0.7]);
%                                 case{'SEAARE'}
%                                     x(isnan(y))=NaN;
%                                     y(isnan(x))=NaN;
%                                     ptch=patch(x,y,'y');hold on;
%                                     set(ptch,'EdgeColor','none','FaceColor',[0.9 0.9 0.95]);
%                                 otherwise
%                                     plot(x,y,'k');hold on;
                            end
                        end
                        if isfield(s.Layers.(fn{i})(j),'Inner')
                            np=length(s.Layers.(fn{i})(j).Inner);
                            for k=1:np
                                x=s.Layers.(fn{i})(j).Inner(k).Coordinates(:,1);
                                y=s.Layers.(fn{i})(j).Inner(k).Coordinates(:,2);
                            end
                            switch(fn{i})
                                case{'LNDARE'}
                                    x(isnan(y))=NaN;
                                    y(isnan(x))=NaN;
                                    ptch=patch(x,y,'y');hold on;
%                                     set(ptch,'EdgeColor','none','FaceColor',[0.7 0.8 0.7]);
%                                 case{'SEAARE'}
%                                     x(isnan(y))=NaN;
%                                     y(isnan(x))=NaN;
%                                     ptch=patch(x,y,'y');hold on;
%                                     set(ptch,'EdgeColor','none','FaceColor',[0.8 0.8 0.9]);
%                                 otherwise
%                                     plot(x,y,'k');hold on;
                            end
                        end
%                     case{'point'}
%                         x=s.Layers.(fn{i})(j).Coordinates(:,1);
%                         y=s.Layers.(fn{i})(j).Coordinates(:,2);
%                         plt=plot(x,y,'.');hold on;
%                         set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','k');
%                     case{'polyline'}
%                         x=s.Layers.(fn{i})(j).Coordinates(:,1);
%                         y=s.Layers.(fn{i})(j).Coordinates(:,2);
%                         plot(x,y,'k');hold on;
%                     case{'multipoint'}
%                         x=s.Layers.(fn{i})(j).Coordinates(:,1);
%                         y=s.Layers.(fn{i})(j).Coordinates(:,2);
%                         sz=zeros(size(x))+5;
%                         c=-s.Layers.(fn{i})(j).Coordinates(:,3);
%                         sc=scatter(x,y,sz,c,'filled');hold on;
%                         %                plot(x,y,'.');hold on;
                end
%                if isfield(s.Layers.(fn{i})(j),'OBJNAM')
%                    name=['  ' s.Layers.(fn{i})(j).OBJNAM];
%                    if ~isempty(name)
%                        xt=mean(x);
%                        yt=mean(y);
%                        tx=text(xt,yt,name);
%                        set(tx,'FontSize',6);
%                    end
%                end
            end
        end
    end
end
