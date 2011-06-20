function folder = uigetfolder(title, initial_path)
%UIGETFOLDER   Standard Windows browse for folder dialog box.
%
%   folder = uigetfolder(title, initial_path)
%
%   Output: folder       = selected folder (empty string if dialog cancelled)
%   Inputs: title        = title string (OPTIONAL)
%           initial_path = initial path (OPTIONAL, defaults to PWD)
%
%   Examples:   folder = uigetfolder                          - default title and initial path
%               folder = uigetfolder('Select results folder') - default initial path
%               folder = uigetfolder([], 'C:\Program Files')  - default title
%
%   See also UIGETFILE, UIPUTFILE

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%-----------------------------------------------------------------------------------------------


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
