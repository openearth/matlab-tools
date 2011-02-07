function handles=ddb_Delft3DFLOW_plotDryPoints(handles,opt,varargin)

%handles=getHandles;

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
            case{'nr'}
                id=varargin{i+1};
        end
    end
end


% model number imd
imd=strmatch('Delft3DFLOW',{handles.Model(:).Name},'exact');

tag='drypoint';
colpas=[0.85 0.85 0.50];
colact=[1 0 0];

allHandles=struc2mat(handles.Model(imd).Input(iad).DryPoints.plotHandles,'handles');

switch lower(opt)
    case{'plot'}
        % First delete existing objects
        % Put all handles
        allHandles=struc2mat(handles.Model(imd).Input(iad).DryPoints.plotHandles,'handles');
        if ~isempty(allHandles)
            delete(allHandles);
            handles.Model(imd).Input(iad).DryPoints.plotHandles=[];
        end
        % Now plot new objects
        for i=1:handles.Model(imd).Input(iad).nrDryPoints
            [x,y,txt,xtxt,ytxt]=GetXY(handles,'drypoints',imd,iad,i);
            x1=x{1};
            y1=y{1};
            z=zeros(size(x1))+6000;
            plt=patch(x1,y1,z);
            set(plt,'FaceColor',colpas);
            set(plt,'EdgeColor','none');
            set(plt,'Tag',tag);
            set(plt,'UserData',i);
            handles.Model(imd).Input(iad).DryPoints.plotHandles(i).handles=plt;
        end
        iac=handles.Model(imd).Input(iad).activeDryPoint;
        if act
            set(allHandles,'HitTest','on');
            set(handles.Model(imd).Input(iad).DryPoints.plotHandles(iac).handles,'FaceColor',colact);
        end
    case{'delete'}
        if ~isempty(allHandles)
            delete(allHandles);
        end
        handles.Model(imd).Input(iad).DryPoints.plotHandles=[];
    case{'update'}
        set(allHandles,'FaceColor',colpas);
        if act
            iac=handles.Model(imd).Input(iad).activeDryPoint;
            set(handles.Model(imd).Input(iad).DryPoints.plotHandles(iac).handles,'FaceColor',colact);
        else
            % Only for texts
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


%%
function m=struc2mat(s,field)
m=[];
k=0;
try
    if isfield(s,'field')
        for i=1:length(s)
            v=s(i).(field);
            for j=1:length(v)
                k=k+1;
                m(k)=s(i).(field)(j);
            end
        end
    end
end

