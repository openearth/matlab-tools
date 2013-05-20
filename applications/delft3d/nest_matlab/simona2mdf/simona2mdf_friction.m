function mdf=simona2mdf_friction(S,mdf,name_mdf)

% simona2mdf_friction : gets the initial conditions out of the siminp file

mmax = mdf.mnkmax(1);
nmax = mdf.mnkmax(2);

%
% get information out of struc
%

nesthd_dir   = getenv('nesthd_path');
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM' 'FRICTION'});
friction     = siminp_struc.ParsedTree.FLOW.PROBLEM.FRICTION;

%
% Determine friction type
%

if strcmpi(friction.GLOBAL.FORMULA,'Manning')        ;mdf.roumet='M';end;
if strcmpi(friction.GLOBAL.FORMULA,'Chezy')          ;mdf.roumet='C';end;
if strcmpi(friction.GLOBAL.FORMULA,'White-Colebrook');mdf.roumet='W';end;
if strcmpi(friction.GLOBAL.FORMULA,'Z0-based')       ;mdf.roumet='W';end;

%
% U-Friction
%

friction_u(1:mmax,1:nmax) = 0.;
friction_u                = simona2mdf_getglobaldata(friction.UDIREC.GLOBAL,friction_u);
if isfield(friction.UDIREC.LOCAL,'BOX')
    friction_u            = simona2mdf_getboxdata   (friction.UDIREC.LOCAL.BOX,friction_u);
end

%
% V-Friction
%

friction_v(1:mmax,1:nmax) = 0.;
friction_v                = simona2mdf_getglobaldata(friction.VDIREC.GLOBAL,friction_v);
if isfield(friction.UDIREC.LOCAL,'BOX')
    friction_v            = simona2mdf_getboxdata   (friction.VDIREC.LOCAL.BOX,friction_v);
end

%
% Finally write
%

rgh(1).Data = friction_u;
rgh(2).Data = friction_v;
mdf.filrgh  = [name_mdf '.rgh'];
wldep('write',mdf.filrgh,rgh);
mdf.filrgh  = simona2mdf_rmpath(mdf.filrgh);
