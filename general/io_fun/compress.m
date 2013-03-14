function OPT = compress(fileNameOut,fileNameIn,varargin)
%COMPRESS  compresses files to a zip, 7z, iso etc, using 7zip
%
% Supports the following formats: 7Z (default), GZIP, BZIP2, TAR, ISO, UDF
%
%   Syntax:
%       OPT = compress(fileNameOut,fileNameIn,varargin)
%
%   Input:
%       fileNameIn   = file(s) to compress
%       $varargin    = keyword/value pairs for additional options where the 
%       following <keyword,value> pairs have been implemented (values 
%       indicated are the current default settings):
%
%       'outpath'   , []        : if nothing specified the original
%                                 filelocation is used
%       'quiet'     , false     : do not surpress output
%       'gui'       , false     : view progress with 7z gui
%       'args'      , '-mx9'    : optional 7z arguments. Specify compresson
%                                 level with '-mx0' (no compression)
%                                 through '-mx9' (ultra compression)
%                                 add '-mmt' for multithreading (example
%                                 '-mx9 -mmt'
%       'type'      , '-t7z'    : Format of compressed file
%                                 Choose from:    
%                                 Type switch:      '-t7z'
%                                 Format:           [7Z - Wikipedia]
%                                 Example filename: archive.7z (default option)
% 
%                                 Type switch:      '-tgzip'
%                                 Format:           [GZIP - Wikipedia]
%                                 Example filename: archive.gzip
%                                                   archive.gz
% 
%                                 Type switch:      '-tzip'
%                                 Format:           [ZIP - Wikipedia]
%                                 Example filename: archive.zip (very compatible)
% 
%                                 Type switch:      '-tbzip2'
%                                 Format:           [BZIP2 - Wikipedia]
%                                 Example filename: archive.bzip2
% 
%                                 Type switch:      '-ttar'
%                                 Format:           [TAR - Wikipedia]
%                                 Example filename: tarball.tar (UNIX and Linux)
% 
%                                 Type switch:      '-tiso'
%                                 Format:           [ISO - Wikipedia]
%                                 Example filename: image.iso
% 
%                                 Type switch:      '-tudf'
%                                 Format:           [UDF - Wikipedia]
%                                 Example filename: disk.udf
%
%   Output:
%       OPT.status  : 0 if succesful, non-zero when function fails
%          .result  : contains output message of 3rd party function 7z.exe
%
%   Example:
%       compress('test.zip',{'c:\Temp\test.doc'},'type','-tzip')
%           compresses c:\temp\test.doc to test.zip
%
%   See also: uncompress, bzip, zip, unzip

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Van Oord
%       Aad van Es
%
%       aes@vanoord.com
%
%       Watermanweg 64
%       POBox 8574
%       3009 AN Rotterdam
%       Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of VOTools which is the internal clone of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 24 Dec 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings
% defaults
OPT.outpath     = [];       % output path
OPT.quiet       = false;    % do not surpress output
OPT.gui         = false;    % do not show 7zip gui
OPT.type        = '-t7z';
OPT.args        = '-mx5'; 
% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

%%
% define outpath
[OPT.fileDir, OPT.fileName, OPT.fileExt] = fileparts(fileNameOut);
if isempty(OPT.outpath)
    OPT.outpath = OPT.fileDir;
end

if ~iscellstr(fileNameIn)
    error('fileNameIn must be an cell array of strings')
end

if ~OPT.quiet
    fprintf('packing to %s ...',fileNameOut);
end
tic

if isdeployed
    basepath = fullfile('7z','7z914');
else
    basepath = fullfile(fileparts(mfilename('fullpath')),'private','7z','7z914');
end

if OPT.gui
    path7zip      = fullfile(basepath,'7zG.exe');
else
    path7zip      = fullfile(basepath,'7z.exe');
end
% 7za a -t7z files.7z *.txt

if ~exist(path7zip,'file')
    error('compress:exe not found:7Zip executable not found at %s',path7zip)
end

fileNameIn    = sprintf('"%s" ',fileNameIn{:});

dosstring     = sprintf('"%s" a %s "%s" %s %s',path7zip,OPT.type,fullfile(fileNameOut),fileNameIn,OPT.args);

[OPT.status, OPT.info] = system(dosstring);

if ~OPT.quiet
    fprintf(1,' took %2.1f sec to %s\n', toc, OPT.outpath);
end