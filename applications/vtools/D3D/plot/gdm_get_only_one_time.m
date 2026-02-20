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
%

function data=gdm_get_only_one_time(data,time_dnum,tol_t,fn)

nt=numel(data.times);
if nt==0 
    error('No time found in data');
end
if any(isnan(data.times))
    error('Cannot select time when NaN times are present');
end
if nt==1
    return; %nothing to do
end

%from here down, we have more than one time an no NaN
if isduration(tol_t)
    tol_t_num=days(tol_t);
else
    tol_t_num=tol_t;
end
messageOut(NaN,sprintf('More than one time for tolerance %f days found. Selecting closest.',tol_t_num));

%find index of time to keep
[~,kt]=min(abs(data.times-time_dnum));

%fields to check
for kf=1:numel(fn)
    if isfield(data,fn{kf})
        data.(fn{kf})=data.(fn{kf})(kt,:,:,:,:,:,:); %be sure to keep all dimensions after time. Not very beautiful but works. 
    end
end

end %function