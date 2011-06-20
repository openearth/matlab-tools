function SERINFO=series_init(varargin),
% SERIES_INIT initiates the creation of a series of bitmap files
%
%       SERIES_INIT(FileBase)
%       Initializes writing a series of TIFF files
%       The TIFF filenames will be FileBase000.tif, FileBase001.tif,
%       FileBase002.tif, ...
%
%       SERIES_INIT(...,'digits',M)
%       Uses M digits for numbering the files (default = 3).
%
%       SERIES_INIT(...,N)
%       Start counting at N.
%
%       SERIES_INIT(...,FileFormat)
%       Writes image files of the specified file format. The files
%       are created using the PRINT command:
%
%         'tif_' or 'tiff_' Tagged Image File Format (TIFF)
%         'jpg_' or 'jpeg_' Joint Photographic Experts Group (JPEG)
%         'png_'            Portable Network Graphics (PNG)
%
%       or using the IMWRITE command:
%
%         'tif' or 'tiff'   Tagged Image File Format (TIFF)
%         'jpg' or 'jpeg'   Joint Photographic Experts Group (JPEG)
%         'bmp'             Windows Bitmap (BMP)
%         'png'             Portable Network Graphics (PNG)
%         'hdf'             Hierarchical Data Format (HDF)
%         'pcx'             Windows Paintbrush (PCX)
%         'xwd'             X Window Dump (XWD)
%
%       S=SERIES_INIT(...)
%       Return a record to be used with SERIES_FRAME.
%
%       See also: SERIES_FRAME, IMWRITE, PRINT

% (c) copyright 18/10/2000
%     H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands
N=0;
M=3;
Type='tif_';

i=1;
while i<=nargin,
  if (i==1),
    filebase=varargin{i};
  elseif ischar(varargin{i}),
    switch lower(varargin{i}),
    case {'d','di','dig','digi','digit','digits'},
      i=i+1;
      if i>nargin,
        error('Error while reading digits.');
      end;
      M=varargin{i};
    case {'tif_','tiff_','png_','tif','tiff','jpg','jpeg','bmp','png','hdf','pcx','xwd'},
      Type=varargin{i};
    case 'tiff0', % backward compatibility
      Type='tiff_';
    otherwise,
      Type=varargin{i};
      if isequal(Type(end),'_') & ~isempty(strmatch(lower(Type(Type>58)),{'jpg_','jpeg_'}))
        % OK accept it, it is probably something like jpg_ or jpeg90_        
      else
        error(sprintf('Unrecognized option or file format: %s',varargin{i}));
      end
    end;
  else,
    N=varargin{i};
  end;
  i=i+1;
end;

SERIES_animation.Base   = filebase;
SERIES_animation.Type   = Type;
SERIES_animation.Number = N;
SERIES_animation.Digits = M;

series_frame('store',SERIES_animation); % update SERIES_animation field in SERIES_FRAME ...

if nargout>0,
  SERINFO=SERIES_animation;
end;