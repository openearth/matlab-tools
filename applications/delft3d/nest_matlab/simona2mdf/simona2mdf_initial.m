function mdf=simona2mdf_initial(S,mdf,name_mdf)

% simona2mdf_initial : gets the initial conditions out of the siminp file (always write to inital condition file)

mmax = mdf.mnkmax(1);
nmax = mdf.mnkmax(2);

%
% get information out of struc
%

nesthd_dir = getenv('nesthd_path');
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS'});
if isempty (siminp_struc.ParsedTree.FLOW.FORCINGS.INITIAL); return; end
initial      = siminp_struc.ParsedTree.FLOW.FORCINGS.INITIAL;

%
% first some warnings
%

if ~isempty(initial.READ_FROM)
    siminp2mdf_warning('READ_FROM (initial conditions) not supported');
end
if ~isempty(initial.COMPUTE)
    siminp2mdf_warning('COMPUTE (initial conditions) not supported');
end

%
% Read initial conditions and write
%

zeta0(1:mmax,1:nmax) = 0.;
u0   (1:mmax,1:nmax) = 0.;
v0   (1:mmax,1:nmax) = 0.;

%
% Waterlevel
%

if ~isempty(initial.WATLEVEL)
    zeta0 = simona2mdf_getglobaldata(initial.WATLEVEL.GLOBAL,zeta0);
    if isfield (initial.WATLEVEL.LOCAL,'BOX')
       zeta0   = simona2mdf_getboxdata(initial.WATLEVEL.LOCAL.BOX,zeta0);
    end
end

%
% UVELOCITY
%
if ~isempty(initial.UVELOCITY)
    u0    = simona2mdf_getglobaldata(initial.UVELOCITY.GLOBAL,u0);
    if isfield (initial.UVELOCITY.LOCAL,'BOX')
       u0      = simona2mdf_getboxdata(initial.UVELOCITY.LOCAL.BOX,u0);
    end
end

%
% VVELOCITY
%

if ~isempty(initial.VVELOCITY)
    v0    = simona2mdf_getglobaldata(initial.VVELOCITY.GLOBAL,v0);
    if isfield (initial.VVELOCITY.LOCAL,'BOX')
       v0      = simona2mdf_getboxdata(initial.VVELOCITY.LOCAL.BOX,u0);
    end
end

%
% Finally write
%

ini(1).Data = zeta0;
ini(2).Data = u0;
ini(3).Data = v0;
mdf.filic  = [name_mdf '.ini'];
wldep('write',mdf.filic ,ini);
mdf.filic  = simona2mdf_rmpath(mdf.filic);
