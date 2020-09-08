%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16573 $
%$Date: 2020-09-08 16:03:40 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: errorprint.m 16573 2020-09-08 14:03:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/main/errorprint.m $
%
%errorprint is a function that prints in the log file the error catched
%
%errorprint(error_obj,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:


function errorprint(error_obj,fid_log)
%comment out fot improved performance if the version is clear from github
% version='2';
% if kt==1; fprintf(fid_log,'display_tloop version: %s\n',version); end 

%% 

np=numel(error_obj.stack);

fprintf(        '¡¡ ERROR !! \n');
fprintf(fid_log,'¡¡ ERROR !! \n');
kp=1;
aux=strrep(error_obj.stack(kp).file,filesep,sprintf('\\%s',filesep)); %add special characters (problems with Linux and Mac?)
fprintf(        '%s in <a href="matlab:matlab.desktop.editor.openAndGoToLine(''%s'',%d)">%s</a>, at line %d \n',error_obj.message,aux,error_obj.stack(kp).line,error_obj.stack(kp).name,error_obj.stack(kp).line);
fprintf(fid_log,'%s in %s, at line %d \n',error_obj.message,error_obj.stack(kp).name,error_obj.stack(kp).line);
fprintf(        'The parents are: \n');
fprintf(fid_log,'The parents are: \n');
for kp=2:np
    aux=strrep(error_obj.stack(kp).file,filesep,sprintf('\\%s',filesep)); %add special characters
    fprintf(        '%d) \t <a href="matlab:matlab.desktop.editor.openAndGoToLine(''%s'',%d)">%s</a>, at line %d \n',kp-1,aux,error_obj.stack(kp).line,error_obj.stack(kp).name,error_obj.stack(kp).line);
    fprintf(fid_log,'%d) \t %s, at line %d \n',kp-1,error_obj.stack(kp).name,error_obj.stack(kp).line);
end

fprintf('    +----+  +     XX      XX                    \n');
fprintf('    |       |      XX    XX                     \n');
fprintf('    +--+    |       XX  XX                      \n');
fprintf('    |       |        XXXX                       \n');
fprintf('    +----+  +---+     XX                        \n');
fprintf('   XXXX                      XX                 \n');
fprintf(' XXX  XX       XXXXXX     XXXXXXXXXXXXXXX       \n');
fprintf('XX     XX    XXX    XXXXXXX          XXX        \n');
fprintf('         XXXXX                                  \n');
fprintf('                                                \n');

fprintf(fid_log,'    +----+  +     XX      XX                    \n');
fprintf(fid_log,'    |       |      XX    XX                     \n');
fprintf(fid_log,'    +--+    |       XX  XX                      \n');
fprintf(fid_log,'    |       |        XXXX                       \n');
fprintf(fid_log,'    +----+  +---+     XX                        \n');
fprintf(fid_log,'   XXXX                      XX                 \n');
fprintf(fid_log,' XXX  XX       XXXXXX     XXXXXXXXXXXXXXX       \n');
fprintf(fid_log,'XX     XX    XXX    XXXXXXX          XXX        \n');
fprintf(fid_log,'         XXXXX                                  \n');
fprintf(fid_log,'                                                \n');


fprintf(        'All for <a href="http://www.ncr-web.org/rivercare/projects/d2">Liselot</a> :D \n\n');
fprintf(fid_log,'All for Liselot :D \n');
end

