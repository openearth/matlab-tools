%% 2. Configure publish settings
%
% Next to cell formatting some settings can control what is published and what is not. It is for
% example possible to prevent matlab code from showing in the tutorial, but include results of the
% exact same matlab code. This tutorial explaines how to control the publish setting for an
% individual tutorial when automatically generated in OpenEarthTools.
%
% <html>
% <a class="relref" href="tutorial_how_to_write_tutorials.html" relhref="tutorial_how_to_write_tutorials.html">Read more about writing tutorials</a>
% </html>

%% How to configure in OpenEarthTools
% 
% OpenEarthTools includes the function:
%
% _publishconfigurations.m_
%
% This function provides the default publish configurations that are used to publish tutorials in
% OpenEarthTools. It is also possible to manually add exceptions to these configurations. To do so
% edit this function:

edit publishconfigurations

%%
% and search for the following part:

%  %% switch filename
%  oldpublish = datenum(version('-date')) < datenum(2008,01,01);
%  switch mfilename
%      case {'testdefinitions_tutorial'}
%          if ~oldpublish
%              config.maxOutputLines = 1000;
%          end
%      otherwise
%          % Use default
%  end

%% 
% To include an exception add the filename of your file to one of the existing cases or create a new
% case in which one of the options (available in the _*cofig*_ struct). To be backwards compatible
% (the publish function changed with matlab 2008a) use the oldpublish variable to determine whether
% the function is called in an older version of matlab. If so many fieldnames are different from the
% ones explained in this tutorial. This is further explained in the function itself, but also
% follows from:

docsearch publish

%% Publish options that can be controlled
% For a full overview of the options that can be set call:

docsearch publish

%%
% The following table highlights the most important options:
%
% <html>
% <table border="solid">
%   <tr>
%       <th>Option</th>
%       <th>Value</th>
%   </tr>
%   <tr>
%       <td>maxHeight</td>
%       <td>Specifies the maximum height, in pixels, for an image that the M-file code generates</td>
%   </tr>
%   <tr>
%       <td>maxWidth</td>
%       <td>Specifies the maximum width, in pixels, for an image that the M-file code generates</td>
%   </tr>
%   <tr>
%       <td>showCode</td>
%       <td>Logical value that specifies whether MATLAB includes the M-file code in the published document</td>
%   </tr>
%   <tr>
%       <td>evalCode</td>
%       <td>Logical value that specifies whether MATLAB runs the code that it is publishing.</td>
%   </tr>
%   <tr>
%       <td>catchError</td>
%       <td>Logical value that specifies what MATLAB does if there is an error in the code that it is publishing.</td>
%   </tr>
%   <tr>
%       <td>maxOutputLines</td>
%       <td>Value that specifies the maximum number of output lines per M-file cell that you want to publish before truncating the output.</td>
%   </tr>
% </table>
% </html>
%