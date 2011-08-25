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
    'stochast',         struct(),           ...     % stochast structure
    'x2zFunction',      @x2z,               ...     % Function to transform x to z
    'x2zVariables',     {{}},               ...     % aditional variables to use in x2zFunction
    'method',           'matrix',           ...     % z-function method 'matrix' (default) or 'loop'
    'NrSamples',        1,                  ...     % number of samples per iteration
    'P2xFunction',      @P2x,               ...     % function to transform P to x
    'seed',             NaN,                ...     % seed for random generator
    'z20Function',      @find_zero_poly,    ...     % line search function
    'z20Variables',     {{}},               ...     % additonal variables to use in z20Function
    'ARS',              true,               ...     % adaptive response surface
    'beta0',            1,                  ...     % initial beta value
    'dbeta',            .1,                 ...     % initial beta threshold
    'Pratio',           .4,                 ...     % threshold for fraction approximated samples
    'confidence',       .95,                ...     % confidence interval of result
    'accuracy',         .5,                 ...     % accuracy of result
    'plot',             false,              ...     % plot result
    'animate',          true                ...     % plot progress
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
if ~isnan(OPT.seed)
    rand('seed', OPT.seed)
end

% compute origin
n           = 1;
n0          = nan;
b0          = 0;
z0          = beta2z(OPT, zeros(1,N), b0);

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
    
    while COV > minCOV
        
        idx                 = abs(beta) <= ARS.betamin+ARS.dbeta & notexact;
        
        % if no samples within beta sphere are left, draw new directions
        if ~any(idx)
            
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
            idx = find(idx,1,'first');
        end
        
        % determine unit vector
        b               = b0;
        z               = z0;
        
        if OPT.ARS && ARS.hasfit
            b           = [b OPT.beta0];
            z           = [z prob_ars_get(un(idx,active).*OPT.beta0,'ARS',ARS)];
        else
            n           = n+1;
            b           = [b OPT.beta0];
            z           = [z beta2z(OPT, un(idx,:), OPT.beta0)];
        end

        % order initial result
        zi              = find(abs(z)==min(abs(z)));
        zi              = [mod(zi+2,2)+1 zi];

        b               = b(zi);
        z               = z(zi);
        
        ca              = false;
        ce              = false;
        
        % approximate line search
        if OPT.ARS && ARS.hasfit
            [ba za na ca] = feval(@OPT.z20Function, un(idx,active), b, z, ...
                'zFunction', @(x,y)prob_ars_get(x.*y,'ARS',ARS), OPT.z20Variables{:});
            
            b           = [b ba];
            z           = [z za];
        end

        % exact line search
        if ~OPT.ARS || (abs(b(end)) <= ARS.betamin+ARS.dbeta && (~ARS.hasfit || ca))
            ii          = unique([1 2 length(b)]);
            
            [be ze ne ce] = feval(@OPT.z20Function, un(idx,:), b(ii), z(ii), ...
                'zFunction', @(x,y)beta2z(OPT,x,y), OPT.z20Variables{:});
            
            ue          = beta2u(un(idx,:),be(:));
            
            b           = [b be];
            z           = [z ze];
            n           = n+ne;

            exact(idx)  = true;
        end

        % store exit status
        converged(idx)  = ~any(~isfinite(z)) && ((~exact(idx) && ca) || ce);
        notexact(idx)   = ~exact(idx) && converged(idx);
        exact(idx)      = exact(idx) && converged(idx);
        beta(idx)       = b(end);
            
        % update response surface
        if OPT.ARS && exact(idx)
            ARS        	= prob_ars_set(ue,ze,'ARS',ARS);
            
            if ARS.hasfit && isnan(n0)
                n0      = n;
            end
        end
        
        % update probability of failure
        dPe             = (1-chi2_cdf(beta(   exact&beta>0).^2,sum(active)))/length(beta);
        dPa             = (1-chi2_cdf(beta(notexact&beta>0).^2,sum(active)))/length(beta);
        Pe              = sum(dPe);
        Pa              = sum(dPa);
        Pf              = Pe+Pa;
        
        % check convergence
        COV             = sqrt((1-Pf)/(length(beta)*Pf));
        Accuracy        = norm_inv((OPT.confidence+1)/2,0,1)*COV;
        
        % update approximation ratio
        Pr              = Pa/Pf;
        
        % determine progress
        progress        = min([1 length(beta)/((1-Pf)/(minCOV^2*Pf))]);
        
        % show progress
        if OPT.animate
            plot_progress(un, beta, ARS, Pf, Pe, Pa, Accuracy, n, n0, progress, exact, notexact, converged);
        end
        
    end
    
    % update beta threshold
    betas       = abs(beta(notexact&beta>0));
    idx         = isort(betas);
    if ~isempty(idx)
        ARS.dbeta   = abs(betas(idx(1)))-ARS.betamin;
    end
    
end

