function cosmos_postXML(hm,m)
% Post scenarios.xml, and scenario + model xml files

model=hm.models(m);

for iw=1:length(model.webSite)

    wbdir=model.webSite(iw).name;
    
    dr=[wbdir '/scenarios'];

    fid=fopen('scp.txt','wt');
    fprintf(fid,'%s\n','option batch on');
    fprintf(fid,'%s\n','option confirm off');
    fprintf(fid,'%s\n','open cosmos:c0sm0sw3bs1t3@cosmos.deltares.nl -timeout=15 -hostkey="ssh-rsa 1024 cc:17:70:a2:d1:1e:ed:86:09:23:ea:2e:1c:3e:66:5e"');
    fprintf(fid,'%s\n',['cd ' dr]);
%     % Upload scenarios.xml
%     fprintf(fid,'%s\n',['put ' hm.webDir wbdir filesep 'scenarios' filesep 'scenarios.xml']);
    fprintf(fid,'%s\n',['mkdir ' hm.scenario]);
    fprintf(fid,'%s\n',['cd ' hm.scenario]);
    % Upload scenario xml
    fprintf(fid,'%s\n',['put ' hm.webDir wbdir filesep 'scenarios' filesep hm.scenario filesep hm.scenario '.xml']);
    % Upload model xml
    fprintf(fid,'%s\n',['put ' hm.webDir wbdir filesep 'scenarios' filesep hm.scenario filesep model.name '.xml']);
    fprintf(fid,'%s\n','close');
    fprintf(fid,'%s\n','exit');
    fclose(fid);
    system([hm.exeDir 'winscp.exe /console /script=scp.txt']);
    delete('scp.txt');

end
