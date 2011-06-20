function [U,V]=cur2ca(u,v,alf)
%CUR2CA Rotate velocity components.
%   [U,V]=CUR2CA(u,v,alf)
%   Rotate velocity components in (xi,eta) directions
%   to components in (x,y) directions.
%   u and v are nTim x N1 x ... Nn x K1 x ... Km matrices
%   alf is an N1 x ... x Nn matrix

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
