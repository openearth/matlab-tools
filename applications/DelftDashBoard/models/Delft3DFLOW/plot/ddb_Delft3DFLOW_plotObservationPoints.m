function handles=ddb_Delft3DFLOW_plotObsPoints(handles,opt,varargin)

% options:
% plot
% delete
% update

iad=ad;
vis=1;
id=0;
act=1;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch(lower(varargin{i}))
            case{'visible'}
                vis=varargin{i+1};
            case{'active'}
                act=varargin{i+1};
            case{'domain'}
                iad=varargin{i+1};
        end
    end
end


% model number imd
imd=strmatch('Delft3DFLOW',{handles.Model(:).Name},'exact');

tag='Obspoint';
colpas='c';
colact=[1 0 0];

% Put all plot handles in one vector
if isfield(handles.Model(imd).Input(iad).obsPoints,'plotHandles')
    allHandles=struc2mat(handles.Model(imd).Input(iad).obsPoints,'plotHandles');
else
    allHandles=[];
end

switch lower(opt)
    case{'plot'}
        % First delete existing objects
        if ~isempty(allHandles)
            delete(allHandles);
            for i=1:handles.Model(imd).Input(iad).nrObsPoints
                handles.Model(imd).Input(iad).obsPoints(i).plotHandles=[];
            end
        end
        % Now plot new objects
        for i=1:handles.Model(imd).Input(iad).nrObsPoints
            txt=handles.Model(imd).Input(id).obsPoints(i).Name;
            m=handles.Model(imd).Input(id).obsPoints(i).M;
            n=handles.Model(imd).Input(id).obsPoints(i).N;
            x{1}=[xg(m-1,n-1) xg(m,n)];
            y{1}=[yg(m-1,n-1) yg(m,n)];
            x{2}=[xg(m,n-1) xg(m-1,n)];
            y{2}=[yg(m,n-1) yg(m-1,n)];
            z=zeros(size(x1))+6000;
            for j=1:length(x)
                x1=x{j};
                y1=y{j};
                z=zeros(size(x1))+6000;
                plt(j)=plot3(x1,y1,z);hold on;
                set(plt(j),'Color',c);
                set(plt(j),'LineWidth',2);
                set(plt(j),'Tag',tag);
                set(plt(j),'UserData',i);
            end
            if ~isempty(txt)
                plt(3)=text(xtxt,ytxt,6500,txt);
                set(plt(3),'Tag',[tag 'Text'],'Clipping','on','HitTest','off');
                set(plt(3),'UserData',i);
            end
            handles.Model(imd).Input(iad).obsPoints(i).plotHandles=plt;
        end
        iac=handles.Model(imd).Input(iad).activeObsPoint;
        if act
            set(allHandles,'HitTest','on');
            set(handles.Model(imd).Input(iad).obsPoints(iac).plotHandles(1:2),'Color',colact);
        end
    case{'delete'}
        if ~isempty(allHandles)
            delete(allHandles);
        end
        for i=1:handles.Model(imd).Input(iad).nrObsPoints
            handles.Model(imd).Input(iad).obsPoints(i).plotHandles=[];
        end
    case{'update'}
        for i=1:handles.Model(imd).Input(iad).nrObsPoints
            set(handles.Model(imd).Input(iad).obsPoints(i).plotHandles(1:2),'Color',colpas);
            if act
                set(handles.Model(imd).Input(iad).obsPoints(i).plotHandles(3),'Visible',1);
            else
                set(handles.Model(imd).Input(iad).obsPoints(i).plotHandles(3),'Visible',0);
            end
        end
        if act
            iac=handles.Model(imd).Input(iad).activeObsPoint;
            set(handles.Model(imd).Input(iad).obsPoints(iac).plotHandles(1:2),'Color',colact);
        end
        if vis
            set(allHandles,'Visible','on');
        else
            set(allHandles,'Visible','off');
        end

end

%%
function [x,y,txt,xtxt,ytxt]=GetXY(handles,att,imd,id,i)

xg=handles.Model(imd).Input(id).GridX;
yg=handles.Model(imd).Input(id).GridY;

switch lower(att)
    case{'obsPoints'}
        txt=handles.Model(imd).Input(id).obsPoints(i).Name;
        m=handles.Model(imd).Input(id).obsPoints(i).M;
        n=handles.Model(imd).Input(id).obsPoints(i).N;
        x{1}=[xg(m-1,n-1) xg(m,n)];
        y{1}=[yg(m-1,n-1) yg(m,n)];
        x{2}=[xg(m,n-1) xg(m-1,n)];
        y{2}=[yg(m,n-1) yg(m-1,n)];
    case{'obsPoints'}
        txt='';
        m1=min(handles.Model(imd).Input(id).obsPoints(i).M1,handles.Model(imd).Input(id).obsPoints(i).M2);
        n1=min(handles.Model(imd).Input(id).obsPoints(i).N1,handles.Model(imd).Input(id).obsPoints(i).N2);
        m2=max(handles.Model(imd).Input(id).obsPoints(i).M1,handles.Model(imd).Input(id).obsPoints(i).M2);
        n2=max(handles.Model(imd).Input(id).obsPoints(i).N1,handles.Model(imd).Input(id).obsPoints(i).N2);
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


%%
function m=struc2mat(s,field)
m=[];
k=0;
try
    if isfield(s,field)
        for i=1:length(s)
            v=s(i).(field);
            for j=1:length(v)
                k=k+1;
                m(k)=s(i).(field)(j);
            end
        end
    end
end

