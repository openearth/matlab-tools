function [underwateryear, beachyear, dunesyear] = neticareadklad(volumeyear)
% function to extract data from netica
% it is possible to incorporate this into the main dunerules later

% call netica
% DO: give cell-by-cell values of change in volume to netica

% DO: retrieve percentages change for beach and dunes
percentagedune = 12;  % average from Netica
percentagebeach = 16;  % average from Netica
% beach is dry beach with MLW as boundary
percentageunderwater = 100 - percentagedune - percentagebeach;

dunesyear = volumeyear.* percentagedune./100;
beachyear = volumeyear.* percentagebeach./100;
underwateryear = volumeyear.* percentageunderwater./100;
