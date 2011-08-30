function result = DS(varargin)
%DS runs a probabilistic computation by Directional Sampling
%
%   Runs a probabilistic computation by Directional Sampling. The
%   implementation is largely obtained from Grooteman (2011) and is called
%   Adaptive Directional Importance Sampling (ADIS). Besides the
%   conventional directional sampling, importance sampling is automatically
%   applied using a beta sphere with a radius of the minimum beta drawn so
%   far plus a certain threshold. Any samples drawn within this sphere is
%   marked as important and computed exactly. Any samples outside this
%   sphere is of less importance and computed using an Adaptive Response
%   Surface (ARS), if available.
%   Also convergence is automatically determined using a confidence
%   interval and required accuarcy. Finally, it is checked whether the
%   resulting probability of failure is mainly obtained from the exact
%   computed samples. Otherwise, the most important approximated samples
%   are recalculated using the exact method until this requirement is
%   satisfied.
%
%   Syntax:
%   result = DS(varargin)
%
%   Input:
%   varargin  = name/value pairs:
%               stochast:       Stochast structure
%               seed:           Seed for random generator
%               x2zFunction:    Function handle to transform x to z
%               x2zVariables:   Additional variables for the x2zFunction
%               P2xFunction:    Function handle to transform P to x
%               P2xVariables:   Additional variables for the P2xFunction
%               z20Function:    Function handle to find z=0 along a line
%               z20Variables:   Additional variables for the z20Function
%               ARS:            Boolean indicating whether to use ARS
%               maxZ:           Maximum z-values of samples used for ARS
%               beta1:          Initial beta value in line search
%               dbeta:          Initial beta threshold for beta sphere
%               Pratio:         Maximum fraction of failure probability
%                               determined by approximated samples
%               confidence:     Confidence interval in convergence
%                               criterium
%               accuracy:       Accuracy in convergence criterium
%               plot:           Boolean indicating whether to plot result
%               animate:        Boolean indicating whether to animate
%                               progress
%
%   Output:
%   result = DS result structure
%
%   Example
%   result = DS('stochast', exampleStochastVar, 'x2zFunction', x2z)
%
%   See also MC, FORM

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
    'stochast',         struct(),           ...
    'seed',             NaN,                ...
    'x2zFunction',      @x2z,               ...
    'x2zVariables',     {{}},               ...
    'P2xFunction',      @P2x,               ...
    'P2xVariables',     {{}},               ...
    'z20Function',      @find_zero_poly2,   ...
    'z20Variables',     {{}},               ...
    'ARS',              true,               ...
    'ARSgetFunction',   @prob_ars_get,      ...
    'ARSgetVariables',  {{}},               ...
    'ARSsetFunction',   @prob_ars_set,      ...
    'ARSsetVariables',  {{}},               ...
    'beta1',            4,                  ...
    'dbeta',            .01,                ...
    'Pratio',           .4,                 ...
    'minsamples',       1,                  ...
    'confidence',       .95,                ...
    'accuracy',         .2,                 ...
    'plot',             false,              ...
    'animate',          false,              ...
    ...
    'method',           'matrix',           ...     % currently not used
    'NrSamples',        1                   ...     % currently not used
);

OPT = setproperty(OPT, varargin{:});

OPT.NrSamples = 1;

%% directional sampling

stochast    = OPT.stochast;
N           = length(stochast);

minCOV      = OPT.accuracy/norm_inv((OPT.confidence+1)/2,0,1);

% determine active stochasts
active      = ~cellfun(@isempty, {stochast.Distr}) &     ...
              ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr}, 'UniformOutput', false));

% set random seed
if isnan(OPT.seed)
    OPT.seed = rand('seed');
end

rand('seed', OPT.seed)

% compute origin
n           = 1;
nARS        = nan;
b0          = 0;
z0          = beta2z(OPT, zeros(1,N), b0);
b           = [];
z           = [];

if z0<0
    error('Origin is part of failure area. This situation is currently not supported.');
end

