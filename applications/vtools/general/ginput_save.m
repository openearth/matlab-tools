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
%

function xy=ginput_save(ni)

[x,y]=ginput(ni);
xy=[x,y];
fpath_save=fullfile(pwd,sprintf('xy_%s',now_chr));
save(fpath_save,'xy');

end
