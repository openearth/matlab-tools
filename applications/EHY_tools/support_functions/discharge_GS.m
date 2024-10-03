function [Dis,cond,hgGate,hgWeir,upE] = discharge_GS(level1,level2,GH,width,muGate,corrGate,corrWeir,C,L,varargin)

%% Compute discharges and discharge condition based on water levels right, left and structure definition
%  Postive discharge if level1 > level2
%  For now, only gate flow (sub- and supercritical)
%  Water levels should be specified relative to the sill depth (hence water level = water depth)
%
%  Initialise
OPT.forcedCondition = NaN;
OPT = setproperty(OPT,varargin);

g      = 9.81;
lambda = g*L/(C*C);
if level1 > level2 sign = 1.0; else sign = -1.0; end
diff   = 1e36;

%  Up and downsteam water levels
if sign ==  1; upWl = level1; downWl = level2; end
if sign == -1; upWl = level2; downWl = level1; end

%  Start with discharge estimated based on water level difference only
Dis_tmp = muGate*corrGate*width*GH*sqrt(2*g*(upWl - downWl))*sign;
crit    = Dis_tmp/1e4;

% Iterate
iter = 0;
while diff > crit && iter < 10000
    iter   = iter + 1;
    upU    = Dis_tmp/(upWl  *width);
    downU  = Dis_tmp/(downWl*width);
    upE    = upU  ^2/(2*g) + upWl  ;
    downE  = downU^2/(2*g) + downWl;
    
    %  Water level at gate both for weir and Gate flow
    hgWeir   = flgsd3fm(width   , width, 0.0, width, 0.0,     0.0, 0.0, upE, downWl, 1.0, ...
                        corrWeir       , lambda                                         ) ;
    hgGate   = flgsd2fm(width   , width, 0.0, width, 0.0, GH, 0.0, 0.0, upE, downWl, 1.0, ...
                        muGate*corrGate, lambda                                         );
%    hgGate   = compute_hgTK(width,GH,downWl,upE,muGate*corrGate,lambda);
    
    if isnan(OPT.forcedCondition)
        cond      = detCond_gs_TRM    (upE,hgWeir,hgGate,GH,muGate);
    else
        cond      = OPT.forcedCondition;
    end
    
    if cond == 3 hgWeir = upE*2/3  ; end
    if cond == 1 hgGate = muGate*GH; end
    
    %% Discharge for gate flow (essentially same formulations, only difference is determination of waterdepth just after gate)
    if cond == 1 || cond == 7 || cond == 0
        
        Dis = muGate*corrGate*width*GH*sqrt(2*g*(upE - hgGate))*sign;
        
        %% Discharge weirflow subcritical
    elseif cond == 6
        % Discharge weirflow subcritical
        Dis = corrWeir*width*hgWeir*sqrt(2*g*(upE - hgWeir))*sign;
    elseif cond == 3
        % Discharge weirflow supercritical
         Dis = corrWeir*width*(2/3)*sqrt((2/3)*g)*upE^(3/2)*sign;
    end
    
    diff       = abs(Dis - Dis_tmp);
   
    Dis_tmp    = 0.01*Dis + 0.99*Dis_tmp;

    if iter == 10000
        
        % Criterion not met
        Dis    = NaN;
        cond   = NaN;
        hgGate = NaN;
        hgWeir = NaN;
        upE    = NaN;
    end
end

end

function hg = compute_hgTK(width,GH,downWl,upH,mu,lambda)

termA = 4*mu*mu*GH*GH*width/downWl*(1.0D0 + lambda/downWl);
termB = 4*mu*GH*width;
A = width;
B = termA - termB;
C = -downWl*downWl*width - termA*upH + termB*upH;

if B^2 - 4*A*C > 0
   hg = (-B + sqrt(B^2 - 4*A*C))/(2*A);
else
    hg = NaN;
end

end

