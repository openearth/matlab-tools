%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19773 $
%$Date: 2024-09-05 16:20:30 +0200 (Thu, 05 Sep 2024) $
%$Author: chavarri $
%$Id: paths_project_layout.m 19773 2024-09-05 14:20:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/paths_project_layout.m $
%
%Analytical solution of Saint-Venant momentum equation when friction 
%dominated.
%
%INPUT:
%   -t = time vector [s]
%   -B = width [m]
%   -u0 = initial velocity [m/s]
%   -h = flow depth [m]
%   -n = Manning coefficient [s/m^(1/3)]
%   -g = acceleration due to gravity [m/s^2]

function u_anl=Saint_Venant_friction_dominated(t,B,u0,t0,h,n,g)

R=B*h/(B+2*h); %hydraulic radius 
Cf=n^2*g/R^(1/3); %non-dimensional friction coefficient
% Ch=sqrt(g/Cf); %chezy value for checking
C=Cf/R;
if u0<0
C=-C; %depending on whether we want positive or negative solution
end
A=1/u0-C*t0;
u_anl=1./(A+C.*t);

end %function