function [Settings,fn]=md_print(varargin)
%MD_PRINT Send a figure to a printer.
%   MD_PRINT(FigureHandles)
%   Opens the user interface for the specified figures (in the
%   specified order). If no argument is specified, the command works
%   on the current figure (if it exists).
%
%   Settings=MD_PRINT(...)
%   Returns the (last) selected output mode and the settings. To use
%   the UI for selection only (i.e. no actual printing/saving of a
%   figure), use an empty list of figures: Settings=MD_PRINT([])
%
%   MD_PRINT(FigureHandles,Settings,FileName)
%   Prints the specified figures using the specified settings.
%   The filename is optional for output to file (PS/EPS/TIF/JPG/EMF/PNG).
%
%   See also PRINT.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%  Painters   'Printer Name'         'PC/WIN'            'UNIX'    'COLOR'
%  COLOR=0 Never, COLOR=1 User Specified, COLOR=2 Always

% Called by print -dsetup:
%#function orient


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
