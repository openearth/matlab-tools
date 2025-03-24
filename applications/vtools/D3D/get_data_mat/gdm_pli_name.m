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

function pliname=gdm_pli_name(fpath_pli)

if ischar(fpath_pli) %it is a file
    if exist(fpath_pli,'file')~=2
        error('pli file does not exist: %s',fpath_pli);
    end
    [~,pliname,~]=fileparts(fpath_pli);
    pliname=strrep(pliname,' ','_');
else %it is a double
    % str=hash_matrix(fpath_pli);
    str=DataHash(fpath_pli);
    pliname=str(1:6);
end

end %function