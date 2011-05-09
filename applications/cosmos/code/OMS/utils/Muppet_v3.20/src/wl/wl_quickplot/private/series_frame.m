function [OSERIES,Ofilename]=series_frame(varargin)
%SERIES_FRAME Saves a figure in one of a series of bitmap images.
%   SERIES_FRAME(Handle)
%   Save the figure with the specified handle to a bitmap file in the
%   active series. Default: current figure.
%
%   S=SERIES_FRAME(...,S)
%   Add to the specified series, where S obtained from SERIES_INIT.
%   The number record of S is updated. The active series is changed
%   according to the settings of S.
%
%   S=SERIES_FRAME('state')
%   Return the state of the active series.
%
%   [S,FileName]=SERIES_FRAME(...)
%   Return the name of the created bitmap file.
%
%   Examples:
%
%     series_init('base','bmp')
%     for i=1:10
%       imagesc(magic(i))
%       series_frame
%     end
%
%     S=series_init('base','bmp')
%     for i=1:10
%       imagesc(magic(i))
%       S=series_frame(S,gcf);
%     end
%
%   See also SERIES_INIT.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
