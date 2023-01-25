function XY = pointcloud_thinner(XY,min_dist,split_amount)
% POINTCLOUD_THINNER efficiently reduces a 2D-pointcloud based on min. allowed distance.
%
% The function POINTCLOUD_THINNER efficiently thins out a 2-dimensional
% pointcloud, based on a min. allowed distance between any 2 points. All
% points wihtin this area are discarded, except for the test-point itself.
% If the pointcloud contains more than 2 dimensions, filtering is performed
% on x and y coordinates only, which are assumed to be the first two
% columns. Other dimensions or properties are maintained per row. 
%________
% Syntax:
%
%      XY_new = pointcloud_thinner(XY,min_dist);
%
% Input variables:
%
%      XY         The pointcloud to be thinned out, is a matrix of size
%                 [M,2] with horizontal and vertical points. One could
%                 also supply a [M,N] matrix, in which case it will assume
%                 [M,1] to be the X-values, and [M,2] to be the Y-values.
%                 All other columns will be maintained rowwise.
%      min_dist   The minimum distance by which points will be removed.
%                 After running the function, the minimum distance between
%                 any 2 points in (x,y) space will be at least min_dist.
%      split_amount For efficient processing the pointcloud may be split in
%                 several parts. split_amount is the maximum length of such
%                 part. A final check will be performed against the
%                 complete reduced pointcloud. Current default is 1e5.
%
% Output variables:
%
%      XY_new     Ouput pointcloud created by POINTCLOUD_THINNER [M,N].
%
% _____
% Note:
%
% The function is made efficient by creating partitions of the data that
% have a size most that is most effectively handled by Matlab, and can
% therefore handle data with multiple millions of points.
%
% ________
% Example:
%
% Thin out a randomized pointcloud:
%
% XY_ori = rand(200000,2);
% XY_new = pointcloud_thinner(XY_ori,0.01);
% p_1 = plot(XY_ori(:,1),XY_ori(:,2),'k.'); hold on;
% p_2 = plot(XY_new(:,1),XY_new(:,2),'r.');
% set(p_2,'markersize',get(p_2,'markersize')+4);
% legend('Original pointcloud','Thinned pointcloud');

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       Deltares
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
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $

