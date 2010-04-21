function Factor=convert_units(InUnits,OutUnits);
%CONVERT_UNITS    Unit conversion function
%
%    factor = convert_units(InUnits,OutUnits)
%
% Given an input and output strings containing units 
% CONVERT_UNITS returns the conversion multiplication 
% factor needed for converting the input units to the output units.
%
%   Input  : - InUnits:  String containing the input units  (e.g. 'days').
%            - OutUnits: String containing the output units (e.g. 'seconds').
%   Output : - factor:   Multiplication factor for converting input units to
%                        output units.
%
% Example : 
%
%   A = convert_units('m^3 * kg^-1 * s^-2','cm^3 * gr^-1 * s^-2').*B;
%
% Note 1: the user is responsible for the balance of the transformation.
% Note 2: units are case-sensitive.
% Note 3: add any unknown units by editing this function.
%
% See web: <a href="http://www.unidata.ucar.edu/software/udunit">http://www.unidata.ucar.edu/software/udunit</a>
% See also: unitsratio (mapping toolbox), unitconv

%-----------------------------------------------------------------------
% Tested : Matlab 6.5
%     By : Eran O. Ofek             July 2003
%    URL : http://wise-obs.tau.ac.il/~eran/matlab.html
%-----------------------------------------------------------------------

% 2008 jan 23: started forces and pressure section [Gerben J. de Boer]
% 2008 jan 23: removed refs to constants [Gerben J. de Boer]
% 2008 apr 14: added plural versions [Gerben J. de Boer]

    InUnits = strrep( InUnits,'%','0.01');
   OutUnits = strrep(OutUnits,'%','0.01');

   %% Definitions  
   % ---------------------
   RAD             = 180./pi;
   cyc             = 1;
   cycle           = 1;
   cycles          = 1;
   
   %% Definitions  
   % ---------------------
   ppm             = 1e-6;

   %% Length units 
   % ---------------------
   mm              = 1e-3;                    % mms
   mms             = mm;                      % mms
   millimeter      = mm;                      % mms
   millimeters     = mm;                      % mms

   cm              = 1e-2;                    % cms
   cms             = cm;                      % cms
   centimeter      = cm;                      % cms
   centimeters     = cm;                      % cms

   inch            = 0.0254;                  % inch
   	     
   feet            = 0.30480;                 % foot
   foot            = feet;                    % foot
   feets           = feet;                    % foot
   	     
   yard            = 0.9144;                  % yard
   yards           = yard;                    % yard
	     
   m               = 1;                       % meters
   meter           = m;                       % meters
   meters          = m;                       % meters
	     
   km              = 1000;                    % km
   kilometer       = km;                      % kilometers
   kilometers      = km;                      % kilometers
	     
   mile            = 1609;                    % miles
   miles           = mile;                    % miles
   
   %% Volume units 
   % ---------------------
   l               = 1e-3;                    % liter
   liter           = l;                       % liter
   liters          = l;                       % liter
   litre           = l;                       % liter
   litres          = l;                       % liter

   %% Time units 
   % ---------------------
   
   s               = 1;                       % seconds
   sec             = s;                       % seconds
   secs            = s;                       % seconds
   second          = s;                       % seconds
   seconds         = s;                       % seconds
   
   ms              = 0.001*s;                 % milliseconds
   millisecs       = ms;                      % milliseconds
   millisec        = ms;                      % milliseconds
   millisecond     = ms;                      % milliseconds
   milliseconds    = ms;                      % milliseconds
   
   min             = 60*s;                    % minutes
   mins            = min;                     % minutes
   minute          = min;                     % minutes
   minutes         = min;                     % minutes
   
   h               = 3600*s;                  % hours
   hr              = h;                       % hours
   hrs             = h;                       % hours
   hour            = h;                       % hours
   hours           = h;                       % hours
   
   sday            = 86164.09053*s;           % sidereal days
   sdays           = sday;                    % sidereal days

   d               = 86400*s;                 % days
   day             = d;                       % days
   days            = d;                       % days
   
   week            = 7.*day;                  % weeks
   weeks           = week;                    % weeks
   
   %% years: http://en.wikipedia.org/wiki/Gregorian_year
   
   yr              = 365.24218967.*day;       % tropical year http://en.wikipedia.org/wiki/Gregorian_year#Sidereal.2C_tropical.2C_and_anomalistic_years
   yrs             = yr;                      % tropical year
   year            = yr;                      % tropical year
   years           = yr;                      % tropical year
   
   common_year     = day*365;                 % common year
   common_years    = common_year;             % common year
    
   leap_year       = day*366;                 % leap year
   leap_years      = leap_year;               % leap year

   Gregorian_year  = day*365.2425;            % Gregorian year
   Gregorian_years = Gregorian_year;          % Gregorian year
    
   Julian_year     = day*365.25;              % Julian year
   Julian_years    = Julian_year;             % Julian year
   
   sidereal_year   = day*365.2564;            % sidereal year
   sidereal_years  = Julian_year;             % sidereal year
  
   cen             = year*100;                % tropical century
   
   month           = year/12;                 % months
   months          = month;                   % months
   
   %% Pressure units 
   % ---------------------
   Pa              = 1;                       % pascal
   hPa             = 100;                     % hectopascal
   bar             = 1e5;                     % bar
   mbar            = 100;                     % millibar

   %% Force units 
   % ---------------------
   dyn             = 1e-5;                    % dyne
   dyne            = 1e-5;                    % dyne
   dynes           = 1e-5;                    % dyne
   	      
   N               = 1;                       % Newton
   newton          = N;                       % Newton
   Newton          = N;                       % Newton
   
   %% Mass units 
   % ---------------------
   ug               = 1e-6;                   % ug
   mg               = 1e-6;                   % ug
   mgr              = 1e-6;                   % ug

   gr               = 1e-3;                   % grams
   grs              = gr;                     % grams
   gram             = gr;                     % grams
   grams            = gr;                     % grams
   
   kg               = 1;                      % kilograms
   kgs              = kg;                     % kilograms
   kilogram         = kg;                     % kilograms
   kilograms        = kg;                     % kilograms

   libra            = 0.32736409;             % libra
   pound            = 0.45359237;             % pound
   
   %% Angle units 
   % ---------------------
   rad             = 1;                       % radian
   deg             = 1./RAD;                  % degree
   amin            = deg./60;                 % arcmin
   asec            = amin./60;                % arcsec
   
   %% Solid Angle units 
   % ---------------------
   ster            = 1;                       % steradian
   sdeg            = 1./(RAD.^2);             % square degree
   smin            = 1./((60.*RAD).^2);       % square arcmin
   ssec            = 1./((3600.*RAD).^2);     % square arcsec

% Find conversion factor 
%---------------------
   F1              = eval(InUnits);
   F2              = eval(OutUnits);
   Factor          = F1./F2;

%% EOF