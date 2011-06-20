function [cout,H,CS] = contourfcorr(varargin)
%CONTOURFCORR Filled contour plot (corrected).
%   CONTOURF(...) is the same as CONTOUR(...) except that the contours
%   are filled.  Areas of the data at or above a given level are filled.
%   Areas below a level are either left blank or are filled by a lower
%   level.  NaN's in the data leave holes in the filled contour plot.
%
%   C = CONTOURF(...) returns contour matrix C as described in CONTOURC
%   and used by CLABEL.
%
%   [C,H,CF] = CONTOURF(...) also returns a column vector H of handles
%   to PATCH objects and the contour matrix CF for the filled areas.
%   The UserData property of each object contains the height value for each
%   contour.
%
%   Example
%      z=peaks; contourf(z), hold on, shading flat
%      [c,h]=contour(z,'k-'); clabel(c,h), colorbar
%
%   See also CONTOUR, CONTOUR3, CLABEL, COLORBAR.

% To correct erroneous ordering of the full area patches
% when the grid is clipped using NaN in the values matrix
% and a constant value for the coordinates. Reason for
% error: the NaNs are replaced by a small value, for
% contour lines close to that value the enclosed area is
% smaller (goes to zero) than the area enclosed by a
% contour line of approximately min(val). This causes
% the contours for smaller values to be plotted after the
% contours for the larger values. The lowest value will
% appear to belong to lie between the smallest thresholds.
% The following code reproduces this phenomenon:
%
% [xx,yy]=meshgrid(1:10,1:10);
% xx([1 end],:)=0;
% xx(:,[1 end])=0;
% yy=xx';
% zz=ones(10,10);
% zz(5,5)=2;
% zz(xx==0)=NaN;
% surf(xx,yy,zz)
% figure;
% contourf(xx,yy,zz,[-2 -1 0 1.5])
% colorbar
%
% This function solves this problem by basing the ordering on
% a dummy, rectangular grid.

%   Author: R. Pawlowicz (IOS)  rich@ios.bc.ca   12/14/94
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision$  $Date$
%
%   Correction by H.R.A. Jagers (Deltares)
%                        bert.jagers@wldelft.nl, 2001/07/18


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
