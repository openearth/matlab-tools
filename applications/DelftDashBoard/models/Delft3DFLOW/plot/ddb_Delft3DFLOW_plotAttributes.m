function handles = ddb_Delft3DFLOW_plotAttributes(handles, opt, att, varargin)
%DDB_DELFT3DFLOW_PLOTATTRIBUTES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_Delft3DFLOW_plotAttributes(handles, opt, att, varargin)
%
%   Input:
%   handles  =
%   opt      =
%   att      =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_Delft3DFLOW_plotAttributes
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Plots, deletes, activates and deactivates Delft3D-FLOW dry points.
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
imd=strmatch('Delft3DFLOW',{handles.Model(:).name},'exact');

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
        attStruc=handles.Model(imd).Input(iad).observationPoints;
        nr=handles.Model(imd).Input(iad).nrObservationPoints;
        iac=handles.Model(imd).Input(iad).activeObservationPoint(1);
        colpas='c';
        colact='r';
        tp='line';
    case{'crosssections'}
        tag='crosssection';
        attStruc=handles.Model(imd).Input(iad).crossSections;
        nr=handles.Model(imd).Input(iad).nrCrossSections;
        iac=handles.Model(imd).Input(iad).activeCrossSection(1);
        colpas='c';
        colact='r';
        tp='line';
    case{'drypoints'}
        tag='drypoint';
        attStruc=handles.Model(imd).Input(iad).dryPoints;
        nr=handles.Model(imd).Input(iad).nrDryPoints;
        iac=handles.Model(imd).Input(iad).activeDryPoint(1);
        colpas=[0.85 0.85 0.50];
        colact='r';
        tp='patch';
    case{'openboundaries'}
        tag='openboundary';
        attStruc=handles.Model(imd).Input(iad).openBoundaries;
        nr=handles.Model(imd).Input(iad).nrOpenBoundaries;
        iac=handles.Model(imd).Input(iad).activeOpenBoundary(1);
        colpas='b';
        colact='r';
        tp='line';
    case{'thindams'}
        tag='thindam';
        attStruc=handles.Model(imd).Input(iad).thinDams;
        nr=handles.Model(imd).Input(iad).nrThinDams;
        iac=handles.Model(imd).Input(iad).activeThinDam(1);
        colpas=[0.85 0.85 0.50];
        colact='r';
        tp='line';
    case{'weirs2d'}
        tag='weir2d';
        attStruc=handles.Model(imd).Input(iad).weirs2D;
        nr=handles.Model(imd).Input(iad).nrWeirs2D;
        iac=handles.Model(imd).Input(iad).activeWeir2D(1);
        colpas=[1 1 0];
        colact='r';
        tp='line';
    case{'discharges'}
        tag='discharge';
        attStruc=handles.Model(imd).Input(iad).discharges;
        nr=handles.Model(imd).Input(iad).nrDischarges;
        iac=handles.Model(imd).Input(iad).activeDischarge(1);
        colpas=[1 0 1];
        colact='r';
        tp='line';
    case{'drogues'}
        tag='drogue';
        attStruc=handles.Model(imd).Input(iad).drogues;
        nr=handles.Model(imd).Input(iad).nrDrogues;
        iac=handles.Model(imd).Input(iad).activeDrogue(1);
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
            for i=1:nr
                attStruc(i).plotHandles=[];
            end
        end
        if ~isempty(allTextHandles)
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
                
            end
            
        end
        
        % Now delete old objects
        if ~isempty(allPlotHandles)
            try
                delete(allPlotHandles);
            end
        end
        if ~isempty(allTextHandles)
            try
                delete(allTextHandles);
            end
        end
        
        
    case{'delete'}
        
        try
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
            hh=findobj(gcf,'Tag',tag);
            if ~isempty(hh)
                delete(hh);
            end
        end
        
    case{'update'}
        
        try
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
        end
end

switch lower(att)
    case{'observationpoints'}
        handles.Model(imd).Input(iad).observationPoints=attStruc;
    case{'crosssections'}
        handles.Model(imd).Input(iad).crossSections=attStruc;
    case{'drypoints'}
        handles.Model(imd).Input(iad).dryPoints=attStruc;
    case{'openboundaries'}
        handles.Model(imd).Input(iad).openBoundaries=attStruc;
    case{'thindams'}
        handles.Model(imd).Input(iad).thinDams=attStruc;
    case{'weirs2d'}
        handles.Model(imd).Input(iad).weirs2D=attStruc;
    case{'discharges'}
        handles.Model(imd).Input(iad).discharges=attStruc;
    case{'drogues'}
        handles.Model(imd).Input(iad).drogues=attStruc;
end



%%
function [x,y,txt,xtxt,ytxt]=getXY(handles,att,imd,id,i)

