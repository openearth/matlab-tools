function SERINFO=series_init(varargin),
%SERIES_INIT Initiates the creation of a series of bitmap files.
%   SERIES_INIT('FileBase')
%   Initializes writing a series of TIFF files
%   The TIFF filenames will be FileBase000.tif, FileBase001.tif,
%   FileBase002.tif, ...
%
%   SERIES_INIT(...,'digits',M)
%   Uses M digits for numbering the files (default = 3).
%
%   SERIES_INIT(...,'subcase',CaseID)
%   Appends string CaseID after the number and before the extension,
%   e.g. SERIES_INIT('FileBase','subcase','A') will generate files
%   called FileBase000A.tif, FileBase001A.tif, ...
%
%   SERIES_INIT(...,N)
%   Start counting at N.
%
%   SERIES_INIT(...,FileFormat)
%   Writes image files of the specified file format. The files
%   are created using the PRINT command:
%
%     'tif_' or 'tiff_' Tagged Image File Format (TIFF)
%     'jpg_' or 'jpeg_' Joint Photographic Experts Group (JPEG)
%     'bmp_'            Windows Bitmap (BMP)
%     'png_'            Portable Network Graphics (PNG)
%     'hdf_'            Hierarchical Data Format (HDF)
%
%   or using the IMWRITE command:
%
%     'tif' or 'tiff'   Tagged Image File Format (TIFF)
%     'jpg' or 'jpeg'   Joint Photographic Experts Group (JPEG)
%     'bmp'             Windows Bitmap (BMP)
%     'png'             Portable Network Graphics (PNG)
%     'hdf'             Hierarchical Data Format (HDF)
%     'pcx'             Windows Paintbrush (PCX)
%     'xwd'             X Window Dump (XWD)
%
%   S=SERIES_INIT(...)
%   Return a record to be used with SERIES_FRAME.
%
%   See also SERIES_FRAME, IMWRITE, PRINT.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
