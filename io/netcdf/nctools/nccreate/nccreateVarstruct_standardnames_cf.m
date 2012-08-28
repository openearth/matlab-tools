function varstruct = nccreateVarstruct_standardnames_cf(standard_name,varargin)
% NCCREATEVARSTRUCT_STANDARDNAMES_CF Creates a varstruct with defaultsd set to those belonging to a specific standardised name 

%% get varstruct structure from nccreateVarstruct
OPT            = nccreateVarstruct();

% set specifics for standard names
OPT.long_name  = ''; 
OPT.units      = ''; 
OPT.definition = ''; 

% parse varargin
OPT            = setproperty(OPT,varargin);

%% define the lists of standard_names, long_names, units and definitions
list = getList;
  
% lookup the standard name in the list
if nargin==0
    varstruct = list.standard_names;
    return
end

n = find(strcmpi(standard_name,list.standard_names),1);
if isempty(n)
    error('standard name not found')
end

if isempty(OPT.long_name);  OPT.long_name  = list.long_names{n};  end
if isempty(OPT.units);      OPT.units      = list.units{n};       end
if isempty(OPT.definition); OPT.definition = list.definitions{n}; end

% add attributes belonging to the standard name
OPT.Attributes =  [{...
    'standard_name',standard_name,...
    'long_name',OPT.long_name,...
    'units',OPT.units,...
    'definition',OPT.definition}...
    OPT.Attributes];

OPT = rmfield(OPT,{'long_name','units','definition'});

% finally check is the varstruct is valid
varstruct = nccreateVarstruct(OPT);

function list = getList()
% input below is auto generated
list.standard_names = {
    'time'
    'altitude'
    'depth'
    'latitude'
    'longitude'
    'projection_x_coordinate'
    'projection_y_coordinate'
    'sea_surface_swell_wave_mean_period_from_variance_spectral_density_first_frequency_moment'
    'sea_surface_swell_wave_significant_height'
    'sea_surface_swell_wave_to_direction'
    'sea_surface_wave_zero_upcrossing_period'
    'sea_surface_wave_mean_period_from_variance_spectral_density_first_frequency_moment'
    'sea_surface_wave_mean_period_from_variance_spectral_density_second_frequency_moment'
    'sea_surface_wave_significant_height'
    'sea_surface_wave_to_direction'
    'sea_surface_wind_wave_mean_period_from_variance_spectral_density_first_frequency_moment'
    'sea_surface_wind_wave_significant_height'
    'sea_surface_wind_wave_to_direction'
    'wind_speed'
    'wind_to_direction'
    'sea_water_x_velocity'
    'sea_water_y_velocity'
    'northward_sea_water_velocity'
    'eastward_sea_water_velocity'
    'direction_of_sea_water_velocity'
    'radial_sea_water_velocity_away_from_instrument'
    'mass_concentration_of_suspended_matter_in_sea_water'
    'water_surface_height_above_reference_datum'
    'water_surface_reference_datum_altitude'
};

list.long_names = {
    'time'
    'altitude'
    'depth'
    'latitude'
    'longitude'
    'x-coordinate'
    'y-coordinate'
    'Mean wave period T-10 (Swell)'
    'Significant wave height (Swell)'
    'Mean wave direction Theta (Swell)'
    'Mean period time Tz'
    'Mean wave period (1st frequency moment)'
    'Mean wave period (2nd frequency moment)'
    'Significant wave height (Sea and Swell)'
    'Mean wave direction Theta (Sea and Swell)'
    'Mean wave period T-10 (Sea)'
    'Significant wave height (Sea)'
    'Mean wave direction Theta (Sea)'
    'Wind speed'
    'Wind direction'
    'Sea water x velocity'
    'Sea water y velocity'
    'Sea water northward velocity'
    'Sea water eastward velocity'
    'Sea water velocity direction'
    'Sea water velocity direction'
    'Mass concentration of suspended matter in sea water'
    'Water surface height above reference datum'
    'Water surface referernce datum altitude'
};

list.units = {
    'days since 1970-01-01 00:00:00 +01:00'
    'm'
    'm'
    'degree_north'
    'degree_east'
    'm'
    'm'
    's'
    'm'
    'degree'
    's'
    's'
    's'
    'm'
    'degree'
    's'
    'm'
    'degree'
    'm/s'
    'degree'
    'm/s'
    'm/s'
    'm/s'
    'm/s'
    'degree'
    'm/s'
    'kg/m3'
    'm'
    'm'
};