xg=handles.Model(imd).Input(id).gridX;
yg=handles.Model(imd).Input(id).gridY;

switch lower(att)
    case{'observationpoints'}
        txt=handles.Model(imd).Input(id).observationPoints(i).name;
        m=handles.Model(imd).Input(id).observationPoints(i).M;
        n=handles.Model(imd).Input(id).observationPoints(i).N;
        x{1}=[xg(m-1,n-1) xg(m,n)];
        y{1}=[yg(m-1,n-1) yg(m,n)];
        x{2}=[xg(m,n-1) xg(m-1,n)];
        y{2}=[yg(m,n-1) yg(m-1,n)];
    case{'drypoints'}
        txt='';
        m1=min(handles.Model(imd).Input(id).dryPoints(i).M1,handles.Model(imd).Input(id).dryPoints(i).M2);
        n1=min(handles.Model(imd).Input(id).dryPoints(i).N1,handles.Model(imd).Input(id).dryPoints(i).N2);
        m2=max(handles.Model(imd).Input(id).dryPoints(i).M1,handles.Model(imd).Input(id).dryPoints(i).M2);
        n2=max(handles.Model(imd).Input(id).dryPoints(i).N1,handles.Model(imd).Input(id).dryPoints(i).N2);
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
        txt=handles.Model(imd).Input(id).openBoundaries(i).name;
        x{1}=handles.Model(imd).Input(id).openBoundaries(i).x;
        y{1}=handles.Model(imd).Input(id).openBoundaries(i).y;
    case{'thindams'}
        txt='';
        m1=min(handles.Model(imd).Input(id).thinDams(i).M1,handles.Model(imd).Input(id).thinDams(i).M2);
        n1=min(handles.Model(imd).Input(id).thinDams(i).N1,handles.Model(imd).Input(id).thinDams(i).N2);
        m2=max(handles.Model(imd).Input(id).thinDams(i).M1,handles.Model(imd).Input(id).thinDams(i).M2);
        n2=max(handles.Model(imd).Input(id).thinDams(i).N1,handles.Model(imd).Input(id).thinDams(i).N2);
        k=0;
        for jj=m1:m2
            for kk=n1:n2
                k=k+1;
                m=jj;
                n=kk;
                if strcmpi(handles.Model(imd).Input(id).thinDams(i).UV,'u')
                    x{k}=[xg(m,n-1) xg(m,n)];
                    y{k}=[yg(m,n-1) yg(m,n)];
                else
                    x{k}=[xg(m-1,n) xg(m,n)];
                    y{k}=[yg(m-1,n) yg(m,n)];
                end
            end
        end
    case{'weirs2d'}
        txt='';
        m1=min(handles.Model(imd).Input(id).weirs2D(i).M1,handles.Model(imd).Input(id).weirs2D(i).M2);
        n1=min(handles.Model(imd).Input(id).weirs2D(i).N1,handles.Model(imd).Input(id).weirs2D(i).N2);
        m2=max(handles.Model(imd).Input(id).weirs2D(i).M1,handles.Model(imd).Input(id).weirs2D(i).M2);
        n2=max(handles.Model(imd).Input(id).weirs2D(i).N1,handles.Model(imd).Input(id).weirs2D(i).N2);
        k=0;
        for jj=m1:m2
            for kk=n1:n2
                k=k+1;
                m=jj;
                n=kk;
                if strcmpi(handles.Model(imd).Input(id).weirs2D(i).UV,'u')
                    x{k}=[xg(m,n-1) xg(m,n)];
                    y{k}=[yg(m,n-1) yg(m,n)];
                else
                    x{k}=[xg(m-1,n) xg(m,n)];
                    y{k}=[yg(m-1,n) yg(m,n)];
                end
            end
        end
    case{'crosssections'}
        txt=handles.Model(imd).Input(id).crossSections(i).name;
        m1=min(handles.Model(imd).Input(id).crossSections(i).M1,handles.Model(imd).Input(id).crossSections(i).M2);
        n1=min(handles.Model(imd).Input(id).crossSections(i).N1,handles.Model(imd).Input(id).crossSections(i).N2);
        m2=max(handles.Model(imd).Input(id).crossSections(i).M1,handles.Model(imd).Input(id).crossSections(i).M2);
        n2=max(handles.Model(imd).Input(id).crossSections(i).N1,handles.Model(imd).Input(id).crossSections(i).N2);
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
        txt=handles.Model(imd).Input(id).discharges(i).name;
        m=handles.Model(imd).Input(id).discharges(i).M;
        n=handles.Model(imd).Input(id).discharges(i).N;
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
        txt=handles.Model(imd).Input(id).drogues(i).name;
        m=ceil(handles.Model(imd).Input(id).drogues(i).M);
        n=ceil(handles.Model(imd).Input(id).drogues(i).N);
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


