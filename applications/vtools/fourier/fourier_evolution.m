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

function [Q,Q_rec]=fourier_evolution(x,y,t,P2,R,omega,dim_ini,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'full',1);

parse(parin,varargin{:});

do_full=parin.Results.full;

%% domain

[dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y);
[x_in,y_in]=meshgrid(x,y);

ne=size(R,1);
nx=numel(x);
ny=numel(y);
nt=numel(t);
nmx=numel(fx2);
nmy=numel(fy2);

%% evol

%% reconstruction of Q

if do_full
    Q=NaN(ne,nx,ny,nt,nmx,nmy);
else
    Q=NaN;
    Q_rec=zeros(ne,nx,ny,nt);
end

for kmx=1:nmx
    for kmy=1:nmy
        kx_fou=2*pi*fx2(kmx);
        ky_fou=2*pi*fy2(kmy);
        cx_fou=P2(kmy,kmx);
        
%         d=[0;0;0;cx_fou]; 
        d=zeros(ne,1);
        d(dim_ini)=cx_fou;
        
        a=R(:,:,kmx,kmy)\d;

        for kt=1:nt
            b=NaN(ne,1);
            for ke=1:ne
                b(ke)=a(ke)*exp(-1i*omega(ke,kmx,kmy)*t(kt));
            end
            c=R(:,:,kmx,kmy)*b;
            for ky=1:ny
                e=real(c*exp(1i*kx_fou*x_in(ky,:)).*exp(1i*ky_fou*y_in(ky,:)));
                if do_full
                    Q(:,:,ky,kt,kmx,kmy)=e;
                else
                    Q_rec(:,:,ky,kt)=Q_rec(:,:,ky,kt)+e;
                end
            end
        end
    end
    fprintf('mode %4.2f %% \n',kmx/nmx*100);
end

if do_full
    Q_rec=sum(Q,[5,6]);
end
