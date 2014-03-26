function handles = ddb_generateBoundarySectionsDFlowFM(handles,maxdist,maxangle)
%DDB_GENERATEBOUNDARYSECTIONSDFLOWFM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateBoundarySectionsDFlowFM(handles)
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

if ~isempty(handles.model.dflowfm.domain(id).grdFile)
    if ~isempty(handles.model.dflowfm.domain(id).depFile)
        
        d=handles.toolbox.modelmaker.sectionLength;
        zmax=handles.toolbox.modelmaker.zMax;
        
        attName=handles.model.dflowfm.domain(id).attName;
        
        handles.model.dflowfm.domain(id).bndFile=[attName '.bnd'];
        
        x=handles.model.dflowfm.domain(id).gridx;
        y=handles.model.dflowfm.domain(id).gridy;
        z=handles.model.dflowfm.domain(id).depth;
        
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
            while m<mmax
                while m<mmax
                    % Find start point
                    if ~isnan(x(m,n(j))) && ~isnan(x(m-1,n(j))) && ...
                            handles.model.dflowfm.domain(id).depth(m,n(j))<zmax
                        mstart=m;
                        break
                    else
                        m=m+1;
                    end
                end
                m=m+1;
                mend=0;
                while m<mstart+d && m<=mmax
                    % Find end point
                    if ~isnan(x(m,n(j))) && ~isnan(x(m-1,n(j))) && ...
                            handles.model.dflowfm.domain(id).depth(m,n(j))<zmax
                        mend=m;
                    else
                        break
                    end
                    m=m+1;
                end
                if mstart>0 && mend>0
                    nb=nb+1;
                    nd=nd+1;
                    handles.model.dflowfm.domain(id).openBoundaries(nb).M1=mstart;
                    handles.model.dflowfm.domain(id).openBoundaries(nb).M2=mend;
                    handles.model.dflowfm.domain(id).openBoundaries(nb).N1=n2(j);
                    handles.model.dflowfm.domain(id).openBoundaries(nb).N2=n2(j);
                    
                    handles.model.dflowfm.domain(id).openBoundaries(nb).alpha=0.0;
                    handles.model.dflowfm.domain(id).openBoundaries(nb).compA='unnamed';
                    handles.model.dflowfm.domain(id).openBoundaries(nb).compB='unnamed';
                    handles.model.dflowfm.domain(id).openBoundaries(nb).type='Z';
                    handles.model.dflowfm.domain(id).openBoundaries(nb).forcing='A';
                    handles.model.dflowfm.domain(id).openBoundaries(nb).profile='Uniform';
                    
                    t0=handles.model.dflowfm.domain(id).startTime;
                    t1=handles.model.dflowfm.domain(id).stopTime;
                    nrsed=handles.model.dflowfm.domain(id).nrSediments;
                    nrtrac=handles.model.dflowfm.domain(id).nrTracers;
                    nrharmo=handles.model.dflowfm.domain(id).nrHarmonicComponents;
                    x=handles.model.dflowfm.domain(id).gridX;
                    y=handles.model.dflowfm.domain(id).gridY;
                    depthZ=handles.model.dflowfm.domain(id).depthZ;
                    kcs=handles.model.dflowfm.domain(id).kcs;
                    kmax=handles.model.dflowfm.domain(id).KMax;
                    
                    handles.model.dflowfm.domain(id).openBoundaries=delft3dflow_initializeOpenBoundary(handles.model.dflowfm.domain(id).openBoundaries,nb, ...
                        t0,t1,nrsed,nrtrac,nrharmo,x,y,depthZ,kcs,kmax);
                    
                    handles.model.dflowfm.domain(id).openBoundaries(nb).name=[dir{j} num2str(nd)];
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
            while n<nmax
                while n<nmax
                    % Find start point
                    if ~isnan(x(m(j),n)) && ~isnan(x(m(j),n-1)) && ...
                            handles.model.dflowfm.domain(id).depth(m(j),n)<zmax
                        nstart=n;
                        break
                    else
                        n=n+1;
                    end
                end
                n=n+1;
                nend=0;
                while n<nstart+d && n<=nmax
                    % Find end point
                    if ~isnan(x(m(j),n)) && ~isnan(x(m(j),n-1)) && ...
                            handles.model.dflowfm.domain(id).depth(m(j),n)<zmax
                        nend=n;
                    else
                        break
                    end
                    n=n+1;
                end
                if nstart>0 && nend>0
                    nb=nb+1;
                    nd=nd+1;
                    handles.model.dflowfm.domain(id).openBoundaries(nb).M1=m2(j);
                    handles.model.dflowfm.domain(id).openBoundaries(nb).M2=m2(j);
                    handles.model.dflowfm.domain(id).openBoundaries(nb).N1=nstart;
                    handles.model.dflowfm.domain(id).openBoundaries(nb).N2=nend;
                    
                    handles.model.dflowfm.domain(id).openBoundaries(nb).alpha=0.0;
                    handles.model.dflowfm.domain(id).openBoundaries(nb).compA='unnamed';
                    handles.model.dflowfm.domain(id).openBoundaries(nb).compB='unnamed';
                    handles.model.dflowfm.domain(id).openBoundaries(nb).type='Z';
                    handles.model.dflowfm.domain(id).openBoundaries(nb).forcing='A';
                    handles.model.dflowfm.domain(id).openBoundaries(nb).profile='Uniform';
                    
                    t0=handles.model.dflowfm.domain(id).startTime;
                    t1=handles.model.dflowfm.domain(id).stopTime;
                    nrsed=handles.model.dflowfm.domain(id).nrSediments;
                    nrtrac=handles.model.dflowfm.domain(id).nrTracers;
                    nrharmo=handles.model.dflowfm.domain(id).nrHarmonicComponents;
                    x=handles.model.dflowfm.domain(id).gridX;
                    y=handles.model.dflowfm.domain(id).gridY;
                    depthZ=handles.model.dflowfm.domain(id).depthZ;
                    kcs=handles.model.dflowfm.domain(id).kcs;
                    
                    handles.model.dflowfm.domain(id).openBoundaries=delft3dflow_initializeOpenBoundary(handles.model.dflowfm.domain(id).openBoundaries,nb, ...
                        t0,t1,nrsed,nrtrac,nrharmo,x,y,depthZ,kcs);
                    
                    handles.model.dflowfm.domain(id).openBoundaries(nb).name=[dir{j} num2str(nd)];
                end
            end
        end
        
        handles.model.dflowfm.domain(id).nrOpenBoundaries=nb;
        
        % Set boundary name in one cell array
        for ib=1:nb
            handles.model.dflowfm.domain(ad).openBoundaryNames{ib}=handles.model.dflowfm.domain(id).openBoundaries(ib).name;
        end
        
        handles=ddb_countOpenBoundaries(handles,id);
        
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries','visible',1,'active',0);
        
        ddb_saveBndFile(handles.model.dflowfm.domain(id).openBoundaries,handles.model.dflowfm.domain(id).bndFile);
        
    else
        ddb_giveWarning('Warning','First generate or load a bathymetry');
    end
else
    ddb_giveWarning('Warning','First generate or load a grid');
end