function ds = flgsd2fm(wsd, wstr, zs, w2, zb2, dg, ds1, ds2, elu, hd, rhoast, ...
                       cgd, lambda)

%     Parameters:
%     NR NAME              IO DESCRIPTION
%     12 cgd               I  Correction coefficient for drowned gate flow.
%      6 dg                I  Gate opening height.
%      7 ds1               I  Delta s1 general structure.
%      8 ds2               I  Delta s2 general structure.
%     14 ds                IO Water level immediately downstream the gate.
%      9 elu               I  Upstream energy level.
%     10 hd                I  Downstream water level.
%     13 imag              O  Logical indicator, = TRUE when determinant of
%                             second order algebraic equation less than
%                             zero.
%     15 lambda            I  Extra resistance in general structure.
%     11 rhoast            I  Downstream water density divided by upstream
%                             water density.
%      4 w2                I  Width at right side of structure.
%      1 wsd               I  Width structure right or left side.
%      2 wstr              I  Width at centre of structure.
%      5 zb2               I  Bed level at right side of structure.
%      3 zs                I  Bed level at centre of structure.
    c13 = 1./3.;
    c23 = 2./3.;

    ag = (1.0D0 - rhoast)*(w2/12.0D0 + wsd/4.0D0) + 0.5D0*(rhoast + 1.0D0)      ...
         *(c13*w2 + c23*wsd);
    d2 = hd - zb2;

    terma = (4.0D0*rhoast*cgd*cgd*dg*dg*wstr*wstr)/(w2*d2)*(1.0D0 + lambda/d2);
    termb = 4.0D0*cgd*dg*wstr;

    bg = (1.0D0 - rhoast)*((d2 + ds1)*(w2 + wsd)/6.D0 + ds1*wsd*c13)            ...
         + 0.5D0*(rhoast + 1.0D0)                                               ...
         *((ds1 + ds2 - d2)*(c13*w2 + c23*wsd) + (c23*d2 + c13*ds1)             ...
         *w2 + (c13*d2 + c23*ds1)*wsd) + terma - termb;

    hsl = elu - zs;

    cg = (1.0D0 - rhoast)*((d2 + ds1)^2*(w2 + wsd)/12.D0 + ds1^2*wsd/6.0D0)    ...
         + 0.5D0*(rhoast + 1.0D0)*(ds1 + ds2 - d2)                             ...
         *((c23*d2 + c13*ds1)*w2 + (c13*d2 + c23*ds1)*wsd) - terma*hsl +       ...
         termb*hsl;

    det = bg*bg - 4.0D0*ag*cg;
    if (det<0.0D0)
       ds = NaN;
    else
       ds = ( - bg + sqrt(det))/(2.0D0*ag);
    end
end

function ds = flgsd3fm(wsd   , wstr, zs, w2, zb2, ds1, ds2, elu, hd, rhoast, cwd, ...
                       lambda)
%     Parameters:
%     NR NAME              IO DESCRIPTION
%     11 cwd               I  Correction coefficient for drowned weir flow.
%      6 ds1               I  Delta s1 general structure.
%      7 ds2               I  Delta s2 general structure.
%     12 ds                IO Water level immediately downstream the gate.
%      8 elu               I  Upstream energy level.
%      9 hd                I  Downstream water level.
%     13 lambda            I  Extra resistance in general structure.
%     10 rhoast            I  Downstream water density divided by upstream
%                             water density.
%      4 w2                I  Width at right side of structure.
%      1 wsd               I  Width structure right or left side.
%      2 wstr              I  Width at centre of structure.
%      5 zb2               I  Bed level at right side of structure.
%      3 zs                I  Bed level at centre of structure.
c13  = 1./3.;
c23  = 2./3.;

d2   = hd - zb2;
hsl  = elu - zs;
term = ((4.0D0*cwd*cwd*rhoast*wstr*wstr)/(w2*d2))*(1.0D0 + lambda/d2);

