function handles = ddb_generateBoundaryLocationsDelft3DFLOW(handles, id, filename)
%DDB_GENERATEBOUNDARYLOCATIONSDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateBoundaryLocationsDelft3DFLOW(handles, id, varargin)
%
%   Input:
%   handles  =
%   id       =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_generateBoundaryLocationsDelft3DFLOW
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

if ~isempty(handles.Model(md).Input(id).grdFile)
    if ~isempty(handles.Model(md).Input(id).depFile)

        % Clear existing boundaries
        handles.Model(md).Input(id).openBoundaries=[];
        handles.Model(md).Input(id).openBoundaries(1).name='';
        handles.Model(md).Input(id).openBoundaries(1).M1=[];
        handles.Model(md).Input(id).openBoundaries(1).M2=[];
        handles.Model(md).Input(id).openBoundaries(1).N1=[];
        handles.Model(md).Input(id).openBoundaries(1).N2=[];        
        handles.Model(md).Input(id).openBoundaries(1).alpha=0.0;
        handles.Model(md).Input(id).openBoundaries(1).compA='unnamed';
        handles.Model(md).Input(id).openBoundaries(1).compB='unnamed';
        handles.Model(md).Input(id).openBoundaries(1).type='Z';
        handles.Model(md).Input(id).openBoundaries(1).forcing='A';
        handles.Model(md).Input(id).openBoundaries(1).profile='Uniform';
        handles.Model(md).Input(id).openBoundaryNames={''};
        handles.Model(md).Input(id).nrOpenBoundaries=0;        
        handles.Model(md).Input(id).activeOpenBoundary=1;        
        handles.Model(md).Input(id).activeOpenBoundaries=1;        
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','openboundaries');
        
        d=handles.Toolbox(tb).Input.sectionLength;
        zmax=handles.Toolbox(tb).Input.zMax;
        
        attName=filename(1:end-4);
        
        handles.Model(md).Input(id).bndFile=[attName '.bnd'];
        
        x=handles.Model(md).Input(id).gridX;
        y=handles.Model(md).Input(id).gridY;
        z=handles.Model(md).Input(id).depth;
        
        mmax=size(x,1);
        nmax=size(x,2);
        
        % Boundary locations
        
        % North and South
        
        dir={'North','South'};
        
        n=[nmax 1];
        n2=[nmax+1 1];
        nb=0;
        
        for j=1:2
            
            nd=0;
            mstart=0;
            mend=0;
            m=2;
            while m<=mmax
                while m<=mmax
                    % Find start point
                    if ~isnan(x(m,n(j))) && ~isnan(x(m-1,n(j))) && ...
                            handles.Model(md).Input(id).depth(m,n(j))<zmax
                        mstart=m;
                        break
                    else
                        m=m+1;
                    end
                end
%                m=m+1;
                mend=0;
                while m<=mstart+d-1 && m<=mmax
                    % Find end point
                    if ~isnan(x(m,n(j))) && ~isnan(x(m-1,n(j))) && ...
                            handles.Model(md).Input(id).depth(m,n(j))<zmax
                        mend=m;
                    else
                        break
                    end
                    m=m+1;
                end
                if mstart>0 && mend>0
                    nb=nb+1;
                    nd=nd+1;
                    handles.Model(md).Input(id).openBoundaries(nb).M1=mstart;
                    handles.Model(md).Input(id).openBoundaries(nb).M2=mend;
                    handles.Model(md).Input(id).openBoundaries(nb).N1=n2(j);
                    handles.Model(md).Input(id).openBoundaries(nb).N2=n2(j);
                    
                    handles.Model(md).Input(id).openBoundaries(nb).alpha=0.0;
                    handles.Model(md).Input(id).openBoundaries(nb).compA='unnamed';
                    handles.Model(md).Input(id).openBoundaries(nb).compB='unnamed';
                    handles.Model(md).Input(id).openBoundaries(nb).type='Z';
                    handles.Model(md).Input(id).openBoundaries(nb).forcing='A';
                    handles.Model(md).Input(id).openBoundaries(nb).profile='Uniform';
                    
                    t0=handles.Model(md).Input(id).startTime;
                    t1=handles.Model(md).Input(id).stopTime;
                    nrsed=handles.Model(md).Input(id).nrSediments;
                    nrtrac=handles.Model(md).Input(id).nrTracers;
                    nrharmo=handles.Model(md).Input(id).nrHarmonicComponents;
                    x=handles.Model(md).Input(id).gridX;
                    y=handles.Model(md).Input(id).gridY;
                    depthZ=handles.Model(md).Input(id).depthZ;
                    kcs=handles.Model(md).Input(id).kcs;
                    
                    handles.Model(md).Input(id).openBoundaries=delft3dflow_initializeOpenBoundary(handles.Model(md).Input(id).openBoundaries,nb, ...
                        t0,t1,nrsed,nrtrac,nrharmo,x,y,depthZ,kcs);
                    
                    handles.Model(md).Input(id).openBoundaries(nb).name=[dir{j} num2str(nd)];
                end
            end
            
        end
        
        % West and East
        dir={'West','East'};
        
        m=[1 mmax];
        m2=[1 mmax+1];
        
        for j=1:2
            
            nd=0;
            nstart=0;
            nend=0;
            n=2;
            while n<=nmax
                while n<=nmax
                    % Find start point
                    if ~isnan(x(m(j),n)) && ~isnan(x(m(j),n-1)) && ...
                            handles.Model(md).Input(id).depth(m(j),n)<zmax
                        nstart=n;
                        break
                    else
                        n=n+1;
                    end
                end
