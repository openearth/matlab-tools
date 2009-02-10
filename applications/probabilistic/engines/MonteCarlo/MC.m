function result = MC(stochast, varargin)
%MC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = MC(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   MC
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%%
%{
% example of MC
result = MC(createStochastVar,...
 'Resistance', 25:5:100);

% example of MC with simple importance sampling
result = MC(createStochastVar,...
 'Resistance', 25:5:100,...
 'ISvariable', 'WL_t',...
 'W', 100);

% example of MC with advanced importance sampling
result = MC(createStochastVar,...
 'Resistance', 25:5:100,...
 'ISvariable', 'WL_t',...
 'f1', 1,...
 'f2', 1e-6);
%}

%% settings
% defaults
OPT = struct(...
    'NrSamples', 1e2,...     % number of samples
    'ISvariable', '',...     % "importance sampling" variable
    'W', 1,...               % "importance sampling" factor
    'f1', Inf,...            % "importance sampling" upper frequency boundary
    'f2', 0,...              % "importance sampling" lower frequency boundary
    'Resistance', 0,...      % Resistance value(s) to be (optionally) used in z-function       
    'P2xFunction', @P2x,...  % Function to transform P to x
    'x2zFunction', @x2z,...  % Function to transform x to z
    'variables', {{}} ...    % aditional variables to use in x2zFunction
    );
% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

getdefaults('stochast', createStochastVar, 0);

Nstoch = length(stochast); % number of stochastic variables

active = ~cellfun(@isempty, {stochast.Distr});

if OPT.f1 < Inf && OPT.f2 > 0 || OPT.W ~= 1
    % in case of importance sampling, check whether specified variable is
    % available
    idIS = strcmp({stochast.Name}, OPT.ISvariable);
    if all(~idIS)
        error([OPT.ISvariable ' not found'])
    end
    if any(idIS & ~active)
        error('Importance Sampling variable should be active')
    end
end

% get random samples of P
P = rand(OPT.NrSamples, Nstoch);

% f2 should be smaller than f2
if OPT.f1 < OPT.f2
    [OPT.f1 OPT.f2] = deal(OPT.f2, OPT.f1);
end

if OPT.f1 < Inf && OPT.f2 > 0
    
    Iplus = 1;
    NaNsinP = true;
    
    while NaNsinP
        Iplus = Iplus + 1;
        maxpgrid = -log10(OPT.f2) + Iplus;
        pgrid = (0.01:0.01:maxpgrid)';
        Ponder = [flipud(0.5*(10.^-pgrid)); (0.489:0.001:0.511)';  (1-0.5*10.^-pgrid)];

        % bepaal kansverdeling en kansdichtheid van H in tabelvorm
        % deze kansverdeling is nodig om de correctie te bepalen
        % die noodzakelijk is bij importance sampling
        cdf = feval(stochast(idIS).Distr, Ponder, stochast(idIS).Params{:});

        [xcentr dPdx] = cdf2pdf(Ponder, cdf);

        % bepaal grenzen voor waterstand-sampling:
        Pgrens = exp(-[OPT.f1 OPT.f2]);    % onderschrijdingskans grenswaarden
        Hgrens = feval(stochast(idIS).Distr, Pgrens, stochast(idIS).Params{:});    % grenswaarden uit CDF
        Hgrens = [0.9 1.1].*Hgrens; % neem deze grenzen wat ruimer, vanwege meer/minder afslag door golven:

        % sample H-waarden
        H = Hgrens(1) + P(:,idIS)*(Hgrens(2)-Hgrens(1));
        P(:,idIS) = interp1(cdf, Ponder, H);

        if all(~any(isnan(P)))
            NaNsinP = false;
        end
    end
    % correctie voor bias in waterstand-sampling:
    p_correctie = interp1(xcentr, dPdx, H);   % PDF waterstand
    p_correctie = repmat((Hgrens(2)-Hgrens(1))*p_correctie, 1, length(OPT.Resistance));
else
    p_correctie = 1;
end

% set the P-values in the columns of the non-active variables to .5
P(:,~active) = deal(.5);

if OPT.W ~= 1
    % change P values of the IS variable to W times as extreme
    P(:,idIS) = 1-(1-P(:,idIS))/OPT.W;
end

% transform P to x
x = feval(OPT.P2xFunction, stochast, P);

% derive z based on x
z = feval(OPT.x2zFunction, x, {stochast.Name}, OPT.Resistance,...
    OPT.variables{:}); % bepaal z(u) uit x(u)
idFail = z<0;

P_f = sum(idFail.* p_correctie)/(OPT.NrSamples*OPT.W);
P_f(P_f == 0) = deal(NaN);

Pexc = prod(1-P(:,active),2);

result = struct(...
    'settings', OPT,...
    'Input', stochast,...
    'Output', struct(...
        'P_f', P_f,...
        'Pexc', Pexc,...
        'Calc', size(z,1),...
        'idFail', idFail,...
        'u', norm_inv(P, 0, 1),...
        'P', P,...
        'x', x,...
        'z', z ...
    ));