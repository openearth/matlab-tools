function [curvatures radii relativeAngle distances] = jarkus_deriveCurvature(varargin)
%JARKUS_DERIVECURVATURE  Derives the coastal curvature from JARKUS data
%
%   Calculates the coastal curvature based on JARKUS data. Two calculation
%   methods are available. The first method assumes the transects to be
%   perpendicular to the shoreline and calculates the curvature by dividing
%   the difference in direction between two transects by the difference in
%   distance. The second method fits a circle in a certain number of points
%   on the shoreline around the transect of interest.
%
%   Syntax:
%   [curvatures radii relativeAngle distances] = jarkus_deriveCurvature(varargin)
%
%   Input:
%   varargin    = key/value pairs of optional parameters
%                 url               = url to JARKUS repository (default:
%                                     jarkus_url)
%                 method            = calculation method to be used (1 for
%                                     direct, 2 for circle fit, default: 2)
%                 z                 = altitude of shoreline (default: 0)
%                 smooth            = smoothing factor for calculation
%                                     method 1 (default: 20)
%                 numPoints         = number of shoreline points to be
%                                     included in calculation method 2
%                                     (default: 10)
%                 Rmin              = minimum radius to be included in
%                                     calculation method 2 (default: 1000)
%                 Rmax              = maximum radius to be included in
%                                     calculation method 2 (default: 20000)
%                 dR                = step size in which the radius should
%                                     be varied in calculation method 2
%                                     (default: 100)
%                 transectMin       = index number of transect to start
%                                     curvature calculation (0 is first, 
%                                     default: 0)
%                 transectMax       = index number of transect to stop
%                                     curvature calculation (0 is last,
%                                     default: 0)
%                 angleThreshold    = maximum angle in degrees between two 
%                                     transects, larger angles are
%                                     considered gaps (default: 25)
%                 distanceThreshold = maximum distance between two
%                                     transects, larger distances are
%                                     considered gaps (default: 400)
%                 maxCurvature      = upper limit of curvature plot
%                                     (default: 50)
%                 jarkusFile        = filename of file containing
%                                     downloaded JARKUS information
%                                     (default: jarkus.mat)
%                 readJarkusFile    = flag to enable reading of JARKUS
%                                     file, if available rather than
%                                     downloading the data again (default:
%                                     true)
%                 writeJarkusFile   = flag to enable writing of JARKUS file
%                                     after data is downloaded (default:
%                                     true)
%                 order             = flag to enable manual ordering of
%                                     transects so they run from north to
%                                     south (default: true)
%                 plot              = flag to enable plotting of the
%                                     derived angles, distances and
%                                     curvatures (default: false)
%                 plotMap           = flag to enable plotting of a coastal
%                                     map with transects, shoreline and
%                                     possibly curvatures (default: false)
%                 verbose           = flag to enable progress bar (default:
%                                     false)
%
%   Output:
%   curvatures      = array of curvatures in degrees per kilometer
%   radii           = array of curvatures in curvature radii in meter
%   relativeAngle   = array with angles between transects
%   distances       = array with distances between transects at shoreline
%
%   Example
%   jarkus_deriveCurvature
%
%   See also circlefit

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Nov 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings

OPT = struct( ...
    'url', jarkus_url, ...
    'method', 2, ...
    'z', 0, ...
    'smooth', 20, ...
    'numPoints', 10, ...
    'Rmin', 1000, ...
    'Rmax', 20000, ...
    'dR', 100, ...
    'transectMin', 0, ...
    'transectMax', 0, ...
    'angleThreshold', 25, ...
    'distanceThreshold', 400, ...
    'maxCurvature', 50, ...
    'jarkusFile', 'jarkus.mat', ...
    'readJarkusFile', true, ...
    'writeJarkusFile', true, ...
    'order', true, ...
    'plot', false, ...
    'plotMap', false, ...
    'verbose', false ...
);

OPT = setProperty(OPT, varargin{:});

if OPT.verbose; wb = waitbar(0, 'Initializing'); end;

%% get jarkus info

% check whether JARKUS data is available in local file
if ~isempty(OPT.jarkusFile) && exist(OPT.jarkusFile, 'file') == 2 && OPT.readJarkusFile == true
    if OPT.verbose; waitbar(0, wb, 'Reading JARKUS data from file'); end;
    
    % read JARKUS data from file
    load(OPT.jarkusFile);
