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

nrkm=numel(rkm);
br=cell(nrkm,1);

for krkm=1:nrkm

switch track
    case {'WL','BO','NI','WA'}
        if rkm>960.15
            if do_nibo
                br{krkm}='NI';
            else
                br{krkm}=waal_name;
            end
        elseif rkm>952.85
            if do_nibo
                br{krkm}='BO';
            else
                br{krkm}=waal_name;
            end                
        elseif rkm>867.00
            br{krkm}=waal_name;
        elseif rkm>852.90
            br{krkm}='BR';
        else
            br{krkm}='Rhein';
        end
    otherwise
        error('do')
end

end

end %function