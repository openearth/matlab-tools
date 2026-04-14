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

function is_done=D3D_is_done(simdef,varargin)

% Check if simulation finished successfully
is_done = D3D_check_dia_status(simdef, ...
    '*** Simulation finished ***', ...
    '** INFO   : Computation finished at:', ...
    varargin{:});

end %function