%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18780 $
%$Date: 2023-03-09 15:28:47 +0100 (do, 09 mrt 2023) $
%$Author: chavarri $
%$Id: D3D_adapt_time.m 18780 2023-03-09 14:28:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_adapt_time.m $
%
%Wrap around `comp_struc` to give as output the difference between values in
%structure. If all elements in both structures are NaN, it considers there 
%is no difference. It only allows structures with the same fieldnames. 

function [common, d1, d2, d1n]=comp_struct_diff(s1,s2,prt,pse,tol)

%% default arguent check
if nargin < 2
	help comp_struct; error('I / O error');
end

if nargin < 3 || isempty(prt); prt = 0; end
if nargin < 4 || isempty(pse); pse = 0; elseif pse ~= 1 && prt == 0; pse = 0; end
if nargin < 5 || isempty(tol); tol = 1e-20; end
if pse > prt, pse = prt; end

%%

[common, d1, d2] = comp_struct(s1,s2,prt,pse,tol);

%%

d1n=check_nans(d1,d2);

end %function

%%
%% FUNCTION
%%

function dn=check_nans(d1,d2)

if isstruct(d1)
    fn1=fieldnames(d1);
    fn2=fieldnames(d2);
    if ~isempty(setdiff(fn1,fn2))
        error('Different number of structure elements.')
    end
    
    ne=numel(fn1);
    for k1=1:ne
        dn.(fn1{k1})=check_nans(d1.(fn1{k1}),d2.(fn1{k1}));
        if isempty(dn.(fn1{k1}))
            dn=rmfield(dn,fn1{k1});
        end
    end
else
    if all(isnan(d1)) && all(isnan(d2))
        dn=[];
    else
        dn=d1-d2;
    end
end

end %function