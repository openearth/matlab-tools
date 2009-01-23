function Factor=convert_units(InUnits,OutUnits);
%CONVERT_UNITS    Unit conversion function

% factor = convert_units(InUnits,OutUnits)
%
%                            Given an input and output strings
%                            containing units - return the conversion
%                            multiplication factor needed for converting
%                            the input units to the output units.
%                            Note: the user is responsible for the
%                                  balance of the transformation.
%
%                            Type of units:
%                              Length:
%                                'mm' ; 'cm' ; 'inch' ; 'feet' ;
%                                'm' - meter ; 'km' ; 'mile' ;
%                                'erad' - Earth radius ; 'au' ;
%                                'ly' - light year ; 'pc'; 'yard'
%                              Time:
%                                's' ; 'min' ; 'hour' ;
%                                'sday' - sidereal day ; week ;
%                                'year'; 'cen' - century
%                              Force:
%                                 'dyne' ; 'N'
%                              Mass:
%                                'gr'; 'kg'; 'emass' - Earth mass;
%                                'jmass' - Jupiter mass;
%                                'smass' - Solar mass;
%                                'mp' - proton mass;
%                                'me' - electron mass;
%                                'libra';'pound'
%                              Angle:
%                                'rad' ; 'deg' ;
%                                'amin' - arcmin ; 'asec' - arcsec
%                              Solid Angle:
%                                'ster' ; 'sdeg' - square degree ;
%                                'smin' - square arcmin ;
%                                'ssec' - square arcsec
%
% Input  : - InUnits:  String containing the input units.
%          - OutUnits: String containing the output units.
% Output : - factor:   Multiplication factor for converting input units to
%                      output units.
%
% Example : 
% a = convert_units('m^3 * kg^-1 * s^-2','cm^3 * gr^-1 * s^-2').*b;
%
%See also:

%-----------------------------------------------------------------------
% Tested : Matlab 6.5
%     By : Eran O. Ofek             July 2003
%    URL : http://wise-obs.tau.ac.il/~eran/matlab.html
%-----------------------------------------------------------------------

% 2008 jan 23: started forces and pressure section [gerben J. de Boer]
% 2008 jan 23: removed refs to constants [gerben J. de Boer]

   RAD    = 180./pi;
   
   %%--- Length units ---
   mm     = 1e-3;                         % mm
   cm     = 1e-2;                         % cm
   inch   = 0.0254;                       % inch
   feet   = 0.30480;                      % foot
   yard   = 0.9144;                       % yard
   m      = 1;                            % meter
   km     = 1000;                         % km
   mile   = 1609;                         % mile
  %erad   = refellipsoid('WGS84');
  %erad   = erad(1);                      % Earth equatorial radius (WGS84)
  %au     = get_constant('au','SI');      % au
  %ly     = get_constant('ly','SI');      % light-year
  %pc     = get_constant('pc','SI');      % pc
   
   %%--- Time units ---
   s      = 1;                            % sec
   min    = 60;                           % minute
   hour   = 3600;                         % hour
   sday   = 86164.09053;                  % sidereal day
   day    = 86400;                        % day
   week   = 7.*day;                       % week
   year   = 365.25.*day;                  % tropical year
   cen    = year*100;                     % tropical century
   
   %%--- Pressure units ---
   Pa     = 1;                            % pascal
   hPa    = 100;                          % hectopascal
   bar    = 1e5;                          % bar
   mbar   = 100;                          % millibar

   %%--- Force units ---
   dyn    = 1e-5;                         % dyne
   dyne   = 1e-5;                         % dyne
   dynes  = 1e-5;                         % dyne
   N      = 1;                            % Newton
   
   %%--- Mass units ---
   gr     = 1e-3;                         % gram
   kg     = 1;                            % kg
  %emass  = get_constant('EarM','SI');    % Earth Mass
  %jmass  = get_constant('JupM','SI');    % Jupiter Mass
  %smass  = get_constant('SolM','SI');    % Solar Mass
  %me     = get_constant('me','SI');      % electron mass
  %mp     = get_constant('mp','SI');      % proton mass
   libra  = 0.32736409;                   % libra
   pound  = 0.45359237;                   % pound
   
   %%--- Angle units ---
   rad    = 1;                            % radian
   deg    = 1./RAD;                       % degree
   amin   = deg./60;                      % arcmin
   asec   = amin./60;                     % arcsec
   
   %%--- Solid Angle units ---
   ster   = 1;                            % steradian
   sdeg   = 1./(RAD.^2);                  % square degree
   smin   = 1./((60.*RAD).^2);            % square arcmin
   ssec   = 1./((3600.*RAD).^2);          % square arcsec
   
   %%--- Find conversion factor ---
   F1     = eval(InUnits);
   F2     = eval(OutUnits);
   Factor = F1./F2;

%% EOF