%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: absolute_limits.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absolute_limits.m $
%
%labels
%
%INPUT
%   -var: variable to generate label
%       -'eta': bed elevation
%
%   -un: factor for unit conversion from SI
%   -lan: language
%       -'en': english
%       -'nl': dutch
%       -'es': Spanisch

function lab=labels4all(var,un,lan)

%% Names
switch var

    %% Some general names
    case 'meas'
        switch lan
            case 'en'
                str_var='Measurement ';
            case 'nl'
                str_var='Meting ';
            case 'es'
                str_var='Medición ';
        end
        un_type=-1; %[none]
    case 'sim'
        switch lan
            case 'en'
                str_var='Simulation ';
            case 'nl'
                str_var='Berekening ';
            case 'es'
                str_var='Cálculo ';
        end
        un_type=-1; %[none]
    case 'date'
        switch lan
            case 'en'
                str_var='Date ';
            case 'nl'
                str_var='Datum ';
            case 'es'
                str_var='Fecha ';
        end
        un_type=-1; %[none]
     case 'dist'
        switch lan
            case 'en'
                str_var='distance';
            case 'nl'
                str_var='afstand';
            case 'es'
                str_var='distancia';
        end
        un_type=1; %[L]
    case 'dist_prof'
        switch lan
            case 'en'
                str_var='Thalweg distance';
            case 'nl'
                str_var='Afstand langs meetraai';
            case 'es'
                str_var='Distancia transversal sección';
        end
        un_type=1; %[L]

    %% Parameters
    case 'eta'
        switch lan
            case 'en'
                str_var='elevation';
            case 'nl'
                str_var='hoogte';
            case 'es'
                str_var='altura';
        end
        un_type=1; %[L]
    case 'etaw'
        switch lan
            case 'en'
                str_var='water level';
            case 'nl'
                str_var='waterstand';
            case 'es'
                str_var='nivel del agua';
        end
        un_type=1; %[L]
    case 'h'
        switch lan
            case 'en'
                str_var='depth';
            case 'nl'
                str_var='diepte';
            case 'es'
                str_var='profundidad';
        end
        un_type=1; %[L]
    case 'sal'
        switch lan
            case 'en'
                str_var='Salinity';
            case 'nl'
                str_var='Saliniteit';
            case 'es'
                str_var='Salinidad';
        end
        un_type=2; %[sal]
        case 'chl'
        switch lan
            case 'en'
                str_var='Chlorinity';
            case 'nl'
                str_var='Chloride';
            case 'es'
                str_var='Cloruro';
        end
        un_type=3; %[chl]
         case 'tem'
        switch lan
            case 'en'
                str_var='Temperature';
            case 'nl'
                str_var='Temperatuur';
            case 'es'
                str_var='Temperatura';
        end
        un_type=4; %[oC]
end %var

%% Units
switch un_type
    case 1
        switch un
            case 1
                str_un=' [m]';
            case 1/1000
                str_un=' [km]';
        end
    case 2
        str_un= ' [psu]';
    case 3
        str_un= ' [mg/l]';
    case 4
        str_un= ' [^oC]';
    otherwise
        str_un= '';
end %un_type

%% Names and units combined
lab= [str_var,str_un];

end %function
