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
function D3D_write_polys(path_out,stru_in)

% L000005
%           56           2
%    1.9385889E+05   4.4052012E+05
%    1.9380717E+05   4.4048145E+05

fid=fopen(path_out,'w');

npol=numel(stru_in);

for kpol=1:npol
    
    nv=size(stru_in(kpol).xy,1);

    if isa(stru_in(kpol).name,'double')
        fprintf(fid,'L%06d \n',stru_in(kpol).name); 
    elseif isa(stru_in(kpol).name,'char')
        fprintf(fid,'%s \n',stru_in(kpol).name); 
    end
    fprintf(fid,'           %d           2 \n',nv); 
    for kv=1:nv
    fprintf(fid,'    %9.8E   %9.8E \n',stru_in(kpol).xy(kv,1),stru_in(kpol).xy(kv,2)); 
    end

end

fclose(fid);

end %function
