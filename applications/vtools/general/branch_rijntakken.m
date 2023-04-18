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
%Branch names of the rijntakken for a given track
%

function br=branch_rijntakken(rkm,track,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'waal','WA');
addOptional(parin,'NI_BO',false);

parse(parin,varargin{:});

waal_name=parin.Results.waal;
do_nibo=parin.Results.NI_BO;

%% CALC

switch track
    case {'WL','BO','NI','WA'}
        if rkm>960.15
            if do_nibo
                br='NI';
            else
                br=waal_name;
            end
        elseif rkm>952.85
            if do_nibo
                br='BO';
            else
                br=waal_name;
            end                
        elseif rkm>867.00
            br=waal_name;
        elseif rkm>852.90
            br='BR';
        else
            br='Rhein';
        end
    otherwise
        error('do')
end

end %function