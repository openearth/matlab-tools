function degUC = degN2degunitcirle(degN)
%DEGN2DEGUNITCIRLE   convert directions between conventions
%
% degUC = DEGN2DEGUNITCIRLE(degN) converts a wind direction
% on a unit circle (degrees cartesian) to a direction in a
% nautical convention (degrees north).
%
% In a unit circle it is the angle between the arrow
% head and the horizontal east.
%
% In a nautical convention it is the angle between the arrow
% tail and the vertical up.
%
% Note that in the unit circle the direction is zero if
% the arrow points towards OUTWARDS towards the east,
% while in the nautical convention it is zero when the direwction
% is INWARDS towards the south.
%
%
% Degrees North            Unit circle
% Nautical convention      Cartesian convention
% Positive inward to (0,0) Positive outward from (0,0)
%
%                                        
% >   N-180   >            <   N-90   <  
%    /     \                  /     \    
% W-90      E-270          W-180     E-0/360
%    \     /                  \     /    
% <   S-0/360 <            >   S-270  >  
%                                        
% angle between tail and   angle between tip and horizontal
% vertical up.
%
%See also: DEGUNITCIRCLE2DEGN, DEGUC2DEGN

degUC = - degN + 270;

degUC(degUC<=0 ) = degUC(degUC<= 0) + 360;
degUC(degUC>360) = degUC(degUC>360) - 360;

