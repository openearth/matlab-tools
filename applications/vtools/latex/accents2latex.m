%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: accents2latex.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/accents2latex.m $
%
%transforms a string with accent to the LaTeX version

function str_auth=accents2latex(str_auth)
                
str_auth=strrep(str_auth,'�','\"a');
str_auth=strrep(str_auth,'�','\"e');
str_auth=strrep(str_auth,'�','\"i');
str_auth=strrep(str_auth,'�','\"o');
str_auth=strrep(str_auth,'�','\"u');

str_auth=strrep(str_auth,'�','\`a');
str_auth=strrep(str_auth,'�','\`e');
str_auth=strrep(str_auth,'�','\`i');
str_auth=strrep(str_auth,'�','\`o');
str_auth=strrep(str_auth,'�','\`u');

str_auth=strrep(str_auth,'�','\''a');
str_auth=strrep(str_auth,'�','\''A');
str_auth=strrep(str_auth,'�','\''e');
str_auth=strrep(str_auth,'�','\''E');
str_auth=strrep(str_auth,'�','\''i');
str_auth=strrep(str_auth,'�','\''o');
str_auth=strrep(str_auth,'�','\''u');

% if strfind(str_auth,'Milivojevi')
%    s=1;
% end
% str_auth=strrep(str_auth,'','\''c'); %this only works in debug mode!
str_auth=strrep(str_auth,'�','\''y');

str_auth=strrep(str_auth,'�','\^a');
str_auth=strrep(str_auth,'�','\^e');
str_auth=strrep(str_auth,'�','\^i');
str_auth=strrep(str_auth,'�','\^o');
str_auth=strrep(str_auth,'�','\^u');

str_auth=strrep(str_auth,'�','\^a');

str_auth=strrep(str_auth,'�','\~n');

str_auth=strrep(str_auth,'�','\v{s}');
str_auth=strrep(str_auth,'�','\v{S}');

str_auth=strrep(str_auth,'�','\c{c}');

str_auth=strrep(str_auth,'�','``');
str_auth=strrep(str_auth,'�','``');
str_auth=strrep(str_auth,'�','''''');
str_auth=strrep(str_auth,'�','''''');

str_auth=strrep(str_auth,'�','-');

str_auth=strrep(str_auth,'�','{\ss}');
str_auth=strrep(str_auth,'�','{\o}');

%DEBUG
% if strfind(str_auth,'Milivojevi')
%    s=1;
% end
%END DEBUG

end
