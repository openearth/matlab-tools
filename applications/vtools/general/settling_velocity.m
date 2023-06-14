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
%compute settling velocity according to Ferguson, R. & Church, M. (2004),
%A Simple Universal Equation for Grain Settling Velocity, Journal of Sedimentary Research, 
%74, 933-937

function ws=settling_velocity(dk,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ws_flag',1,@isnumeric);
% parin.KeepUnmatched = true;
addOptional(parin,'wsform',NaN);
addOptional(parin,'dstar',NaN);

parse(parin,varargin{:});

ws_flag=parin.Results.ws_flag;
wsform=parin.Results.wsform;
dstar=parin.Results.dstar;

%% INPUT

R=1.65;
g=9.81;
c1=20;
c2=1.1;
nu=1e-6;

%% CALC

switch ws_flag
    case 1
        ws=R.*g.*dk.^2/(c1.*nu+sqrt(0.75.*c2.*R.*g.*dk.^3));
    case 2
        ws=ws_VR(dk,wsform,dstar);
    otherwise
        error('Inexistent settling velocity number %d',ws_flag)
end %switch

end %function

%%
%% FUNCTIONS
%%

%% VR

function ws = ws_VR(dk,wsform,dstar)

R=1.65;
g=9.81;
nu=1e-6;

switch wsform
   case 1 %Van Rijn
       for i = 1:length(dk)
           ws = zeros(1,length(dk));
           if (dk(i)>1.0E-3)
              ws(i) = 1.1 * (R*g*dk(i))^0.5;
           elseif (dk(i)<=1.0E-3 && dk(i)>100E-6)
              ws(i) = 10.0 * nu / dk(i)*(sqrt(1.0+(0.01*R*g*dk(i)^3/nu/nu))-1.0);
           else
              ws(i) = R * g * dk(i)^2/18.0/nu;
           end
       end
   case 2 %AHRENS, J. P. (2000). "A fall-velocity equation" Journal of Waterway, Port, Coastal, and Ocean Engineering, ASCE, 126(2), 99-102.
       archim  = dstar.^3;
       Cl = 0.055*tanh((12.0*archim.^(-0.59)).*(exp(-0.0004*archim))); % coefficient for laminar regime
       Ct = 1.060*tanh((0.016*archim.^0.5).*(exp(-120.0./archim))); % coefficient for turbulent regime
       ws =(nu./dk).*(Cl.*archim + Ct.*sqrt(archim));
   case 3 %Ahrens 2003
       archim  = dstar.^3;
       Cl = 0.055*tanh((12.0*archim.^(-0.59)).*(exp(-0.0004*archim))); % coefficient for laminar regime
       Ct = 1.010*tanh((0.016*archim.^0.5).*(exp(-115.0./archim))); % coefficient for turbulent regime
       ws =(nu./dk).*(Cl.*archim + Ct.*sqrt(archim));
   otherwise
       error('Settling velocity method %d does not exist',wsform)
end %switch
end %function
