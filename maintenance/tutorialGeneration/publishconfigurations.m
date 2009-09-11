function config = publishconfigurations(mfilename,publishtemplate,outputhtmldir)
%PUBLISHCONFIGURATIONS  Returns manually set publish configurations for tutorials.
%
%   This file can be manually filled with preference publish configurations for each tutorial.
%
%   Syntax:
%   config = publishconfigurations(mfilename)
%
%   Input:
%   mfilename  = Name of the tutorial (as it is in the repository).
%
%   Output:
%   config     = Publish configurations.
%
%   Example
%   publishconfigurations
%
%   See also publish

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
% Created: 10 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Get defaults
config = defaultopts(publishtemplate,outputhtmldir);

%% switch filename
oldpublish = datenum(version('-date')) < datenum(2008,01,01);
switch mfilename
    case {'prob_calculation_tutorial',...
            '_tutorial_initiate_toolbox',...
            '_tutorial_creating_new_functions'}
        config.evalCode = false;
        config.showCode = true;
    otherwise
        % Use default
end

end

%% Functin that returns defaults
function config = defaultopts(publishtemplate,outputhtmldir)
%% Switch matlab version
vs = datenum(version('-date'));
if vs >= datenum(2008,01,01)
    % Publish has altered since the version of 2008a (7.4). We need to distiquish between these
    % versions for compatibility reasons.

    %% Field                Allowable format
    % format                'doc','html' (default), 'latex', 'ppt', 'xml'
    % stylesheet            '' (default), XSL file name (used only when format is html, latex, or xml)
    % outputDir             '' (default, a subfolder named html), full path
    % imageFormat           'png' (default unless format is latex), 'epsc2' (default when format is latex), any format supported by print when figureSnapMethod is print, any format supported by imwrite functions when figureSnapMethod is getframe, entireFigureWindow, or entireGUIWindow.
    % figureSnapMethod      'entireGUIWindow' (default),'entireFigureWindow''print','getframe'
    %                       See the FigureSnap Method Options table for details on the effects of these settings.
    % useNewFigure          true (default), false
    % maxHeight             [] (default), any positive integer specifying the maximum height, in pixels, for an image that publish.m generates
    % maxWidth              [] (default), any positive integer specifying the maximum width, in pixels, for an image that publish.m generates
    % showCode              true (default), false
    % evalCode              true (default), false
    % catchError            true (default, continues publishing and includes the error in the published file), false (displays the error and publishing ends)
    % codeToEvaluate        M-file you are publishing (default), any valid code
    % createThumbnail       true (default), false
    % maxOutputLines        Inf (default), nonnegative integer specifying the maximum number of output lines to publish per M-file cell before truncating the output
    
    config = struct(...
        'maxOutputLines',15,...
        'format','html',...
        'stylesheet',publishtemplate,...
        'outputDir',outputhtmldir,...
        'catchError',true,...
        'useNewFigure',true);
else
    %% Field             Allowable Values
    % format            'doc','html' (default), 'latex', 'ppt', 'xml'
    % stylesheet        '' (default), XSL filename (used only when format is html, latex, or xml)
    % outputDir         '' (default, a subfolder named html), full pathname
    % imageFormat       'png' (default unless format is latex), 'epsc2' (default when format is latex), any format supported by print when figureSnapMethod is print, any format supported by imwrite functions when figureSnapMethod is getframe.
    % figureSnapMethod  'print' (default),'getframe'
    % useNewFigure      true (default), false
    % maxHeight         [] (default), positive integer specifying number of pixels
    % maxWidth          [] (default), positive integer specifying number of pixels
    % showCode          true (default), false
    % evalCode          true (default), false
    % stopOnError       true (default), false
    % createThumbnail   true (default), false
    
    config = struct(...
        'format','html',...
        'stylesheet',publishtemplate,...
        'outputDir',outputhtmldir,...
        'stopOnError',true,...
        'useNewFigure',true);
    if ~quiet
        disp('You are using a matlab version prior to 7.4. This version does not allow');
        disp('codeToEvaluate as an option for the publish function.');
        disp('  ');
        disp('As a consequence we could not prevent the publish function to leave all');
        disp('variables created during publishing in the base workspace. Be aware of this');
        disp('shortcoming of matlab.');
        disp(' ');
        disp('Furthermore error information will not be included in the published html file.');
    end
end
end