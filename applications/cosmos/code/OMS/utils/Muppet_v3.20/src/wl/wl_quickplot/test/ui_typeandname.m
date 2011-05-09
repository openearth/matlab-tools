function varargout=ui_typeandname(varargin)
%UI_TYPEANDNAME  Selection dialog with name specification.
%   [SelectedType,SelectedName,SelectedNr]=UI_TYPEANDNAME(Types)
%   creates a dialog in which the user can select one of the type
%   strings specified in the cell string array Types. The selected type
%   string is returned as SelectedType, its number in the list is
%   returned as SelectedNr. The user can also specify a name, which is
%   returned as SelectedName.
%
%   Default type and name can be specified as two additional input
%   arguments:
%   ...=UI_TYPEANDNAME(Types,DefaultType,DefaultName)
%
%   The dialog name/title is by default empty. It can be set by
%   specifying the keyword WINDOWTITLE and the title:
%   ...=UI_TYPEANDNAME(...,'windowtitle',Title)
%
%   If the user should only select a quantity from a list (no
%   additional name associated with the selection) you can simplify the
%   dialog accordingly by specifying the keyword SPECIFYNAME and as
%   value NO. The number of output arguments is reduced to two, namely
%   only the SelectedType and SelectedNr:
%   [SelectedType,SelectedNr]=UI_TYPEANDNAME(...,'specifyname','no')
%
%   See also UI_TYPE

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
