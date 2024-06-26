%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18303 $
%$Date: 2022-08-15 16:11:52 +0200 (ma, 15 aug 2022) $
%$Author: chavarri $
%$Id: twoD_study.m 18303 2022-08-15 14:11:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
%
%Fit a sine to data:
% y = A*sin(B*x + C) + D
%
%INPUT:
%   -x = x-coordinate of data.
%   -y = y-coordinate of data. I.e., f(x).
%
%OUTPUT:
%
%
%E.G.:
% 
% x=linspace(0,2*pi,100);
% y=2*sin(3*x+1)+0.5+0.1*randn(size(x));
% [y_fit,ABCD,y_0,gof]=fit_sine(x,y);
% 
% figure;
% hold on;
% plot(x,y,'bo','MarkerFaceColor','b');
% plot(x, y_fit, 'r-')
% plot(x, y_0, 'g-');
% legend('data','fit','initial guess');
% xlabel('x');
% ylabel('y');
% grid on;
% hold off;

function [y_fit,ABCD,y_0,gof]=fit_sine(x,y,varargin)

%% PARSE

%% CALC

%Initial guess for parameters [A, B, C, D]
yu=max(y);
yl=min(y);
yr=yu-yl; %range of `y`
yz=y-yu+(yr/2);
zx=x(yz.*circshift(yz,1)<=0); %zero-crossings
T=2*mean(diff(zx)); %period
ym=mean(y); %offset

ABCD_0=[yr/2, 2*pi/T, 0, ym];

%Sine function to fit
F_sin=@(p,x)p(1)*sin(p(2)*x+p(3))+p(4);

%Objective function for optimization (sum of squared errors)
F_obj=@(p)sum((y-F_sin(p, x)).^2);

%optimization using fminsearch
options=optimset('display','off');
ABCD=fminsearch(F_obj,ABCD_0,options);

%Goodness of fit (maybe change to `statistics_V`)
y_fit=F_sin(ABCD, x);
residual=y-y_fit;
sse=sum(residual.^2); % Sum of squared errors
rsquare=1-sse/sum((y-mean(y)).^2); % R-square
dfe=length(y)-length(ABCD); % Degrees of freedom
adjrsquare=1-(1-rsquare)*(length(y)-1)/dfe; % Adjusted R-square
rmse=sqrt(sse/dfe); % Root mean squared error

gof.sse = sse;
gof.rsquare = rsquare;
gof.adjrsquare = adjrsquare;
gof.rmse = rmse;

%Initial guess
y_0=F_sin(ABCD_0, x);

end %function