function XNan=setnan(XLogic),
% SETNAN converts a logical 0/1-matrix into a 0/NaN-matrix
%        XNan=SETNAN(XLogic)
%        returns NaN if XLogic is 1 (XLogic<-2) | (XLogic>0)
%        returns 0   if XLogic is 0 (-2<=Xlogic<=0)

% (c) copyright 1998, H.R.A. Jagers, University of Twente / Delft Hydraulics

XNan=realmax*(1+XLogic)*0;