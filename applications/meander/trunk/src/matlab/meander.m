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
fsfn0  = 0* (8*af*exp(-3.3*af^(2/3)));

AeR = H0.*iR/Gthet; 
s2  = s(end) + diff(s(end-1:end));

ds  = diff([s;s2]);

B2b = [0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b;             % First derivative matrix off-left diagonal
B2c = zeros(N,1);
diRds = matprodsol(B2a,B2b,B2c,iR);

%asr = h./Cfe/2.*dasRds + Sn.*Fr.*iR/2 + AR/2 - iR - h./Cfe/2.*diRds + 4*chi./Cfe/2.*W.^2/pi/pi.*fsfn0.*iR;
%asr - h./Cfe/2.*dasRds - AR/2 = Sn.*Fr.*iR/2 - iR - h./Cfe/2.*diRds + 4*chi./Cfe/2.*W.^2/pi/pi.*fsfn0.*iR;
%(1 - h./Cfe/2.*dds) * asr - 1/2*AR = Sn.*Fr.*iR/2 - iR - h./Cfe/2.*diRds + 4*chi./Cfe/2.*W.^2/pi/pi.*fsfn0.*iR;

%AR + 1./G./h.*W.^2/pi/pi.*dARds = AeR + (b-1)./G./h.*W.^2/pi/pi.*dasRds
%AR + 1./G./h.*W.^2/pi/pi.*dARds - (b-1)./G./h.*W.^2/pi/pi.*dasRds = AeR;
%(1 - 1./G./h.*W.^2/pi/pi.*dds) * AR - ((b-1)./G./h.*W.^2/pi/pi.*dds)*asR = AeR;

% (1 - h./Cfe/2.*dds)              * asR - 1/2                            * AR = Sn.*Fr.*iR/2 - iR - h./Cfe/2.*diRds + 4*chi./Cfe/2.*W.^2/pi/pi.*fsfn0.*iR;
% - ((b-1)./G./h.*W.^2/pi/pi.*dds) * asR + (1 - 1./G./h.*W.^2/pi/pi.*dds) * AR = AeR;
% 
% %[A11, A12] * [asR]  = R1
% %[A21, A22]   [AR]   = R2
% 
% A = spdiags()

B1b = ones(N,1);        % Identity matrix diagonal
B2b = H0./Cfe/2.*[0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b([2:end,1]);      % First derivative matrix off-left diagonal
A11 = spdiags([B2a, B1b+B2b],-1:0,N,N);

B1b = -1/2*ones(N,1);        % Identity matrix diagonal
B2b = 0.*[0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b([2:end,1]);      % First derivative matrix off-left diagonal
A12 = spdiags([B2a, B1b+B2b],-1:0,N,N);

B1b = 0.*ones(N,1);        % Identity matrix diagonal
B2b = (b-1)./Gthet./H0.*B.^2/pi/pi.*[0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b([2:end,1]);      % First derivative matrix off-left diagonal
A21 = spdiags([B2a, B1b+B2b],-1:0,N,N);

B1b = ones(N,1);        % Identity matrix diagonal
B2b = 1./Gthet./H0.*B.^2/pi/pi.*[0;1./ds(2:N)];   % First derivative matrix diagonal
B2a = -B2b([2:end,1]);      % First derivative matrix off-left diagonal
A22 = spdiags([B2a, B1b+B2b],-1:0,N,N);

R1 = Sn.*Fr.*iR/2 - iR - H0./Cfe/2.*diRds + 4*chi./Cfe/2.*B.^2/pi/pi.*fsfn0.*iR;
R2 = AeR; 

%A = [A11, zeros(size(A12)); zeros(size(A21)), eye(size(A22))];
A = [A11, A12; A21, A22];
R = [R1;R2];
X = inv(A)*R;

output = inv(A)*X;
asR = output(1:N); 
AR = output(N+1:2*N); 

end


