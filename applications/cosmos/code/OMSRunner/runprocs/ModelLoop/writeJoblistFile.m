function writeJoblistFile(hm,m,opt)

hm.Models(m).ProcessDuration=hm.Models(m).ExtractDuration+hm.Models(m).PlotDuration+hm.Models(m).UploadDuration;
fid=fopen([hm.ScenarioDir  'joblist' filesep opt '.' datestr(hm.Cycle,'yyyymmdd.HHMMSS') '.' hm.Models(m).Name],'wt');
fprintf(fid,'%s\n',datestr(hm.Models(m).SimStart,'yyyymmdd HHMMSS'));
fprintf(fid,'%s\n',datestr(hm.Models(m).SimStop,'yyyymmdd HHMMSS'));
fprintf(fid,'%s\n',['Run duration     : ' num2str(hm.Models(m).RunDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Move duration    : ' num2str(hm.Models(m).MoveDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Extract duration : ' num2str(hm.Models(m).ExtractDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Plot duration    : ' num2str(hm.Models(m).PlotDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Upload duration  : ' num2str(hm.Models(m).UploadDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Process duration : ' num2str(hm.Models(m).ProcessDuration,'%8.2f') ' s']);
fclose(fid);
