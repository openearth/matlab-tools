function result = MCEstimator(idFail,P_corr, Confidence)
%MCConvidence  computes Monte Carlo estimator and convidence intervals 

%   This routine derives the Monte carlo estimator for the probability of 
%    failure and confidence intervals. It
%   derives the variance of all N samples of gx. gx is the value of the 
%   the Monte Carlo estimator. for Crude Monte carlo, gx is either 1
%   (failure), or 0 (no failure). for impotance sampling, gx is either 0
%   (no failure) or f(x)/h(x), where f(x) is the density function of random vector X
%   and h(x) is the importance sampling distribution. 
%
%   Syntax:
%   result = MC(stochast)
%   result = MC(..
%       'stochast', stochast,...
%       'NrSamples', 1000);
%
%   Input:
%   idFail:     vector with 1/0 values that indicate failure/no failure
%   P_corr:     Corrections for importance sampling: f(x)/h(x)
%   Confidence: k-value for desired confidence interval (i.e. k=1.96  = 95%
%                confidence inteval
%
%   Output:
%   result = structure with results:
%       gx:              % individual values of the MC estimator
%       P_f:             % resulting end value of the MC estimator
%       P_z:             % evolution of the MC estimator
%       Acy_abs:         % absolute error in P_f (with certainty related to confidence interval)
%       Acy_absV:        % evolution of 'Acy_abs' 
%       Acy_rel:         % Acy_rel

%   Example
%   MC
%
%   See also MC, MCConfidence

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       ferdinand Diermanse
%
%       ferdinand.diermanse@deltares.nl	
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

% Created: 06 sept 2012
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

    N = length(P_corr);
    cumNsamps = (1:N)';
    gx = mean(idFail,2).*P_corr;          % individual values of the MC estimator
    P_z         = cumsum(gx)./cumNsamps;  % evolution of the MC estimator
    P_f         = P_z(end);               % resulting end value of the MC estimator

    % compute accurracy 
    kk=norm_inv((Confidence+1)/2,0,1);       % k-value for desired confidence interval
    diff = gx - P_z;   % deviation of individual estimators from mean
    Variance = cumsum(diff.^2)./(cumNsamps.^2); % variance
    Id1 = find(gx>0, 1, 'first');        % first 'failure'
    Variance(1:Id1-1) = NaN;             % no valid variance estimate until at least 1 failure is sampled

    Sigma = sqrt(Variance);    % standard deviation
    Acy_absV = Sigma*kk;       % limit of the absolute error in P_f (with certainty related to kk) 
    Acy_abs = Acy_absV(end);   % last value of the absoluut error 
    Acy_rel =Acy_abs/P_f;      % relative error 
    
    % store results in strcuture
    result = struct(...
    'gx',           gx,   ...           % individual values of the MC estimator
    'P_f',          P_f,       ...      % resulting end value of the MC estimator
    'P_z',          P_z,       ...      % evolution of the MC estimator
    'Acy_abs',      Acy_abs,    ...     % absolute error in P_f (with certainty related to confidence interval)
    'Acy_absV',     Acy_absV,   ...     % evolution of 'Acy_abs' 
    'Acy_rel',      Acy_rel     ...      % Acy_rel
    );
