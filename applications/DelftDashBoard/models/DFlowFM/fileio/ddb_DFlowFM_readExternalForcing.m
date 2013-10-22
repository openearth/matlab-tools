function handles = ddb_DFlowFM_readExternalForcing(handles)
%ddb_DFlowFM_readExternalForcing  One line description goes here.

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

%% Reads DFlow-FM external forcing

fname=handles.Model(md).Input.extforcefile;

s=[];
n=0;
fid=fopen(fname,'r');
while 1
    str=fgetl(fid);
    if str==-1
        break
    end
    str=deblank2(str);
    if ~isempty(str)
        if strcmpi(str(1),'*')
            % Comment line
        else
            switch lower(str(1:6))
                case{'quanti'}
                    n=n+1;
                    s(n).quantity=str(10:end);
                case{'filety'}
                    s(n).filetype=str(10:end);
                case{'filena'}
                    s(n).filename=str(10:end);
                case{'method'}
                    s(n).method=str(8:end);
                case{'operan'}
                    s(n).operand=str(9:end);
            end
        end
        
    end
end
fclose(fid);

% Clear boundary info
boundaries=[];
boundaries(1).name='';
handles.Model(md).Input.activeboundary=1;
handles.Model(md).Input.nrboundaries=0;
handles.Model(md).Input.boundarynames={''};
nb=0;

for ii=1:length(s)
    switch lower(s(ii).quantity)
        case{'waterlevelbnd'}
            nb=nb+1;
            plifile=s(ii).filename;
            name=plifile(1:end-4);
            [x,y]=landboundary('read',plifile);
            boundaries = ddb_DFlowFM_initializeBoundary(boundaries,x,y,name,nb,handles.Model(md).Input.tstart,handles.Model(md).Input.tstop);
            boundaries(nb).type=s(ii).quantity;
            handles.Model(md).Input.boundarynames{nb}=name;            
        case{'dischargebnd'}
            nb=nb+1;
            plifile=s(ii).filename;
            name=plifile(1:end-4);
            [x,y]=landboundary('read',plifile);
            boundaries = ddb_DFlowFM_initializeBoundary(boundaries,x,y,name,nb,handles.Model(md).Input.tstart,handles.Model(md).Input.tstop);
            boundaries(nb).type=s(ii).quantity;
            handles.Model(md).Input.boundarynames{nb}=name;            
        case{'spiderweb'}
            handles.Model(md).Input.spiderwebfile=s(ii).filename;
            handles.Model(md).Input.wind=1;
        case{'windx'}
            handles.Model(md).Input.windufile=s(ii).filename;
            handles.Model(md).Input.wind=1;
        case{'windy'}
            handles.Model(md).Input.windvfile=s(ii).filename;
            handles.Model(md).Input.wind=1;
        case{'atmosphericpressure'}
            handles.Model(md).Input.airpressurefile=s(ii).filename;
            handles.Model(md).Input.airpressure=1;
        case{'rain'}
            handles.Model(md).Input.rainfile=s(ii).filename;
            handles.Model(md).Input.rain=1;
    end
end

% Now read time series / component files
for ib=1:length(boundaries)
    for inode=1:length(boundaries(ib).x)
        % Component file
        fname=[boundaries(ib).name '_' num2str(inode,'%0.4i') '.cmp'];
        if exist(fname,'file')
            components=dflowfm.readCmpFile(fname);
            boundaries(ib).nodes(inode).cmp=1;
            if ischar(components(1).component)
                % Astronomic
                boundaries(ib).nodes(inode).astronomiccomponents=components;
                boundaries(ib).nodes(inode).cmptype='astro';
            else
                % Harmonic
                boundaries(ib).nodes(inode).harmoniccomponents=components;
                boundaries(ib).nodes(inode).cmptype='harmo';
            end
        else
            % Components have already been initialized in ddb_DFlowFM_initializeBoundary
            boundaries(ib).nodes(inode).cmp=0;
        end
        % Time series file file
        fname=[boundaries(ib).name '_' num2str(inode,'%0.4i') '.tim'];
        if exist(fname,'file')
            s=load(fname);
            boundaries(ib).nodes(inode).timeseries.time=handles.Model(md).Input.refdate+s(:,1)/1440;            
            boundaries(ib).nodes(inode).timeseries.value=s(:,2);            
            boundaries(ib).nodes(inode).tim=1;
        else
            % Time series have already been initialized in ddb_DFlowFM_initializeBoundary
            boundaries(ib).nodes(inode).tim=0;
        end
    end
end

handles.Model(md).Input.nrboundaries=nb;
handles.Model(md).Input.boundaries=boundaries;
