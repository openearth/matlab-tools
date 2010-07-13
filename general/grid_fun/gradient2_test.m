function gradient2_test()
% GRADIENT2_TEST  test that compares gradient2 to gradient
%
% %  Generates 3 cases plots:
%  * gradient()
%  * gradient2(): upwind method
%  * gradient2(): central method
%
% Compare magnitude and direction for the 3 cases
%
%   See also gradient2

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $


disp('TO DO: test by comparing to default gradient')
disp('TO DO: add original corner grid as gray lines')

OPT.cd     = fileparts(mfilename('fullpath'));

OPT.export = ~TeamCity.running;

OPT.discretisations{1} = 'central';  % gradient2
OPT.discretisations{2} = 'upwind';   % gradient2
OPT.discretisations{3} = 'gradient'; % gradient

if ~exist('clrmap','file')
    wlsettings;
end

for idis=1:length(OPT.discretisations)
    
    OPT.discretisation = OPT.discretisations{idis};
    
    [x,y,z] = peaks;
    [xc,yc] = corner2center(x,y);
    
    %% Calculate gradients in all separate triangles.
    %% -----------------------------------
    
    if     strcmp(OPT.discretisation,'gradient')
        [fx  ,fy  ] = gradient(z,x(1,:),y(:,1));
        [fdir,fabs] = cart2pol(fx,fy);
        
    else
        
        [fx  ,fy  ] = gradient2(x,y,z,'discretisation',OPT.discretisation);
        [fdir,fabs] = cart2pol(fx,fy);
        
        map     = triquat(x,y);
        q       = map.quat; % tri     = quat(x,y);
        tri     = map.tri;  % tri     = delaunay(x,y);
        
    end
    
    dz      = max(z(:));
    
    %% Plot mesh
    %-------------------------------------
    
    if ~strcmp(OPT.discretisation,'gradient')
        
        figure('name',['method: ',OPT.discretisation,': mesh']);clf
        [c,h]  = contour2(x,y,z,[-6:2:6]);
        colorbar
        set(gca,'clim',get(gca,'clim'));
        view(0,90)
        hold on
        
        p = trimesh(tri,x,y,z+dz,'FaceColor','none','EdgeColor',[.5 .5 .5]);
        
        [tri.xc,tri.yc,tri.zc] = tri_corner2center(tri,x,y,z);
        
        if strcmp(OPT.discretisation,'central') | ...
                strcmp(OPT.discretisation,'gradient')
            quiver3(x ,y ,zeros(size(y )) + dz,fx,fy,ones(size(fx))*5,'k')
        else
            quiver3(xc,yc,zeros(size(yc)) + dz,fx,fy,ones(size(fx))*5,'k')
        end
        
        axis equal
        title(OPT.discretisation)
        
        if OPT.export
            print2screensize([OPT.cd,filesep,OPT.discretisation,'_mesh']);
        end
        
    end
    
    %% Plot |grad|
    %-------------------------------------
    
    figure('name',['method: ',OPT.discretisation,': |grad|']);clf
    P = pcolorcorcen(x,y,fabs);
    hold on
    [c,h]  = contour2(x,y,z,[-6:2:6],'k');
    
    if strcmp(OPT.discretisation,'central') | ...
            strcmp(OPT.discretisation,'gradient')
        quiver3(x ,y ,zeros(size(y )) + dz,fx,fy,ones(size(fx))*5,'k')
    else
        quiver3(xc,yc,zeros(size(yc)) + dz,fx,fy,ones(size(fx))*5,'k')
    end
    
    colorbarwithtitle('magnitude')
    
    axis equal
    title(OPT.discretisation)
    
    if OPT.export
        print2screensize([OPT.cd,filesep,OPT.discretisation,'_fabs']);
    end
    
    %% Plot direction(grad)
    %-------------------------------------
    
    figure('name',['method: ',OPT.discretisation,': direction']);clf
    P = pcolorcorcen(x,y,fdir);
    hold on
    [c,h]  = contour2(x,y,z,[-6:2:6],'k');
    
    if strcmp(OPT.discretisation,'central') | ...
            strcmp(OPT.discretisation,'gradient')
        quiver3(x ,y ,zeros(size(y )) + dz,fx,fy,ones(size(fx))*5,'k')
    else
        quiver3(xc,yc,zeros(size(yc)) + dz,fx,fy,ones(size(fx))*5,'k')
    end
    
    caxis([-pi pi])
    colormap(clrmap([1 0 0; 0 1 0; 0 0 1; 1 1 1],4))
    colorbarwithtitle('direction')
    
    axis equal
    title(OPT.discretisation)
    
    if OPT.export
        print2screensize([OPT.cd,filesep,OPT.discretisation,'_fdir']);
    end
    
end % idis=1:length(OPT.discretisations)
