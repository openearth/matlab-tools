function tc=readBestTrackUnisys(fname)
%DDB_READBESTTRACKUNISYS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ddb_readBestTrackUnisys(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ddb_readBestTrackUnisys
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
fid=fopen(filename,'r');

n=0;

tx0=fgets(fid);
v0=strread(tx0,'%s','delimiter',' ');
nn=length(v0);
y=str2double(v0{nn});

tx0=fgets(fid);
name=tx0(1:end-1);

handles.toolbox.tropicalcyclone.date=[];
handles.toolbox.tropicalcyclone.trX=[];
handles.toolbox.tropicalcyclone.trY=[];
handles.toolbox.tropicalcyclone.par1=[];
handles.toolbox.tropicalcyclone.par2=[];

handles.toolbox.tropicalcyclone.name=name;

tx0=fgets(fid);

for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        n=n+1;
        v0=strread(tx0,'%s','delimiter',' ');
        lat=str2double(v0{2});
        lon=str2double(v0{3});
        tstr=v0{4};
        vel=str2double(v0{5});
        pr=v0{6};
        if isnan(str2double(pr))
            pr=0;
        else
            pr=str2double(pr);
        end
        mm=str2double(tstr(1:2));
        dd=str2double(tstr(4:5));
        hh=str2double(tstr(7:8));
        handles.toolbox.tropicalcyclone.date(n)=datenum(y,mm,dd,hh,0,0);
        handles.toolbox.tropicalcyclone.trX(n)=lon;
        handles.toolbox.tropicalcyclone.trY(n)=lat;
        handles.toolbox.tropicalcyclone.par1(n)=vel;
        handles.toolbox.tropicalcyclone.par2(n)=pr;
    else
        break;
    end
end
handles.toolbox.tropicalcyclone.nrPoint=n;
handles.toolbox.tropicalcyclone.holland=0;
handles.toolbox.tropicalcyclone.initSpeed=0;
handles.toolbox.tropicalcyclone.initDir=0;
handles.toolbox.tropicalcyclone.startTime=handles.toolbox.tropicalcyclone.date(1);

fclose(fid);

