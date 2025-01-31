%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18312 $
%$Date: 2022-08-19 08:16:54 +0200 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: fourier_eigenvalues.m 18312 2022-08-19 06:16:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/fourier/fourier_eigenvalues.m $
%
%Compute evolution of fourier coefficients for given frequencies.

function [Q,Q_rec]=fourier_evolution_frequency(fx2,fy2,x_in,y_in,t,P2,R,omega,dim_ini,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'full',1);

parse(parin,varargin{:});

do_full=parin.Results.full;

%% SIZE

ne=size(R,1);
[ny,nx]=size(x_in);
nt=numel(t);
nmx=numel(fx2);
nmy=numel(fy2);

%% evolution

%preallocate
if do_full
    Q=NaN(ne,nx,ny,nt,nmx,nmy); %getting information for each mode, much more memory required
else
    Q=NaN;
    Q_rec=zeros(ne,nx,ny,nt); %already summing up the modes
end

%loop
for kmx=1:nmx
    for kmy=1:nmy
        kx_fou=2*pi*fx2(kmx);
        ky_fou=2*pi*fy2(kmy);
        
        if ismatrix(P2)
            d=zeros(ne,1);
            d(dim_ini)=P2(kmy,kmx);
        else
            d=P2(:,kmy,kmx);
        end

        a=R(:,:,kmx,kmy)\d;

        for kt=1:nt
            b=NaN(ne,1);
            for ke=1:ne
                b(ke)=a(ke)*exp(-1i*omega(ke,kmx,kmy)*t(kt));
            end %ke
            c=R(:,:,kmx,kmy)*b;
            for ky=1:ny
                e=real(c*exp(1i*kx_fou*x_in(ky,:)).*exp(1i*ky_fou*y_in(ky,:)));
                if do_full
                    Q(:,:,ky,kt,kmx,kmy)=e;
                else
                    Q_rec(:,:,ky,kt)=Q_rec(:,:,ky,kt)+e;
                end
            end %ky
        end %kt
    end %kmy
    fprintf('mode %4.2f %% \n',kmx/nmx*100);
end %kmx

if do_full
    Q_rec=sum(Q,[5,6]);
end

end %function