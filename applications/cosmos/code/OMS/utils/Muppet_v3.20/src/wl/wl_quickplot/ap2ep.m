function [SEMA,  ECC, INC, PHA, w, TWOCIR]=ap2ep(Au, PHIu, Av, PHIv, plot_demo)
%
% Convert tidal amplitude and phase lag (ap-) parameters into tidal ellipse
% (ep-) parameters. Please refer to ep2app for its inverse function.
% 
% Usage:
%
% [SEMA,  ECC, INC, PHA, w]=ap2ep(Au, PHIu, Av, PHIv, plot_demo)
%
% where:
%
%     Au, PHIu, Av, PHIv are the amplitudes and phase lags (in degrees) of 
%     u- and v- tidal current components. They can be vectors or 
%     matrices or multidimensional arrays.
%            
%     plot_demo is an optional argument, when it is supplied as an array 
%     of indices, say [i j k l], the program will plot an  ellipse 
%     corresponding to Au(i,j, k, l), PHIu(i,j,k,l), Av(i,j,k,l), and 
%     PHIv(i,j,k,l); 
%     
%     Any number of dimensions are allowed as long as your computer 
%     resource can handle.     
%     
%     SEMA: Semi-major axes, or the maximum speed;
%     ECC:  Eccentricity, the ratio of semi-minor axis over 
%           the semi-major axis; its negative value indicates that the ellipse
%           is traversed in clockwise direction.           
%     INC:  Inclination, the angles (in degrees) between the semi-major 
%           axes and u-axis.                        
%     PHA:  Phase angles, the time (in angles and in degrees) when the 
%           tidal currents reach their maximum speeds,  (i.e. 
%           PHA=omega*tmax).
%          
%           These four ep-parameters will have the same dimensionality 
%           (i.e., vectors, or matrices) as the input ap-parameters. 
%
%     w:    Optional. If it is requested, it will be output as matrices
%           whose rows allow for plotting ellipses and whose columns are  
%           for different ellipses corresponding columnwise to SEMA. For
%           example, plot(real(w(1,:)), imag(w(1,:))) will let you see 
%           the first ellipse. You may need to use squeeze function when
%           w is a more than two dimensional array. See example.m. 
%
% Document:   tidal_ellipse.ps
%   
% Revisions: May  2002, by Zhigang Xu,  --- adopting Foreman's northern 
% semi major axis convention.
% 
% For a given ellipse, its semi-major axis is undetermined by 180. If we borrow
% Foreman's terminology to call a semi major axis whose direction lies in a range of 
% [0, 180) as the northern semi-major axis and otherwise as a southern semi major 
% axis, one has freedom to pick up either northern or southern one as the semi major 
% axis without affecting anything else. Foreman (1977) resolves the ambiguity by 
% always taking the northern one as the semi-major axis. This revision is made to 
% adopt Foreman's convention. Note the definition of the phase, PHA, is still 
% defined as the angle between the initial current vector, but when converted into 
% the maximum current time, it may not give the time when the maximum current first 
% happens; it may give the second time that the current reaches the maximum 
% (obviously, the 1st and 2nd maximum current times are half tidal period apart)
% depending on where the initial current vector happen to be and its rotating sense.
%
% Version 2, May 2002


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
