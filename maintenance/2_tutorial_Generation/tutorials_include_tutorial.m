%% 4. Include a tutorial in the OpenEarth tutorial overview
%
% This tutorial describes the steps to be taken to include your tutorial in the overview on the wiki
% and in the matlab help.
%
% <html>
% <a class="relref" href="tutorial_how_to_write_tutorials.html" relhref="tutorial_how_to_write_tutorials.html">Read more about writing tutorials</a>
% </html>
%
%% 1. Unlock OpenEarth help documentation
%
% After matlab loads the help navigator, it locks all help files for the remaining matlab session.
% To create new documentation you must therefore be sure that either:
%
% * The matlab documentation is unlocked (for example with "Unlocker.exe" which is also available in
% the openearthtools repository). Matlab help documentation is located at:
% |fullfile(openearthtoolsroot,'docs','OpenEarthDocs');|
% * The help browser is not opened during the matlab session that is pending (in other words restart
% matlab to make sure that they are not locked).
%

%% 2. Run oetpublish
%
% After unlocking the documentation you can use oetpublish to create all documentation:

oetpublish all

%% 3. Check the documentation
%
% *Wiki html pages*
%
% The html pages that are included on the wiki can be examined in two ways. 
%
% # By clicking one of the links that are printed in the command window during the process
% # By opening tutorial_summary.html manually (located at fullfile(openearthtoolsroot,'tutorials');)
%
% *Matlab documentation*
%
% To verify the matlab documentation it is best to restart matlab and look in the help navigator.
% Restarting matlab is necessary, because sometimes the old documentation will still be loaded 
% regardless of the fact that is was just overwritten.

%% 4. Commit the changed tutorials to the repository
%
% Once you are satisfied with the result it needs to be committed to the central repository. Help
% documents on the wiki are refreshed every 60 seconds. It could therefore take 60 seconds before
% the committed changes are actually visible on the wiki.