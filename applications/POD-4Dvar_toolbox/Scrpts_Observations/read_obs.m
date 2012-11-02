clc, clear;
% There are two formats available.
% The original information was sent in mat files that contain x,y,z
% coordinates and two fields related to the time of observation, hour and
% minute.This information comes at the original measurement resolution,
% which is a lot higher than the one used in the model.
%
% The other format available is Deltft3D dep files that have been produced
% with matlab, with the same script used for the initial condition dep-file
% used for the reduced order model generation.Therefore, this files have
% already been processed to match the model's resolution. The script used
% is: 
% p:\x0385-gs-mor\ivan\paper_2\Data from Rosh\bathymetries\runtopoIvan.m
%
% Issues on how to generate the observation operator efficiently and
% reliably should be addressed.



% This loads the original mat files, as sent by Michellet
%        matfileslist = cellstr(ls([pwd,filesep,'the_observations',filesep,'*.mat']));
%        numfiles = length(matfileslist);
%        for iobs = 1:1:numfiles, bathymetry(iobs) = load([pwd,filesep,'the_observations',filesep,matfileslist{iobs}]); end
%        clear iobs numfiles

% This loads the dep files as produced for Delft3D
        
        depfileslist = cellstr(ls([pwd,filesep,'the_observations',filesep,'*.dep']));
        numfiles = length(depfileslist);
        
        for iobs = 1:1:numfiles, 
            thedeps(iobs) = wlgrid('read',[pwd,filesep,'the_observations',filesep,depfileslist{iobs}(1:end-3),'grd']); 
        end

        for iobs = 1:1:numfiles,
            
            thedeps(iobs).Z = wldep('read',[pwd,filesep,'the_observations',filesep,depfileslist{iobs}],thedeps(iobs)); 
            thedeps(iobs).active_z_index = thedeps(iobs).Z(2:end,2:end)~=0;
            
            obs.z = thedeps(iobs).Z(thedeps(iobs).Z~=0);
            obs.x = thedeps(iobs).X(thedeps(iobs).active_z_index); 
            obs.y = thedeps(iobs).Y(thedeps(iobs).active_z_index);
            
            save(depfileslist{iobs}(1:end-4), '-struct', 'obs');
        end

        clear iobs numfiles

    
    