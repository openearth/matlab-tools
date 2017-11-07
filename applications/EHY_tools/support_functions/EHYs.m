function EHY_userStats(mfilename)
try
    filename='n:\Deltabox\Bulletin\groenenb\OET_EHY\stats\stats.csv';
    if exist(filename,'file')
        fid=fopen(filename,'a');
    else
        fid=fopen(filename,'w');
    end
    fprintf(fid,'%s\n',[getenv('username') ';' mfilename ';' datestr(now)]);
    fclose(fid);
end