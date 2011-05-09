function I = spirint(varargin)
%SPIRINT Computes spiral intensity from 3D flow field.
%
%   SPI=SPIRINT(Chezy,NefisFile,TimeStep)
%   The Chezy value is required (see explanation below). The other
%   two input arguments may be dropped. In that case the following
%   defaults are used:
%   Default NefisFile = last opened Nefis file
%   Default TimeStep = last stored in Nefis file
%   If the file is a communication file, the specified Chezy may
%   be empty, that is []. In that case the roughness is read from
%   the file.
%
%   For 2D simulations, the spiral intensity is read directly
%   from the NEFIS file (Chezy value is a dummy argument). For
%   3D simulations, it is computed as
%
%       (vda * qx1 - uda * qy1) * Uda
%   I = -----------------------------
%       (uda * qx1 + vda * qy1) * alf
%
%   Uda = sqrt(uda^2+vda^2)
%   alf = (2/(kappa^2)) * (1.0 - 0.5 * sqrt(g) / (kappa * C) )
%
%   uda/vda : depth averaged flow velocity in u/v direction
%   qx1/qy1 : discharge in lowest layer
%   g       : gravitational acceleration
%   kappa   : von Karman constant
%   C       : Chezy roughness value

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

% determine Chezy value ... Chz

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
