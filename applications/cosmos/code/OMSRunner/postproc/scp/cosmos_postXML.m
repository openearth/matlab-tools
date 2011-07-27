function cosmos_postXML(hm,m)
% Post scenarios.xml, and scenario + model xml files

Model=hm.Models(m);

for iw=1:length(Model.WebSite)

    wbdir=Model.WebSite(iw).Name;
    
    dr=[wbdir '/scenarios'];

    fid=fopen('scp.txt','wt');
    fprintf(fid,'%s\n','option batch on');
    fprintf(fid,'%s\n','option confirm off');
    fprintf(fid,'%s\n','open cosmos:c0sm0sw3bs1t3@cosmos.deltares.nl -timeout=15 -hostkey="ssh-rsa 1024 cc:17:70:a2:d1:1e:ed:86:09:23:ea:2e:1c:3e:66:5e"');
    fprintf(fid,'%s\n',['cd ' dr]);
    % Upload scenarios.xml
    fprintf(fid,'%s\n',['put ' hm.WebDir wbdir filesep 'scenarios' filesep 'scenarios.xml']);
    fprintf(fid,'%s\n',['mkdir ' hm.Scenario]);
    fprintf(fid,'%s\n',['cd ' hm.Scenario]);
    % Upload scenario xml
    fprintf(fid,'%s\n',['put ' hm.WebDir wbdir filesep 'scenarios' filesep hm.Scenario filesep hm.Scenario '.xml']);
    % Upload model xml
    fprintf(fid,'%s\n',['put ' hm.WebDir wbdir filesep 'scenarios' filesep hm.Scenario filesep Model.Name '.xml']);
    fprintf(fid,'%s\n','close');
    fprintf(fid,'%s\n','exit');
    fclose(fid);
    system([hm.MainDir 'exe' filesep 'winscp.exe /console /script=scp.txt']);
    delete('scp.txt');

end
