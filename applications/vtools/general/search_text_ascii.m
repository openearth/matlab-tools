%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17345 $
%$Date: 2021-06-11 11:16:16 +0200 (Fri, 11 Jun 2021) $
%$Author: chavarri $
%$Id: file_in_cell_io.m 17345 2021-06-11 09:16:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/file_in_cell_io.m $
%
%find the line in an ascii file starting from a certain one that has certain text on it

function kl_tok=search_text_ascii(path_ascii,tok_find,kl_start)

fid=fopen(path_ascii,'r');

kl=0;
kl_tok=NaN;
while ~feof(fid)
    kl=kl+1;
    fline=fgetl(fid);
    if kl>kl_start
        bol=contains(fline,tok_find);
        if bol
            kl_tok=kl;
            fclose(fid);
            return
        end %bol
    end %kl<kl_start
end %~feof(fid)

end %function

