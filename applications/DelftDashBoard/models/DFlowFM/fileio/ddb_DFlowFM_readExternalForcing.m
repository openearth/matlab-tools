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
            boundaries = ddb_DFlowFM_initializeBoundary(boundaries,x,y,name,nb);
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

handles.Model(md).Input.nrboundaries=nb;
handles.Model(md).Input.boundaries=boundaries;
