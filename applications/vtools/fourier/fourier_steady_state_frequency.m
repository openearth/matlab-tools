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
%Compute the Fourier coefficients of a steady-state solution for `ne-1`
%eignevalues given the perturbation in one dimension. 

function [Q,Q_rec,P2all]=fourier_steady_state_frequency(fx2,fy2,x_in,y_in,P2,dim_ini,M,R,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'full',1);
addOptional(parin,'reconstruct',1);

parse(parin,varargin{:});

do_full=parin.Results.full;
do_rec=parin.Results.reconstruct;

%% CALC

%% dimensions

ne=size(R,1);
nt=1; kt=1;
nmx=numel(fx2);
nmy=numel(fy2);
[ny,nx]=size(x_in);

%preallocate
Q=NaN;
Q_rec=NaN;
if do_rec
    if do_full
        Q=NaN(ne,nx,ny,nt,nmx,nmy); %getting information for each mode, much more memory required
    else
        Q_rec=zeros(ne,nx,ny,nt); %already summing up the modes
    end
end

P2all=NaN(ne,nmy,nmx);

dim_steady=1:1:ne;
dim_steady(dim_ini)=[];

%% loop

for kmx=1:nmx
    for kmy=1:nmy
        kx_fou=2*pi*fx2(kmx);
        ky_fou=2*pi*fy2(kmy);
        cx_fou=P2(kmy,kmx);

        M_flow=M(dim_steady,dim_steady,kmx,kmy);
        M_force=M(dim_steady,dim_ini);
        b=-M_force.*cx_fou;
        c=M_flow\b;

        % [M,R,~,~,omega]=ECT_M(pert_anl,kx_fou,ky_fou,Dx,Dy,C,Ax,Ay,B,M_pmm);
        % M_flow=M(1:3,1:3);
        % M_force=M(1:3,4);
        % b=-M_force.*cx_fou;
        % c=M_flow\b;
    
        %save fourier coefficients
        P2all(dim_steady,kmy,kmx)=c;
        P2all(dim_ini,kmy,kmx)=cx_fou;

        if do_rec
            for ky=1:ny
                e=real(c*exp(1i*kx_fou*x_in(ky,:)).*exp(1i*ky_fou*y_in(ky,:)));
                if do_full
                    Q(:,:,ky,kt,kmx,kmy)=e;
                else
                    Q_rec(:,:,ky,kt)=Q_rec(:,:,ky,kt)+e;
                end
            end %ky
        end
    end %kmy
end %kmx

if do_full && do_rec
    Q_rec=sum(Q,[5,6]);
end

end %function