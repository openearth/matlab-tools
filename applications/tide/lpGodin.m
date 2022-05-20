function data = lpGodin(data,times,varargin)

%% Bridge to call the oetsettings function godin_filter
data = godin_filter(data,times,'full',true)';
