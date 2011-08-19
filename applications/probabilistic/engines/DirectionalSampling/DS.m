function result = DS(varargin)
%DS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = DS(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   DS
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
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
% Created: 12 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings

varargin = prob_checkinput(varargin{:});

OPT = struct(...
    'stochast',     struct(),   ...     % stochast structure
    'x2zFunction',  @x2z,       ...     % Function to transform x to z
    'variables',    {{}},       ...     % aditional variables to use in x2zFunction
    'method',       'matrix',   ...     % z-function method 'matrix' (default) or 'loop'
    'NrSamples',    1e2,        ...     % number of samples
    'P2xFunction',  @P2x,       ...     % function to transform P to x
    'seed',         NaN,        ...     % seed for random generator
    'epsZ',         1e-2,       ...     % precision in stop criterium
    'maxiter',      50,         ...     % maximum number of iterations
    'maxretry',     3,          ...     % maximum number of iterations before retry
    'ARS',          true,       ...     % adaptive response surface
    'betath',       1.2         ...     % beta threshold
);

OPT = setproperty(OPT, varargin{:});

%% directional sampling

stochast    = OPT.stochast;
N           = length(stochast);

% determine active stochasts
active      = ~cellfun(@isempty, {stochast.Distr}) &     ...
              ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr}, 'UniformOutput', false));

% set random seed
if ~isnan(OPT.seed)
    rand('seed', OPT.seed)
end
    
% draw random numbers
P               = nan(OPT.NrSamples, N);
P(:, active)    = rand(OPT.NrSamples, sum(active));
P(:,~active)    = .5;

% transform P to u
u               = norm_inv(P,0,1);

% normalize u
ul              = sqrt(sum(u.^2,2));
un              = u./repmat(ul,1,N);

% compute origin
n               = 1;
x0              = 0;
z0              = DS_beta2z(OPT, zeros(1,size(un,2)), x0);

% intialize response surface
RS              = struct('u', [], 'z', [], 'fit', struct());

% find beta value
S               = struct();
S.origin        = struct('beta', x0, 'z', x0);
S.process       = struct('betamin', Inf, 'betath', Inf);
for i = 1:OPT.NrSamples
    
    S.exact(i)  = false;
    
    % determine unit vector
    n           = n+1;
    x           = [x0 1];
    z           = [z0 DS_beta2z(OPT, un(i,:), x(2))];
    
    % order initial result
    ii          = find(abs(z)==min(abs(z)));
    idx         = [mod(ii+2,2)+1 ii];

    x           = x(idx);
    z           = z(idx);

    % approximate line search
    if OPT.ARS && ~isempty(RS.u)
        [x z]   = find_zero(OPT, @(x,y)polyvaln(RS.fit,x.*y), un(i,active), x, z, 0);
    end

    % exact line search
    if ~OPT.ARS || abs(x(end)) < S.process.betath(end)
        [x z n] = find_zero(OPT, @(x,y)DS_beta2z(OPT,x,y), un(i,:), x, z, n);
        
        S.exact(i) = true;
    end
    
    % store exit status
    S.converged(i)      = ~any(~isfinite(z)) && length(z)<=OPT.maxiter+1;
    S.exact(i)          = S.exact(i) && S.converged(i);
    
    % update beta sphere
    S.process.betamin(i)= min(S.process.betamin(end), abs(x(end)));
    S.process.betath(i) = S.process.betamin(i).*OPT.betath;
    
    % store process results
    S.process.beta{i}   = x';
    S.process.z{i}      = z';
    
    [S.process.x{i} S.process.P{i}] = DS_beta2x(OPT, ...
        repmat(un(i,:),length(S.process.beta{i}),1), ...
        S.process.beta{i}(:));
    S.process.u{i}      = norm_inv(S.process.P{i}, 0, 1);
    
    % create response service
    if OPT.ARS && S.exact(i) && sum(S.exact) >= 2*sum(active)+1
        RS.u    = vertcat(S.process.u{S.exact});
        RS.z    = vertcat(S.process.z{S.exact});
        
        notinf  = all(isfinite(RS.u),2) & isfinite(RS.z);
        RS.fit  = polyfitn(RS.u(notinf,active), RS.z(notinf), 2);
    end
    
    S.process.RS(i) = RS;
end

% store final results
S.betas                         = get_final_result(S.process.beta);
S.P                             = get_final_result(S.process.P);
S.x                             = get_final_result(S.process.x);
S.u                             = get_final_result(S.process.u);
S.z                             = get_final_result(S.process.z);
S.computations                  = n;

% compute failure probability
S.betas(~S.converged)           = 0;
S.betas(S.betas<0)              = 0;

idx                             = S.betas > 0;
S.P_f                           = sum(1-chi2_cdf(S.betas(idx).^2,sum(active)))/OPT.NrSamples;
S.Beta                          = norm_inv(1-S.P_f, 0, 1);

% add additional data
S.Calc                          = OPT.NrSamples;

%% create result structure

result = struct(...
    'settings',     rmfield(OPT, {'stochast'}),             ...
    'Input',        stochast,                               ...
    'Output',       S                                       ...
);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x z n] = find_zero(OPT, fcn, un, x, z, n)
    while abs(z(end))>OPT.epsZ
        n   = n+1;
        p   = polyfitn(z,x,length(x)-1);
        x   = [x polyvaln(p,0)];
        z   = [z feval(fcn, un, x(end))];

        if length(z)<OPT.maxretry
            xl  = x(end-1);
            while ~isfinite(z(end))
                n   = n+1;
                x   = [x mean([xl x(end)])];
                z   = [z feval(fcn, un, x(end))];

                if length(z)>OPT.maxiter+1; break; end;
            end
        end

        if ~isfinite(z(end)) || length(z)>OPT.maxiter+1; break; end;
    end
end

function mtx = get_final_result(data)
    mtx = cellfun(@(x) x(end,:), data, 'UniformOutput', false);
    mtx = vertcat(mtx{:});
end

function [z x P] = DS_beta2z(OPT, un, beta)
    [x P]   = DS_beta2x(OPT, un, beta);
    z       = DS_x2z(OPT, x);
end

function [x P] = DS_beta2x(OPT, un, beta)
    P       = norm_cdf(repmat(beta,1,size(un,2)).*un,0,1);
    x       = feval(OPT.P2xFunction, OPT.stochast, P);
end

function z = DS_x2z(OPT, x)
    nf      = ~any(isinf(x),2);
    
    if any(nf); z(nf) = prob_zfunctioncall(OPT, OPT.stochast, x(nf,:)); end;
    
    z(~nf)  = -Inf;
end
