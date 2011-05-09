function cfxconvergence(FOfil)
%CFXCONVERGENCE Convergence plot for CFX simulation
%   CFXCONVERGENCE(FOfil)
%   creates a convergence plot based on the data in 
%   the specified CFX fo-file.

% (c) copyright 1999-2000 H.R.A.Jagers, bert.jagers@wldelft.nl

if ischar(FOfil),
  FOfil=cfx('openfo',FOfil);
end;

if ~isstruct(FOfil),
  error('Invalid CFX fo-file specified.');
end;

data=cfx('read',FOfil,'monitoring point');

threeD=size(data,2)==13;

figure
data(:,1)=(1:size(data,1))';
subplot(3,2,1)
semilogy(data(:,1),data(:,2));
xlabel('iteration \rightarrow');
ylabel('absolute residual source sum \rightarrow');
title('u momentum');

subplot(3,2,2)
semilogy(data(:,1),data(:,3));
xlabel('iteration \rightarrow');
ylabel('absolute residual source sum \rightarrow');
title('v momentum');

if threeD,
  subplot(3,2,3)
  semilogy(data(:,1),data(:,4));
  xlabel('iteration \rightarrow');
  ylabel('absolute residual source sum \rightarrow');
  title('w momentum');
end;

subplot(3,2,4)
semilogy(data(:,1),data(:,4+threeD));
xlabel('iteration \rightarrow');
ylabel('absolute residual source sum \rightarrow');
title('mass');

subplot(3,2,5)
semilogy(data(:,1),data(:,5+threeD));
xlabel('iteration \rightarrow');
ylabel('absolute residual source sum \rightarrow');
title('kinetic energy (k)');

subplot(3,2,6)
semilogy(data(:,1),data(:,6+threeD));
xlabel('iteration \rightarrow');
ylabel('absolute residual source sum \rightarrow');
title('dissipation (\epsilon)');

md_paper('portrait','Convergence rates for CFX simulation:',FOfil.FileName(1:3));