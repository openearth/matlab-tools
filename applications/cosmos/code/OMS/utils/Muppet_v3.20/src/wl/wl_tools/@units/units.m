function u = units(arg1,arg2)
%UNITS Units class constructor.
%   UNITS(arg) creates or converts a units object.
%
%   The argument may be a string containing any of several dozen key
%   words, such as meter, kg, second, milli, foot, volt and lightyear,
%   separated by single punctuation characters including ., *, -, / and ^.
%   Many commonly used terms from the MKS, CGS and English systems
%   of measurement are recognized.
%
%   Eg.  units('meter')                    1 meter
%        980*units('cm/s^2')               980 cm/s^2
%        units('g')                        9.8066 m/s^2
%        units('c')                        299792458 m/s
%        units('hertz')                    1 cycle/sec
%        (0:5:55)'*units('miles/hour')     [1x12double] * mile/hour
%
%   The result is expressed in terms of powers of eight fundamental units,
%   Two of the fundamental units can be chosen from three different systems,
%   while six of the fundamental units are the same for all three systems.
%
%                               SI,MKS        CGS            English,USA
%
%        length                 meter         centimeter     inch
%        mass                   kilogram      gram           pound
%        time                   second
%        current                ampere
%        temperature            Kelvin
%        amount of substance    mole
%        light intensity        candela
%        rotation               radian
%
%   UNITS(arg1,arg2) converts arg1 to the units specified by arg2.
%
%   Eg.  640*units('acre','mile')          1 mile^2
%        units('microcentury','min')       52.5949 min      
%        c = units('c')                    c = 299792458 m/s
%        units(c,'English')                11802852677.1654 in/s
%        units(c,'miles/sec')              186282.3971 miles/sec
%        units(c,'ft, nanosecond')         0.98357 ft/nano-second
%
%   UNITS HELP      returns a cell array of all the recognized key words.
%   UNITS HELP XXX  returns the definition of the key word XXX.
%   New key words may be added by editing this file, @units/units.m.
%
%   Eg.  units help
%        units help year
%
%   An excellent reference, by Prof. Russ Rowlett, University of
%   North Carolina at Chapel Hill, is available on the Web at:
%   http://www.unc.edu/~rowlett/units.
%
%   See also: units/convert, units/mks, units/cgs, units/usa

%   The units structure has three fields.  The .val field is a traditional
%   MATLAB scalar, vector or matrix containing the numerical value.
%   The .bas field is a cell array of eight basis units; the default basis
%   is {'m','kg','s','A','K','mol','cd','rad'}.  The .pow field is a vector
%   with eight integer components containing the powers of the basis units.
%   For example, the acceleration of gravity is g = units('g').  With the
%   default .bas field, the other two fields are g.val = 9.80665 and
%   g.pow = [1 0 -2 0 0 0 0 0], which represents m/s^2.

if nargin == 0 | isempty(arg1)
   u = basic_unit(1);
   return

elseif isa(arg1,'units')
   u = arg1;
   if (nargin == 1), return, end

elseif isa(arg1,'double')
   u = basic_unit(arg1);
   return

elseif ~isstr(arg1)
   error('First argument must be a double, a string, or a units object.')

elseif strcmp(arg1,'help')
   if nargin < 2 | strcmp(arg2,'all')
      u = units_help_all;
   else
      u = units_help(arg2);
   end
   return

elseif ~all(isletter(arg1))

   % Recursively parse string

   s = arg1;
   k = min(find(~isletter(s)));
   if s(k) == '/'
      u = units(s(1:k-1))/units(s(k+1:end));
   elseif s(k) == '^'
      u = units(s(1:k-1))^str2num(s(k+1))*units(s(k+2:end));
   else
      u = units(s(1:k-1))*units(s(k+1:end));
   end

