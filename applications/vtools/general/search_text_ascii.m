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