% intialize matrices
un          = nan(0,N);
beta        = nan(0,1);
exact       = false(0,1);
notexact    = false(0,1);
converged   = false(0,1);

% initialize response surface
ARS         = prob_ars_struct(          ...
                'active', active,       ...
                'u', zeros(1,N),        ...
                'z', z0,                ...
                'dbeta', OPT.dbeta);
            
% start iterations
Pr          = Inf;
while Pr > OPT.Pratio
    
    COV         = Inf;
    reevaluate  = unique([find(abs(b) <= ARS.betamin+ARS.dbeta) find(notexact)]);
    
    while COV > minCOV || ~isempty(reevaluate)
        
        % if no samples within beta sphere are left, draw new directions
        if isempty(reevaluate)
            
            idx             = size(un,1)+[1:OPT.NrSamples];
            exact(idx)      = false;
            converged(idx)  = false;

            % draw random numbers
            P               = nan(OPT.NrSamples, N);
            P(:, active)    = rand(OPT.NrSamples, sum(active));
            P(:,~active)	= .5;

            % transform P to u
            u               = norm_inv(P,0,1);

            % normalize u
            ul              = sqrt(sum(u.^2,2));
            un(idx,:)       = u./repmat(ul,1,N);
            
        else
            idx             = reevaluate(1);
        end
        
        % determine unit vector
        if OPT.ARS && ARS.hasfit
            ba          = OPT.beta1;
            za          = feval(OPT.ARSgetFunction,un(idx,active).*OPT.beta1,'ARS',ARS,OPT.ARSgetVariables{:});
            be          = [];
            ze          = [];
        else
            n           = n+1;
            ba          = [];
            za          = [];
            be          = OPT.beta1;
            ze          = beta2z(OPT, un(idx,:), OPT.beta1);
        end
        
        b               = [b0 ba be];
        z               = [z0 za ze];

        % order initial result
        zi              = find(abs(z)==min(abs(z)));
        zi              = [mod(zi+2,2)+1 zi];

        b               = b(zi);
        z               = z(zi);
        
        ca              = false;
        ce              = false;
        
        % approximate line search
        if OPT.ARS && ARS.hasfit
            [bn zn nn ca] = feval(@OPT.z20Function, un(idx,active), b, z, ...
                'zFunction', @(x,y)feval(OPT.ARSgetFunction,x.*y,'ARS',ARS,OPT.ARSgetVariables{:}), ...
                OPT.z20Variables{:});
            
            ba          = [ba bn];
            za          = [za zn];
            
            b           = [b  bn];
            z           = [z  zn];
        end

        % exact line search
        if ~OPT.ARS || ~ARS.hasfit || (abs(b(end)) <= ARS.betamin+ARS.dbeta && ca)
            
            ii          = [1 2];
            
            % select unit vector and approximated point closest to zero
            if OPT.ARS && ARS.hasfit
                ii      = unique([ii find(abs(z)==min(abs(z)),1,'first')]);
            end
            
            [bn zn nn ce] = feval(@OPT.z20Function, un(idx,:), b(ii), z(ii), ...
                'zFunction', @(x,y)beta2z(OPT,x,y), OPT.z20Variables{:});
            
            be          = [be bn];
            ze          = [ze zn];
            
            b           = [b  bn];
            z           = [z  zn];
            
            n           = n+nn;

            exact(idx)  = true;
        end

        % store exit status
        converged(idx)  = ~any(~isfinite(z)) && ((~exact(idx) && ca) || ce);
        notexact(idx)   = ~exact(idx) && converged(idx);
        exact(idx)      = exact(idx) && converged(idx);
        beta(idx)       = b(end);
        
        nb              = length(beta);
        
        % update response surface
        if OPT.ARS && exact(idx)
            ue          = beta2u(un(idx,:),be(:));
            ARS        	= feval(OPT.ARSsetFunction,ue,ze,'ARS',ARS,OPT.ARSsetVariables{:});
            
            if ARS.hasfit && isnan(nARS)
                nARS    = n;
            end
        end
        
        ndir            = (n-nARS)/(sum(exact)-2*sum(ARS.active)+1);
        
        % update probability of failure
        dPe             = (1-chi2_cdf(beta(   exact&beta>0).^2,sum(active)))/nb;
        dPa             = (1-chi2_cdf(beta(notexact&beta>0).^2,sum(active)))/nb;
        dPo             = zeros(size(beta(beta<=0)));
        dP              = [dPe dPa dPo];
        Pe              = sum(dPe);
        Pa              = sum(dPa);
        Pf              = Pe+Pa;
        
        % check convergence
        if sum(dP>0)>OPT.minsamples && Pf > 0
            sigma           = sqrt(1/(nb*(nb-1))*sum((dP-Pf).^2));
            COV             = sigma/Pf;
        end
        
        Accuracy        = norm_inv((OPT.confidence+1)/2,0,1)*COV*Pf;
        
        % update approximation ratio
        Pr              = Pa/Pf;
        
        % determine progress
        if OPT.animate
            nPr         = max([0 find(cumsum(sort(dPa,'descend'))>Pa-OPT.Pratio*Pf,1,'first')-1]);
            nCOV        = max([0 .5+sqrt(.25+sum((dP-Pf).^2)/(minCOV*Pf)^2)]);
            progress    = min([1 nb/(nCOV+nPr)]);
            
            plotDS(un, beta, ARS, Pf, Pe, Pa, Accuracy, n, nARS, ndir, progress, exact, notexact, converged);
        end
        
        if ~isempty(reevaluate)
            reevaluate(1) = [];
        end
        
    end
    
    % update beta threshold
    betas       = abs(beta(notexact&beta>0));
    idx         = isort(betas);
    if ~isempty(idx)
        ARS.dbeta   = abs(betas(idx(1)))-ARS.betamin;
    end
    
