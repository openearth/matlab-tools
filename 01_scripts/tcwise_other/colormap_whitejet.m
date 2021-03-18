function map = colormap_whitejet(hax,N)
% COLORMAP_WHITEJET Change colormap to jet with 0 as white
%   colormap_whitejet(), without any arguments, changes the colormap to a
%   jet colormap with 0 as white, and changes the color axes limits from 0
%   to the current color axes maximum.
%
%   map = colormap_whitejet(...) returns the colormap.
%
%   ... = colormap_whitejet(hax,N) uses the axes specified by "hax" instead
%   of the current axes, and creates a colormap with N values. Note that
%   both inputs are optional.
%
%   Inputs (Optional):
%   hax - Handle to axes (default: current axes)
%     N - # of rows of desired colormap (default: 256)
%
%   Outputs (Optional):
%   map - Resultant "white jet" colormap
%   Nade Sritanyaratana
%   Created August 14, 2014
%   Copyright 2014 The MathWorks, Inc.
if ~exist('N','var')
    N = 256;
else
    validateattributes(N,{'numeric'},{'integer'});
end
if ~exist('hax','var')
    hax = gca;
elseif ~(ishghandle(hax)&&strcmp(get(hax,'Type'),'axes'))
    error('MATLAB:colormap_whitejet:InvalidAxes', ...
        '''hax'' must be a graphics handle to an axes object.');
end
[cmin,cmax] = caxis(hax);
caxis([0,cmax])
map = jet(N); % current colormap
map(1,:) = [1,1,1];
colormap(map)
if nargout==0
    clear map;
end
end