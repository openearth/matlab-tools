function EHY_userStats(mfilename)
try
    filename=['n:\Deltabox\Bulletin\groenenb\OET_EHY\stats\' getenv('username') '__' mfilename '__' datestr(now,'yyyymmddHHMMSS') '.ehy'];
    fid=fopen(filename,'w');
    fclose(fid);
end