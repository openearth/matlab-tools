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

function lab=labels4all(var,un,lan)

switch var
    case 'eta'
        switch lan
            case 'en'
                str_var='elevation';
            case 'nl'
                error('write')
        end
        un_type=1; %[L]
    case 'dist'
        switch lan
            case 'en'
                str_var='distance';
            case 'nl'
                str_var='afstand';
        end
        un_type=1; %[L] 
    case 'dist_prof'
        switch lan
            case 'en'
                str_var='distance along section';
            case 'nl'
                str_var='afstand langs gevaren track';
        end
        un_type=1; %[L] 
    case 'etaw'
        switch lan
            case 'en'
                str_var='water level';
            case 'nl'
                str_var='waterstand';
        end
        un_type=1; %[L] 
    case 'h'
        switch lan
            case 'en'
                str_var='depth';
            case 'nl'
                str_var='diepte';
        end
        un_type=1; %[L]
end %var

switch un_type
    case 1
        switch un
            case 1
                str_un=' [m]';
            case 1/1000
                str_un=' [km]';
        end
end %un_type
        
lab=strcat(str_var,str_un);

end %function