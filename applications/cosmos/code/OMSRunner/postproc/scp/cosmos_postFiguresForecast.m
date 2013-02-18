function cosmos_postFigures(hm,m)
% Post model output (kmz, png) to web server

model=hm.models(m);

locdir=[hm.webDir 'zandmotor' filesep 'forecast' filesep 'results' filesep model.forecastplot.name];

% Uploading figures

dr='zandmotor';

fid=fopen('scp.txt','wt');
fprintf(fid,'%s\n','option batch on');
fprintf(fid,'%s\n','option confirm off');
fprintf(fid,'%s\n','option echo on');
fprintf(fid,'%s\n','open cosmos:c0sm0sw3bs1t3@cosmos.deltares.nl -timeout=15 -hostkey="ssh-rsa 1024 cc:17:70:a2:d1:1e:ed:86:09:23:ea:2e:1c:3e:66:5e"');
fprintf(fid,'%s\n',['cd ' dr]);
fprintf(fid,'%s\n',['mkdir forecast']);
fprintf(fid,'%s\n',['cd forecast']);
fprintf(fid,'%s\n',['mkdir results']);
fprintf(fid,'%s\n',['cd results']);
fprintf(fid,'%s\n',['mkdir ' model.forecastplot.name]);
fprintf(fid,'%s\n',['cd ' model.forecastplot.name]);
fprintf(fid,'%s\n','rm *.png');
fprintf(fid,'%s\n','rm *.xml');
fprintf(fid,'%s\n',['put ' locdir filesep '*.*']);
fprintf(fid,'%s\n','close');
fprintf(fid,'%s\n','exit');
fclose(fid);
system([hm.exeDir 'winscp.exe /console /script=scp.txt']);
delete('scp.txt');