list.definitions = {
    'Variables representing time must always explicitly include the units attribute; there is no default value. The units attribute takes a string value formatted as per the recommendations in the Udunits package.'
    'Altitude is the (geometric) height above the geoid, which is the reference geopotential surface. The geoid is similar to mean sea level.'
    'Depth is the vertical distance below the surface. Depth is positive downward.'
    'Latitude is positive northward; its units of degree_north (or equivalent) indicate this explicitly.'
    'Longitude is positive eastward; its units of degree_east (or equivalent) indicate this explicitly.'
    ''
    ''
    'A period is an interval of time, or the time-period of an oscillation.'
    'Height is the vertical distance above the surface.'
    'to_direction is used in the construction X_to_direction and indicates the direction towards which the velocity vector of X is headed.'
    'A period is an interval of time, or the time-period of an oscillation. The zero upcrossing period is defined as the time interval between consecutive occasions on which the surface height passes upward above the mean level.'
    'The swell wave directional spectrum can be written as a five dimensional function S(t,x,y,f,theta) where t is time, x and y are horizontal coordinates (such as longitude and latitude), f is frequency and theta is direction. S can be integrated over direction to give S1= integral(S dtheta). Frequency moments, M(n) of S1 can then be calculated as follows: M(n) = integral(S1 f^n df), where f^n is f to the power of n. The first wave period, T(m1), is calculated as the square root of the ratio M(0)/M(1).'
    'The swell wave directional spectrum can be written as a five dimensional function S(t,x,y,f,theta) where t is time, x and y are horizontal coordinates (such as longitude and latitude), f is frequency and theta is direction. S can be integrated over direction to give S1= integral(S dtheta). Frequency moments, M(n) of S1 can then be calculated as follows: M(n) = integral(S1 f^n df), where f^n is f to the power of n. The second wave period, T(m2), is calculated as the square root of the ratio M(0)/M(2).'
    'Height is the vertical distance above the surface.'
    'to_direction is used in the construction X_to_direction and indicates the direction towards which the velocity vector of X is headed.'
    'A period is an interval of time, or the time-period of an oscillation.'
    'Height is the vertical distance above the surface.'
    'to_direction is used in the construction X_to_direction and indicates the direction towards which the velocity vector of X is headed.'
    'The wind speed is the magnitude of the wind velocity. Wind is defined as a two-dimensional (horizontal) air velocity vector, with no vertical component.'
    'Wind is defined as a two-dimensional (horizontal) air velocity vector, with no vertical component. In meteorological reports, the direction of the wind vector is usually (but not always) given as the direction from which it is blowing (wind_from_direction) (westerly, northerly, etc.).'
    'A velocity is a vector quantity. "x" indicates a vector component along the grid x-axis, when this is not true longitude, positive with increasing x.'
    'A velocity is a vector quantity. "y" indicates a vector component along the grid y-axis, when this is not true latitude, positive with increasing y.'
    'A velocity is a vector quantity. "Northward" indicates a vector component which is positive when directed northward (negative southward).'
    'A velocity is a vector quantity. "Eastward" indicates a vector component which is positive when directed eastward (negative westward).'
    '"direction_of_X" means direction of a vector, a bearing. A velocity is a vector quantity.'
    'A velocity is a vector quantity. Radial velocity away from instrument means the component of the velocity along the line of sight of the instrument where positive implies movement away from the instrument (i.e. outward). The "instrument" (examples are radar and lidar) is the device used to make an observation.'
    'Mass concentration means mass per unit volume and is used in the construction mass_concentration_of_X_in_Y, where X is a material constituent of Y. A chemical species denoted by X may be described by a single term such as ''nitrogen'' or a phrase such as ''nox_expressed_as_nitrogen''.'
    'water_surface_height_above_reference_datum ''Water surface height above reference datum'' means the height of the upper surface of a body of liquid water, such as sea, lake or river, above an arbitrary reference datum. The altitude of the datum should be provided in a variable with standard name water_surface_reference_datum_altitude. The surface called "surface" means the lower boundary of the atmosphere.'
    'Altitude is the (geometric) height above the geoid, which is the reference geopotential surface. The geoid is similar to mean sea level. ''Water surface reference datum altitude'' means the altitude of the arbitrary datum referred to by a quantity with standard name ''water_surface_height_above_reference_datum''. The surface called "surface" means the lower boundary of the atmosphere.'
};
    