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
%Check D3D diagnostic file for specific status strings

function status_found = D3D_check_dia_status(simdef, search_str_case1, search_str_case2, varargin)
% Check if specific strings appear in D3D diagnostic file
%
% Inputs:
%   simdef          - Simulation definition structure
%   search_str_case1 - String to search for when structure == 1
%   search_str_case2 - String to search for when structure == 2
%
% Output:
%   status_found - true if string found, false otherwise

% simdef = D3D_simpath(simdef);

% Determine search string based on structure
switch simdef.D3D.structure
    case 1
        search_str = search_str_case1;
    case 2
        search_str = search_str_case2;
end

% Efficient search using shared utility function
kl = D3D_search_dia(simdef.file.dia, search_str);

status_found = true;
if numel(kl) > 1
    messageOut(NaN, sprintf('Simulation run more than once: %s', simdef.D3D.dire_sim));
    kl = kl(end);
end
if isempty(kl) || isnan(kl)
    status_found = false;
end

end %function
