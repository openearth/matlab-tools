function cosmos_postSCP(hm,m)

% Post model output (kmz, png) to web server

Model=hm.Models(m);
cont=hm.Models(m).Continent;

%locdir=[hm.WebDir Model.WebSite filesep 'scenarios' filesep hm.Scenario filesep Model.Continent filesep Model.Name filesep 'figures'];
locdir=[hm.WebDir 'scenarios' filesep hm.Scenario filesep Model.Continent filesep Model.Name filesep 'figures'];

% Uploading figures

% dr=['public_html/' Model.WebSite '/scenarios'];
% dr=['htdocs/' Model.WebSite '/scenarios'];
% dr=[Model.WebSite '/scenarios'];
dr='scenarios';

fid=fopen('scp.txt','wt');
fprintf(fid,'%s\n','option batch on');
fprintf(fid,'%s\n','option confirm off');
fprintf(fid,'%s\n','option echo on');
% fprintf(fid,'%s\n','open ormondt:0rm0ndt@dtvirt5.deltares.nl -timeout=15 -hostkey="ssh-rsa 2048 34:bf:74:05:1e:54:16:c0:86:2a:ca:2d:76:67:4c:34"');
fprintf(fid,'%s\n','open cosmos:c0sm0sw3bs1t3@cosmos.deltares.nl -timeout=15 -hostkey="ssh-rsa 1024 cc:17:70:a2:d1:1e:ed:86:09:23:ea:2e:1c:3e:66:5e"');
fprintf(fid,'%s\n',['cd ' dr]);
fprintf(fid,'%s\n',['mkdir ' hm.Scenario]);
fprintf(fid,'%s\n',['cd ' hm.Scenario]);
fprintf(fid,'%s\n',['mkdir ' cont]);
fprintf(fid,'%s\n',['cd ' cont]);
fprintf(fid,'%s\n',['mkdir ' hm.Models(m).Name]);
fprintf(fid,'%s\n',['cd ' hm.Models(m).Name]);
fprintf(fid,'%s\n','mkdir figures');
fprintf(fid,'%s\n','cd figures');
fprintf(fid,'%s\n','rm *.png');
fprintf(fid,'%s\n','rm *.kmz');
fprintf(fid,'%s\n',['put ' locdir filesep '*.*']);
fprintf(fid,'%s\n','close');
fprintf(fid,'%s\n','exit');
fclose(fid);
system([hm.MainDir 'exe' filesep 'winscp.exe /console /script=scp.txt']);
delete('scp.txt');


