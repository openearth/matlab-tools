function DATA=gload
%GLOAD    gui to load a *.mat file
%
%See also: GLOAD, LOAD, GIMREAD

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

   [filename, pathname ] = uigetfile;

   DATA=load([pathname,filename]);
   
%% EOF   