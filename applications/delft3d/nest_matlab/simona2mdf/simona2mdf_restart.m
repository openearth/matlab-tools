function mdf = simona2mdf_processes (S,mdf,name_mdf)

% simona2mdf_restart: restart nformation out of the parsed siminp tree

warning = false;

warntext{1} = 'SIMINP2MDF Restart Warning:';
warntext{2} = '';

nesthd_dir = getenv('nesthd_path');

%
% Check for restart information
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'RESTART'});
if ~isempty(siminp_struc.ParsedTree.RESTART)
   warning = true;
   warntext{end+1} = 'Conversion of RESTART file (from SDS to tri-rst)';
   warntext{end+1} = 'not implemented yet';
   warntext{end+1} = '';
end

%
% Writes the warning
%

if warning
   simona2mdf_warning(warntext);
end
