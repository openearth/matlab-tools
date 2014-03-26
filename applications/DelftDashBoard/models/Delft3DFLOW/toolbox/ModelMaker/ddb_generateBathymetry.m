function handles = ddb_generateBathymetry(handles, id, varargin)
%DDB_GENERATEBATHYMETRYDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateBathymetryDelft3DFLOW(handles, id, varargin)
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
%   ddb_generateBathymetryDelft3DFLOW
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
if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

% Default (use background bathymetry)
datasets{1}=handles.screenParameters.backgroundBathymetry;
zmin=-100000;
zmax=100000;
startdates=floor(now);
searchintervals=-1e5;

if ~isempty(handles.model.delft3dflow.domain(id).grdFile)
    
    for i=1:length(varargin)
        if ischar(varargin{i})
            switch lower(varargin{i})
                case{'datasets'}
                    datasets=varargin{i+1};
                case{'zmin'}
                    zmin=varargin{i+1};
                case{'zmax'}
                    zmax=varargin{i+1};
                case{'startdates'}
                    startdates=varargin{i+1};
                case{'searchintervals'}
                    searchintervals=varargin{i+1};
            end
        end
    end
    
    dpori=handles.model.delft3dflow.domain(id).depth;
    dmax=max(max(dpori));
    if isempty(dmax)
        dmax=NaN;
    end
    
    if length(datasets)==1
        % Standard method, just one bathymetry dataset
        if isnan(dmax)
            opt='overwrite';
        else
            ButtonName = questdlg('Overwrite existing bathymetry?', ...
                'Delete existing bathymetry', ...
                'Cancel', 'No', 'Yes', 'Yes');
            switch ButtonName,
                case 'Cancel',
                    return;
                case 'No',
                    opt='combine';
                case 'Yes',
                    opt='overwrite';
            end
        end
    else
        % Merge method, more than one bathymetry dataset
        opt='combine';
        handles.model.delft3dflow.domain(id).depth=zeros(size(handles.model.delft3dflow.domain(id).depth));
        handles.model.delft3dflow.domain(id).depth(handles.model.delft3dflow.domain(id).depth==0)=NaN;
    end
    
    wb = waitbox('Generating bathymetry ...');
    
    attName=handles.model.delft3dflow.domain(id).attName;
    
    % Generate bathymetry    
    
    for idata=1:length(datasets)


        % Loop through selected datasets
        
        bathyset=datasets{idata};
        startdate=startdates(idata);
        searchinterval=searchintervals(idata);
        zmn=zmin(idata);
        zmx=zmax(idata);
        
        % Convert grid to cs of background image
        coord=handles.screenParameters.coordinateSystem;
        iac=strmatch(lower(bathyset),lower(handles.bathymetry.datasets),'exact');
        dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
        dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
        [xg,yg]=ddb_coordConvert(xg,yg,coord,dataCoord);
        
        % Find minimum grid resolution
        [dmin,dmax]=findMinMaxGridSize(xg,yg,'cstype',handles.screenParameters.coordinateSystem.type);
        xl(1)=min(min(xg));
        xl(2)=max(max(xg));
        yl(1)=min(min(yg));
        yl(2)=max(max(yg));
        dbuf=(xl(2)-xl(1))/10;
        xl(1)=xl(1)-dbuf;
        xl(2)=xl(2)+dbuf;
        yl(1)=yl(1)-dbuf;
        yl(2)=yl(2)+dbuf;
        
        [xx,yy,zz,ok]=ddb_getBathymetry(handles.bathymetry,xl,yl,'bathymetry',bathyset,'maxcellsize',dmin,'startdate',startdate,'searchinterval',searchinterval);
        
        % Remove values outside requested range
        zz(zz<zmn)=NaN;
        zz(zz>zmx)=NaN;
        
        xg(isnan(xg))=0;
        yg(isnan(yg))=0;
        
        %    zz=min(zz,5);
        isn=isnan(zz);
%         mmtb=strmatch('ModelMaker',{handles.Toolbox(:).name},'exact');
        
%        zz=min(zz,handles.toolbox.modelmaker.zMax);
        zz(isn)=NaN;
        
        z=interp2(xx,yy,zz,xg,yg);
        %    z=gridcellaveraging2(xx,yy,zz,xg,yg,dmin,'min');
        
        switch opt
            case{'overwrite'}
                handles.model.delft3dflow.domain(id).depth=z;
            case{'combine'}
                handles.model.delft3dflow.domain(id).depth(isnan(handles.model.delft3dflow.domain(id).depth))=z(isnan(handles.model.delft3dflow.domain(id).depth));
        end
        
    end
    
    switch lower(handles.model.delft3dflow.domain(id).dpsOpt)
        case{'dp'}
            handles.model.delft3dflow.domain(id).depth(:,1)=handles.model.delft3dflow.domain(id).depth(:,2);
            handles.model.delft3dflow.domain(id).depth(1,:)=handles.model.delft3dflow.domain(id).depth(2,:);
    end
    
    z=handles.model.delft3dflow.domain(id).depth;
    
    
    handles.model.delft3dflow.domain(id).depthZ=getDepthZ(z,handles.model.delft3dflow.domain(id).dpsOpt);
    
    ddb_wldep('write',[attName '.dep'],z);
    
    handles.model.delft3dflow.domain(id).depFile=[attName '.dep'];
    
    
    %    setHandles(handles);
    
    try
        close(wb);
    end
    
    handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',id);
    
    %    ddb_plotFlowBathymetry(handles,'plot',id);
    
else
    ddb_giveWarning('Warning','First generate or load a grid');
end

