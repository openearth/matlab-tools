%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Read geotiff files. This function stems from <GEOTIFF_READ>. 
%Unfortunaltely, in that function reading of the <z> variable
%is not always correct. Hence, I read the <z> variable using
%imread. 
%
%INPUT
%   - fpath_tif = full path to a tif-file.
%
%OUTPUT
%   - I = structure with image information.
%       - I.x = x-vector
%       - I.y = y-vector
%       - I.z = z-matrix
%       - I.mask = mask for filtering no-data points
%
%OPTIONAL (pair input)
%   - x_limits = lower and uper limit of data to take from tif in x-direction
%   - y_limits = lower and uper limit of data to take from tif in y-direction
%
%TODO:
%   -
%
%E.G.
%
% [I,Tinfo]=readgeotiff(fpath_tif);
% I=readgeotiff(fpath_tif,'x_limits',[1.56e5,1.57e5],'y_limits',[4.258e5,4.26e5]);
% 
% figure
% imagesc(I.x, I.y, I.z);  % x and y are vectors
% set(gca,'YDir','normal')
% set(gca().Children, 'AlphaData', I.mask);
% colorbar

function [I,image_info,fcn_data_type]=readgeotiff(fname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'x_limits',[-inf,inf]);
addOptional(parin,'y_limits',[-inf,inf]);

parse(parin,varargin{:});

x_limits=parin.Results.x_limits;
y_limits=parin.Results.y_limits;

%% CALC

%% get image information

[image_info,no_data,x_vector,y_vector,fcn_data_type]=TIF_info(fname);

%% filter

%x-direction is normal
col_ini=find(x_vector>x_limits(1),1,'first');
col_fin=find(x_vector<x_limits(2),1,'last');

%y-direction is reversed
row_ini=find(y_vector<y_limits(2),1,'first');
row_fin=find(y_vector>y_limits(1),1,'last');

%% apply filter to coordinates

I.x=x_vector(col_ini:1:col_fin);
I.y=y_vector(row_ini:1:row_fin);

%% READ

I.z=imread(fname,'PixelRegion',{[row_ini,row_fin],[col_ini,col_fin]});

%% MASK

bol_empty=I.z==no_data;
I.z(bol_empty)=NaN;
I.mask=double(~bol_empty);

end %function