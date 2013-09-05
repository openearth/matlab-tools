function mdf=simona2mdf_initial(S,mdf,name_mdf)

% simona2mdf_initial : gets the initial conditions out of the siminp file (always write to inital condition file)

mmax                 = mdf.mnkmax(1);
nmax                 = mdf.mnkmax(2);
zeta0(1:mmax,1:nmax) = 0.;
u0   (1:mmax,1:nmax) = 0.;
v0   (1:mmax,1:nmax) = 0.;
s0                   = [];

%
% get information out of struc
%

nesthd_dir = getenv('nesthd_path');
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'INITIAL'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.INITIAL')
    initial      = siminp_struc.ParsedTree.FLOW.FORCINGS.INITIAL;
else
    return
end

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

%
% Waterlevel
%

if simona2mdf_fieldandvalue(initial,'WATLEVEL.GLOBAL')
    zeta0 = simona2mdf_getglobaldata(initial.WATLEVEL.GLOBAL,zeta0);
end
if simona2mdf_fieldandvalue(initial,'WATLEVEL.LOCAL.BOX')
    zeta0  = simona2mdf_getboxdata(initial.WATLEVEL.LOCAL.BOX,zeta0);
end

%
% UVELOCITY
%

if simona2mdf_fieldandvalue(initial,'UVELOCITY.GLOBAL')
    u0    = simona2mdf_getglobaldata(initial.UVELOCITY.GLOBAL,u0);
end
if simona2mdf_fieldandvalue(initial,'UVELOCITY.LOCAL.BOX')
    u0     = simona2mdf_getboxdata(initial.UVELOCITY.LOCAL.BOX,u0);
end

%
% VVELOCITY
%

if simona2mdf_fieldandvalue(initial,'VVELOCITY.GLOBAL')
    v0    = simona2mdf_getglobaldata(initial.VVELOCITY.GLOBAL,v0);
end
if simona2mdf_fieldandvalue(initial,'VVELOCITY.LOCAL.BOX')
    v0      = simona2mdf_getboxdata(initial.VVELOCITY.LOCAL.BOX,v0);
end

%
% Salinity
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'TRANSPORT'});


if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT')
    if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT.PROBLEM.SALINITY')
        s0(1:mmax,1:nmax) = 0.;
       
        constnr = siminp_struc.ParsedTree.TRANSPORT.PROBLEM.SALINITY.CO;
        initial = siminp_struc.ParsedTree.TRANSPORT.FORCINGS.INITIAL.CONSTITUENT.CO;
        
        for icons = 1: length(initial)
            if initial(icons).SEQNR == constnr
                sal_ini = initial(icons);
            end
        end
        
        if simona2mdf_fieldandvalue(sal_ini,'GLOBAL')
            s0    = simona2mdf_getglobaldata(sal_ini.GLOBAL,s0);
        end
       
        if simona2mdf_fieldandvalue(sal_ini,'LOCAL.BOX')
            s0    = simona2mdf_getboxdata(sal_ini.LOCAL.BOX,s0);
        end
    end
end
          
%
% Finally write
%

ini(1).Data = zeta0;
ini(2).Data = u0;
ini(3).Data = v0;
if ~isempty(s0)
    ini(4).Data = s0;
end

mdf.filic  = [name_mdf '.ini'];
wldep('write',mdf.filic ,ini);
mdf.filic  = simona2mdf_rmpath(mdf.filic);


%
% Remove non necessary (constat values) fields
%

mdf = rmfield(mdf,'zeta0');
mdf = rmfield(mdf,'u0');
mdf = rmfield(mdf,'v0');
mdf = rmfield(mdf,'s0');
mdf = rmfield(mdf,'t0');
