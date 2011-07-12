function PostXML(hm,m)

% Post scenarios.xml and model xml

Model=hm.Models(m);

for iw=1:length(Model.WebSite)

    wbdir=Model.WebSite(iw).Name;
    
    dr=[wbdir '/scenarios'];

    fid=fopen('scp.txt','wt');
    fprintf(fid,'%s\n','option batch on');
    fprintf(fid,'%s\n','option confirm off');
    %fprintf(fid,'%s\n','open ormondt:0rm0ndt@dtvirt5.deltares.nl -hostkey="ssh-rsa 2048 34:bf:74:05:1e:54:16:c0:86:2a:ca:2d:76:67:4c:34"');
    fprintf(fid,'%s\n','open cosmos:c0sm0sw3bs1t3@cosmos.deltares.nl -timeout=15 -hostkey="ssh-rsa 1024 cc:17:70:a2:d1:1e:ed:86:09:23:ea:2e:1c:3e:66:5e"');
    fprintf(fid,'%s\n',['cd ' dr]);
    %fprintf(fid,'%s\n',['put ' hm.WebDir Model.WebSite filesep 'scenarios' filesep hm.Scenario filesep 'models.xml']);
    fprintf(fid,'%s\n',['put ' hm.WebDir wbdir filesep 'scenarios' filesep 'scenarios.xml']);
    fprintf(fid,'%s\n',['mkdir ' hm.Scenario]);
    fprintf(fid,'%s\n',['cd ' hm.Scenario]);
    fprintf(fid,'%s\n',['mkdir ' Model.Continent]);
    fprintf(fid,'%s\n',['cd ' Model.Continent]);
    fprintf(fid,'%s\n',['mkdir ' Model.Name]);
    fprintf(fid,'%s\n',['cd ' Model.Name]);
    fprintf(fid,'%s\n',['put ' hm.WebDir wbdir filesep 'scenarios' filesep hm.Scenario filesep Model.Continent filesep Model.Name filesep Model.Name '.xml']);
    fprintf(fid,'%s\n','close');
    fprintf(fid,'%s\n','exit');
    fclose(fid);
    system([hm.MainDir 'exe' filesep 'winscp.exe /console /script=scp.txt']);
    delete('scp.txt');

end

% Model=hm.Models(m);
% 
% try
% 
%     disp('Connecting to FTP site ...');
%     f=ftp('members.upc.nl','m.ormondt','8AMGU55S');
% 
%     disp(['cd ' Model.WebSite '/scenarios/' hm.Scenario]);
%     
%     cd(f,[Model.WebSite '/scenarios/' hm.Scenario]);
% 
%     try % to delete models.xml
%         disp('Deleting models.xml ...');
%         delete(f,'models.xml');
%     end
% 
%     try % to upload models.xml
%         disp('Uploading models.xml ...');
%         mput(f,[hm.WebDir Model.WebSite filesep 'scenarios' filesep hm.Scenario filesep 'models.xml']);
%         disp('models.xml uploaded ...');
%     end
%     
%     close(f);
% 
% catch
%     disp('Something went wrong with uploading to FTP site!');
% end
