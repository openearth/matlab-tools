function addEos(eosPath)
% add eosEarth to your path
%
% addEos(eosPath)
%
% INPUT: eosPath (optional).  Default 'S:\in-house\MATLAB\ExternalLibraries\eoslib05\matlab'
%
if nargin  < 1
    eosPath = 'S:\in-house\MATLAB\ExternalLibraries\eoslib05\matlab';
end
if ~exist('theta_from_t','file')
    thePath = pwd;
    cd(openEarthPath) ;
    addpath(eosPath);
    cd(thePath)
else
    disp('Eos is already in the path');
end