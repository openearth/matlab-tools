function handles = ddb_openXYZFile(handles, ii)
%DDB_OPENXYZFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_openXYZFile(handles, ii)
%
%   Input:
%   handles =
%   ii      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_openXYZFile
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
fname=[handles.Bathymetry.Dataset(ii).DirectoryName filesep handles.Bathymetry.Dataset(ii).FileName];

fid=fopen(fname,'r');

nc=0;
comment{1}='';
for k=1:1000
    v=deblank(fgetl(fid));
    if v(1)=='*' || v(1)=='%'
        if ~isempty(deblank(v(2:end)))
            nc=nc+1;
            comment{nc}=deblank(v(2:end));
        end
    else
        nfirst=k;
        break
    end
end
fclose(fid);

fid=fopen(fname,'r');
for i=1:nfirst-1
    dummy=fgetl(fid);
end
c=textscan(fid,'%f%f%f');
handles.Bathymetry.Dataset(ii).Comments=comment;
handles.Bathymetry.Dataset(ii).Type='vector';
handles.Bathymetry.Dataset(ii).x=c{1};
handles.Bathymetry.Dataset(ii).y=c{2};
handles.Bathymetry.Dataset(ii).z=c{3};
fclose(fid);

x=c{1};
y=c{2};

% sample files usually use the convention of z being counted positive in downward
% direction, so for DA it has to bo converted.
if  abs(min(c{3})) < abs(max(c{3}))
    z=-c{3};
else % now, probably the convention of the sample file is positive upward, ask for confirmation!
    answer = questdlg('The sample file appears to have the convention of z being counted positive upward, is this correct?', ...
        'Convention Question', ...
        'No', 'Yes', 'Yes');
    switch answer,
        case 'Yes', % no conversion needed now
            z=c{3};
        case 'No', % conversion needed
            z=-c{3};
    end
end


% Check if it's really a matrix

% First x
nx=length(x);
xdist=x-x(1);
d=xdist;

d=abs(d);
d(d==0)=NaN;
dmin=min(d);

dx=dmin;

mtx=1;
for i=1:nx
    if ~isnan(d(i))
        dv=d(i)/dmin;
        dvr=round(dv);
        if abs(dv-dvr)>0.1
            mtx=0;
            break
        end
    end
end

if mtx==1
    % Now y
    ny=length(y);
    ydist=y-y(1);
    d=ydist;
    
    d=abs(d);
    d(d==0)=NaN;
    dmin=min(d);
    
    dy=dmin;
    
    for i=1:ny
        if ~isnan(d(i))
            dv=d(i)/dmin;
            dvr=round(dv);
            if abs(dv-dvr)>0.1
                mtx=0;
                break
            end
        end
    end
end

if mtx
    answer = questdlg('The dataset appears to be a regular matrix. Do you want to convert it?', ...
        'Convert Question', ...
        'No', 'Yes', 'Yes');
    switch answer,
        case 'Yes',
            mtx=1;
        case 'No',
            mtx=0;
    end
end

if mtx
    % It's a matrix, now fill it
    xmin=min(x);
    ymin=min(y);
    xmax=max(x);
    ymax=max(y);
    format long
    nxx=round((xmax-xmin)/dx)+1;
    nyy=round((ymax-ymin)/dy)+1;
    dx=(xmax-xmin)/(nxx-1);
    dy=(ymax-ymin)/(nyy-1);
    xx=xmin:dx:xmax;
    yy=ymin:dy:ymax;
    [xg,yg]=meshgrid(xx,yy);
    wb = awaitbar(0,'Converting to matrix...');
    for i=1:nyy
        str=['Converting to matrix - grid line ' num2str(i) ' of ' ...
            num2str(nyy) ' ...'];
        [hh,abort2]=awaitbar(i/nyy,wb,str);
        for j=1:nxx
            kx=find(abs(x-xg(i,j))<dx/5);
            ypos=y(kx);
            ky=find(abs(ypos-yg(i,j))<dy/5);
            if ~isempty(ky)
                k=kx(ky(1));
                zg(i,j)=z(k);
            else
                zg(i,j)=nan;
            end
        end
        if abort2 % Abort the process by clicking abort button
            mtx=0;
            break;
        end;
        if isempty(hh); % Break the process when closing the figure
            mtx=0;
            break;
        end;
    end
    if ~isempty(hh)
        close(wb);
    end
    if mtx
        handles.Bathymetry.Dataset(ii).Comments=comment;
        handles.Bathymetry.Dataset(ii).Type='gridded';
        handles.Bathymetry.Dataset(ii).x=xx;
        handles.Bathymetry.Dataset(ii).y=yy;
        handles.Bathymetry.Dataset(ii).z=zg;
    end
end

