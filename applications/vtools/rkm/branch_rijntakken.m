%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19243 $
%$Date: 2023-11-20 11:49:45 +0100 (Mon, 20 Nov 2023) $
%$Author: chavarri $
%$Id: branch_rijntakken.m 19243 2023-11-20 10:49:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/branch_rijntakken.m $
%
%Branch names of the rijntakken for a given track
%

function [br,br_num]=branch_rijntakken(rkm,track,varargin)

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
br_num=NaN(nrkm,1);

for krkm=1:nrkm

    %name
    switch track
        case {'WL','BO','NI','WA'}
            if rkm(krkm)>960.15
                if do_nibo
                    br{krkm}='NI';
                else
                    br{krkm}=waal_name;
                end
            elseif rkm(krkm)>952.85
                if do_nibo
                    br{krkm}='BO';
                else
                    br{krkm}=waal_name;
                end                
            elseif rkm(krkm)>867.00
                br{krkm}=waal_name;
            elseif rkm(krkm)>852.90
                br{krkm}='BR';
            else
                br{krkm}='Rhein';
            end
        case {'IJ','LE','BR','NR','PK','RH'}
            br{krkm}=track;
        otherwise
            error('Unknown branch %s',track)
    end
    
    %number
    br_num(krkm,1)=branch_rijntakken_str2double(br{krkm});

end %rkm

end %function