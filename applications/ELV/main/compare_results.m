%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 137 $
%$Date: 2017-07-20 09:50:06 +0200 (Thu, 20 Jul 2017) $
%$Author: V $
%$Id: compare_results.m 137 2017-07-20 07:50:06Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/compare_results.m $
%
%compare_results compares 2 output file. 0 means they are the same
%
%[equal_bol_t,equal_bol,dif_idx,dif_res,dif_max,diff_time]=compare_results(output_ref,output_chk,var)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%170207
%   -V. Created for the first time.
%
function [equal_bol_t,equal_bol,dif_idx,dif_res,dif_max,diff_time,diff_time_rel]=compare_results(output_ref,output_chk,var)

% output_ref=load('d:\checkouts\ELV\test\reference\002\output.mat');
% output_chk=load('d:\checkouts\ELV\test\reference\003\output.mat');
% 
% var={'u','h','etab','Mak','La','msk','Ls','qbk','Cf','ell_idx'}; %variables name to output; 

output_ref=load(output_ref);
output_chk=load(output_chk);

tol=1e-8;

nv=numel(var);
dif_idx=cell(nv,1);
dif_res=cell(nv,1);
equal_bol=true(nv,1);
dif_max=NaN(nv,1);

for kv=1:nv
    dif_res{kv,1}=output_ref.(var{kv})-output_chk.(var{kv});
    dif_lidx=find(abs(dif_res{kv,1})>tol);
    dif_idx{kv,1}=ind2sub(size(dif_lidx),dif_lidx);
    equal_bol(kv,1)=~isempty(dif_idx{kv,1});
    dif_max(kv,1)=max(max(max(max(abs(dif_res{kv,1})))));
end

equal_bol_t=any(equal_bol);

%time
if isfield(output_ref,'time_loop') && isfield(output_chk,'time_loop')
    time_ref=sum(output_ref.time_loop);
    time_chk=sum(output_chk.time_loop);
else
    time_ref=NaN;
    time_chk=NaN;
end

diff_time=time_chk-time_ref;
diff_time_rel=(time_chk-time_ref)/time_ref;