else
    if OPT.verbose; waitbar(0, wb, 'Retrieving JARKUS data'); end;
    
    % connect to JARKUS repository
    jarkusInfo = nc_info(OPT.url);

    % select last year altitude from jarkus repository
    i = strcmpi({jarkusInfo.Dataset.Name}, 'altitude');
    i = jarkusInfo.Dataset(i).Size(1)-1;

    % read altitude data
    jarkusAltitude = nc_varget(OPT.url, 'altitude', [i 0 0], [1 -1 -1]);
    
    % read cross-shore, x and y grid
    jarkusCrossshoreGrid = nc_varget(OPT.url, 'cross_shore')';
    jarkusXGrid = nc_varget(OPT.url, 'x');
    jarkusYGrid = nc_varget(OPT.url, 'y');

    % retrieve area codes and transect id's
    jarkusAreaCode = nc_varget(OPT.url, 'areacode')';
    jarkusTransectIDs = nc_varget(OPT.url, 'id')';
    
    % check whether JARKUS data should be written to file
    if ~isempty(OPT.jarkusFile) && OPT.writeJarkusFile == true
        if OPT.verbose; waitbar(0.5, wb, 'Saving JARKUS data to file'); end;

        % write JARKUS data to file
        save(OPT.jarkusFile, 'jarkusAreaCode', 'jarkusTransectIDs', ...
            'jarkusXGrid', 'jarkusYGrid', 'jarkusCrossshoreGrid', ...
            'jarkusAltitude');
    end
end

if OPT.verbose; waitbar(1, wb); end;

%% set transect order

% modify order of transects, if requested
if OPT.order
    if OPT.verbose; waitbar(0, wb, 'Ordering transects'); end;
    
    transectOrder = [];

    % flip transect order for areacodes that run from south to north
    for i = unique(jarkusAreaCode)
        if i < 7
            transectOrder = [transectOrder fliplr(find(jarkusAreaCode == i))];
        else
            transectOrder = [transectOrder find(jarkusAreaCode == i)];
        end
    end

    % FIXME
    % change order from dissident sections so the entire transect
    % collection runs from north to south
    transectOrder = [ transectOrder(1:113) transectOrder(137:285) ...
        transectOrder(114:136) transectOrder(301:486) ...
        transectOrder(286:300) transectOrder(487:end) ];

    jarkusAltitude = jarkusAltitude(transectOrder, :);
    jarkusXGrid = jarkusXGrid(transectOrder, :);
    jarkusYGrid = jarkusYGrid(transectOrder, :);
    jarkusTransectIDs = jarkusTransectIDs(transectOrder);
    
    if OPT.verbose; waitbar(1, wb); end;
end

% select transect range
if OPT.verbose; waitbar(0, wb, 'Selecting transects'); end;

% decrease number of transects based on given selection
if OPT.transectMin > 0 && OPT.transectMax > 0
    transectRange = OPT.transectMin:OPT.transectMax;
elseif OPT.transectMin > 0
    transectRange = OPT.transectMin:length(jarkusTransectIDs);
elseif OPT.transectMax > 0
    transectRange = 1:OPT.transectMax;
else
    transectRange = 1:length(jarkusTransectIDs);
end

jarkusAltitude = jarkusAltitude(transectRange, :);
jarkusXGrid = jarkusXGrid(transectRange, :);
jarkusYGrid = jarkusYGrid(transectRange, :);
jarkusTransectIDs = jarkusTransectIDs(transectRange);

if OPT.verbose; waitbar(1, wb); end;

%% read transects

x = NaN(size(jarkusTransectIDs));
y = NaN(size(jarkusTransectIDs));
a = NaN(size(jarkusTransectIDs));

if OPT.verbose; waitbar(0, wb, 'Determining shoreline'); end;

% loop through al transects to determine cross-shore position of shoreline
% for each transect
for i = 1:length(jarkusTransectIDs)
    
    isNotNaN = ~isnan(jarkusAltitude(i,:));
    
    % check whether transect is valid
    if any(isNotNaN)
        
        % find crossing of coastal profile with a given reference level
        % assuming this to be the shoreline
        crossing = max(findCrossings( ...
            jarkusCrossshoreGrid(isNotNaN), ...
            jarkusAltitude(i,isNotNaN), ...
            [ min(jarkusCrossshoreGrid(isNotNaN)) ...
            max(jarkusCrossshoreGrid(isNotNaN)) ], ...
            [OPT.z OPT.z] ...
        ));
        
        % check whether a crossing has been found
        if isempty(crossing)
            crossing = NaN;
        else
            
            % translate cross-shore coordinate to global x-corodinate
            x(i) = interp1(jarkusCrossshoreGrid(isNotNaN), ...
                jarkusXGrid(i,isNotNaN), crossing);
            
            % translate cross-shore coordinate to global y-coordinate
            y(i) = interp1(jarkusCrossshoreGrid(isNotNaN), ...
                jarkusYGrid(i,isNotNaN), crossing);
            
            % calculate direction angle of transect with respect to north
            a(i) = xy2degN(jarkusXGrid(i,end), jarkusYGrid(i,end), ...
                jarkusXGrid(i,1), jarkusYGrid(i,1));
        end
    end
    
    if OPT.verbose; waitbar(i/length(jarkusTransectIDs), wb); end;
end

%% calculate curvatures

% calculate angles and distances between transects
relativeAngle = diff(a);
distances = sqrt(diff(x).^2 + diff(y).^2);

% skip gaps larger than thresholds
iisGap = abs(relativeAngle) > OPT.angleThreshold | abs(distances) > OPT.distanceThreshold;
iisNaN = isnan(distances) | isnan(relativeAngle);

