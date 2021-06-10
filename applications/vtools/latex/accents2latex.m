%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
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