% plot result
if OPT.plot
    plot_progress(un, beta, ARS, Pf, Pe, Pa, Accuracy, n, n0, progress, exact, notexact, converged);
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
        'Beta',         norm_inv(1-Pf, 0, 1),               ...
        'Calc',         n,                                  ...
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
        'ARS',          ARS                                 ...
    )                                                       ...
);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [z x u P] = beta2z(OPT, un, beta)
    [x u P] = beta2x(OPT, un, beta);
    
    nf      = ~any(isinf(x),2);
    if any(nf); z(nf) = prob_zfunctioncall(OPT, OPT.stochast, x(nf,:)); end;
    z(~nf)  = -Inf;
end

function [x u P] = beta2x(OPT, un, beta)
    u       = beta2u(un, beta);
    [x P]   = u2x(OPT, u);
end

function [x P] = u2x(OPT, u)
    P       = norm_cdf(u,0,1);
    x       = feval(OPT.P2xFunction, OPT.stochast, P);
end

function u = beta2u(un, beta)
    u = zeros(0,size(un,2));
    for i = 1:length(beta)
    	u = [u ; beta(i).*un];
    end
end

function plot_progress(un, beta, ARS, Pf, Pe, Pa, Accuracy, n, n0, progress, exact, notexact, converged)

    fh = findobj('Tag','DSprogress');
    
    % initialize plot
    if isempty(fh)
        fh = figure('Tag','DSprogress');
        
        subplot(3,1,[1 2]); hold on;
        
        uitable( ...
            'Units','normalized', ...
            'Position',[0.09 0.05 0.82 0.25],...
            'Data', [], ...
            'ColumnName', {'total', 'exact', 'approx', 'not converged' 'model'},...
            'RowName', {'N' 'P' 'Accuracy' 'Ratio'});
    end
    
    ax  = findobj(gcf,'Type','axes','Tag','');
    uit = findobj(gcf,'Type','uitable');
    
    % create plot grid
    lim         = linspace(-10,10,100);
    [gx gy]     = meshgrid(lim,lim);

    % plot response surface
    d = find(ARS.active, 2);
            
    if ARS.hasfit
        dat         = zeros(numel(gx),sum(ARS.active));
        dat(:,d)    = [gx(:) gy(:)];
        rsz         = reshape(polyvaln(ARS.fit,dat), size(gx));

        ph = findobj(fh,'Tag','ARS');
        if isempty(ph)
            ph = pcolor(ax,gx,gy,rsz);
            set(ph,'Tag','ARS');
            colorbar; shading flat;
        else
            set(ph,'CData',rsz)
        end
    end

    % plot DS samples
    up = un.*repmat(beta(:),1,size(un,2));
    
    ph1 = findobj(fh,'Tag','P1');
    ph2 = findobj(fh,'Tag','P2');
    ph3 = findobj(fh,'Tag','P3');
    
    if isempty(ph1) || isempty(ph2) || isempty(ph3)
        ph1 = scatter(ax,un(~converged,d(1)),un(~converged,d(2)),'MarkerEdgeColor','b');
        ph2 = scatter(ax,up(notexact,  d(1)),up(notexact,  d(2)),'MarkerEdgeColor','r');
        ph3 = scatter(ax,up(exact,     d(1)),up(exact,     d(2)),'MarkerEdgeColor','g');
        
        set(ph1,'Tag','P1');
        set(ph2,'Tag','P2');
        set(ph3,'Tag','P3');
    else
        set(ph1,'XData',un(~converged,d(1)),'YData',un(~converged,d(2)));
        set(ph2,'XData',up(notexact,  d(1)),'YData',up(notexact,  d(2)));
        set(ph3,'XData',up(exact,     d(1)),'YData',up(exact,     d(2)));
    end

    % plot beta sphere
    [x1,y1] = cylinder(ARS.betamin,100);
    [x2,y2] = cylinder(ARS.betamin+ARS.dbeta,100);

    ph1 = findobj(fh,'Tag','B1');
    ph2 = findobj(fh,'Tag','B2');
    
    if isempty(ph1) || isempty(ph2)
        ph1 = plot(ax,x1(1,:),y1(1,:),':k');
        ph2 = plot(ax,x2(1,:),y2(1,:),'-k');
        
        set(ph1,'Tag','B1');
        set(ph2,'Tag','B2');
    else
        set(ph1,'XData',x1(1,:),'YData',y1(1,:));
        set(ph2,'XData',x2(1,:),'YData',y2(1,:));
    end

    % create labels
    xlabel('u_1');
    ylabel('u_2');
    
    title(sprintf('%4.3f%%', progress*100));

    % update table contents
    nf = (n-n0)/(sum(exact)-2*sum(ARS.active)+1);
    
    data = { ...
        length(beta) sum(exact) sum(notexact) sum(~converged)   n               ; ...
        Pf           Pe         Pa            ''                n0              ; ...
        Accuracy     ''         ''            ''                nf              ; ...
        ''           Pe/Pf      Pa/Pf         ''                n/length(beta)  };

    set(uit,'Data',data);
    set(ax,'XLim',[min(gx(:)) max(gx(:))],'YLim',[min(gy(:)) max(gy(:))]);
    
    drawnow;
            
end
