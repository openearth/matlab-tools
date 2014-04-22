function writeMDA(mda_filename_tmp, baseline_ldb, varargin)
%write MDA : Writes a unibest mda-file (also computes cross-shore distance between reference line and shoreline)
%
%   Syntax:
%     function writeMDA(filename, baseline, resolution, shoreline, dx)
% 
%   Input:
%     mda_filename        string with output filename of mda-file
%     baseline            string with filename of polygon of reference line  OR  X,Y coordinates of ref.line [Nx2]
%     resolution          (optional) specify max. distance between two supporting points [m](default = 10 m)
%     shoreline           (optional) string with filename of polygon of shoreline (default : baseline = shoreline)
%     dx                  (optional) resolution to cut up baseline (default = 0.05)
% 
%   Output:
%     .mda file
%
%   Example:
%     x = [1:10:1000]';
%     y = x.^1.2;
%     writeMDA('test.mda', [x,y]);
%     writeMDA('test.mda', [x,y], [x+20,y]);
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%       freek.scheel@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Check and handle the function input:

keywords.coastline_ldb   = [];
keywords.min_resolution  = [];
keywords.baseline_dx     = [];
keywords.plot_figures    = 0;

if nargin == 0
    default_keywords = keywords
    return
end

if odd(length(varargin)) % Check for input consistency
    error('Odd number of input parameters for <keyword,value> pairs supplied, please check this');
end

% Set user defined changes to default keywords:

keywords = setproperty(keywords,varargin);

% baseline_ldb_tmp checks:
if ~isempty(baseline_ldb)
    if isstruct(baseline_ldb)
        baseline_ldb = cell2mat(baseline_ldb);
    end
    if isstr(baseline_ldb)
        baseline_ldb = landboundary('read',baseline_ldb);
    end
    if isnumeric(baseline_ldb)
        if length(size(baseline_ldb)) == 2
            ldb_size = size(baseline_ldb);
            if ~isempty(find(ldb_size==2))
                if length(find(ldb_size==2))==1
                    if ldb_size(1) == 2
                        baseline_ldb = baseline_ldb'
                    else
                        % Just a normal ldb is found, good
                    end
                else
                    % [2x2] is found, bit small, but alright, we'll use it..
                end
            else
                error(['Unexpected format of baseline ldb, should be [Nx2] or [2xN], it is [' num2str(size(baseline_ldb)) ']']);
            end
        else
            error(['Unexpected dimension of baseline ldb, should be [Nx2] or [2xN], it is [' num2str(size(baseline_ldb)) ']']);
        end
        % Check for NaN's in the baseline:
        if sum(sum(isnan(baseline_ldb)))>0
            % Remove all preceding and trailing NaN's if they exist
            while sum(isnan(baseline_ldb(end,:)))>0
                baseline_ldb(end,:) = [];
            end
            while sum(isnan(baseline_ldb(1,:)))>0
                baseline_ldb(1,:) = [];
            end
            if sum(sum(isnan(baseline_ldb)))>0
                plot(baseline_ldb(:,1),baseline_ldb(:,2),'k'); hold on; axis equal; grid on; title('Your baseline ldb including NaN connected points (red circles)');
                plot(baseline_ldb([find(sum(isnan(baseline_ldb),2)./sum(isnan(baseline_ldb),2)==1)+1; find(sum(isnan(baseline_ldb),2)./sum(isnan(baseline_ldb),2)==1)-1],1),baseline_ldb([find(sum(isnan(baseline_ldb),2)./sum(isnan(baseline_ldb),2)==1)+1; find(sum(isnan(baseline_ldb),2)./sum(isnan(baseline_ldb),2)==1)-1],2),'ro');
                error('NaN''s are found cutting-up your baseline (see figure), this is not allowed, please use the ldbTool or RGFGRID/QUICKIN to change this');
            end
        end
    else
        error(['Unexpected baseline ldb input, should be a [Nx2] or [2xN] vector or ldb filename']);
    end
