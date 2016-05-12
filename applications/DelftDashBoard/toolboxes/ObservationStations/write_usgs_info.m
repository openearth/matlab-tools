%% Get data for a specific station
% Works for parcode and siteno
clear all; close all

Dir = 'd:\';
addpath('d:\DelftDashBoard\Taken\Functionaliteit\')

% Load river data for Tijuana
ParCode = {'00065'};                % Parameter code, Look up in parameter-file
tstart  = '2010-10-01';             % Tbegin
tend    = '2015-01-01';             % Tend
SiteNo  = '08376300';               % Station Number (from USGS website)

data = nwi_usgs_read(SiteNo,tstart,tend,ParCode,Dir);