relativeAngle(iisGap) = 0;
relativeAngle(iisNaN) = 0;
distances(iisGap) = mean(abs(distances(~iisGap & ~iisNaN)));
distances(iisNaN) = mean(abs(distances(~iisGap & ~iisNaN)));

error = [];
circles = [];

if OPT.verbose; waitbar(0, wb, 'Calculating curvatures'); end;

% select calculation method
switch OPT.method
    case 1
        % calculate curvatures directly from distances and angles between
        % transects assuming that all transects are perpendicular to the
        % shoreline
        curvatures = smooth(relativeAngle ./ abs(distances), OPT.smooth) .* 1000;
        radii = 180 ./ pi ./ curvatures;
    case 2
        d = [0:0.1:2*pi];
        radii = [];
        curvatures = [];
        
        % loop through transects and calculate curvatures by fitting a
        % circle to a certain number of shoreline points surrounding the
        % observed transect
        for i = 1:length(jarkusTransectIDs)
            
            % fit circle
            [R a rms center] = circlefit(x,y,'point',i,'numPoints',OPT.numPoints,'Rmin',OPT.Rmin,'Rmax',OPT.Rmax,'dR',OPT.dR);
            
            radii(i) = R;
            curvatures(i) = 180/pi/R*1000;
            error(i) = 180/pi/(R-rms)*1000-curvatures(i);
            circles(i,:,:) = [center(1)+R*sin(d) ; center(2)+R*cos(d)]';
            
            if OPT.verbose; waitbar(i/length(jarkusTransectIDs), wb); end;
        end
        
        error(isinf(error)|isnan(error)) = 0;
        curvatures(isinf(curvatures)|isnan(curvatures)) = 0;
end

if OPT.verbose; waitbar(1, wb); end;

%% plot stuff

if OPT.verbose; close(wb); end;

% plot angles, distances and curvatures, if requested
if OPT.plot
    
    % create subplots
    f1 = figure;
    s1=subplot(3,1,1); hold on;
    s2=subplot(3,1,2); hold on;
    s3=subplot(3,1,3); hold on;

    % plot angles, distances and curvatures with their mean values
    plot(s1,abs(relativeAngle),'-b'); plot(s1,[0 length(curvatures)],mean(abs(relativeAngle))*ones(1,2),'-r');
    plot(s2,abs(distances),'-b'); plot(s2,[0 length(curvatures)],mean(abs(distances))*ones(1,2),'-r');
    plot(s3,abs(curvatures),'-b'); plot(s3,[0 length(curvatures)],mean(abs(curvatures))*ones(1,2),'-r');
    if ~isempty(error); plot(s3,abs(curvatures)+error,':b'); plot(s3,abs(curvatures)-error,':b'); end;

    % set plot settings
    set(s1,'YLim',[0 OPT.angleThreshold]); title(s1,'relative angle'); xlabel(s1,'jarkus nr [-]'); ylabel(s1,'angle [^o]');
    set(s2,'YLim',[0 OPT.distanceThreshold]); title(s2,'relative distance'); xlabel(s2,'jarkus nr [-]'); ylabel(s2,'distance [m]');
    set(s3,'YLim',[0 180/pi/OPT.Rmin*1000]); title(s3,['curvature (error: ' num2str(mean(error)) ')']); xlabel(s3,'jarkus nr [-]'); ylabel(s3,'curvature [^o/km]');

    % FIXME
    % indicate areacode borders
    areas = [113 285 486 590 848 1142 1307 1441 1562 1636 1755 1865 1873 1893 2088 2178];
    areas = areas(areas >= transectRange(1) & areas <= transectRange(end)) - transectRange(1) + 1;
    
    if ~isempty(areas)
        plot(s1,ones(2,1)*areas,[0 OPT.angleThreshold],'Color','k','LineStyle',':');
        plot(s2,ones(2,1)*areas,[0 OPT.distanceThreshold],'Color','k','LineStyle',':');
        plot(s3,ones(2,1)*areas,[0 180/pi/OPT.Rmin*1000],'Color','k','LineStyle',':');
    end

    % plot maximum curvature known in current regulations
    plot(s3,[0 length(curvatures)],24*ones(1,2),'-g');
    
end

% plot coastal map with transects, shoreline and possibly fitted circles,
% if requested
if OPT.plotMap
    
    f2 = figure;
    
    % plot circles
    if ~isempty(circles); plot(circles(:,:,1)', circles(:,:,2)', '-g'); hold on; end;
    
    % plot transects
    plot(jarkusXGrid', jarkusYGrid', '-k'); hold on;
    
    % plot shoreline
    scatter(x,y,'or','MarkerFaceColor','r'); hold on;
    
    % set plot settings
    set(gca, 'XLim', [min(min(jarkusXGrid)) max(max(jarkusXGrid))], 'YLim', [min(min(jarkusYGrid)) max(max(jarkusYGrid))]);
    
    grid on;
    axis equal;
    
end