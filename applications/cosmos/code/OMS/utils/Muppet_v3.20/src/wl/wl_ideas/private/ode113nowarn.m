function [tout,yout,varargout] = ode113nowarn(odefile,tspan,y0,options,varargin)
%ODE113NOWARN Same as ODE113 without one warning.
%   Solve non-stiff differential equations, variable order method.
%   [T,Y] = ODE113('F',TSPAN,Y0) with TSPAN = [T0 TFINAL] integrates the
%   system of differential equations y' = F(t,y) from time T0 to TFINAL with
%   initial conditions Y0.  'F' is a string containing the name of an ODE
%   file.  Function F(T,Y) must return a column vector.  Each row in
%   solution array Y corresponds to a time returned in column vector T.  To
%   obtain solutions at specific times T0, T1, ..., TFINAL (all increasing
%   or all decreasing), use TSPAN = [T0 T1 ... TFINAL].
%   
%   [T,Y] = ODE113('F',TSPAN,Y0,OPTIONS) solves as above with default
%   integration parameters replaced by values in OPTIONS, an argument
%   created with the ODESET function.  See ODESET for details.  Commonly
%   used options are scalar relative error tolerance 'RelTol' (1e-3 by
%   default) and vector of absolute error tolerances 'AbsTol' (all
%   components 1e-6 by default).
%   
%   [T,Y] = ODE113('F',TSPAN,Y0,OPTIONS,P1,P2,...) passes the additional
%   parameters P1,P2,... to the ODE file as F(T,Y,FLAG,P1,P2,...) (see
%   ODEFILE).  Use OPTIONS = [] as a place holder if no options are set.
%   
%   It is possible to specify TSPAN, Y0 and OPTIONS in the ODE file (see
%   ODEFILE).  If TSPAN or Y0 is empty, then ODE113 calls the ODE file
%   [TSPAN,Y0,OPTIONS] = F([],[],'init') to obtain any values not supplied
%   in the ODE113 argument list.  Empty arguments at the end of the call
%   list may be omitted, e.g. ODE113('F').
%   
%   As an example, the commands
%   
%       options = odeset('RelTol',1e-4,'AbsTol',[1e-4 1e-4 1e-5]);
%       ode113('rigidode',[0 12],[0 1 1],options);
%   
%   solve the system y' = rigidode(t,y) with relative error tolerance 1e-4
%   and absolute tolerances of 1e-4 for the first two components and 1e-5
%   for the third.  When called with no output arguments, as in this
%   example, ODE113 calls the default output function ODEPLOT to plot the
%   solution as it is computed.
%   
%   [T,Y,TE,YE,IE] = ODE113('F',TSPAN,Y0,OPTIONS) with the Events property
%   in OPTIONS set to 'on', solves as above while also locating zero
%   crossings of an event function defined in the ODE file.  The ODE file
%   must be coded so that F(T,Y,'events') returns appropriate information.
%   See ODEFILE for details.  Output TE is a column vector of times at which
%   events occur, rows of YE are the corresponding solutions, and indices in
%   vector IE specify which event occurred.
%   
%   See also ODEFILE and
%       other ODE solvers:  ODE45, ODE23, ODE15S, ODE23S, ODE23T, ODE23TB
%       options handling:   ODESET, ODEGET
%       output functions:   ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
%       odefile examples:   ORBITODE, ORBT2ODE, RIGIDODE, VDPODE

%   ODE113 is a fully variable step size, PECE implementation in terms of
%   modified divided differences of the Adams-Bashforth-Moulton family of
%   formulas of orders 1-12.  The natural "free" interpolants are used.
%   Local extrapolation is done.

%   Details are to be found in The MATLAB ODE Suite, L. F. Shampine and
%   M. W. Reichelt, SIAM Journal on Scientific Computing, 18-1, 1997.

%   Mark W. Reichelt and Lawrence F. Shampine, 6-13-94
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision$  $Date$

true = 1;
false = ~true;

nsteps = 0;                             % stats
nfailed = 0;                            % stats
nfevals = 0;                            % stats
npds = 0;                               % stats
ndecomps = 0;                           % stats
nsolves = 0;                            % stats