else

   s = arg1;

   % Prefix

   prefix = 1;
   k = 1;
   if length(s) >= 4
      k = 5;
      switch(s(1:4))
         case {'peta'},   prefix = 1e15;
         case {'tera'},   prefix = 1e12;
         case {'giga'},   prefix = 1e9;
         case {'mega'},   prefix = 1e6;
         case {'kilo'},   prefix = 1e3;
         case {'deka'},   prefix = 10;
         case {'deci'},   prefix = 1/10;
         case {'nano'},   prefix = 1/1e9;
         case {'pico'},   prefix = 1/1e12;
         otherwise, k = 1;
      end
   end
   if k == 1 & length(s) >= 5
      k = 6;
      switch(s(1:5))
         case {'hecto'},  prefix = 100;
         case {'centi'},  prefix = 1/100;
         case {'milli'},  prefix = 1/1e3;
         case {'micro'},  prefix = 1/1e6;
         case {'femto'},  prefix = 1/1e15;
         otherwise, k = 1;
      end
   end
   if length(s) > k & s(k) == '-'
      k = k+1;
   end

   % Ignore any trailing 's'

   e = length(s);
   if e > 1 & s(e) == 's'
      e = e-1;
   end

   switch s(k:e);

   % Fundamental units

   case {'second','sec','s'}, basic_unit('s');   % time
   case {'meter','m'},     basic_unit('m');      % length
   case {'kilogram','kg'}, basic_unit('kg');     % mass
   case {'ampere','A'},    basic_unit('A');      % current
   case {'kelvin','K'},    basic_unit('K');      % temperature
   case {'mole','mol'},    basic_unit('mol');    % amount of substance
   case {'candela','cd'},  basic_unit('cd');     % light intensity
   case {'radian','rad'},  basic_unit('rad');

   % Derived units

   case {'degree','deg'},  pi/180*units('rad');
   case {'cycle','rev'},   2*pi*units('rad');
   case {'hertz','Hz'},    units('cycle/s');
   case {'newton','N'},    units('kg*m/s^2');
   case {'pascal','Pa'},   units('N/m^2');
   case {'joule','J'},     units('N*m');
   case {'watt','W'},      units('J/s');
   case {'coulomb','C'},   units('A*s');
   case {'volt','V'},      units('W/A');
   case {'farad','F'},     units('C/V');
   case {'ohm'},           units('V/A');

   % CGS

   case {'cm'},            units('centimeter');
   case {'gram','gr'},     units('kg')/100;
   case {'calorie','cal'}, 4.1868*units('J');
   case {'dyne'},          units('N')/1.e5;

   % Length

   case {'km'},            units('kilometer');
   case {'inch','in'},     units('ft')/12;
   case {'foot','ft'},     0.3048*units('m');
   case {'mile','mi'},     5280*units('ft');
   case {'yard','yd'},     3*units('ft');
   case {'fathom'},        6*units('ft');
   case {'rod','rd'},      5.5*units('yd');
   case {'furlong','fur'}, 40*units('rod');
   case {'lightyear'},     units('c*yr');
   case {'au'},            149597870*units('kilometer');
   case {'parsec'},        cot(pi/180/3600)*units('au');

   % Mass

   case {'pound','lb'},    453.59237*units('gr');
   case {'amu','u'},       units('gram')/units('Avogadro*mole');

   % Energy

   case {'Btu'},           1055.056*units('J');

   % Force

   case {'lbf'},           units('lb-g');

   % Area

   case {'acre'},          160*units('rod^2');
   case {'are'},           100*units('m^2');
   case {'hectare'},       100*units('are');
   case {'barn'},          1.e-28*units('m^2');

   % Volume

   case {'liter','L'},     units('m^3')/1000;
   case {'cc'},            units('L')/1000;

   % Time

   case {'minute','min'},  60*units('sec');
   case {'hour','hr'},     60*units('min');
   case {'day'},           24*units('hr');
   case {'week'},          7*units('day');
   case {'fortnight'},     2*units('week');
   case {'year','yr'},     (365+97/400)*units('day')-26.0237*units('sec');
   case {'century'},       100*units('yr');

   % Velocity

   case {'mph'},           units('miles/hour');

   % Physical constants

   case {'c'},             299792458*units('m/s');       % speed of light
   case {'g'},             9.80665*units('m/s^2');       % gravity
   case {'e'},             1.6021773349e-19*units('C');  % electron charge
   case {'me'},            9.109389754e-31*units('kg');  % electron mass
   case {'mp'},            1.672623110e-27*units('kg');  % proton mass
   case {'alpha'},         2*pi*1.e-7*units('c*e^2/h');  % fine structure
   case {'atm'};           101325*units('Pa');           % atmospheric pressure
   case {'R','gas'},       8.31451070*units('J/mol*K');  % gas constant
   case {'Avogadro','NA'}, 6.022136736e23*units('1/mol');
   case {'Newton','G'},    6.6725985e-11*units('m^3/kg*s^2');
   case {'Planck','h'},    6.62607540e-34*units('J*s');

   % Not recognized

   otherwise,              if isempty(s(k:e))
                              basic_unit(1);
                           else
                              basic_unit(NaN);
                           end
   end

   u = ans;
   u.val = prefix*u.val;
   if (nargin == 1) & all(u.pow >= 0) & (sum(u.pow) == 1)
      u.bas{find(u.pow)} = s;
      u.val = 1;
   end