else
    error('empty baseline_ldb specified, please check this')
end
baseline     = baseline_ldb;
baseline_ori = [];

% mda_filename_tmp checks:
if ~isempty(mda_filename_tmp)
    if isstruct(mda_filename_tmp)
        if length(mda_filename_tmp)==1
            mda_filename_tmp = cell2mat(mda_filename_tmp);
        else
            error('too many mda_filename names specified, please check this')
        end
    end
    if isstr(mda_filename_tmp)
        if length(mda_filename_tmp)<5
            mda_filename_tmp = [mda_filename_tmp '.MDA'];
        else
            if ~(strcmp(mda_filename_tmp(1,end-3:end),'.mda') | strcmp(mda_filename_tmp(1,end-3:end),'.MDA'))
                mda_filename_tmp = [mda_filename_tmp '.MDA'];
            end
        end
    else
        error('mda_filename should be specified as a string, please check this')
    end
else
    error('empty mda_filename specified, please check this')
end
mda_filename = mda_filename_tmp;

% baseline_dx checks:
if ~isempty(keywords.baseline_dx)
    if isstruct(keywords.baseline_dx)
        keywords.baseline_dx = cell2mat(keywords.baseline_dx);
    end
    if ~isnumeric(keywords.baseline_dx)
        error('Please specify a number for baseline_dx');
    else
        if length(keywords.baseline_dx)>1
            error('Please specify one number for baseline_dx');
        end
    end
end

% min_resolution checks:
if ~isempty(keywords.min_resolution)
    if isstruct(keywords.min_resolution)
        keywords.min_resolution = cell2mat(keywords.min_resolution);
    end
    if ~isnumeric(keywords.min_resolution)
        error('Please specify a number for min_resolution');
    else
        if length(keywords.min_resolution)>1
            error('Please specify one number for min_resolution');
        end
    end
end

% plot_figures checks:
if ~isempty(keywords.plot_figures)
    if isstruct(keywords.plot_figures)
        keywords.plot_figures = cell2mat(keywords.plot_figures);
    end
    if ~isnumeric(keywords.plot_figures)
        error('Please specify true/false (1/0) for plot_figures');
    else
        if length(keywords.plot_figures)>1
            error('Please specify true/false (1/0) for plot_figures');
        else
            if keywords.plot_figures ~= 0
                keywords.plot_figures = 1;
            end
        end
    end
else
    error('Please specify true/false (1/0) for plot_figures');
end

% coastline_ldb checks:
if ~isempty(keywords.coastline_ldb)
    coast_is_baseline = 0;
    if isstruct(keywords.coastline_ldb)
        keywords.plot_figures = cell2mat(keywords.coastline_ldb);
    end
    if isstr(keywords.coastline_ldb)
        keywords.coastline_ldb = landboundary('read',keywords.coastline_ldb);
    end
    if isnumeric(keywords.coastline_ldb)
        if length(size(keywords.coastline_ldb)) == 2
            ldb_size = size(keywords.coastline_ldb);
            if ~isempty(find(ldb_size==2))
                if length(find(ldb_size==2))==1
                    if ldb_size(1) == 2
                        keywords.coastline_ldb = keywords.coastline_ldb'
                    else
                        % Just a normal ldb is found, good
                    end
                else
                    % [2x2] is found, bit small, but alright, we'll use it..
                end
            else
                error(['Unexpected format of coastline ldb, should be [Nx2] or [2xN], it is [' num2str(size(keywords.coastline_ldb)) ']']);
            end
        else
            error(['Unexpected dimension of coastline ldb, should be [Nx2] or [2xN], it is [' num2str(size(keywords.coastline_ldb)) ']']);
        end
    end
    coastline = keywords.coastline_ldb;
else
    coast_is_baseline = 1;
    coastline = baseline;
end

%% Do some data manipulation

if ~isempty(keywords.baseline_dx)
    % add_equidist_points is to be changed by Freek
    baseline_ori = baseline;
    baseline = add_equidist_points(keywords.baseline_dx,baseline,'equi');
    baseline = baseline(2:end-1,:);