if nargin == 0
  error('Not enough input arguments.  See ODE113.');
elseif ~isstr(odefile) & ~isa(odefile, 'inline')
  error('First argument must be a single-quoted string.  See ODE113.');
end

if nargin == 1
  tspan = []; y0 = []; options = [];
elseif nargin == 2
  y0 = []; options = [];
elseif nargin == 3
  options = [];
elseif ~isempty(options) & ~isa(options,'struct')
  if (length(tspan) == 1) & (length(y0) == 1) & (min(size(options)) == 1)
    tspan = [tspan; y0];
    y0 = options;
    options = [];
    varargin = {};
    msg = sprintf('Use ode113(''%s'',tspan,y0,...) instead.',odefile);
    warning(['Obsolete syntax.  ' msg]);
  else
    error('Correct syntax is ode113(''odefile'',tspan,y0,options).');
  end
end

% Get default tspan and y0 from odefile if none are specified.
if isempty(tspan) | isempty(y0)
  if (nargout(odefile) < 3) & (nargout(odefile) ~= -1)
    msg = sprintf('Use ode113(''%s'',tspan,y0,...) instead.',odefile);
    error(['No default parameters in ' upper(odefile) '.  ' msg]);
  end
  [def_tspan,def_y0,def_options] = feval(odefile,[],[],'init',varargin{:});
  if isempty(tspan)
    tspan = def_tspan;
  end
  if isempty(y0)
    y0 = def_y0;
  end
  if isempty(options)
    options = def_options;
  else
    options = odeset(def_options,options);
  end
end

% Test that tspan is internally consistent.
tspan = tspan(:);
ntspan = length(tspan);
if ntspan == 1
  t0 = 0;
  next = 1;
else
  t0 = tspan(1);
  next = 2;
end
tfinal = tspan(ntspan);
if t0 == tfinal
  error('The last entry in tspan must be different from the first entry.');
end
tdir = sign(tfinal - t0);
if any(tdir * (tspan(2:ntspan) - tspan(1:ntspan-1)) <= 0)
  error('The entries in tspan must strictly increase or decrease.');
end

t = t0;
y = y0(:);
neq = length(y);

% Get options, and set defaults.
rtol = odeget(options,'RelTol',1e-3);
if (length(rtol) ~= 1) | (rtol <= 0)
  error('RelTol must be a positive scalar.');
end
if rtol < 100 * eps 
  rtol = 100 * eps;
  warning(['RelTol has been increased to ' num2str(rtol) '.']);
end

atol = odeget(options,'AbsTol',1e-6);
if any(atol <= 0)
  error('AbsTol must be positive.');
end

normcontrol = strcmp(odeget(options,'NormControl','off'),'on');
if normcontrol
  if length(atol) ~= 1
    error('Solving with NormControl ''on'' requires a scalar AbsTol.');
  end
else
  if (length(atol) ~= 1) & (length(atol) ~= neq)
    error(sprintf(['Solving %s requires a scalar AbsTol, ' ...
                   'or a vector AbsTol of length %d'],upper(odefile),neq));
  end
  atol = atol(:);
end
threshold = atol / rtol;

% By default, hmax is 1/10 of the interval.
hmax = min(abs(tfinal-t), abs(odeget(options,'MaxStep',0.1*(tfinal-t))));
if hmax <= 0
  error('Option ''MaxStep'' must be greater than zero.');
end
htry = abs(odeget(options,'InitialStep'));
if htry <= 0
  error('Option ''InitialStep'' must be greater than zero.');
end

haveeventfun = strcmp(odeget(options,'Events','off'),'on');
if haveeventfun
  valt = feval(odefile,t,y,'events',varargin{:});
  teout = [];
  yeout = [];
  ieout = [];
end

if nargout > 0
  outfun = odeget(options,'OutputFcn');
else
  outfun = odeget(options,'OutputFcn','odeplot');
end
if isempty(outfun)
  haveoutfun = false;
else
  haveoutfun = true;
  outputs = odeget(options,'OutputSel',1:neq);
end
refine = odeget(options,'Refine',1);
printstats = strcmp(odeget(options,'Stats','off'),'on');

