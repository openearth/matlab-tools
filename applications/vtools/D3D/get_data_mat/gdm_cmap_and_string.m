%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function [cmap,cstring,clims]=gdm_cmap_and_string(in_p,val)

%% PARSE

in_p=isfield_default(in_p,'lan','en');
lan=in_p.lan;
in_p=isfield_default(in_p,'frac',NaN);
frac=in_p.frac;
in_p=isfield_default(in_p,'is_diff',0);
is_diff=in_p.is_diff;
in_p=isfield_default(in_p,'is_diff_t',0);
is_diff_t=in_p.is_diff_t;
in_p=isfield_default(in_p,'is_diff_s',0);
is_diff_s=in_p.is_diff_s;
in_p=isfield_default(in_p,'is_std',0);
is_std=in_p.is_std;
in_p=isfield_default(in_p,'is_percentage',0);
is_percentage=in_p.is_percentage;
in_p=isfield_default(in_p,'tol_clims',1e-8);
tol_clims=in_p.tol_clims;
% in_p=isfield_default(in_p,'clims',[NaN,NaN]); %inside do_auto_limit
in_p=isfield_default(in_p,'unit',1);
unit=in_p.unit;
in_p=isfield_default(in_p,'variable','');
variable=in_p.variable;
in_p=isfield_default(in_p,'Lref','+NAP');
Lref=in_p.Lref;
in_p=isfield_default(in_p,'clims',[NaN,NaN]);
clims=in_p.clims;

% v2struct(in_p) %do not use `v2struct` if passing other input. In case
% there is `val` in `in_p`, it gets overwritten. 

if is_std && is_diff
    error('It cannot be both std and diff.')
end

%%

[lab,str_var,str_un,str_diff,str_background,str_std,str_diff_back,str_fil,str_rel,str_perc,str_dom]=labels4all(variable,unit,lan,'frac',frac,'Lref',Lref);

clims_comp=[min(val(:),[],'omitnan'),max(val(:),[],'omitnan')];
if isnan(clims_comp(1)) %still NaN because all are NaN
    clims_comp=[-tol_clims,+tol_clims];
end
if diff(clims_comp)<eps
    clims_comp=clims_comp+[-tol_clims,+tol_clims];
end

if is_diff_t || is_diff
    cstring=str_diff;
    cmap_comp=flipud(brewermap(100,'RdYlBu'));
    clims_comp=absolute_limits(clims_comp);
elseif is_diff_s || is_diff
    cstring=str_diff;
    cmap_comp=flipud(brewermap(100,'RdYlGn'));
    clims_comp=absolute_limits(clims_comp);
elseif is_std
    cstring=str_std;
    cmap_comp=turbo(100);
    clims_comp=absolute_limits(clims_comp);
elseif is_percentage
    cstring=str_perc;
    cmap_comp=turbo(100);
    clims_comp=absolute_limits(clims_comp);
else
    cstring=lab;
    cmap_comp=turbo(100);
end

if do_auto_limit(in_p,'clims')
    clims=clims_comp;
end

if do_auto_limit(in_p,'cmap')
    cmap=cmap_comp;
end

end %function

%%
%%
%%

function do_auto=do_auto_limit(in_p,str)

do_auto=false;
if isfield(in_p,str)==0 
    do_auto=true;
    return
end
if isdatetime(in_p.(str)(1)) 
    if isnat(in_p.(str)(1))
        do_auto=true;
    end
    return
end
if isnan(in_p.(str)(1))    
    do_auto=true;
    return
end

end