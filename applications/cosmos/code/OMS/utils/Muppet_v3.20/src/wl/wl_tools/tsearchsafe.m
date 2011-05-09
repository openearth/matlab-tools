function theResult = tsearchsafe(x, y, tri, xi, yi)

% tsearchsafe -- TSEARCH for arbitrary triangles.
%  tsearchsafe('demo') demonstrates itself by
%   invoking "tsearch(10)".
%  tsearchsafe(NTRI, NPTS) demonstrates itself with
%   NTRI triangle-points and NPTS test-points
%   (default = NTRI=10, NPTS=10*NTRI).  The
%   NTRI points are triangulated, then 1/4
%   of the resulting triangles are randomly
%   chosen as subjects for the demonstration.
%  tsearchsafe(x, y, tri, xi, yi) mimics TSEARCH for
%   an arbitrary group of non-overlapping triangles,
%   not necessarily produced by DELAUNAY.  The result
%   is an array of triangle indices for those points
%   that lie strictly inside a triangle.  All other
%   points are represented by NaN.  (The TSEARCH
%   routine is not reliable for non-Delaunay sets of
%   triangles.)
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 04-Apr-2000 15:24:36.
% Updated    04-Apr-2000 16:25:19.

if nargout > 0, theResult = []; end

if nargin < 1, x = 'demo'; end

if isequal(x, 'demo'), help(mfilename), x = 10; end
if ischar(x), x= eval(x); end

if length(x) == 1
	ntriangles = max(x, 5);
	if nargin < 2, y = 10*x; end
	if ischar(y), y = eval(y); end
	npoints = max(y, 10);
	x = 0.75*rand(ntriangles, 1) + 1/8;
	y = 0.75*rand(ntriangles, 1) + 1/8;
	tri = delaunay(x, y);
	t = [];
	while sum(t) < 3
		t = (rand(size(tri, 1), 1) < 0.25);
	end
	tri = tri(t, :);
	xi = rand(npoints, 1);
	yi = rand(npoints, 1);
	tic;
	result = feval(mfilename, x, y, tri, xi, yi);
	disp([' ## Elapsed time: ' num2str(toc)])
	if nargout > 0
		theResult = result;
	else
		hold off
		trimesh(tri, x, y, zeros(size(x)), ...
			'EdgeColor', [0 0 1], ...
			'FaceColor', 'none', ...
			'LineWidth', 0.5)
		f = find(~isnan(result));
		g = find(isnan(result));
		hold on
		if npoints > 1000
			plot(xi(f), yi(f), 'g.', xi(g), yi(g), 'r.')
		else
			plot(xi(f), yi(f), 'g+', xi(g), yi(g), 'r+')
		end
		hold off
		view(2)
		grid off
		try, zoomsafe, catch, zoom on, end
		figure(gcf)
		set(gcf, 'Name', [mfilename ' ' int2str(ntriangles) ' ' int2str(npoints)])
		if nargout > 0, theResult = result; end
	end
	return
end

result = zeros(size(xi)) + NaN;

% Compute bounding rectangles for triangles.

t = tri.';
xmin = min(x(tri.')).';
xmax = max(x(tri.')).';
ymin = min(y(tri.')).';
ymax = max(y(tri.')).';

% Eliminate out-of-bounds points from
%  further consideration.

g = find(xi >= min(xmin) & xi <= max(xmax) & ...
			yi >= min(ymin) & yi <= max(ymax));

if (0)
	eliminated = length(xi) - length(g)
end

% For each point, find all the triangles
%  for which each point lies within their
%  bounding rectangles, then perform TSEARCH
%  on each one.  We depend on the assumption
%  that TSEARCH is reliable for a single
%  triangle and many points.

% NOTE: By pre-sorting the triangles and the (xi, yi)
%  points, we could reduce the calculation time, by
%  (say) working from right-to-left.
%  Also, whereas we presently loop over the (xi, yi),
%  we could also do the opposite, depending on the
%  relative numbers of triangles and (xi, yi) points.

for j = 1:length(g)
	k = g(j);
	xtemp = xi(k);
	ytemp = yi(k);
	f = find( ...   % Points strictly inside the bounds.
		(xtemp >= xmin) & ...
		(xtemp <= xmax) & ...
		(ytemp >= ymin) & ...
		(ytemp <= ymax));
	if any(f)
		for i = 1:length(f)
			index = tsearch(x, y, tri(f(i), :), xtemp, ytemp);
			if ~isnan(index)
            result(k) = f(i);
            break
			end
		end
	end
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