if strcmp(odeget(options,'Mass','off'),'on') | ...
  strcmp(odeget(options,'MassConstant','off'),'on')
  error(['Solver does not handle mass matrices, M*y'' or M(t)*y''.  '...
         'See ODE15S, ODE23S, ODE23T, or ODE23TB.']);
end

% Set the output flag.
if ntspan > 2
  outflag = 1;                          % output only at tspan points
elseif refine <= 1
  outflag = 2;                          % computed points, no refinement
else
  outflag = 3;                          % computed points, with refinement
end

% Allocate memory if we're generating output.
if nargout > 0
  if ntspan > 2                         % output only at tspan points
    tout = zeros(ntspan,1);
    yout = zeros(ntspan,neq);
  else                                  % alloc in chunks
    chunk = max(ceil(128 / neq),refine);
    tout = zeros(chunk,1);
    yout = zeros(chunk,neq);
  end
  nout = 1;
  tout(nout) = t;
  yout(nout,:) = y.';
end

% Initialize method parameters.
maxk = 12;
two = 2 .^ (1:13)';
gstar = [ 0.5000;  0.0833;  0.0417;  0.0264;  ...
          0.0188;  0.0143;  0.0114;  0.00936; ...
          0.00789;  0.00679; 0.00592; 0.00524; 0.00468];

% The input arguments of odefile determine the args to use to evaluate f.
if nargin(odefile) == 2
  args = {};                            % odefile accepts only (t,y)
else
  args = [{''} varargin];               % use (t,y,'',p1,p2,...)
end

yp = feval(odefile,t,y,args{:});
nfevals = nfevals + 1;                  % stats
[m,n] = size(yp);
if n > 1
  error([upper(odefile) ' must return a column vector.'])
elseif m ~= neq
  msg = sprintf('an initial condition vector of length %d.',m);
  error(['Solving ' upper(odefile) ' requires ' msg]);
end

hmin = 16*eps*abs(t);
if isempty(htry)
  % Compute an initial step size h using y'(t).
  absh = min(hmax, abs(tspan(next) - t));
  if normcontrol
    rh = (norm(yp) / max(norm(y),threshold)) / (0.25 * sqrt(rtol));
  else
    rh = norm(yp ./ max(abs(y),threshold),inf) / (0.25 * sqrt(rtol));
  end
  if absh * rh > 1
    absh = 1 / rh;
  end
  absh = max(absh, hmin);
else
  absh = min(hmax, max(hmin, htry));
end

% Initialize.
k = 1;
K = 1;
phi = zeros(neq,14);
phi(:,1) = yp;
psi = zeros(12,1);
alpha = zeros(12,1);
beta = zeros(12,1);
sig = zeros(13,1);
sig(1) = 1;
w = zeros(12,1);
v = zeros(12,1);
g = zeros(13,1);
g(1) = 1;
g(2) = 0.5;

hlast = 0;
klast = 0;
phase1 = true;

% Initialize the output function.
if haveoutfun
  feval(outfun,[t tfinal],y(outputs),'init');
end

% THE MAIN LOOP

