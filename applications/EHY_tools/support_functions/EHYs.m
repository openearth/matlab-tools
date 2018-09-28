function EHY_userStats(mfilename)
try
    if ispc
        filename=['n:\Deltabox\Postbox\Groenenboom, Julien\@LASTMONTH\' getenv('username') '__' mfilename '__' datestr(now,'yyyymmddHHMMSS') '.ehy'];
        fid=fopen(filename,'w+');
        fclose(fid);
    end
end