% =========================================================================
% MATLAB FUNCTIONS FOR READING AND WRITING TELEMAC (SERAPHIN) FILES
% =========================================================================
%
% Author: Thomas Benson, HR Wallingford, UK
% email: t.benson@hrwallingford.co.uk
% date: 14-Aug-2009
%
% OVERVIEW:
% These m-files are aimed at those who want to read, write and manipulate
% results files (Seraphin/Selafin format) from the Telemac2D/3D
% hydrodynamic modelling system of EDF/Sogreah (www.telemacsystem.com).
%
% A couple of usage examples have been included to help understand how to
% use the lower level functions so that you can incorporate them into your
% own Matlab code.
% 
% To get started, run 'teldemo.m', this will perform a time average on all 
% the variables in the example hydrodynamic results file then saves the 
% answer to a new Seraphin file (with a single timestep). It then plots
% the mean water depth (variable 3) from the newly created file.
%
% I would like to acknowledge Dr Jon French of the Coastal and Estuarine
% Research Unit (University College London) for providing code that
% inspired these routines.
%
% =========================================================================
% CONTENTS:
% =========================================================================
%
% teldemo.m             - the main example script
%                         
% The above script simply calls the following two functions:
%
% telmean.m             - calculates the time average all the timesteps in 
%                         the example seraphin file (seraphin_example.res)
%                         It then saves the result to a new file.
% telplot.m             - loads a Seraphin file and plots a user specified 
%                         variable at a specified timestep. 
%
% The above functions call the following low level functions for reading
% and writing Seraphin format files:
%
% telheadr.m            - read  Telemac2D result file header information 
% telstepr.m            - read  Telemac2D result file timestep information           
% telheadw.m            - write Telemac2D result file header information                                
% telstepw.m            - write Telemac2D result file timestep information  
%
% Other files:
%
% mersey.res            - an example Telemac2D flow result file
% readme.txt            - this file
