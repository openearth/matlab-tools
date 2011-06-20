function varargout=thindam(varargin)
%THINDAM Plot dams, weirs and vanes.
%   THINDAM(NFStruct,T)
%   plots the KFU/V dams for time step T if T>0
%   plots the KCU/V thin dams if T==0 (default)
%
%   THINDAM(NFStruct,T,'3D')
%   same as above but now the dams will be
%   plotted with as 3D surfaces based on the
%   bottom and waterlevel information in the
%   specified NEFIS file.
%
%
%   THINDAM(XCOR,YCOR,UDAM,VDAM);
%   plots the dams on the specified grid.
%
%   The XCOR and YCOR represent the bottom points.
%   Valid entries for UDAM and VDAM are:
%
%   1) 0/1 matrix of same size as XCOR/YCOR
%      1 = dam, 0 = no dam
%
%   2) D x 2 matrix specifying the M,N coordinates
%      of the dams
%
%   3) D x 4 matrix specifying the begin/end M,N
%      coordinates of the dams like in the Delft3D
%      input files.
%
%   THINDAM(..., 'bottom',<bottom_args>, ...
%                'top',<top_args>)
%   plots the dams as 3D surfaces with specified
%   top and bottom elevations. The elevation data
%   should be specified with positive direction up.
%
%   Additional options:
%
%   * 'parent',axes handle
%     the dams/vanes are plotted in the specified
%     axes instead of the current axes.
%
%   * 'angle',<angle_args>
%     the dams/vanes are rotated to match the specified
%     angle in degrees with respect to the positive X-axis
%     (positive angle in anti-clockwise direction).
%
%   * 'color',<color_args>
%     the dams are colored using the specified data.
%
%   * 'thickness',<thickness_args>
%     the thickness of the dams is specified (default 0).
%
%   If a color data field has been specified, there are
%   a few more options available:
%
%   * 'shape',<type> (default 'dam')
%     alternative: 'rhombus'.
%   * 'drawdams',<onoff> (default 'on')
%     set to 'off' if you don't want the dams.
%   * 'drawlabels',<ofoff> (default 'off')
%     set to 'on' if you want to plot the color values as
%     text.
%   * 'labelformat',<format> (default '%g')
%     defines the format for displaying the values.
%   * 'fontsize',<size> (default 4)
%     defines the size of the values.
%
%   Valid entries for all <..._args> are:
%
%   * a constant, uniform value for alle dams
%
%   * a matrix of same size as XCOR/YCOR containing
%     elevations in the depth points.
%
%   * a matrix of same size as XCOR/YCOR containing
%     elevations in the waterlevel points. To
%     distinguish this entry from the former you
%     need to add the string 'H' or 'S' as an extra
%     argument after the matrix:
%        THINDAM(... ,ELEVMATRIX,'H', ...)
%     The elevation will be used uniformly along
%     each elementary dam.
%
%   * two matrices of same size as XCOR/YCOR containing
%     elevations in the U resp. V points.
%
%   * two D x s arrays specifying the height of the
%     individual dams. If the array is D x 1 the
%     elevation is taken uniformly, is the array is
%     D x 2 the first elevation is taken for the
%     dam end with lowest (M,N) the second elevation
%     for the dam end with highest (M,N). The first
%     array specifies the elevation for dams in U
%     direction the second array for dams in the V
%     direction:
%        THINDAM(... ,ELEVU,ELEVV, ...)
%     This option cannot be used in combination with
%     option 1 for the UDAM and VDAM entries (nor with
%     the option. The number of heights should match
%     the number of dam records / elementary dams.
%
%
%   THINDAM('xyw',XDAM,YDAM,WDAM,...)
%   plots dams at specified locations with specified
%   width. An option entry should be either:
%
%   * a constant (uniform value for alle dams), or
%
%   * a matrix of same size as XDAM/YDAM/WDAM.
%
%
%   H=THINDAM(...)
%   returns the handle of the line/surface object.
%
%   [X,Y]=THINDAM(...)                           (2D case only)
%   returns the x,y-arrays normally used for plotting.
%   The dams are not plotted.
%
%   [X,Y,M,N]=THINDAM(...)                       (2D case only)
%   returns nx2 matrices containing per row a pair of
%   endpoints for an elementary dam. The dams are not plotted.
%
%   [X,Y,Z]=THINDAM(...)                         (3D case only)
%   returns the x,y,z-arrays normally used for plotting.
%   The dams are not plotted.
%
%   [X,Y,BOTTOM,TOP]=THINDAM(...)                (3D case only)
%   returns nx2 matrices containing per row a pair of endpoints
%   for an elementary dam: X coordinates, Y coordinates, bottom
%   elevation and top elevation. The dams are not plotted.
%
%   [X,Y,BOTTOM,TOP,M,N]=THINDAM(...)            (3D case only)
%   returns nx2 matrices containing per row a pair of endpoints
%   for an elementary dam: X coordinates, Y coordinates, bottom
%   elevation, top elevation, M index, N index. The dams are
%   not plotted.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%
% ------- do some initialization
%

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
