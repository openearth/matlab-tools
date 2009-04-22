function IMAGE=gimread
%GIMREAD    calls UIGETFILE and passes result to IMREAD
%
%See also: GIMREAD, IMREAD

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

[filename, pathname ] = uigetfile(...
       {'*.jpg;*.tiff;*.gif;*.bmp;*.png;*.hdf;*.pcx;*.xwd;*.ico;*.cur;*.ras;*.pbm;*.pgm;*.ppm;',...
           'suported image types';,...
        '*.*',...
           'All Files (*.*)'}, ...
        'Pick a file');
    
IMAGE = imread([pathname,filename]);    

%% EOF