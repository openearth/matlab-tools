function L = duffsim(T,dt,z,a,b,alf)
% DUFFSIM Generates a sample path of a harmonic oscillator 
%
% CALL:  L = duffsim(T,dt,z,a,b,alf);
%
%        L   = a three column matrix with time in the first, the simulated 
%              process in the second and the derivative of the simulated 
%              process in the third column.
%        T   = the maximum time.
%        dt  = the time step.
%        z,a = parameters in the equation for the oscillator.
%
%   (b,alf are optional imputs with default values -1,2, respectively)
%         The routine generates a sample path of a harmonic oscillator 
%         with a nonlinear spring, driven by Gaussian white noise (if alf=2) 
%         or alpha-stable white noise (if 0<alf<2). The oscillator is
% 
%           L''(t) + 2zL'(t) + bL(t) + aL(t)^3 = sW'(t),
%
%         where  W'(t)  is a white-noise process, s=2*qrt(z)  and  z,b,a  are 
%         constants. Important parameter values; 0<z<1, a=0, b=1 normalized
%         linear oscillator (Var(L(t))=Var(L'(t))=1); a=b=0, alf=2 then L'(t)
%         is the Ornstein-Uhlenbeck process; a,z>0, b=-1 Duffing oscilator.  
%         The simulation technique is Euler's discretization scheme.

% History: 
% Adapted from WAT. 
% revised jr: 00.05.16
% - updated final loading
% - updated information

if ( (z<=0) | (z>=1) )
  error('   Parameter z not in (0,1).')
end
  
if nargin<5
   b=-1;
end
if nargin<6
   alf=2;
end
if nargin<4
   b=1;
   a=0;
end
N=(floor(T/dt)+1)*100;
 if (N>5000000)
     error('Time step  dt  is too small, break.')
 end   

if exist('simduff.in'), delete simduff.in, end

disp('   Writing data.')
data=[N 0.01*dt z a b alf];
seed=floor(1e8+rand*899999999);
fprintf('simduff.in','%6.0f %7.5f %7.5f %7.5f %7.5f %7.5f\n',data);
fprintf('simduff.in','%10.0f\n',seed);
disp('   Starting Fortran executable.')
dos([wafoexepath 'simduff.exe']);
             
disp('   Loading data.')
L=load('out.dat');
delete simduff.in
