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

function rkm_file=gdm_read_rkm_file(fpath_rkm)
fid=fopen(fpath_rkm,'r');
rkm_file=textscan(fid,'%f %f %s %f','headerlines',1,'delimiter',',');
fclose(fid);
rkm_file{1,3}=cellfun(@(X)strrep(X,'_','\_'),rkm_file{1,3},'UniformOutput',false);
end %function