%                 n=n+1;
                nend=0;
                while n<nstart+d-1 && n<=nmax
                    % Find end point
                    if ~isnan(x(m(j),n)) && ~isnan(x(m(j),n-1)) && ...
                            handles.Model(md).Input(id).depth(m(j),n)<zmax
                        nend=n;
                    else
                        break
                    end
                    n=n+1;
                end
                if nstart>0 && nend>0
                    nb=nb+1;
                    nd=nd+1;
                    handles.Model(md).Input(id).openBoundaries(nb).M1=m2(j);
                    handles.Model(md).Input(id).openBoundaries(nb).M2=m2(j);
                    handles.Model(md).Input(id).openBoundaries(nb).N1=nstart;
                    handles.Model(md).Input(id).openBoundaries(nb).N2=nend;
                    
                    handles.Model(md).Input(id).openBoundaries(nb).alpha=0.0;
                    handles.Model(md).Input(id).openBoundaries(nb).compA='unnamed';
                    handles.Model(md).Input(id).openBoundaries(nb).compB='unnamed';
                    handles.Model(md).Input(id).openBoundaries(nb).type='Z';
                    handles.Model(md).Input(id).openBoundaries(nb).forcing='A';
                    handles.Model(md).Input(id).openBoundaries(nb).profile='Uniform';
                    
                    t0=handles.Model(md).Input(id).startTime;
                    t1=handles.Model(md).Input(id).stopTime;
                    nrsed=handles.Model(md).Input(id).nrSediments;
                    nrtrac=handles.Model(md).Input(id).nrTracers;
                    nrharmo=handles.Model(md).Input(id).nrHarmonicComponents;
                    x=handles.Model(md).Input(id).gridX;
                    y=handles.Model(md).Input(id).gridY;
                    depthZ=handles.Model(md).Input(id).depthZ;
                    kcs=handles.Model(md).Input(id).kcs;
                    
                    handles.Model(md).Input(id).openBoundaries=delft3dflow_initializeOpenBoundary(handles.Model(md).Input(id).openBoundaries,nb, ...
                        t0,t1,nrsed,nrtrac,nrharmo,x,y,depthZ,kcs);
                    
                    handles.Model(md).Input(id).openBoundaries(nb).name=[dir{j} num2str(nd)];
                end
            end
        end
        
        handles.Model(md).Input(id).nrOpenBoundaries=nb;
        
        % Set boundary name in one cell array
        for ib=1:nb
            handles.Model(md).Input(ad).openBoundaryNames{ib}=handles.Model(md).Input(id).openBoundaries(ib).name;
        end
        
        handles=ddb_countOpenBoundaries(handles,id);
        
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries','visible',1,'active',0);
        
        ddb_saveBndFile(handles,id);
        
    else
        ddb_giveWarning('Warning','First generate or load a bathymetry');
    end
else
    ddb_giveWarning('Warning','First generate or load a grid');
end

