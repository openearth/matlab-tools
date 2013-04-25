function bnd=get_bnd_data(filename)

% get_bnd_data : Gets the boundary definition

%
%  Determine file type
%

filetype = nesthd_det_filetype(filename);

%
% Use appropriate funtion to get the bnd data
%

switch filetype;
   case 'Delft3D'
      bnd = delft3d_io_bnd('read',filename);
   case 'siminp'
      bnd = siminp_io_bnd(filename);
end
