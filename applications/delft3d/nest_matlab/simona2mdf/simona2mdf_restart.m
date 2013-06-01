function mdf = simona2mdf_processes (S,mdf,name_mdf)

% simona2mdf_restart: restart nformation out of the parsed siminp tree

warning = false;

warntext{1} = 'SIMINP2MDF Restart Warning:';
warntext{2} = '';
warntext{end+1} = 'Conversion of RESTART file (from SDS to tri-rst)';
warntext{end+1} = 'not implemented yet';
warntext{end+1} = '';

nesthd_dir = getenv('nesthd_path');

%
% Check for restart information (use try/catch to distinguish reading from RESTART
% information from writing restart information)
%

try
   siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'RESTART'});
   if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.RESTART')
      warning = true;
   end
catch
    warning = false;
end
%
% Writes the warning
%

if warning
   simona2mdf_warning(warntext);
end
