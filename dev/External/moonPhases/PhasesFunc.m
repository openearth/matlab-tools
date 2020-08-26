%------------------------------------------------------------------------------
%
% PhasesFunc: Goal function for search of phase events [-pi, pi]
%
% Input:
%   T         Ephemeris Time (Julian centuries since J2000)
%
% Output:     
%   out       Difference between the longitude of the Moon from the Sun
%             and the nominal value for a given phase (New Moon 0, First 
%             Quarter pi/2, etc.) (in [rad])
%
% Global:
%   Phase     Flag for desired lunar phase
%
% Last modified:   2018/01/16   M. Mahooti
% 
%------------------------------------------------------------------------------
function out = PhasesFunc(T)

global Phase

Ast_Const

tau_Sun = 8.32/(1440*36525); % 8.32 min  [cy]

MJD_UTC = 36525*T+MJD_J2000;
[r_Mercury,r_Venus,r_Earth,r_Mars,r_Jupiter,r_Saturn,r_Uranus, ...
 r_Neptune,r_Pluto,r_Moon,r_Sun] = JPL_Eph_DE430(MJD_UTC);
r_Moon = EclMatrix(MJD_UTC)*PrecMatrix(MJD_J2000,MJD_UTC)*r_Moon;
[lM,bM,rM] = CalcPolarAngles(r_Moon);

MJD_UTC = 36525*(T-tau_Sun)+MJD_J2000;
[r_Mercury,r_Venus,r_Earth,r_Mars,r_Jupiter,r_Saturn,r_Uranus, ...
 r_Neptune,r_Pluto,r_Moon,r_Sun] = JPL_Eph_DE430(MJD_UTC);
r_Sun = EclMatrix(MJD_UTC)*PrecMatrix(MJD_J2000,MJD_UTC)*r_Sun;
[lS,bS,rS] = CalcPolarAngles(r_Sun);

LongDiff = lM - lS;

out = mod( LongDiff - Phase*pi/2 + pi, pi2 ) - pi;

