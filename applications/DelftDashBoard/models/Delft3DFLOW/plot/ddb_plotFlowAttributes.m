function ddb_plotFlowAttributes(handles,att,opt,id,varargin)

imd=strmatch('Delft3DFLOW',{handles.Model(:).name},'exact');

if ~isempty(varargin)
    ia=varargin{1};
    iac=varargin{2};
else
    ia=0;
    iac=0;
end

switch lower(att)
    case{'observationpoints'}
        tag='ObservationPoint';
        nr=handles.Model(imd).Input(id).NrObservationPoints;
        col='c';
        colact='r';
        tp='line';
    case{'crosssections'}
        tag='CrossSection';
        nr=handles.Model(imd).Input(id).NrCrossSections;
        col='c';
        colact='r';
        tp='line';
    case{'drypoints'}
        tag='DryPoint';
        nr=handles.Model(imd).Input(id).NrDryPoints;
        col=[0.85 0.85 0.50];
        colact='r';
        tp='patch';
    case{'openboundaries'}
        tag='OpenBoundary';
        nr=handles.Model(imd).Input(id).nrOpenBoundaries;
        col='b';
        colact='r';
        tp='line';
    case{'thindams'}
        tag='ThinDam';
        nr=handles.Model(imd).Input(id).NrThinDams;
        col=[0.85 0.85 0.50];
        colact='r';
        tp='line';
    case{'discharges'}
        tag='Discharge';
        nr=handles.Model(imd).Input(id).NrDischarges;
        col=[1 0 1];
        colact='r';
        tp='line';
    case{'drogues'}
        tag='Drogue';
        nr=handles.Model(imd).Input(id).NrDrogues;
        col='g';
        colact='r';
        tp='line';
end

if strcmpi(tp,'line')
    coltp='Color';
else
    coltp='FaceColor';
end

hp=findobj(gca,'Tag',tag);
ht=findobj(gca,'Tag',[tag 'Text']);
if ~isempty(hp)
     set(hp,coltp,col);
end

switch lower(opt)
    case{'plot'}
        if ia==0
            % Plot all
            n1=1;
            n2=nr;
            % First Delete Objects
            for j=1:length(hp)
                usd=get(hp(j),'UserData');
                if usd(1)==id
                    delete(hp(j));
                end
            end
            for j=1:length(ht)
                usd=get(ht(j),'UserData');
                if usd(1)==id
                    delete(ht(j));
                end
            end            
        else
            % Just one
            n1=ia;
            n2=ia;
            % First Delete Objects
            ha=findobj(gca,'Tag',tag,'UserData',[id ia]);
            delete(ha);
            ha=findobj(gca,'Tag',[tag 'Text'],'UserData',[id ia]);
            delete(ha);
        end
        for i=n1:n2
            [x,y,txt,xtxt,ytxt]=GetXY(handles,att,imd,id,i);
            if i==iac
                c=colact;
            else
                c=col;
            end
            if strcmpi(tp,'line')
                % Line
                for j=1:length(x)
                    x1=x{j};
                    y1=y{j};
                    z=zeros(size(x1))+6000;
                    plt=plot3(x1,y1,z);hold on;
                    set(plt,'Color',c);
                    set(plt,'LineWidth',2);
                    set(plt,'Tag',tag);
                    set(plt,'UserData',[id i]);
                end
                if ~isempty(txt) && iac>0
                    tx=text(xtxt,ytxt,6500,txt);
                    set(tx,'Tag',[tag 'Text'],'Clipping','on','HitTest','off');
                    set(tx,'UserData',[id i]);
                end
            else
                % Patch
                x1=x{1};
                y1=y{1};
                z=zeros(size(x1))+6000;
                plt=patch(x1,y1,z);hold on;
                set(plt,'FaceColor',c);
                set(plt,'EdgeColor','none');
                set(plt,'Tag',tag);
                set(plt,'UserData',[id i]);
            end
        end
    case{'delete'}
        if ia==0
            % Delete all
            for j=1:length(hp)
                usd=get(hp(j),'UserData');
                if usd(1)==id
                    delete(hp(j));
                end
            end
            for j=1:length(ht)
                usd=get(ht(j),'UserData');
                if usd(1)==id
                    delete(ht(j));
                end
            end            
        else
            % Delete ia
            hp1=findobj(gca,'Tag',tag,'UserData',[id ia]);
            ht1=findobj(gca,'Tag',[tag 'Text'],'UserData',[id ia]);
            delete(hp1);
            delete(ht1);
            % Re-order objects
            for i=ia+1:nr
                h1=findobj(gca,'Tag',tag,'UserData',[id i]);
                h2=findobj(gca,'Tag',[tag 'Text'],'UserData',[id i]);
                if ~isempty(h1)
                    set(h1,'UserData',[id i-1]);
                end
                if ~isempty(h2)
                    set(h2,'UserData',[id i-1]);
                end
            end
            % Set new active object
            h1=findobj(gca,'Tag',tag,'UserData',[id iac]);
            if ~isempty(h1)
                set(h1,coltp,colact);
            end
        end
    case{'activate'}
        for j=1:length(hp)
            usd=get(hp(j),'UserData');
            if usd(1)==id
                set(hp(j),'Visible','on','HitTest','on');
            end
        end
        if iac>0
            ha=findobj(hp,'UserData',[id iac]);
            if ~isempty(ha)
                set(ha,coltp,colact);
            end
            for j=1:length(ht)
                usd=get(ht(j),'UserData');
                if usd(1)==id
                    set(ht(j),'Visible','on');
                end
            end
        end
    case{'deactivate'}
        for j=1:length(hp)
            usd=get(hp(j),'UserData');
            if usd(1)==id
                set(hp(j),'Visible','off');
            end
        end
        for j=1:length(ht)
            usd=get(ht(j),'UserData');
            if usd(1)==id
                set(ht(j),'Visible','off');
            end
        end
    case{'deactivatebutkeepvisible'}
        for j=1:length(hp)
            usd=get(hp(j),'UserData');
            if usd(1)==id
                set(hp(j),'Visible','on','HitTest','off');
            end
        end
        for j=1:length(ht)
            usd=get(ht(j),'UserData');
            if usd(1)==id
                set(ht(j),'Visible','off');
            end
        end
