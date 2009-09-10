%% Initializing the toolbox
% if you use MATLAB and OpenEarth, you should always start off with running
% oetsettings. Oetsettings is essential to unleash the power of OpenEarth 
% to MATLAB. It adds all relevant toolbox paths to the matlab search
% path. 

%% Oetsettings
% Figure out what folder oetsettings.m is located in, and the run it.
% Oetsettings is located in the Matlab directory of your OpenEarth checkout
% 

run('<enter filepath here>/oetsettings');

%% Create a shortcut
% As you don't want to remember this code, but you will run it every time
% you start MATLAB from know on, you should make a ahortcut for it on the
% shortcut bar. Just rightclick ==> new shortcut. Enter the command to run 
% oetsettings. If you save this, you can run oetsetings by pressing
% that shortcut button. You might even want to add some other commands, so
% matlab is effectiveley reset every time you press this button.

restoredefaultpath

run('<enter filepath here>\oetsettings.m')

cd <enter filepath here>

clc; clear; close;

%%
% 
% <<prerendered_images/create_shortcut.PNG>>
% 