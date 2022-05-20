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

function [vpara,vperp]=project_vector(veast,vnorth,angle_track)

angle_track=reshape(angle_track,1,[]);
nat=numel(angle_track);
[sveast_1,sveast_2]=size(veast);
[svnorth_1,svnorth_2]=size(vnorth);
if sveast_2~=nat && sveast_1==nat
    veast=veast';
elseif sveast_1~=nat && sveast_2~=nat
    error('one of the sizes of ''veast'' should match the length of ''angle_track''')
end
if svnorth_2~=nat && svnorth_1==nat
    vnorth=vnorth';
elseif svnorth_1~=nat && svnorth_2~=nat
    error('one of the sizes of ''vnorth'' should match the length of ''angle_track''')
end

vpara=cos(angle_track).*veast+sin(angle_track).*vnorth;
vperp=sin(angle_track).*veast-cos(angle_track).*vnorth;