end

%%
function [x,y,txt,xtxt,ytxt]=GetXY(handles,att,imd,id,i)

xg=handles.Model(imd).Input(id).GridX;
yg=handles.Model(imd).Input(id).GridY;

switch lower(att)
    case{'observationpoints'}
        txt=handles.Model(imd).Input(id).ObservationPoints(i).Name;
        m=handles.Model(imd).Input(id).ObservationPoints(i).M;
        n=handles.Model(imd).Input(id).ObservationPoints(i).N;
        x{1}=[xg(m-1,n-1) xg(m,n)];
        y{1}=[yg(m-1,n-1) yg(m,n)];
        x{2}=[xg(m,n-1) xg(m-1,n)];
        y{2}=[yg(m,n-1) yg(m-1,n)];
    case{'drypoints'}
        txt='';
        m1=min(handles.Model(imd).Input(id).DryPoints(i).M1,handles.Model(imd).Input(id).DryPoints(i).M2);
        n1=min(handles.Model(imd).Input(id).DryPoints(i).N1,handles.Model(imd).Input(id).DryPoints(i).N2);
        m2=max(handles.Model(imd).Input(id).DryPoints(i).M1,handles.Model(imd).Input(id).DryPoints(i).M2);
        n2=max(handles.Model(imd).Input(id).DryPoints(i).N1,handles.Model(imd).Input(id).DryPoints(i).N2);
        x1=xg(m1-1:m2,n1-1)';
        y1=yg(m1-1:m2,n1-1)';
        x1=[x1 xg(m2,n1-1:n2)];
        y1=[y1 yg(m2,n1-1:n2)];
        x1=[x1 xg(m2:-1:m1-1,n2)'];
        y1=[y1 yg(m2:-1:m1-1,n2)'];
        x1=[x1 xg(m1-1,n2:-1:n1-1)];
        y1=[y1 yg(m1-1,n2:-1:n1-1)];
        x{1}=x1;
        y{1}=y1;
    case{'openboundaries'}
        txt=handles.Model(imd).Input(id).OpenBoundaries(i).Name;
        x{1}=handles.Model(imd).Input(id).OpenBoundaries(i).X;
        y{1}=handles.Model(imd).Input(id).OpenBoundaries(i).Y;
    case{'thindams'}
        txt='';
        m1=min(handles.Model(imd).Input(id).ThinDams(i).M1,handles.Model(imd).Input(id).ThinDams(i).M2);
        n1=min(handles.Model(imd).Input(id).ThinDams(i).N1,handles.Model(imd).Input(id).ThinDams(i).N2);
        m2=max(handles.Model(imd).Input(id).ThinDams(i).M1,handles.Model(imd).Input(id).ThinDams(i).M2);
        n2=max(handles.Model(imd).Input(id).ThinDams(i).N1,handles.Model(imd).Input(id).ThinDams(i).N2);
        k=0;
        for jj=m1:m2
            for kk=n1:n2
                k=k+1;
                m=jj;
                n=kk;
                if strcmpi(handles.Model(imd).Input(id).ThinDams(i).UV,'u')
                    x{k}=[xg(m,n-1) xg(m,n)];
                    y{k}=[yg(m,n-1) yg(m,n)];
                else
                    x{k}=[xg(m-1,n) xg(m,n)];
                    y{k}=[yg(m-1,n) yg(m,n)];
                end
            end
        end
    case{'crosssections'}
        txt=handles.Model(imd).Input(id).CrossSections(i).Name;
        m1=min(handles.Model(imd).Input(id).CrossSections(i).M1,handles.Model(imd).Input(id).CrossSections(i).M2);
        n1=min(handles.Model(imd).Input(id).CrossSections(i).N1,handles.Model(imd).Input(id).CrossSections(i).N2);
        m2=max(handles.Model(imd).Input(id).CrossSections(i).M1,handles.Model(imd).Input(id).CrossSections(i).M2);
        n2=max(handles.Model(imd).Input(id).CrossSections(i).N1,handles.Model(imd).Input(id).CrossSections(i).N2);
        k=0;
        for jj=m1:m2
            for kk=n1:n2
                k=k+1;
                m=jj;
                n=kk;
                if m2>m1
                    x{k}=[xg(m-1,n) xg(m,n)];
                    y{k}=[yg(m-1,n) yg(m,n)];
                else
                    x{k}=[xg(m,n-1) xg(m,n)];
                    y{k}=[yg(m,n-1) yg(m,n)];
                end
            end
        end
    case{'discharges'}
        txt=handles.Model(imd).Input(id).Discharges(i).Name;
        m=handles.Model(imd).Input(id).Discharges(i).M;
        n=handles.Model(imd).Input(id).Discharges(i).N;
        x{1}(1)=0.5*(xg(m-1,n-1)+xg(m  ,n-1));
        y{1}(1)=0.5*(yg(m-1,n-1)+yg(m  ,n-1));
        x{1}(2)=0.5*(xg(m  ,n-1)+xg(m  ,n  ));
        y{1}(2)=0.5*(yg(m  ,n-1)+yg(m  ,n  ));
        x{1}(3)=0.5*(xg(m  ,n  )+xg(m-1,n  ));
        y{1}(3)=0.5*(yg(m  ,n  )+yg(m-1,n  ));
        x{1}(4)=0.5*(xg(m-1,n  )+xg(m-1,n-1));
        y{1}(4)=0.5*(yg(m-1,n  )+yg(m-1,n-1));
        x{1}(5)=x{1}(1);
        y{1}(5)=y{1}(1);
    case{'drogues'}
        txt=handles.Model(imd).Input(id).Drogues(i).Name;
        m=ceil(handles.Model(imd).Input(id).Drogues(i).M);
        n=ceil(handles.Model(imd).Input(id).Drogues(i).N);
        x{1}(1)=0.5*(xg(m-1,n-1)+xg(m  ,n-1));
        y{1}(1)=0.5*(yg(m-1,n-1)+yg(m  ,n-1));
        x{1}(2)=0.5*(xg(m  ,n  )+xg(m-1,n  ));
        y{1}(2)=0.5*(yg(m  ,n  )+yg(m-1,n  ));
        x{2}(1)=0.5*(xg(m-1,n  )+xg(m-1,n-1));
        y{2}(1)=0.5*(yg(m-1,n  )+yg(m-1,n-1));
        x{2}(2)=0.5*(xg(m  ,n-1)+xg(m  ,n  ));
        y{2}(2)=0.5*(yg(m  ,n-1)+yg(m  ,n  ));
end

xtxt=0.5*(x{1}(1)+x{end}(end));
ytxt=0.5*(y{1}(1)+y{end}(end));

