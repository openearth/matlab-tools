function varargout=ui_type(varargin)
%UI_TYPE Simple selection dialog.
%   [SelectedType,SelectedNr]=UI_TYPE(Types)
%   creates a dialog in which the user can select one of the type
%   strings specified in the cell string array Types. The selected type
%   string is returned as SelectedType, its number in the list is
%   returned as SelectedNr.
%
%   Default type can be specified as an additional input arguments:
%   ...=UI_TYPEANDNAME(Types,DefaultType)
%
%   The dialog name/title is by default empty. It can be set by
%   specifying the keyword WINDOWTITLE and the title:
%   ...=UI_TYPEANDNAME(...,'windowtitle',Title)
%
%   See also UI_TYPEANDNAME

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