end

% loop through points of the baseline and find for each point the
% perpendicular distance to the coastline if coast ~= baseline
if coast_is_baseline
    y = zeros(size(baseline,1),1);
else
    max_dist_to_coast = ceil(sqrt(sum((diff([min(coastline(:,1)) min(coastline(:,2)); max(coastline(:,1)) max(coastline(:,2))])).^2)));
    if size(coastline,1)>10000 & size(baseline,1)>5
        disp(['You''ve supplied quite a large coastline landboundary ([Nx2] with N=' num2str(size(coastline,1)) ')']);
        disp('Determining the cross-shore distance from the baseline to the coastline may take some time');
        disp('You are advised to cut up the coastline to parts really needed for this analysis (if possible)');
    end
    disp(' ');
    fprintf(1,'\nComputing cross-sectional distances from baseline to coastline:      ')
    for ii=1:size(baseline,1)
        fprintf(1,[repmat('\b',1,(length(num2str(100*((ii-1)/size(baseline,1)),'%9.0f'))+2)) num2str(100*(ii/size(baseline,1)),'%9.0f') ' %%']);
        if ii==1
            baseline_angle(ii,1) = mod((xy2degN(baseline(ii,1),baseline(ii,2),baseline(ii+1,1),baseline(ii+1,2)) - 90),360);
        elseif ii==size(baseline,1)
            baseline_angle(ii,1) = mod((xy2degN(baseline(ii-1,1),baseline(ii-1,2),baseline(ii,1),baseline(ii,2)) - 90),360);
        else
            baseline_angle(ii,1) = mod((xy2degN(baseline(ii-1,1),baseline(ii-1,2),baseline(ii+1,1),baseline(ii+1,2)) - 90),360);
        end
        [X_crs Y_crs] = polyintersect([baseline(ii,1) baseline(ii,1)+(sind(baseline_angle(ii,1))*max_dist_to_coast)],[baseline(ii,2) baseline(ii,2)+(cosd(baseline_angle(ii,1))*max_dist_to_coast)],coastline(:,1),coastline(:,2));
        if keywords.plot_figures
            if ii == 1
                figure;
                if ~isempty(baseline_ori)
                    plot(baseline(:,1),baseline(:,2),'.-','linewidth',2,'markersize',16,'color','k'); hold on; grid on; box on; axis equal;
                    plot(baseline_ori(:,1),baseline_ori(:,2),'x','linewidth',2,'markersize',14,'color','k'); % [139 69 19]/255
                else
                    plot(baseline(:,1),baseline(:,2),'x-','linewidth',2,'markersize',14,'color','k'); hold on; grid on; box on; axis equal;
                end
                plot(coastline(:,1),coastline(:,2),'-','linewidth',3,'color',[238 201 0]/255);
            end
        end
        if size(X_crs,1)==0
            y(ii,1) = NaN;
        else
            if size(X_crs,1)>1
                X_crs = X_crs(find(sqrt(((X_crs - baseline(ii,1)).^2) + ((Y_crs - baseline(ii,2)).^2)) == min(sqrt(((X_crs - baseline(ii,1)).^2) + ((Y_crs - baseline(ii,2)).^2)))),1);
                Y_crs = Y_crs(find(sqrt(((X_crs - baseline(ii,1)).^2) + ((Y_crs - baseline(ii,2)).^2)) == min(sqrt(((X_crs - baseline(ii,1)).^2) + ((Y_crs - baseline(ii,2)).^2)))),1);
            end
            y(ii,1) = sqrt(((X_crs - baseline(ii,1)).^2) + ((Y_crs - baseline(ii,2)).^2));
            if keywords.plot_figures
                plot([baseline(ii,1) X_crs],[baseline(ii,2) Y_crs],'k--','linewidth',2); drawnow;
                text(mean([baseline(ii,1) X_crs]),mean([baseline(ii,2) Y_crs]),['y = ' num2str(y(ii,1),'%9.1f') ' mtr.'],'horizontalalignment','center');
            end
        end
        if ii==size(baseline,1)
            fprintf(1,[repmat('\b',1,(length(num2str(100*(ii/size(baseline,1)),'%9.0f'))+2)) num2str(100*(ii/size(baseline,1)),'%9.0f') ' %%']); pause(0.01);
            fprintf(1,'\n');
            disp(' ');
        end
    end
    % Remove preceeding and trailing NaN's:
    num_ini_nans_removed = 0;
    num_end_nans_removed = 0;
    while isnan(y(end,1))
        if keywords.plot_figures
            plot(baseline(end,1),baseline(end,2),'rx','markersize',16,'linewidth',3);
        end
        y(end,:)              = [];
        baseline(end,:)       = [];
        baseline_angle(end,:) = [];
        num_end_nans_removed = num_end_nans_removed + 1;
    end
    while isnan(y(1,1))
        if keywords.plot_figures
            plot(baseline(1,1),baseline(1,2),'rx','markersize',16,'linewidth',3);
        end
        y(1,:)              = [];
        baseline(1,:)       = [];
        baseline_angle(1,:) = [];
        num_ini_nans_removed = num_ini_nans_removed + 1;
    end
    
    if sum(isnan(y))>0
        if keywords.plot_figures
            for ii = find(isnan(y)==1)'
                plot([baseline(ii,1) baseline(ii,1)+(sind(baseline_angle(ii,1))*max_dist_to_coast)],[baseline(ii,2) baseline(ii,2)+(cosd(baseline_angle(ii,1))*max_dist_to_coast)],'r--','linewidth',3);
            end
            xlim([min([baseline(:,1); coastline(:,1)]) max([baseline(:,1); coastline(:,1)])]);
            ylim([min([baseline(:,2); coastline(:,2)]) max([baseline(:,2); coastline(:,2)])]);
            title('The red line(s) indicate the cross-section(s) without perpendicular coastline data');
            drawnow;
            error(['Not all internal baseline points have perpendicular coastline data (you can check the red lines in the figure for help)']);
        end
        error(['Not all internal baseline points have perpendicular coastline data (you can set plot_figures = true (1) to help you show the problem in a figure)']);
    end
    
    if num_ini_nans_removed>0
        disp(['ATTENTION: ' num2str(num_ini_nans_removed) ' initial baseline points were removed as no perpendicular coastline data was found']);
    end
    if num_end_nans_removed>0
        disp(['ATTENTION: ' num2str(num_end_nans_removed) ' trailing baseline points were removed as no perpendicular coastline data was found']);
    end
    if ((num_ini_nans_removed+num_end_nans_removed)>0) & (keywords.plot_figures == 0)
        disp('If you want, you can inspect this behaviour by setting plot_figures to true (1)');
    elseif ((num_ini_nans_removed+num_end_nans_removed)>0) & (keywords.plot_figures == 1)
        disp('Please check the figure to see if you agree with this automated removal');
    end
    
end

% Add additional gridpoints in between the baselinepoints if keywords.min_resolution requires this:

if ~isempty(keywords.min_resolution)
    N = [0; ceil(diff(pathdistance(baseline(:,1),baseline(:,2)))/keywords.min_resolution)];
    N = min(99,N); % limiter
    N(find(N(2:end)<1)+1) = 1; % Make sure each value (except the first) is above 0 
else
    N = [0; ones(size(baseline,1)-1,1)];
end
Ray = [1:size(baseline,1)]';

%% Write everything to the MDA file:

fid=fopen(mda_filename_tmp,'wt');
fprintf(fid,'%s\n',' BASISPOINTS');
fprintf(fid,'%4.0f\n',length(N));
fprintf(fid,'%s\n','     Xw             Yw             Y              N              Ray');
fprintf(fid,'%13.1f   %13.1f %11.2f %11.0f %11.0f\n',[baseline y(:) N Ray]');
fclose(fid);
