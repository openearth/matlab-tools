%--------------------------------------------------------------------------
%
% MoonPhases: Determines the times of lunar phases and checks for eclipses
%
% References:
% O. Montenbruck, T. Pfleger, "Astronomy on the Personal Computer", 
% Springer Verlag, Heidelberg, 4th edition (2000).
% Meeus J.; Astronomical Algorithms; Willmann-Bell; Richmond, Virginia; 2nd
% edition (1998).
% https://eclipse.gsfc.nasa.gov/LEcat5/deltatpoly.html
% 
% Last modified:   2018/01/16   M. Mahooti
% 
%--------------------------------------------------------------------------
clc
clear
format long g

global Phase PC

Ast_Const

load DE430Coeff.mat
PC = DE430Coeff;

% Phase
% 0 'NewMoon'
% 1 'FirstQuarter'
% 2 'FullMoon'
% 3 'LastQuarter'

dT = 7/36525; % Step (1 week)

% Title
fprintf('\n');
fprintf('        PHASES: Phases of the Moon and Check for Eclipses\n');
fprintf('\n');

% Input
fprintf(' Dates of Lunar Phases for the year ... ');
Year = input(' yyyy ');
fprintf('\n');

% Header
fprintf(' New Moon ');
fprintf('          First Quarter');
fprintf('     Full Moon');
fprintf('          Last Quarter\n');

% Assure that we get the year's first New Moon
% [T0, T1]: Interval bracketing the instant TPhase to be found
T0 = ( Mjday(Year-1, 12, 1) - MJD_J2000 )/36525;
T1 = T0 + dT;
TPhase = T0;

% Check 13 months
for Lunation=0:13
  
  % Search for phases
  for iPhase = 0:3
      
      Phase = iPhase;
      
      % Bracket desired phase event
      D0 = PhasesFunc(T0);
      D1 = PhasesFunc(T1);
      
      while ( (D0*D1>0) || (D1<D0) )
          T0 = T1;
          D0 = D1;
          T1 = T1+dT;
          D1 = PhasesFunc(T1);
      end
      
      % Iterate time of phase
      TPhase = Pegasus(@PhasesFunc, T0, T1);
      
      % Correct for difference of ephemeris time and universal time
      JD = TPhase*36525+MJD_J2000+2400000.5;
      [year,mon,day,hr,min,sec] = invjday(JD);
      temp   = JD-2415019.5;
      leapyrs= floor( ( year-1901 )*0.25 );
      days   = temp - ((year-1900)*365 + leapyrs );
      ET_UT = ETminUT(year+days/365.25);
      MjdUT = ( TPhase*36525+MJD_J2000 ) - ET_UT/86400;
      
      % Output date and time of event
      if ( Phase==0 )
          fprintf(' ');
      end
      MjdRound = floor(1440*MjdUT+0.5)/1440+0.00001;
      [year,mon,day,hr,min,sec] = invjday(MjdRound + 2400000.5);
      fprintf('%4d/%2.2d/%2.2d  %2.2d:%2.2d', year, mon, day, hr, min);      
      
      % Eclipse check
      MJD_UTC = 36525*TPhase+MJD_J2000;
      [r_Mercury,r_Venus,r_Earth,r_Mars,r_Jupiter,r_Saturn,r_Uranus, ...
       r_Neptune,r_Pluto,r_Moon,r_Sun] = JPL_Eph_DE430(MJD_UTC);
      r_Moon = EclMatrix(MJD_UTC)*PrecMatrix(MJD_J2000,MJD_UTC)*r_Moon;
      [l,b,r] = CalcPolarAngles(r_Moon);
      beta = b;
      
      if ( iPhase == 0 )
          fprintf('%s', SolarEclipseFlag(beta));
      elseif ( iPhase == 2 )
          fprintf('%s', LunarEclipseFlag(beta));
      else
          fprintf(' ');  % First or Last Quarter
      end
      
      % Move search interval by one week
      T0 = TPhase;
      T1 = T0 + dT;
  end
  fprintf('\n');
end

% Footer
fprintf('\n All times in Universal Time (UT).\n\n');

