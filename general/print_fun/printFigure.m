function printFigure(fh, location, permission, ddriver, resolution)
%PRINTFIGURE  routine to save a figure to a .png-file
%
%   Routine saves the figure with figurehandle 'fh' to a predefined
%   location (including the figure file name). If no location defined, the
%   figure file will called like the caller function with '_Figure.png' at
%   the end in the path of the caller function. If printFigure is called
%   from the command window without a specified location, the figure will
%   be called 'printFigure.<ext>' and saved in the current working directory.
%   If permission is not 'overwrite' and the file name (either predefined 
%   or automatically generated) already exists, '_#' will be added to the 
%   file name, # being an integer. # will start with 1 and be highered 
%   until the file name is unique.
%
%   Syntax:
%   printFigure(fh, location, permission, ddriver, resolution)
%
%   Input:
%   fh         = figure handle
%   location   = string containing destination path and figure filename
%                without extension
%   permission = optional, if permission is set to 'overwrite', then a
%                possible existing file with the specified filename will be
%                overwritten
%   ddriver    = optional, device driver (see help print), default is '-dpng'
%   resolution = optional, resolution of plot, default is '-r300'
%
%   Example
%   printFigure
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 13 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%% check input
getdefaults('ddriver', '-dpng', 0, 'resolution', '-r300', 0);
if nargin == 0
    fh = gcf;
end
if nargin < 3
    permission = '';
end

%% create figure file name if not defined
if ~exist('location','var') || isempty(location)
    ST = dbstack;
    if length(ST)>1
        location = [evalin('caller','pwd') filesep,ST(2).name '_Figure']; % creates a figure file with the name of the caller function with '_Figure' at the end in the path of the caller function 
    else
        location = fullfile(cd, 'printFigure'); % creates a figure file called 'printFigure' in the current working directory
    end
end

%% remove possible extension from location (right extension will be added during printing
dotlocation = findstr(location, '.');
if ~isempty(dotlocation)
    location = location(1:dotlocation(end)-1);
end

%% make sure that file name is not '.png' only
if max(findstr(location, filesep)) == length(location)
    location = [location 'printFigure'];
end

[directory figurefilename] = fileparts(location);

%% print figure to tempfile in tempdir
print(fh, ddriver, resolution, [tempdir figurefilename])
[dummy1 dummy2 extension] = fileparts(getFileName(tempdir, '*', [], 1));
location = [location extension];

%% make sure that existing figure file is not overwritten
if exist(location, 'file')
    disp([location, ' already exists'])
    [directory figurefilename extension] = fileparts(location);
    if ~strcmp(permission, 'overwrite')
        id = 0;
        while exist(location, 'file') % as long as file name is not unique, higher # (in '_#')
            id=id+1;
            location = [directory filesep figurefilename '_' num2str(id) extension]; % add '_#' to the file name
        end
        disp(['Figure has been saved to ''',location,'''']);
    else
        disp('File has been overwritten by new figure')
    end
else
    disp(['Figure has been saved to ''',location,'''']);
end

%% move figure file from tempdir to final location
movefile([tempdir figurefilename extension], location)