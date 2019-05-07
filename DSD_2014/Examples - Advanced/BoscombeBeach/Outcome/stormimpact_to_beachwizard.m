% This script transforms an XBeach storm impact model for Boscombe Beach
% (U.K.) into a Beach Wizzard model.
% 
% -------------------------------------------------------------------------
% Version           Name                Date
% -------------------------------------------------------------------------
% v1.0              rooijen/thiel       04-Sep-2012
% v1.1              rooijen             27-Nov-2012
%
clear all;close all;clc

%% Read in storm impact model
mod_dir = ('d:\XBeach\Examples\BoscombeBeach\Boscombe_BW\');
xbm_si = xb_read_input([mod_dir,'params.txt']);

%% Change settings for BeachWizard model
pars_BW = xb_generate_settings('instat','stat_table','bcfile','waves.txt','wavint',6000,...        % wave bc
                               'morphology',0);                                                          % moprhology settings
                               
xbm_BW = xs_join(xbm_si,pars_BW); % Combine the original and new settings

%% Write new model
xb_write_input([mod_dir,'params.txt'],xbm_BW);