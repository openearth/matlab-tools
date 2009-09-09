function oetpublish(varargin)
%OETPUBLISH  publishes the tutorial that is currently being edited in the matlab editor.
%
%   This function takes the file that was last selected in the matlab editor (or any file given as
%   input) and publishes it in the OpenEarthStyle.
%
%   Syntax:
%   oetpublish(varargin)
%   oetpublish(varargin,'hide')
%
%   Input:
%   varargin  = keyword value pairs
%       filename    -   Name of the tutorial (mfile) that needs to be published (default = last
%                       selected file in the matlab editor).
%       outputdir   -   Name of the output dir (default: tempdir)
%
%   'hide'  -   By default the result is opened in your browser. Including hide suppresses this
%               command.
%
%   Example
%   oetpublish
%
%   See also publish editorCurrentFile

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Get inpt arguments
outputdir = fullfile(tempdir,'oetpublish');
id = find(strcmpi(varargin,'outputdir'));
if ~isempty(id)
    outputdir = varargin{id+1};
end

[dr filename] = fileparts(editorCurrentFile);
id = find(strcmpi(varargin,'filename'));
if ~isempty(id)
    [dr filename] = fileparts(varargin{id+1});
    if isempty(dr)
        dr = fileparts(which(filename));
    end
end

show = true;
if any(strcmpi(varargin,'hide'))
    show = false;
end

%% create output dir
if ~isdir(outputdir)
    mkdir(outputdir);
end

%% Copy script files to html dir 
tmpdir = tempname;
templatedir = fullfile(openearthtoolsroot,'maintenance','tutorialGeneration','template');
scriptdir = fullfile(templatedir,'html','script');
copyfile(scriptdir,tmpdir,'f');
drs = strread(genpath(tmpdir),'%s',-1,'delimiter',';');
id = find(~cellfun(@isempty,strfind(drs,'.svn')));
for idr = 1:length(id)
    if isdir(drs{id(idr)})
        rmdir(drs{id(idr)},'s');
    end
end
copyfile(tmpdir,fullfile(outputdir,'script'),'f');

%% publish tutorial
% publishopts
publishopts = struct(...
    'maxOutputLines',15,...
    'format','html',...
    'stylesheet',fullfile(templatedir,'mxdom2tutorialhtmllocal.xsl'),...
    'catchError',true,...
    'outputDir',outputdir,...
    'useNewFigure',true,...
    'codeToEvaluate',[]);

publishedfile = publish(filename,publishopts);

if show
    winopen(publishedfile);
end