function mdf = simona2mdf_times (S,mdf,name_mdf)

% simona2mdf_times : gets thimes out of the parsed siminp tree

nesthd_dir = getenv('nesthd_path');

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM' 'TIMEFRAME'});

times = siminp_struc.ParsedTree.FLOW.PROBLEM.TIMEFRAME;

itdate     = datenum(times.DATE);
mdf.itdate = datestr(itdate,'yyyy-mm-dd');
mdf.tstart = times.TSTART;
mdf.tstop  = times.TSTOP;

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM' 'METHODVARIABLES'});
mdf.dt     = siminp_struc.ParsedTree.FLOW.PROBLEM.METHODVARIABLES.TSTEP;

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM' 'SMOOTHING'});
try
   mdf.tlfsmo = siminp_struc.ParsedTree.FLOW.PROBLEM.SMOOTHING.TLSMOOTH;
end