done = false;
while ~done
  
  % By default, hmin is a small number such that t+hmin is only slightly
  % different than t.  It might be 0 if t is 0.
  hmin = 16*eps*abs(t);
  absh = min(hmax, max(hmin, absh));    % couldn't limit absh until new hmin
  h = tdir * absh;
  
  % Stretch the step if within 10% of tfinal-t.
  if 1.1*absh >= abs(tfinal - t)
    h = tfinal - t;
    absh = abs(h);
    done = true;
  end
  
  % LOOP FOR ADVANCING ONE STEP.
  failed = 0;
  if normcontrol
    invwt = 1 / max(norm(y),threshold);
  else
    invwt = 1 ./ max(abs(y),threshold);
  end
  while true

    % Compute coefficients of formulas for this step.  Avoid computing
    % those quantities not changed when step size is not changed.

    % ns is the number of steps taken with h, including the 
    % current one.  When k < ns, no coefficients change
    if h ~= hlast  
      ns = 0;
    end
    if ns <= klast 
      ns = ns + 1;
    end
    if k >= ns
      beta(ns) = 1;
      alpha(ns) = 1 / ns;
      temp1 = h * ns;
      sig(ns+1) = 1;
      for i = ns+1:k
        temp2 = psi(i-1);
        psi(i-1) = temp1;
        temp1 = temp2 + h;
        
        beta(i) = beta(i-1) * psi(i-1) / temp2;
        alpha(i) = h / temp1;
        sig(i+1) = i * alpha(i) * sig(i);
      end
      psi(k) = temp1;

      % Compute coefficients g.
      if ns == 1                        % Initialize v and set w
        v = 1 ./ (K .* (K + 1));
        w = v;
      else
        % If order was raised, update diagonal part of v.
        if k > klast
          v(k) = 1 / (k * (k+1));
          for j = 1:ns-2
            v(k-j) = v(k-j) - alpha(j+1) * v(k-j+1);
          end
        end
        % Update v and set w.
        for iq = 1:k+1-ns
          v(iq) = v(iq) - alpha(ns) * v(iq+1);
          w(iq) = v(iq);
        end
        g(ns+1) = w(1);
      end

      % Compute g in the work vector w.
      for i = ns+2:k+1
        for iq = 1:k+2-i
          w(iq) = w(iq) - alpha(i-1) * w(iq+1);
        end
        g(i) = w(1);
      end
    end   

    % Change phi to phi star.
    i = ns+1:k;
    phi(:,i) = phi(:,i) * diag(beta(i));

    % Predict solution and differences.
    phi(:,k+2) = phi(:,k+1);
    phi(:,k+1) = zeros(neq,1);
    p = zeros(neq,1);
    for i = k:-1:1
      p = p + g(i) * phi(:,i);
      phi(:,i) = phi(:,i) + phi(:,i+1);
    end
    p = y + h * p;
    tlast = t;
    t = tlast + h;
    yp = feval(odefile,t,p,args{:});
    nfevals = nfevals + 1;

    % Estimate errors at orders k, k-1, k-2.
    phikp1 = yp - phi(:,1);
    if normcontrol
      temp3 = norm(phikp1) * invwt;
      err = absh * (g(k) - g(k+1)) * temp3;
      erk = absh * sig(k+1) * gstar(k) * temp3;
      if k >= 2
        erkm1 = absh * sig(k) * gstar(k-1) * ...
            (norm(phi(:,k)+phikp1) * invwt);
      else
        erkm1 = 0.0;
      end
      if k >= 3
        erkm2 = absh * sig(k-1) * gstar(k-2) * ...
            (norm(phi(:,k-1)+phikp1) * invwt);
      else
        erkm2 = 0.0;
      end
    else
      temp3 = norm(phikp1 .* invwt,inf);
      err = absh * (g(k) - g(k+1)) * temp3;
      erk = absh * sig(k+1) * gstar(k) * temp3;
      if k >= 2
        erkm1 = absh * sig(k) * gstar(k-1) * ...
            norm((phi(:,k)+phikp1) .* invwt,inf);
      else
        erkm1 = 0.0;
      end
      if k >= 3
        erkm2 = absh * sig(k-1) * gstar(k-2) * ...
            norm((phi(:,k-1)+phikp1) .* invwt,inf);
      else
        erkm2 = 0.0;
      end
    end
    
    % Test if order should be lowered
    knew = k;
    if (k == 2) & (erkm1 <= 0.5*erk)
      knew = k - 1;
    end
    if (k > 2) & (max(erkm1,erkm2) <= erk)
      knew = k - 1;
    end
    
    % Test if step successful
    if err > rtol                       % Failed step
      nfailed = nfailed + 1;            % stats
      if absh <= hmin
        msg = sprintf(['Failure at t=%e.  Unable to meet integration ' ...
                       'tolerances without reducing the step size below ' ...
                       'the smallest value allowed (%e) at time t.\n'], ...
                      tlast,hmin);
