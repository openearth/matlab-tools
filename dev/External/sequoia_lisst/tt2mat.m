% tt2mat file for Matlab use
% Usage:
%
%  	data = tt2mat('filename',nvariables);
%
% Produces a variable i.e. rows x nvaribles in size from a binary .dat file
% For LISST-100 and LISST-100X nvariables should be 40
% For LISST-Portable and LISST-Infinite nvariables should be 80
% Modified 7/13/98: removed end statement at end of function
% mod
% Comments added April 15 2008 by OAM. Version 1.5

function [data]= tt2mat(filename,nvariables)

fid = fopen(filename);% open file
d = fread(fid,'uint8');% read the binary data into d vector
fclose(fid);%close file
d = d(1:2:length(d))*256+d(2:2:length(d));% binary data converted into digital counts
rows = floor(length(d)/nvariables);%figure out the number of rows we will have
d = d(1:(rows*nvariables));%re-size d so it is of length (rows * nvariables)
dm = reshape(d,nvariables,rows);%get an nvariables * rows matrix from d

data = dm';%transpose it to get an rows * nvariables (40 or 80 columns) matrix