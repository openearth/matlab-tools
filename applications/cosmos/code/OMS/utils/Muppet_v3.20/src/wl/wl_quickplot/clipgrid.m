function [xo,yo] = clipgrid(x,y,xp,yp,varargin)
%CLIPGRID Clip a grid away from the inside/outside of a polygon.
%   [XO,YO] = CLIPGRID(XI,YI,XP,YP,SIDE) clips the grid specified by the
%   XI,YI coordinates away from the SIDE ('inside' or 'outside') of the
%   polygon given by the XP,YP coordinates. In general the clipping will
%   not be perfect and manual improvements can be made (especially if the
%   polygon has sharp corners).
%
%   [XO,YO] = CLIPGRID(XI,YI,XP,YP) by default clips the grid away from the
%   inside of the polygon.
%
%   CLIPGRID(...) without output arguments plots the original grid, clipped
%   grid, deleted points together with the polygon.
%
%   CLIPGRID(...,FACTOR) uses the specified FACTOR in the evaluation of
%   Distance_Polygon_ClipPoint < FACTOR * Distance_ClipPoint_KeepPoint
%   where the first variable is the distance between the polygon and the
%   point to be clipped and the last variable is the distance between the
%   point to be clipped and the neighboring point to keep. If this
%   condition is satisfied the point to be clipped will be moved onto the
%   polygon; if the condition is not satisfied the point to keep will be
%   moved onto the polygon. By default FACTOR equals 0.9 which means that
%   points to keep will only be shifted if the distance between grid points
%   would otherwise be reduced to less than 10% of the original distance.
%   Small grid cells are least likely to form if FACTOR = 0.5, bigger
%   values of FACTOR lead to less grid distortion.
%
%   CLIPGRID without input arguments shows a simple example.
%
%   Note: because common grid orthogonality rules will be violated (local)
%   momentum conservation is no longer satisfied for Delft3D simulations on
%   such a grid! Apply this method only if local momentum conservation is
%   not relevant for the outcome of your simulation.
%
%   Example 1
%      [x,y]=meshgrid(0:100,0:100);
%      s1 = sin((0:5:90)*pi/180);
%      s2 = fliplr(s1);
%      clipgrid(x,y,[s1*100 s2*50],[s2*100 s1*50],'outside')
%
%   Example 2
%      [x,y]=meshgrid(0:50,0:40);
%      [xo,yo]=clipgrid(x,y,[17 23 13 7],[7 17 23 13]);
%      clipgrid(xo,yo,[37 43 33 27],[17 27 33 23])
%      line([17 23 13 7 17],[7 17 23 13 7],'linewidth',3)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
