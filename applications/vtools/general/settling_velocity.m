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

parse(parin,varargin{:});

ws_flag=parin.Results.ws_flag;

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
        ws=ws_VR(dk,varargin{:});
    otherwise
        error('Inexistent settling velocity number %d',ws_flag)
end %switch

end %function

%%
%% FUNCTIONS
%%

%% VR

function ws_VR(dk,varargin)
   
%        ! Van Rijn
%        if (d50>1.0E-3_hp) then
%           ws = 1.1_hp * (delta * ag *d50)**0.5_hp
%        elseif (d50<=1.0E-3_hp .and. d50>100E-6_hp) then
%           ws = 10.0_hp * vicmol / d50*(sqrt(1.0_hp+(0.01_hp*delta*ag*d50**3/vicmol/vicmol))-1.0_hp)
%        else
%           ws = delta * ag * d50**2/18.0_hp/vicmol
%        endif

end %function

%%

%     elseif (wsform == 2) then
%        ! AHRENS, J. P. (2000). "A fall-velocity equation" Journal of Waterway, Port, Coastal, and Ocean Engineering, ASCE, 126(2), 99-102.
%        archim  = dstar**3
%        ! coefficient for laminar regime
%        Cl = 0.055_hp*tanh((12.0_hp*archim**(-0.59_hp))*(exp(-0.0004_hp*archim)))
%        ! coefficient for turbulent regime
%        Ct = 1.060_hp*tanh((0.016_hp*archim**0.5_hp)*(exp(-120.0_hp/archim)))
%        !
%        ws =(vicmol/d50)*(Cl*archim + Ct*sqrt(archim))
%     elseif (wsform == 3) then
%        ! Ahrnes 2003
%        archim  = dstar**3
%        ! coefficient for laminar regime
%        Cl = 0.055_hp*tanh((12.0_hp*archim**(-0.59_hp))*(exp(-0.0004_hp*archim)))
%        ! coefficient for turbulent regime
%        Ct = 1.010_hp*tanh((0.016_hp*archim**0.5_hp)*(exp(-115.0_hp/archim)))
%        !
%        ws =(vicmol/d50)*(Cl*archim + Ct*sqrt(archim))
