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
%Cf=nondimensional friction coefficient such that the bed shear stress is `tau=rho*Cf*u^2`. E.g., Cf=0.01 
%Cn=nondimensional Chezy friction coefficient 
%C=Chezy friction coefficient [m^(1/2)/s]. E.g., C=25

function C_out=convert_friction(conv,C_in,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81,@isnumeric);

parse(parin,varargin{:});

g=parin.Results.g;

%% CALC

switch conv
    case 'C2Cf'
        C_out=g./C_in.^2;
    case 'Cf2C'
        C_out=sqrt(g/C_in);
    case 'Cn2C'
        Cf=convert_friction('Cn2Cf',C_in,varargin{:});
        C_out=convert_friction('Cf2C',Cf,varargin{:});
    case 'Cn2Cf'
        C_out=1./C_in.^2; %Cf=1/Cn^2
    case 'C2Cn'
        C_out=C_in./sqrt(g);
    otherwise
        error('do')
end

end