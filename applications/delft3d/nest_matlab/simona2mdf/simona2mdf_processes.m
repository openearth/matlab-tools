function mdf = simona2mdf_processes (S,mdf,name_mdf)

% simona2mdf_processes : gets proces information out of the parsed siminp tree

warning = false;
warntext{1} = 'SIMINP2MDF Processes Warning:';
warntext{2} = '';

nesthd_dir = getenv('nesthd_path');

%
% Check for salinity
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'TRANSPORT' 'PROBLEM'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT.PROBLEM')
   warning = true;
   warntext{end+1} = 'Conversion of TRANSPORT not implemented yet';
end

%
% Check for temperature
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'HEATMODEL'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.HEATMODEL')
   warning = true;
   warntext{end+1} = 'Conversion of SALINITY not implemented yet';
end

%
% Check for wind
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'GENERAL'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.GENERAL.WIND')
   mdf.sub1(3) = 'w';
end

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.GENERAL.SPACE_VAR_WIND')
   warning = true;
   warntext{end+1} = 'Conversion of WIND (space varying) not implemented yet';
end
%
% Writes the warning
%
warntext{end+1} = '';

if warning
   simona2mdf_warning(warntext);
end
