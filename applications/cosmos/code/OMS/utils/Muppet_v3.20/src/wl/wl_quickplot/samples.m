function [x,y,z]=samples(cmd,varargin)
%SAMPLES Read/write sample data from file.
%     XYZ = SAMPLES('read',FILENAME) read the specified file and return the
%     samples as one Nx3 array.
%
%     [X,Y,Z] = SAMPLES('read',FILENAME) read the specified file and return
%     the samples in three separate Nx1 arrays.
%
%     SAMPLES('write',FILENAME,XYZ) write samples given in a Nx3 array to
%     file.
%
%     SAMPLES('write',FILENAME,X,Y,Z) write samples given in three Nx1
%     arrays to file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
