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
        case {'IJ'}
		    if rkm(krkm)>878.05
                br{krkm}='IJ';
            elseif rkm(krkm)>867.05
                br{krkm}='PK';
            elseif rkm(krkm)>852.90
                br{krkm}='BR';
            else
                br{krkm}='Rhein';
            end
		case {'LE','NR'}
            if rkm(krkm)>929.35
                br{krkm}='LE';
            elseif rkm(krkm)>878.08
                br{krkm}='NR';
            elseif rkm(krkm)>867.05
                br{krkm}='PK';
            elseif rkm(krkm)>852.90
                br{krkm}='BR';
            else
                br{krkm}='Rhein';
            end
        case {'PK'}
            if rkm(krkm)>878.05
                error('Branch PK is given, but the river kilometre is larger than the end value of PK (878.05): %f',rkm(krkm))
            elseif rkm(krkm)<867.05
                error('Branch PK is given, but the river kilometre is smaller than the begin value of PK (867.05): %f',rkm(krkm))
            else
                br{krkm}=track;
            end
        case {'BR','RH'}
            br{krkm}=track;
        otherwise
            error('Unknown branch %s',track)
    end
    
    %number
    br_num(krkm,1)=branch_rijntakken_str2double(br{krkm});

end %rkm

end %function