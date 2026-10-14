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
%n=Manning's roughness coefficient [s/m^(1/3)]. E.g., n=0.03

function C_out=convert_friction(conv,C_in,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81,@isnumeric);
addOptional(parin,'h',1,@isnumeric);

parse(parin,varargin{:});

g=parin.Results.g;
h=parin.Results.h;

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
    case 'n2Cf'
        n=C_in;
        C_out=n^2*g/h^(1/3);
    case 'n2C'
        n=C_in;
        C_out=convert_friction('n2Cf',n,varargin{:});
        C_out=convert_friction('Cf2C',C_out,varargin{:});
    otherwise
        error('do')
end

end