%        warning(msg); % <-------------------------------------------- ODE113NOWARN difference compared to ODE113
        if haveoutfun
          feval(outfun,[],[],'done');
        end
        if printstats                   % print cost statistics
          fprintf('%g successful steps\n', nsteps);
          fprintf('%g failed attempts\n', nfailed);
          fprintf('%g function evaluations\n', nfevals);
          fprintf('%g partial derivatives\n', npds);
          fprintf('%g LU decompositions\n', ndecomps);
          fprintf('%g solutions of linear systems\n', nsolves);
        end
        if nargout > 0
          tout = tout(1:nout);
          yout = yout(1:nout,:);
          if haveeventfun
            varargout{1} = teout;
            varargout{2} = yeout;
            varargout{3} = ieout;
            varargout{4} = [nsteps; nfailed; nfevals; npds; ndecomps; nsolves];
          else
            varargout{1} = [nsteps; nfailed; nfevals; npds; ndecomps; nsolves];
          end
        end
        return;
      end
      
      % Restore t, phi, and psi.
      phase1 = false;
      t = tlast;
      for i = K
        phi(:,i) = (phi(:,i) - phi(:,i+1)) / beta(i);
      end
      for i = 2:k
        psi(i-1) = psi(i) - h;
      end

      failed = failed + 1;
      reduce = 0.5;
      if failed == 3
        knew = 1;
      elseif failed > 3
        reduce = min(0.5, sqrt(0.5*rtol/erk));
      end
      absh = max(reduce * absh, hmin);
      h = tdir * absh;
      k = knew;
      K = 1:k;
      done = false;
      
    else                                % Successful step
      break;
      
    end
  end
  nsteps = nsteps + 1;                  % stats

  klast = k;
  hlast = h;

  % Correct and evaluate.
  ylast = y;
  y = p + h * g(k+1) * phikp1;
  yp = feval(odefile,t,y,args{:});
  nfevals = nfevals + 1;                % stats
  
  % Update differences for next step.
  phi(:,k+1) = yp - phi(:,1);
  phi(:,k+2) = phi(:,k+1) - phi(:,k+2);
  for i = K
    phi(:,i) = phi(:,i) + phi(:,k+1);
  end

  if (knew == k-1) | (k == maxk)
    phase1 = false;
  end

  % Select a new order.
  kold = k;
  if phase1                             % Always raise the order in phase1
    k = k + 1;
  elseif knew == k-1                    % Already decided to lower the order
    k = k - 1;
    erk = erkm1;
  elseif k+1 <= ns                      % Estimate error at higher order
    if normcontrol
      erkp1 = absh * gstar(k+1) * (norm(phi(:,k+2)) * invwt);
    else
      erkp1 = absh * gstar(k+1) * norm(phi(:,k+2) .* invwt,inf);
    end
    if k == 1
      if erkp1 < 0.5*erk
        k = k + 1;
        erk = erkp1;
      end
    else
      if erkm1 <= min(erk,erkp1)
        k = k - 1;
        erk = erkm1;
      elseif (k < maxk) & (erkp1 < erk)
        k = k + 1;
        erk = erkp1;
      end
    end
  end
  if k ~= kold
    K = 1:k;
  end
  
  tstep = t;
  ystep = y;
  if haveeventfun
    [te,ye,ie,valt,stop] = ...
        odezero('ntrp113',odefile,valt,tlast,ylast,t,y,t0,varargin, ...
        klast,phi,psi);
    nte = length(te);
    if nte > 0
      if nargout > 2
        teout = [teout; te];
        yeout = [yeout; ye.'];
        ieout = [ieout; ie];
      end
      if stop                           % stop on a terminal event
        t = te(nte);
        y = ye(:,nte);
        done = true;
      end
    end
  end
  
  if nargout > 0
    oldnout = nout;
    if outflag == 2                     % computed points, no refinement
      nout = nout + 1;
      if nout > length(tout)
        tout = [tout; zeros(chunk,1)];
        yout = [yout; zeros(chunk,neq)];
      end
      tout(nout) = t;
      yout(nout,:) = y.';
    elseif outflag == 3                 % computed points, with refinement
      if nout + refine > length(tout)
        tout = [tout; zeros(chunk,1)];  % requires chunk >= refine
        yout = [yout; zeros(chunk,neq)];
      end
      dt = (t - tlast) / refine;
      for i = 1:refine-1
        tinterp = tlast + i*dt;
        nout = nout + 1;
        tout(nout) = tinterp;
        yout(nout,:) = ntrp113(tinterp,[],[],tstep,ystep,klast,phi,psi).';
      end
      nout = nout + 1;
      tout(nout) = t;
      yout(nout,:) = y.';
    elseif outflag == 1                 % output only at tspan points
      while next <= ntspan
        if tdir * (t - tspan(next)) < 0
          if haveeventfun & done
            nout = nout + 1;
            tout(nout) = t;
            yout(nout,:) = y.';
          end
          break;
        elseif t == tspan(next)
          nout = nout + 1;
          tout(nout) = t;
          yout(nout,:) = y.';
          next = next + 1;
          break;
        end
        nout = nout + 1;                % tout and yout are already allocated
        tout(nout) = tspan(next);
        yout(nout,:) = ntrp113(tspan(next),[],[],tstep,ystep,klast,phi,psi).';
        next = next + 1;
      end
    end
    
    if haveoutfun
      i = oldnout+1:nout;
      if ~isempty(i) & (feval(outfun,tout(i),yout(i,outputs).') == 1)
        tout = tout(1:nout);
        yout = yout(1:nout,:);
        if haveeventfun
          varargout{1} = teout;
          varargout{2} = yeout;
          varargout{3} = ieout;
          varargout{4} = [nsteps; nfailed; nfevals; npds; ndecomps; nsolves];
        else
          varargout{1} = [nsteps; nfailed; nfevals; npds; ndecomps; nsolves];
        end
        return;
      end
    end
    
  elseif haveoutfun
    if outflag == 2
      if feval(outfun,t,y(outputs)) == 1
        return;
      end
    elseif outflag == 3                 % computed points, with refinement
      dt = (t - tlast) / refine;
      for i = 1:refine-1
        tinterp(i,1) = tlast + i*dt;
        yinterp(:,i) = ntrp113(tinterp(i),[],[],tstep,ystep,klast,phi,psi);
      end
      if feval(outfun,[tinterp; t],[yinterp(outputs,:), y(outputs)]) == 1
        return;
      end
    elseif outflag == 1                 % output only at tspan points
      ninterp = 0;
      while next <= ntspan 
        if tdir * (t - tspan(next)) < 0
          if haveeventfun & done
            ninterp = ninterp + 1;
            tinterp(ninterp,1) = t;
            yinterp(:,ninterp) = y;
          end
          break;
        elseif t == tspan(next)
          ninterp = ninterp + 1;
          tinterp(ninterp,1) = t;
          yinterp(:,ninterp) = y;
          next = next + 1;
          break;
        end
        ninterp = ninterp + 1;
        tinterp(ninterp,1) = tspan(next);
        yinterp(:,ninterp) = ...
            ntrp113(tspan(next),[],[],tstep,ystep,klast,phi,psi);
        next = next + 1;
      end
      if ninterp > 0
        if feval(outfun,tinterp(1:ninterp),yinterp(outputs,1:ninterp)) == 1
          return;
        end
      end
    end
  end

  % Select a new step size.
  if phase1
    absh = 2 * absh;
  elseif 0.5*rtol >= erk*two(k+1)
    absh = 2 * absh;      
  elseif 0.5*rtol < erk
    reduce = (0.5 * rtol / erk)^(1 / (k+1));
    absh = absh * max(0.5, min(0.9, reduce));
  end
  
end

if haveoutfun
  feval(outfun,[],[],'done');
end

if printstats                           % print cost statistics
  fprintf('%g successful steps\n', nsteps);
  fprintf('%g failed attempts\n', nfailed);
  fprintf('%g function evaluations\n', nfevals);
  fprintf('%g partial derivatives\n', npds);
  fprintf('%g LU decompositions\n', ndecomps);
  fprintf('%g solutions of linear systems\n', nsolves);
end

if nargout > 0
  tout = tout(1:nout);
  yout = yout(1:nout,:);
  if haveeventfun
    varargout{1} = teout;
    varargout{2} = yeout;
    varargout{3} = ieout;
    varargout{4} = [nsteps; nfailed; nfevals; npds; ndecomps; nsolves];
  else
    varargout{1} = [nsteps; nfailed; nfevals; npds; ndecomps; nsolves];
  end
end
