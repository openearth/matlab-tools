function tif_init(filebase,N),
% TIF_INIT initiates the creation of a series of TIFF files
%
%       TIF_INIT(FileBase)
%       Initializes writing a series of TIFF files
%       The TIFF filenames will be FileBase000.tif, FileBase001.tif,
%       FileBase002.tif, ...
%
%       TIF_INIT(FileBase,N)
%       Start counting at N.
%
%       See also: TIF_FRAME

% (c) 1998-2000
% Author:  H.R.A.Jagers
%          University of Twente / Delft Hydraulics, The Netherlands
%          bert.jagers@wldelft.nl

TIF_animation.Base = filebase;
if nargin==2,
  TIF_animation.Step = N;
else,
  TIF_animation.Step = 0;
end;
tif_frame(TIF_animation); % update TIF_animation field in TIF_FRAME ...
