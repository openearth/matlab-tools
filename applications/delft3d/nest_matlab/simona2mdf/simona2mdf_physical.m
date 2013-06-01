function mdf=simona2mdf_physical(S,mdf,~)

% simona2mdf_initial : gets the physical parmaters out of the siminp file

%
% get information out of struc
%

nesthd_dir = getenv('nesthd_path');
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'GENERAL'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.GENERAL.PHYSICALPARAM') 
    params   = siminp_struc.ParsedTree.GENERAL.PHYSICALPARAM;
else
    params   = [];
end

if ~isempty(params);
    mdf.ag     = params.GRAVI;
    mdf.rhow   = params.WATDENSITY;
    mdf.rhoa   = params.AIRDENSITY;
    mdf.vicoww = params.DYNVISCOSI/mdf.rhow;
else
    % set defaults
    mdf.ag     =    9.813;
    mdf.rhow   = 1023.;
    mdf.rhoa   =    1.205;
    mdf.vicoww =    1.0E-3/mdf.rhow;
end

%
% Water temperature (only if saliity is a transport quantity)
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'DENSITIES'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.DENSITIES')
    density = siminp_struc.ParsedTree.DENSITIES;
else
    density = [];
end

if ~isempty(density)
    mdf.tempw = density.TEMPWATER;
    mdf.salw  = density.SALINITY;
    mdf.rhow  = density.RHOREF*1000.;
end

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'DENSITY'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.DENSITY')
    simona2.mdf_warning({'DENSITY not supported yet';'(DENSITIES is supported)'});
end

%
% Finally, some resetting of defaults
%

mdf.denfrm = 'Eckart'; % only simona option
mdf.barocp = 'n';      % genarally better option