aw = ( - term*hsl - 4.0D0*cwd*wstr + (1.0D0 - rhoast)                       ...
    *(w2/12.0D0 + wsd/4.0D0) + 0.5D0*(rhoast + 1.0D0)*(c13*w2 + c23*wsd))  ...
    /term;

bw = (4.0D0*cwd*wstr*hsl + (1.0D0 - rhoast)                                 ...
    *((d2 + ds1)*(w2 + wsd)/6.D0 + ds1*wsd*c13) + 0.5D0*(rhoast + 1.0D0)   ...
    *((ds1 + ds2 - d2)*(c13*w2 + c23*wsd) + (c23*d2 + c13*ds1)             ...
    *w2 + (c13*d2 + c23*ds1)*wsd))/term;

cw = ((1.0D0 - rhoast)*((d2 + ds1)^2*(w2 + wsd)/12.D0 + ds1^2*wsd/6.0D0)    ...
    + 0.5D0*(rhoast + 1.0D0)*(ds1 + ds2 - d2)                              ...
    *((c23*d2 + c13*ds1)*w2 + (c13*d2 + c23*ds1)*wsd))/term;

%    Solve the equation ds**3 + aw*ds**2 + bw*ds +cw to get the water
%    level at the sill
p = bw/3.0D0 - aw*aw/9.0D0;
q = aw*aw*aw/27.0D0 - aw*bw/6.0D0 + cw/2.0D0;
hulp = q*q + p*p*p;

if (hulp<0.0D0)
    p = abs(p);
    phi = acos(abs(q)/p/sqrt(p))/3.0D0;
    r60 = acos(0.5D0);
    fac = 2.0*sign(q)*sqrt(p);
    h2a = -fac*cos(phi);
    h2b = fac*cos(r60 - phi);
    h2c = fac*cos(r60 + phi);
    ds = max([h2a; h2b; h2c]) - aw/3.0D0;
else
    hulp = sqrt(hulp);
    hulp1 = -q + hulp;
    if (abs(hulp1)<1E-6)
        u = 0 ; v = 0;
    else
        u = abs(hulp1)^c13*sign(hulp1);
        hulp1 = -q - hulp;
        v = abs(hulp1)^c13*sign(hulp1);
    end
    ds = u + v - aw/3.0D0;
end

end

function condition = detCond_gs_fortran(upE,hgWeir,hgGate,GH,muGate)

%% determine condition (following fortran code!)
condition = 0;
hc = upE*2/3;
if GH > 0
    if hgWeir > hc
        if GH >=  hgWeir
            % drowned (subcritical) weir flow
            condition = 6;
        else
            % gateflow
            condition = NaN;
        end
    else
        if GH >= hc
            % Free supercritical weir flow
            condition =  3;
        else
            condition = NaN;
        end
    end

    % Determine sub or supercritical gate flow
    if isnan(condition)
        %  Gate flow

        dc = muGate*GH;
        if isnan(hgGate)
            % Superctitical gate flow
            condition = 1;
        elseif hgGate <= dc
            % Supercritical gate flow
            condition = 1;
        else
            % subcritical gate flow
            condition = 7;
        end
    end
end


end

function condition = detCond_gs_TRM(upE,hgWeir,hgGate,GH,muGate)

% determine condition (based upon Technical Reference manual Sobek)
condition = 0;
if GH > 0
    hc = upE*2/3;
    if     hgWeir >hc && GH > hgWeir
        % drowned (subcritical) weir flow
        condition = 6;
    elseif hgWeir < hc && GH > hgWeir
        % free (supercritical) weir flow
        condition = 3 ;
    else
        % Gateflow
        hc = muGate*GH;
        if hgGate > hc
            % drowned gate flow (subcritical)
            condition = 7;
        elseif isnan (hgGate) || hgGate < hc
            % free gate flow (supercritical)
            condition = 1;
        end
    end
end

end





