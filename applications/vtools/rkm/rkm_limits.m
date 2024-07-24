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

function rkm=rkm_limits(tag)

switch lower(tag)
    case {'borgharen-linne','bl'}
        rkm=[15,69];
    case {'linne-roermond','lr'}
        rkm=[68,81];
    case {'roermond-belfeld','rb'}
        rkm=[79,101];
    case {'belfeld-sambeek','bs'}
        rkm=[101,148];
    case {'sambeek-grave','sg'}
        rkm=[146,176];
    case {'grave-lith','gl'}
        rkm=[175,202];
    case {'lith-keizersveer','lk'}
        rkm=[200,249];
    otherwise
        error('No known branch %s',tag);
end %switch

end %function