%% Code start
if exist('split_amount','var') ~= 1
    split_amount = 100000;
    % Tests have shown that once you're searching in arrays longer than 100.000
    % the amount of time required starts to scale linearly (below this amount,
    % search times are roughly equal). The test could change in the future
    % (better computers, more efficient Matlab, etc.) and is indicated below:
    %
    % for jj=1:100; for ii=[10.^[0:8]]; tic; find([1:ii].^2 == 1);
    % val(log10(ii)+1,jj)=toc; end; end; disp(round([10.^[0:8]]));
    % disp(mean(val'));
end

if isnumeric(XY)
    if size(XY,2)<2
        error('Your input matrix should have at least 2 dimensions');
    elseif size(XY,1)<2
        error('Your XY data should have at least 2 points');
    elseif size(XY,1) < size(XY,2)
        warning('Your pointcloud has more dimensions than points! [%i, %i]\nPlease flip your data if this is incorrect\n',size(XY,1),size(XY,2));
    end
else
    error('XY input should be a matrix');
end

dx = diff([min(XY(:,1)) max(XY(:,1))]);
dy = diff([min(XY(:,2)) max(XY(:,2))]);

if dy == 0 || dx/dy > 1
    % Pointcloud is longest along the x-axis:
    [XY]=sortrows(XY,1);
elseif dx == 0 || dx/dy <= 1
    % Pointcloud is longest along the y-axis:
    [XY]=sortrows(XY,2);
end

ori_size = size(XY,1);

% Minimum distance check is based on distance^2, to avoid computation of sqrt.
min_distsq=min_dist.^2;


%% Filtering
% The pointcloud is split in chuncks of [split_amount] rows for faster
% filtering. If size(XY,1)<split_amount, final filtering is performed
% imediately.
number_of_partitions  = ceil(size(XY,1)./split_amount);
next_iter             = true;

filter_tel = 1;
number_of_pts_removed = [];

while number_of_partitions > 1 && next_iter
    fprintf(1,'Filter #%i\n',filter_tel);
    clear XY_parts;
    number_of_pts_removed(filter_tel) = 0; %#ok<*AGROW>
    partition_size = floor(size(XY,1)/number_of_partitions);

    for ii=1:number_of_partitions
        inds = ([ii-1 ii] .* partition_size) + [1 0];
        if ii == number_of_partitions
            inds = [inds(1) size(XY,1)];
        end
        XY_parts{ii} = XY(inds(1):inds(2),:);
    end

    tic;
    XY_new = [];
    for partition = 1:length(XY_parts)
        for ii=1:length(XY_parts{partition})
            if ~isnan(XY_parts{partition}(ii,1))
                % All points closer than min_dist are set to nan (viz.
                % removed from data) except for the point itself.
                % Comparison based on distance^2 omits computing the sqrt,
                % which saves a lot of time!
                % Logical indexing suffices and is much faster than calling
                % find.
                % Duplicate points (same (x,y)) are now removed too.
                %XY_parts{partition}(find(sqrt(((XY_parts{partition}(:,1) - XY_parts{partition}(ii,1)).^2) + ((XY_parts{partition}(:,2) - XY_parts{partition}(ii,2)).^2)) < min_dist & sqrt(((XY_parts{partition}(:,1) - XY_parts{partition}(ii,1)).^2) + ((XY_parts{partition}(:,2) - XY_parts{partition}(ii,2)).^2)) > 0),:) = NaN;
                mask = (((XY_parts{partition}(:,1) - XY_parts{partition}(ii,1)).^2) + ((XY_parts{partition}(:,2) - XY_parts{partition}(ii,2)).^2)) < min_distsq;
                mask(ii) = 0;
                if any(mask)
                    XY_parts{partition}(mask,:) = NaN;
                end
            end
        end
        fprintf(1,'Filter #%i: partition %2i/%2i - ETA: %4.1fmin.\n', filter_tel, partition, number_of_partitions, toc*(1-partition/length(XY_parts))/(partition/length(XY_parts))/60);
        XY_new = [XY_new; XY_parts{partition}(~isnan(XY_parts{partition}(:,1)),:)];
        number_of_pts_removed(filter_tel) = number_of_pts_removed(filter_tel) + sum(isnan(XY_parts{partition}(:,1)));
    end
    
    if number_of_pts_removed(filter_tel) == 0 || number_of_pts_removed(filter_tel) < (0.001 * size(XY,1))
        next_iter = false;
    end
    
    number_of_partitions  = ceil(size(XY_new,1)./split_amount);
    XY = XY_new;
    filter_tel = filter_tel + 1;
    fprintf(1,'\n');
end

%% Final filtering
% To assert if all points in different parts also differ at least min_dist,
% a final filter step is performed on the whole filtered pointcloud.
tic;
fprintf(1,'Final filter\n');
for ii=1:size(XY,1)
    if rem(ii,round(size(XY,1)/100,0)) == 0 %ii/(split_amount/100) == round(ii/(split_amount/100))
        fprintf(1,'Finalizing: Step %5i/%5i - %4.1f%% of total - ETA: %5.1fmin.\n', ii, size(XY,1), ii/size(XY,1)*100, toc*(1-ii/size(XY,1))/(ii/size(XY,1))/60);
    end
    if ~isnan(XY(ii,1))
        % All points closer than min_dist are set to nan (viz. removed from
        % data) except for the point itself.
        % Comparison based on distance^2 omits computing the sqrt, which
        % saves a lot of time!
        % Logical indexing suffices and is much faster than calling find.
        % Duplicate points (same (x,y)) are now removed too.
        %XY(find(sqrt(((XY(:,1) - XY(ii,1)).^2) + ((XY(:,2) - XY(ii,2)).^2)) < min_dist & sqrt(((XY(:,1) - XY(ii,1)).^2) + ((XY(:,2) - XY(ii,2)).^2)) > 0),:) = NaN;
        mask = (((XY(:,1) - XY(ii,1)).^2) + ((XY(:,2) - XY(ii,2)).^2)) < min_distsq;
        mask(ii) = 0;
        if any(mask)
            XY(mask,:) = NaN;
        end
    end
end
number_of_pts_removed(end+1) = sum(isnan(XY(:,1)));
XY = XY(~isnan(XY(:,1)),:);

fprintf(1,'\nScript completed succesfully.\n');
fprintf(1,'Removed a total of %i points from the %i point dataset.\n', sum(number_of_pts_removed), ori_size);
fprintf(1,'Points removed in step %i: %i\n',[1:length(number_of_pts_removed);number_of_pts_removed])
fprintf(1,'Thinned dataset (min. distance %g) has a total of %i points.\n', min_dist, size(XY,1));

%EOF