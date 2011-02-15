function handles=ddb_Delft3DFLOW_plotAttributes(handles,opt,att,varargin)
% Plots, deletes, activates and deactivates Delft3D-FLOW dry points.
% Options are:
% plot
% delete
% update
%
% Optional input arguments:
% 'domain'  - domain nr 
% 'visible' - 1 or 0
% 'active' - 1 or 0

% Default values
iad=ad;
vis=1;
act=1;

% model number imd
imd=strmatch('Delft3DFLOW',{handles.Model(:).Name},'exact');

% Read input arguments
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

switch lower(att)
    case{'observationpoints'}
        tag='observationpoint';
        attStruc=handles.Model(imd).Input(iad).ObservationPoints;
        nr=handles.Model(imd).Input(iad).NrObservationPoints;
        iac=handles.Model(imd).Input(iad).activeObservationPoint;
        colpas='c';
        colact='r';
        tp='line';
    case{'crosssections'}
        tag='crosssection';
        attStruc=handles.Model(imd).Input(iad).CrossSections;
        nr=handles.Model(imd).Input(iad).NrCrossSections;
        iac=handles.Model(imd).Input(iad).activeCrossSection;
        colpas='c';
        colact='r';
        tp='line';
    case{'drypoints'}
        tag='drypoint';
        attStruc=handles.Model(imd).Input(iad).DryPoints;
        nr=handles.Model(imd).Input(iad).nrDryPoints;
        iac=handles.Model(imd).Input(iad).activeDryPoint;
        colpas=[0.85 0.85 0.50];
        colact='r';
        tp='patch';
    case{'openboundaries'}
        tag='openboundary';
        attStruc=handles.Model(imd).Input(iad).OpenBoundaries;
        nr=handles.Model(imd).Input(iad).NrOpenBoundaries;
        iac=handles.Model(imd).Input(iad).activeOpenBoundary;
        colpas='b';
        colact='r';
        tp='line';
    case{'thindams'}
        tag='thindam';
        attStruc=handles.Model(imd).Input(iad).ThinDams;
        nr=handles.Model(imd).Input(iad).nrThinDams;
        iac=handles.Model(imd).Input(iad).activeThinDam;
        colpas=[0.85 0.85 0.50];
        colact='r';
        tp='line';
    case{'discharges'}
        tag='discharge';
        attStruc=handles.Model(imd).Input(iad).Discharges;
        nr=handles.Model(imd).Input(iad).NrDischarges;
        iac=handles.Model(imd).Input(iad).activeDischarge;
        colpas=[1 0 1];
        colact='r';
        tp='line';
    case{'drogues'}
        tag='drogue';
        attStruc=handles.Model(imd).Input(iad).Drogues;
        nr=handles.Model(imd).Input(iad).NrDrogues;
        iac=handles.Model(imd).Input(iad).activeDrogue;
        colpas='g';
        colact='r';
        tp='line';
end

% Put all plot and text handles in one vector
if isfield(attStruc,'plotHandles')
    allPlotHandles=struc2mat(attStruc,'plotHandles');
else
    allPlotHandles=[];
end
if isfield(attStruc,'textHandles')
    allTextHandles=struc2mat(attStruc,'textHandles');
else
    allTextHandles=[];
end

switch lower(opt)
    case{'plot'}

        % First delete existing objects
        if ~isempty(allPlotHandles)
            delete(allPlotHandles);
            drawnow;
            for i=1:nr
                attStruc(i).plotHandles=[];
            end
        end
        if ~isempty(allTextHandles)
            delete(allTextHandles);
            drawnow;
            for i=1:nr
                attStruc(i).plotHandles=[];
            end
        end
        
        if nr>0
            % Now plot new objects
            for i=1:nr
                [x,y,txt,xtxt,ytxt]=getXY(handles,att,imd,iad,i);
                c=colpas;
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
                        set(plt,'UserData',i);
                        attStruc(i).plotHandles(j)=plt;
                    end
                    if ~isempty(txt)
                        tx=text(xtxt,ytxt,6500,txt);
                        set(tx,'Tag',tag,'Clipping','on','HitTest','off');
                        set(tx,'UserData',i);
                        attStruc(i).textHandles=tx;
                        set(tx,'HitTest','off');
                    else
                        attStruc(i).textHandles=[];
                    end
                    
                    % Set active color
                    if i==iac && act
                        set(attStruc(i).plotHandles,'Color',colact);
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
                    set(plt,'UserData',i);
                    attStruc(i).plotHandles=plt;
                    attStruc(i).textHandles=[];

                    % Set active color
                    if i==iac && act
                        set(attStruc(i).plotHandles,'FaceColor',colact);
                    end
                    
                end
                
                % Set hittest on or off
                if act
                    set(attStruc(i).plotHandles,'HitTest','on');
                else
                    set(attStruc(i).plotHandles,'HitTest','off');
                end
    
                % Set visibility
                if vis
                    set(attStruc(i).plotHandles,'Visible','on');
                    if act
                        set(attStruc(i).textHandles,'Visible','on');
                    else
                        set(attStruc(i).textHandles,'Visible','off');
                    end
                else
                    set(attStruc(i).plotHandles,'Visible','off');
                    set(attStruc(i).plotHandles,'Visible','off');
                end
                
%                drawnow;

            end

        end
        
    case{'delete'}

        if ~isempty(allPlotHandles)
            delete(allPlotHandles);
%            drawnow;
        end

        if ~isempty(allTextHandles)
            delete(allTextHandles);
%            drawnow;
        end
        for i=1:nr
            attStruc(i).plotHandles=[];
            attStruc(i).textHandles=[];
        end
        
    case{'update'}
        
        % Set colors
        if ~isempty(allPlotHandles)
            if strcmpi(tp,'line')
                set(allPlotHandles,'Color',colpas);
                if act
                    set(attStruc(iac).plotHandles,'Color',colact);
                end
            else
                set(allPlotHandles,'FaceColor',colpas);
                if act
                    set(attStruc(iac).plotHandles,'FaceColor',colact);
                end
            end
        end
        
        if ~isempty(allPlotHandles)
            % Set hittest
            if act
                set(allPlotHandles,'HitTest','on');
            else
                set(allPlotHandles,'HitTest','off');
            end
            % Set visibility plot handles
            if vis
                set(allPlotHandles,'Visible','on');
            else
                set(allPlotHandles,'Visible','off');
            end
        end

        if ~isempty(allTextHandles)
            % Set visibility text handles
            if vis
                if act
                    set(allTextHandles,'Visible','on');
                else
                    set(allTextHandles,'Visible','off');
                end
            else
                set(allTextHandles,'Visible','off');
            end
        end
%        drawnow;
       
end

switch lower(att)
    case{'observationpoints'}
        handles.Model(imd).Input(iad).ObservationPoints=attStruc;
    case{'crosssections'}
        handles.Model(imd).Input(iad).CrossSections=attStruc;
    case{'drypoints'}
        handles.Model(imd).Input(iad).DryPoints=attStruc;
    case{'openboundaries'}
        handles.Model(imd).Input(iad).OpenBoundaries=attStruc;
    case{'thindams'}
        handles.Model(imd).Input(iad).ThinDams=attStruc;
    case{'discharges'}
        handles.Model(imd).Input(iad).Discharges=attStruc;
    case{'drogues'}
        handles.Model(imd).Input(iad).Drogues=attStruc;
end



%%
function [x,y,txt,xtxt,ytxt]=getXY(handles,att,imd,id,i)

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