end

% prepare output
u           = un.*repmat(beta(:),1,size(un,2));
[x P]       = u2x(OPT, u);

%% create result structure

result = struct(...
    'settings',     rmfield(OPT, {'stochast'}),             ...
    'Input',        stochast,                               ...
    'Output',       struct(                                 ...
        'P_f',          Pf,                                 ...
        'P_e',          Pe,                                 ...
        'P_a',          Pa,                                 ...
        'Beta',         norm_inv(1-Pf, 0, 1),               ...
        'Calc',         n,                                  ...
        'Calc_ARS',     nARS,                               ...
        'Calc_dir',     ndir,                               ...
        'un',           un,                                 ...
        'beta',         beta(:),                            ...
        'u',            u,                                  ...
        'P',            P,                                  ...
        'x',            x,                                  ...
        'z',            z,                                  ...
        'exact',        exact(:),                           ...
        'notexact',     notexact(:),                        ...
        'converged',    converged(:),                       ...
        'COV',          COV,                                ...
        'Accuracy',     Accuracy,                           ...
        'Pratio',       Pr,                                 ...
        'ARS',          ARS,                                ...
        'seed',         rand('seed')                        ...
    )                                                       ...
);

% plot result
if OPT.plot
    plotDS(result);
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [z x u P] = beta2z(OPT, un, beta)
    [x u P] = beta2x(OPT, un, beta);
    
    nf      = ~any(~isfinite(x),2);
    if any(nf); z(nf) = prob_zfunctioncall(OPT, OPT.stochast, x(nf,:)); end;
    z(~nf)  = -Inf;
end

function [x u P] = beta2x(OPT, un, beta)
    u       = beta2u(un, beta);
    [x P]   = u2x(OPT, u);
end

function [x P] = u2x(OPT, u)
    P       = norm_cdf(u,0,1);
    x       = feval(OPT.P2xFunction, OPT.stochast, P, OPT.P2xVariables{:});
end

function u = beta2u(un, beta)
    u = zeros(0,size(un,2));
    for i = 1:length(beta)
    	u = [u ; beta(i).*un];
    end
end
