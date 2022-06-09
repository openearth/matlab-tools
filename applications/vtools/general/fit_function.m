%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17536 $
%$Date: 2021-10-29 21:38:05 +0200 (Fri, 29 Oct 2021) $
%$Author: chavarri $
%$Id: fig_Q_analysis_vertical.m 17536 2021-10-29 19:38:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/fig_Q_analysis_vertical.m $
%


function [B,fval,y_fit,fcn]=fit_function(fun,x,y,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'x0',[]);

parse(parin,varargin{:});

x0=parin.Results.x0;

%%
error('see <stat_fit_gumbel> and similar')

switch fun
    case 'lin'
%         error('not sure what happens here but does not work fine')
        fcn = @(b,x) b(1).*x+b(2);
        if isempty(x0)
            x0=ones(1,2);
        end
    case 'exp'
        fcn = @(b,x) b(1).*exp(b(2).*x);
        if isempty(x0)
            x0=ones(1,2);
        end
    otherwise
        error('add')
end

opt=optimset('MaxFunEvals',15000,'MaxIter',10000);
% fcn_min=@(b) norm(y - fcn(b,x));
fcn_min=@(b) sqrt(sum((y - fcn(b,x)).^2)/numel(y));
[B,fval] = fminsearch(fcn_min,x0,opt);

y_fit=fcn(B,x);

%%
% figure
% hold on
% plot(x,y,'-*')
% plot(x,y_fit,'-*')
