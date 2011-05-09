function values = getgrib(file, varid, corner, end_point, stride, order, squeeze_it)
%
%GETGRIB retrieves data from a GRIB file.
%
%values = getgrib(file, varid, corner, end_point, stride, order, squeeze_it)
%
% IMPORTANT NOTE:
%
% GETGRIB uses the READ_GRIB function available from
% http://www.opnml.unc.edu/OPNML_Matlab/read_grib/read_grib.html
%
%DESCRIPTION:
% getgrib retrieves data from a GRIB file using options similar to 
% the getnc utility used for reading netCDF files. The NetCDF utility 
% getnc is available from CSIRO at: 
% http://www.marine.csiro.au/sw/matlab-netcdf.html
%
%DATA:
% getgrib returns grib data in a structure
%   values.data = data array
%   values.date = date from grib file
%
%Note: getgrib does not support the getnc options change_miss and new_miss
%
%INPUT:
%  file is the name of a GRIB file.
%  varid must be the name of a variable.
%  corner is a vector of length n specifying the hyperslab corner
%    with the lowest index values (the bottom left-hand corner in a
%    2-space). A negative element means that all values in that 
%    direction will be returned.  If a negative scalar is used this 
%    means that all of the elements in the array will be returned.
%  end_point is a vector of length n specifying the hyperslab corner
%    with the highest index values (the top right-hand corner in a
%    2-space).
%  stride is a vector of length n specifying the interval between
%    accessed values of the hyperslab (sub-sampling) in each of the n
%    dimensions.  A value of 1 accesses adjacent values in the given
%    dimension; a value of 2 accesses every other value; and so on. If
%    no sub-sampling is required in any direction then it is allowable
%    to just pass the scalar 1 (or -1 to be consistent with the corner
%    and end_point notation).
%  order is a vector of length n specifying the order of the dimensions in
%    the returned array.  order = [1 2 3 .. n] for an n dimensional
%    netCDF variable will return an array with the dimensions in their 
%    native order. More general permutations are given re-arranging the
%    numbers 1 to n in the vector.
%  squeeze_it specifies whether the returned array should be squeezed.
%    That is, when squeeze_it is non-zero then the squeeze function will
%    be applied to the returned array to eliminate singleton array
%    dimensions.  This is the default.  Note also that a 1-d array is
%    returned as a column vector.
%
% OUTPUT:
%  values is a scalar, vector or array of values that is read in
%     from the GRIB file
%
%---------------------------------------------------------------------

global ParamTable

missing = 1e10;
values = [];

if ~exist(file,'file')
  disp([file,' not found'])
  return
end

if ~exist('varid')
  disp('usage: getgrib(filename,varid)')
  return
end

% check corner and end_point dimensions against header data

if ~exist('corner') | isempty(corner)
  corner = [-1 -1 -1];
elseif length(corner) ~= 3
  disp('corner length incorrect, must be 3')
  return
end


if ~exist('end_point') | isempty(end_point)
  end_point = [-1 -1 -1];
elseif length(end_point) ~= 3
  disp('end_point length incorrect, must be 3')
  return
end

% check stride

if ~exist('stride') 
  stride = [1 1 1];
elseif isempty(stride)
  stride = [1 1 1];  
else
  if length(stride) == 1
    stride = [abs(stride) abs(stride) abs(stride)];
  elseif length(stride < 3)
    disp('end_point length incorrect, must be 3')
    return
  end
end

% check ParamTable
if isempty(ParamTable)
  ParamTable = 'NCEPOPER';
end

%start with header scan

try
  gribrec = read_grib(file,{varid},'HeaderFlag',1,'DataFlag',0,'ScreenDiag',0,'ParamTable',ParamTable);
catch
  disp(['ERROR: Variable ',varid,' not found.'])
  disp(['Use read_grib(''',file,''',''inv'') to check the grib inventory.'])
  return
end

if isempty(gribrec)
  disp(['ERROR: Variable ',varid,' not found.'])
  disp(['Use read_grib(''',file,''',''inv'') to check the grib inventory.'])
  return
end
  
nrecs = size(gribrec,2);

if corner(1) == -1
  if end_point(1) ~= -1 
    disp('both corner(1) and end_point(1) are not -1')
    return 
  end
  corner(1) = 1;    
  end_point(1) = nrecs;
end

%now go for the data
try
  grib = read_grib(file,[gribrec([corner(1):stride(1):end_point(1)]).record],'ScreenDiag',0,'ParamTable',ParamTable);
catch
  disp('ERROR: reading data block from grib file.  Check endpoint dimensions.')
  return
end

nrecs = size(grib,2);

for i = 1:nrecs
  grib(i).fltarray = reshape(grib(i).fltarray,grib(i).gds.Ni,grib(i).gds.Nj);
  grib(i).fltarray(grib(i).fltarray>=missing) = ones(size(grib(i).fltarray(grib(i).fltarray>=missing)))*nan;
  grib(i).fltarray = grib(i).fltarray';
end

% tack the date into the values structure

values.date = grib(1).stime;

if corner(2) == -1
  if end_point(2) ~= -1
    disp('both corner(2) and end_point(2) are not -1')
    return 
  end
  corner(2) = 1;    
  end_point(2) = grib(1).gds.Nj;
end

if corner(3) == -1
  if end_point(3) ~= -1 
    disp('both corner(3) and end_point(3) are not -1')
    return 
  end
  corner(3) = 1;    
  end_point(3) = grib(1).gds.Ni;
end

for i = 1:nrecs
  values.data(:,:,i) = grib(i).fltarray(corner(2):stride(2):end_point(2),corner(3):stride(3):end_point(3));
  grib(i).fltarray = [];
end

if exist('order') & ~isempty(order)
  values.data = permute(values.data,order);
end

if exist('squeeze_it') & ~isempty(squeeze_it)
  values.data = squeeze(values.data);
end

return