end

if nargin == 2

   % Convert 

   SI = {'m','kg','s','A','K','mol','cd','rad'};
   if isa(arg2,'units')
      bas2 = arg2.bas;
   elseif strcmp(arg2,'MKS') | strcmp(arg2,'SI')
      bas2 = SI;
   elseif strcmp(arg2,'CGS')
      bas2 = {'cm','gr','s','A','K','mol','cd'};
   elseif  strcmp(arg2,'USA') | strcmp(arg2,'English')
      bas2 = {'in','lb','s','A','K','mol','cd'};
   elseif isstr(arg2)
      s = [arg2 ' '];
      bas2 = SI;
      while length(s) > 1
         k = min(find(~isletter(s)));
         w = units(s(1:k-1));
         if all(w.pow >= 0) & (sum(w.pow) == 1)
            bas2{find(w.pow)} = s(1:k-1);
         end
         s(1:k) = [];
      end
   end
   
   for k = 1:8
      if (u.pow(k) ~= 0) & ~isequal(u.bas{k},bas2{k})
         r = units(u.bas{k},'SI');
         s = units(bas2{k},'SI');
         u.val = u.val/(s.val/r.val)^u.pow(k);
         u.bas{k} = bas2{k};
      end
   end

end

% ========================

function u = basic_unit(s);
% Create the underlying structure for the units object.

u.val = 1;
u.bas = {'m','kg','s','A','K','mol','cd','rad'};
u.pow = zeros(1,8);
if isa(s,'double')
   u.val = s;
else
   switch s
      case 'm',   u.pow(1) = 1;
      case 'kg',  u.pow(2) = 1;
      case 's',   u.pow(3) = 1;
      case 'A',   u.pow(4) = 1;
      case 'K',   u.pow(5) = 1;
      case 'mol', u.pow(6) = 1;
      case 'cd',  u.pow(7) = 1;
      case 'rad', u.pow(8) = 1;
   end
end
u = class(u,'units');

% ========================

function s =  units_help_all
% Find all of the key words recognized by the units constructor.

fp = fopen('@units/units.m');
s = {'SI','MKS','CGS','English','USA'};
line = fgetl(fp);
while ~strcmp(line,'end')
   if findstr(line,'case');
      t = eval(line(findstr(line,'{'):findstr(line,'}')));
      s = {s{:} t{:}};
   end
   line = fgetl(fp);
end
s = sort(s);
n = 5;
m = ceil(length(s)/n);
for k = length(s)+1:m*n, s{k} = '    '; end
s = reshape(s,m,n);
fclose(fp);

% ========================

function s =  units_help(keyword)
% Find one of the key words recognized by the units constructor.

fp = fopen('@units/units.m');
s = '';
line = fgetl(fp);
while ~strcmp(line,'end')
   if findstr(line,'case')
      if findstr(line(findstr(line,'{'):findstr(line,'}')),keyword)
         s = strvcat(s,line);
      end
   end
   line = fgetl(fp);
end
if isempty(s)
   s = '   Sorry, not found.';
end
fclose(fp);
