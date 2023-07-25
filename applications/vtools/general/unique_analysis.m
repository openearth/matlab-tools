%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18952 $
%$Date: 2023-05-22 16:55:45 +0200 (Mon, 22 May 2023) $
%$Author: chavarri $
%$Id: figure_layout.m 18952 2023-05-22 14:55:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
%
%Compute the mean and standard deviation of a given variable `y` according
%to the indices in matrix `mat`. The variable of the first columns of `mat`
%is used as the `x` vector for analysis. Variable `mat_out` contains the
%unique indices of each of the cases without consideting the first column.
%
%Usually, `y` is a certain variable (e.g., computational time) of a series 
%of `nu` simulations. Matrix `mat` contains the variations of the 
%simulations. E.g., `mat(:,1)` contains the number of size fractions of 
%each simulation, `mat(:,2)` contains the sediment transport relation, etc. 
%For each unique set of parameters, the mean of duration time and standard 
%deviation is computed and ordered as a function of the number of size
%fractions.

function [x,y_mean,y_std,y_mean_rel,y_std_rel,mat_out]=unique_analysis(mat,y)

%% PARSE

if numel(y)~=size(mat,1)
    error('The number of cases is different in the vector with results than in the input matrix with indices')
end

%% CALC

mat_u=unique(mat,'rows'); %unique cases

nu=size(mat_u,1); %number of cases

%preallocate
%y_aux:
% rows = cases
% col 1 = mean
% col 2 = std
%
if isduration(y(1))
    y_aux=NaT(nu,2)-NaT; 
elseif isdatetime(y(1))
    y_aux=NaT(nu,2);
else
    y_aux=NaN(nu,2);
end

%compute mean and std
for ku=1:nu
    bol_g=ismember(mat,mat_u(ku,:),'rows');
    y_aux(ku,1)=mean(y(bol_g));
    y_aux(ku,2)=std(y(bol_g));
end

mat_out=unique(mat(:,2:end),'rows'); %for varying number of fractions
nu=size(mat_out,1);
x=cell(nu,1);
y_mean=cell(nu,1);
y_std=cell(nu,1);
for ku=1:nu
    bol_g=ismember(mat_u(:,2:end),mat_out(ku,:),'rows');
    x{ku}=mat_u(bol_g); %fractions vector (all should be the same)
    y_mean{ku}=y_aux(bol_g,1);
    y_std{ku}=y_aux(bol_g,2);

    %relative
    y_mean_rel{ku}=(y_mean{ku}-y_mean{ku}(1))./y_mean{ku}(1)*100;
%     y_std_rel{ku}=(y_std{ku}-y_std{ku}(1))./y_std{ku}(1)*100;
    y_std_rel{ku}=[];
end
