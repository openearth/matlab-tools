function ARS = prob_ars_set_mult(b, u, z, varargin)
%PROB_ARS_SET_MULT One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_total(varargin)
%
%   Input: For <keyword,value> pairs call prob_ars_total() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_total
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Sep 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings

OPT = struct(...
    'ARS',              prob_ars_struct_mult,   ...                         % ARS structure
    'DesignPointDetection', true,               ...                         % Boolean switch for automatic detection of design points                
    'DesignPointFunction',  @prob_ars_design_point_detection,   ...         % Design point detection function 
    'ARSsetFunction',   @prob_ars_set2,         ...                         % Function handle to update ARS structure based on a set
                                                ...                            of vectors u and corresponding z-values
    'ARSsetVariables',  {{}}                    ...                         % Additional variables to the ARSsetFunction
);

OPT = setproperty(OPT, varargin{:});

%% Include points from ARS structure

ARS     = OPT.ARS;

b       = [cat(1,ARS.b); b'];                                               % Include beta values already present in ARS structure
u       = [cat(1,ARS.u); u];                                                % Include u values already present in ARS structure
z       = [cat(1,ARS.z); z'];                                               % Include z values already present in ARS structure

%% Design point detection

if OPT.DesignPointDetection
    [b_DPs b_other u_DPs u_other z_DPs z_other i]   = feval(    ...             % Find design points and cluster the other points to them
        OPT.DesignPointFunction,  ...
        b, ...
        u, ...
        z, ...
        'ARS', ARS ...
        );
    
    nr_DPs = size(z_DPs,1);
else
    nr_DPs = 1;                                                             % Only one ARS
    
    b_DPs   = nan;
    u_DPs   = nan(1,size(u,2));
    z_DPs   = nan;
    b_other     = b;
    u_other     = u;
    z_other     = z;
end

%% Generate ARS's



if nr_DPs>1
    for n = 1:nr_DPs
        ii = find(i==n);
        bi  = [b_DPs(n); b_other(ii,:)];
        ui  = [u_DPs(n,:); u_other(ii,:)];
        zi  = [z_DPs(n); z_other(ii)];
        ARS(n)  = feval( ...                                                % Compute ARS based on exact samples
            OPT.ARSsetFunction,     ...
            bi,                     ...
            ui,                     ...
            zi,                     ...
            'nr_DPs', nr_DPs,       ... 
            'n', n,                 ...
            'ARS',ARS,              ...
            OPT.ARSsetVariables{:}      );
    end
else                                                                        
    % Generate only a single ARS
    bi  = [b_DPs; b_other];
    ui  = [u_DPs; u_other];
    zi  = [z_DPs; z_other];
    
    ARS(1)  = feval( ...                                                    % Compute ARS based on exact samples
        OPT.ARSsetFunction,     ...
        bi,                     ...    
        ui,                     ...
        zi,                     ...
        'ARS',ARS,              ...
        OPT.ARSsetVariables{:}      );
end