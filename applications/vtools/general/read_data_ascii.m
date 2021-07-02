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

function data=read_data_ascii(path_ascii,tok_find,kl_start)

npreall=1000; %make varargin

data=cell(npreall,1);
fid=fopen(path_ascii,'r');

kl=0;
kld=0;
while ~feof(fid)
    kl=kl+1;
    fline=fgetl(fid);
    if kl>kl_start
        tok=regexp(fline,tok_find,'tokens');
        if isempty(tok)
            data=data(1:kld);
            fclose(fid);
            return
        else
            kld=kld+1;
            data{kld,1}=tok;
            if size(data,1)==kld
                data=cat(1,data,cell(npreall,1));
            end %preall
        end %bol
    end %kl<kl_start
end %~feof(fid)

end %function

