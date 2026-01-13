function [asR, AR] = meander(s,iR)

[physpar] = getphyspar();
b         = physpar.b;       % Non-linearity of sediment transport model
g         = physpar.g;       % Gravity
karman    = physpar.karman;  % von Karman constant
Sn        = physpar.Sn;      % Transverse slope
chi       = physpar.chi;     % Increase in bed friction parameter
% Eu        = physpar.Eu;
% iS        = physpar.iS;      % Valley slope
% z0        = physpar.ks/30;
H0        = physpar.H0;
B         = physpar.B; 
q0        = physpar.q0;      % Unit discharge
Fr        = q0/H0/sqrt(g*H0);
U0         = q0/H0;
thetcr    = physpar.thetcr;
thet0     = physpar.thet;
specden   = physpar.specden;
relden    = physpar.relden;
D50       = physpar.D50;
Gthet     = 1/physpar.Ashld/thet0.^(physpar.Bshld);
lamdas    = B.^2/pi^2./H0./Gthet;
lamdas    = lamdas(:);
Cfe = physpar.Cf0;

[numpar]   = getnumpar();
CFL        = numpar.asRCFL;
smoothrad  = numpar.smoothrad;
streamcurv = numpar.streamcurv;
bedtype    = numpar.bedtype;
asRacc     = numpar.asRacc;
routyp     = numpar.routyp;
calfac     = numpar.calfac;
rn         = numpar.rn;
maxK       = numpar.maxK;
sweacc     = numpar.sweacc;  % Accuracy cutoff for SWE calculation

%% Initialization
% Make vertical input
% q       = q(:);
% h       = h(:);
% W       = W(:);
% Cfe     = Cfe(:);
iR      = iR(:);
s      = s(:);
N = length(iR);

af     = min(sqrt(Cfe)/karman, 0.5);
fsfn0  = (8*af*exp(-3.3*af^(2/3)));

AeR = H0.*iR/Gthet; 
s2  = s(end) + diff(s(end-1:end));

ds  = diff([s;s2]);

B2b = [0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b;             % First derivative matrix off-left diagonal
B2c = zeros(N,1);
diRds = matprodsol(B2a,B2b,B2c,iR);

lambda_asr = H0./Cfe/2;  %[m]
F_asr_1a = Sn.*Fr.*iR/2 - iR/2;      %[1/m]
%F_asr_1b = AR/2; 
F_asr_2 = - H0./Cfe/2.*diRds;               %[1/m]
F_asr_3 = 4*chi./Cfe.*H0.^2/B.^2.*fsfn0.*iR;  %[1/m ]
F_asr_4 = 0;

lambda_AR = 1./Gthet./H0.*B.^2/pi/pi; %[m]
F_AR_1 = AeR; %[1/m]
%F_AR_2 = (b-1)./Gthet./H0.*B.^2/pi/pi*dasRds; %[1/m]


% (1 + lambda_asr.*dds)            * asR - 1/2                  * AR = F_asr_1a + F_asr_2 + F_asr_3
% - ((b-1)./G./h.*W.^2/pi/pi.*dds) * asR + (1 + lambda_AR.*dds) * AR = F_AR_1;
% 
% %[A11, A12] * [asR]  = R1
% %[A21, A22]   [AR]   = R2
% 
% A = spdiags()

B1b = ones(N,1);        % Identity matrix diagonal
B2b = lambda_asr.*[0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b([2:end,1]);      % First derivative matrix off-left diagonal
A11 = spdiags([B2a, B1b+B2b],-1:0,N,N);

B1b = -1/2*ones(N,1);        % Identity matrix diagonal
B2b = 0.*[0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b([2:end,1]);      % First derivative matrix off-left diagonal
A12 = spdiags([B2a, B1b+B2b],-1:0,N,N);

B1b = 0.*ones(N,1);        % Identity matrix diagonal
B2b = -(b-1)./Gthet./H0.*B.^2/pi/pi.*[0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b([2:end,1]);      % First derivative matrix off-left diagonal
A21 = spdiags([B2a, B1b+B2b],-1:0,N,N);

B1b = ones(N,1);        % Identity matrix diagonal
B2b = lambda_AR.*[0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b([2:end,1]);      % First derivative matrix off-left diagonal
A22 = spdiags([B2a, B1b+B2b],-1:0,N,N);

R1 = F_asr_1a + F_asr_2 + F_asr_3;
R2 = F_AR_1; 

%A = [A11, zeros(size(A12)); zeros(size(A21)), eye(size(A22))];
A = [A11, A12; A21, A22];
R = [R1;R2];
X = inv(A)*R;

output = inv(A)*X;
asR = output(1:N); 
AR = output(N+1:2*N); 

end


