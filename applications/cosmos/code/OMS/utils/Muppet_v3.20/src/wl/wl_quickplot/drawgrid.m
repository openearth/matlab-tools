function [x,y]=drawgrid(varargin),
%DRAWGRID Plots the grid.
%   DRAWGRID(NFStruct)
%   draws the grid in the current axes
%
%   [X,Y]=DRAWGRID(NFStruct);
%   returns X and Y (but does not draw the grid)
%
%   DRAWGRID(X,Y);
%   draws the grid given by the specified X and Y
%   matrices in the current axes
%
%   ...,'optionname',optionval,...
%   supported options:
%   * 'color'      value can be RGB-triplet, color character, or
%                  'ortho' for orthogonality of grid
%                  'msmo' for M smoothness of grid
%                  'nsmo' for N smoothness of grid
%   * 'm1n1'       [N M] number of gridpoint(1,1)
%   * 'fontsize'   size of the font used for grid numbering
%   * 'gridstep'   label step used for grid numbering
%                  if gridstep is [], gridlines are not labeled
%   * 'ticklength' length of ticks in axes coordinates or 'auto'
%   * 'parent'     axes handle in which to plot grid
%   * 'clipzero'   by default co-ordinate pairs of (0,0) are
%                  clipped. Set to 'off' to plot co-ordinates
%                  at (0,0).

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
