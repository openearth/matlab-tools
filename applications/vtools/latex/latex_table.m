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
%Write LaTeX table
%
%E.G.
%str_num={'%d','%4.3f','%3.2f','%3.2f','%5.4f'};

function latex_table(fpath_tab,mat_w,str_num)

fid=fopen(fpath_tab,'w');
[nl,nc]=size(mat_w);
str_w='';
for kc=1:nc
str_w=strcat(str_w,str_num{kc},' &');
end
str_w(end)='';
str_w=strcat(str_w,' \\\\ \r\n');
for kl=1:nl
fprintf(fid,str_w,mat_w(kl,:));
end
fclose(fid);

end %function