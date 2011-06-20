function a=h4(str,username,password,exedir)

fid=fopen('tmp.sh','wt');      
fprintf(fid,'%s\n','#!/bin/sh');
fprintf(fid,'%s\n','. /opt/sge/InitSGE');
fprintf(fid,'%s\n',str);
fprintf(fid,'%s\n','rm tmp.sh');
fclose(fid);    

system([exedir filesep 'dos2unix tmp.sh']);
        
[success,message,messageid]=movefile('tmp.sh','u:\','f');

a=system([exedir filesep 'plink ' username '@h4 -pw ' password ' ~/tmp.sh']);
