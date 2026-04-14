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

function is_interr=D3D_is_interrupt(simdef,varargin)

% Check if simulation was interrupted
is_interr = D3D_check_dia_status(simdef, ...
    '*** ERROR Flow exited abnormally', ...
    '** INFO   : Simulation did not reach stop time', ...
    varargin{:});

end %function