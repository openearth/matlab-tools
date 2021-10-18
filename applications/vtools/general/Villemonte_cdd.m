%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17465 $
%$Date: 2021-08-25 16:36:23 +0200 (Wed, 25 Aug 2021) $
%$Author: chavarri $
%$Id: perpendicular_polyline.m 17465 2021-08-25 14:36:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/perpendicular_polyline.m $
%
%based on <D-Flow_FM_Technical_Reference_Manual.pdf> Version: 1.1.0; SVN Revision: 72877; 27 September 2021

function c_dd=Villemonte_cdd(E1,E2,varargin)


%% parameters

OPT.c1=1; %C 1 is a user-specified calibration coefficient. The Tabellenboek measurements correspond to the default value C 1 = 1,
OPT.c2=10; %C 2 is a user-specified calibration coefficient. It has a default value C 2 = 10, which is the value for hydraulically smooth weirs. For hydraulically rough weirs, the recommended value is C 2 = 50.
OPT.m1=4; %user-specified ramp of the upwind slope toward the weir ratio of ramp length and height, [ ? ], default 4.0
OPT.m2=4; %user-specified ramp of the downwind slope from the weir ratio of ramp length and height [ ? ], default 4.0
OPT.m=1/2; %in Villemonte it is 0.385 but the power of the submergence ratio is different. See <Yossef18> referencing to Ali13
OPT.L=3; %L crest is the length of the weir’s crest [ m ] in the direction across the weir (i.e., in the direction of the flow).
OPT.d1=0; %sill height (distance from bed level to crest height)

OPT=setproperty(OPT,varargin{:});

c1=OPT.c1;
c2=OPT.c2;
m1=OPT.m1;
m2=OPT.m2;
m=OPT.m;
L=OPT.L;

%%

%% CALC

w=exp(-0.5*E1./L);
b3=4/5+13/20*exp(-m2/10);
b2=1-1/4*exp(-m1/2);
b1=w.*b2+(1-w).*b3;
cd0=c1.*b1;

f1=d1./E1;
f2=1-exp(-m2/c2);
a1=1+f1.*f2;
a2=1+f1;
a3=1./a1.^2-1./a2.^2;
p=27/4/cd0^2./a3;

S=E2/E1;
c_dr=(1-S.^p).^m;

%in <D-Flow_FM_Technical_Reference_Manual.pdf> the critical discharge
%is defined as 2/3E*sqrt(2g/3E) but we define it as Cd*2/3*sqrt(2g)E^(3/2)
%they differ by 1/sqrt(3)

c_dm=1/sqrt(3)*cd0;
c_dd=c_dm*c_dr;
    
end %function