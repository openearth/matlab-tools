  function [alphasAND, betasAND, alphasOR, betasOR] = CombinedProbability(alphasIn,...
      betasIn, rhos, varargin)  
%Hohenbichler routine (combined probability of failure)
%
% function for combining Z-functions (different failure mechanisms)of 
% n elements in Series and Parallel:
%   P(Z2<0 AND Z1<0) = P(Z2<0 && Z1<0) = Parallel system
%   P(Z2<0 OR Z1<0) = P(Z2<0 || Z1<0) = Series system
% and subsequent processing of alphas and betas (i.e. replacing the old 
% values with the new values).

% Z1 and Z2 (Zn) are both described by the same n random variables 
% u1 ... un; however, corresponing u-values of eacg Z are not fully 
% correlated. The mutual correlation is described by random variable rho.

%INPUT--------------------------------------------------------------------
% alphasIn = alphas of all Z-functions (dimension: m * n)
% betasIn  = corresponding betas (dimension: m*1)
% rhos     = correlation coefficients of u-values (dimensions: 1*n)
% (varargin) method   = computational method is 'Numerical'(default) or 'FORM'
%
% m Z-functions and Ne random variables
%
%OUTPUT ------------------------------------------------------------------
% alphasAND = combined alfas for parallel system
% betasAND  = combined beta/reliability for parallel system
% alphasOR  = combined alfas for series system
% betasOR   = combined beta/reliability for series system
%
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% @ Ferdinand Diermanse (Deltares)
% @ Ana Teixeira (Deltares)
%
% Created: xxxxxxxxx
% Created with Matlab version: xxxxxxx
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%


if isempty(varargin)
method='Numerical'; 
else
method=varargin;   
end

  [alphasAND, betasAND] = HohenbichlerMultiElement(alphasIn, betasIn, rhos, 'parallel',method);
  [alphasOR, betasOR] = HohenbichlerMultiElement(alphasIn, betasIn, rhos, 'series',method);

% dimensions
N = size(alphasIn,2);

Results=zeros(4,2);
alphasA=zeros(N,3);

%%

Results(1,1)=betasIn(1);
Results(2,1)=betasIn(2);

Results(1,2)=1-normcdf(betasIn(1),0,1);
Results(2,2)=1-normcdf(betasIn(2),0,1);

Results(3,1)=betasAND; 
Results(4,1)=betasOR;

Results(3,2)=1-normcdf(betasAND,0,1);
Results(4,2)=1-normcdf(betasOR,0,1);

%-----------------------------------------

alphasA(:,1)=(1:N)';
alphasA(:,2)=alphasAND';
alphasA(:,3)=alphasOR';

%%
disp '     ' 
fprintf('Reliability results:\n'); 
disp (method)
fprintf('>---------------- beta    pf \n');  
fprintf('mechanism (1) :');
fprintf('%7.2f  %7.5f', Results(1,:)); 
fprintf('\n'); 
fprintf('mechanism (2) :');
fprintf('%7.2f  %7.5f', Results(2,:)); 
fprintf('\n'); 
disp '     ' 
fprintf('Combined reliability: \n'); 
fprintf('>---------------- beta    pf \n');  
fprintf('  (1) AND (2) :');
fprintf('%7.2f  %7.5f', Results(3,:)); 
fprintf('\n'); 
fprintf('  (1) OR (2)  :');
fprintf('%7.2f  %7.5f', Results(4,:)); 
fprintf('\n'); 
disp '     '

% Reliability results:
% >---------------- beta    pf 
% mechanism (1) :   1.00  1.00000
% mechanism (2) :   1.00  1.00000
%      
% Combined reliability: 
% >---------------- beta    pf 
%   (1) AND (2) :   1.00  1.00000
%   (1) OR (2)  :   1.00  1.00000
% 
% Would you like to see the combined alphas ? (y/n)

ask1 = input('Would you like to see the combined alphas ? (y/n): ', 's');
        if ask1=='y' 
disp '     ' 
fprintf('Combined alphas:\n');  
fprintf('>----ui   Parallel   Series\n');  
fprintf('%7.0f   %7.3f   %7.3f\n', alphasA'); 
        end

  end