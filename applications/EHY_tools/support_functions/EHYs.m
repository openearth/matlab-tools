function EHY_userStats(mfilename)
try
    filename=['n:\Deltabox\Bulletin\groenenb\OET_EHY\stats\' getenv('username') '_' mfilename '_' datestr(now,'yyyymmddHHMMSS')];
    fid=fopen(filename,'w');
    fclose(fid);
end