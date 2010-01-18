function [xInitial,zInitial,D50,WL_t,Hsig_t,Tp_t] = DUROSCheckConditions(xInitial,zInitial,D50,WL_t,Hsig_t,Tp_t)

%% Check whether D50, WL_t, Hsig_t and Tp_t are numeric, non-empty and
%% non-nan
checkconditions(D50, WL_t, Hsig_t, Tp_t)

%% Check WL
% check min / max waterlevel
decdigs = 8; % number of decimal digits to round the water level
if WL_t ~= roundoff(WL_t, decdigs)
    WL_t = roundoff(WL_t, decdigs);
    writemessage(-9, ['Water level has been rounded to ' num2str(decdigs) ' decimal digits.']);
end

%%
n_d = DuneErosionSettings('get', 'n_d');
Plus = DuneErosionSettings('get', 'Plus');
TP12slimiter = DuneErosionSettings('get', 'TP12slimiter');

if (strcmp(Plus,'-plus') || strcmp(Plus,'-plusplus')) && TP12slimiter
    if Tp_t < 12*sqrt(n_d)^-1
        Tpold=Tp_t;
        Tp_t = 12*sqrt(n_d)^-1;
        writemessage(-2, ['Parabolic shape is based on Tp_t = ' num2str(Tp_t) ' s, instead of ',num2str(Tpold,'%.2f'),' s']);
    elseif Tp_t > 20*sqrt(n_d)^-1
        Tpold=Tp_t;
        Tp_t = 20*sqrt(n_d)^-1;
        writemessage(-2, ['Parabolic shape is based on Tp_t = ' num2str(Tp_t) ' s, instead of ',num2str(Tpold,'%.2f'),' s']);
    end
end

%% Check profile
if ~isnumeric(xInitial)
    writemessage(-11, 'Input profile (c) is not a valid array.');
    xInitial = false;
    warning('DUROSCHECKCONDITIONS:notnumeric', 'xInitial must be numeric');
elseif isempty(xInitial)
    writemessage(-11, 'Input profile (x) is empty.');
    xInitial = false;
    warning('DUROSCHECKCONDITIONS:empty', 'xInitial must be non-empty');
end
if ~isnumeric(zInitial)
    writemessage(-11, 'Input profile (z) is not a valid array.');
    xInitial = false;
    warning('DUROSCHECKCONDITIONS:notnumeric', 'zInitial must be numeric');
elseif isempty(zInitial)
    writemessage(-11, 'Input profile (z) is empty.');
    xInitial = false;
    warning('DUROSCHECKCONDITIONS:empty', 'zInitial must be non-empty');
end

% check whether information is available above the waterline
if max(zInitial) < WL_t
    writemessage(-10, 'Water level exceeds the maximum profile height.');
    xInitial = false;
    warning('DUROSCHECKCONDITIONS:lowprofile', 'There is no part of the profile above the specified water level. Please check your input');
    return;
end

% remove nan values
nanid = isnan(zInitial) | isnan(xInitial);
xInitial(nanid) = []; 
zInitial(nanid) = [];

% make sure that profile is expressed as column vectors
if issorted(size(xInitial))
    xInitial = xInitial';
end
if issorted(size(zInitial))
    zInitial = zInitial';
end

%{
% optional: make sure that profile is positive seaward
[xInitial zInitial] = checkCrossShoreProfile(xInitial, zInitial,...
    'x_direction', -1);
%}

%% Check additional volume formulation
try
    Volume = -100; %#ok<NASGU>
    TargetVolume = eval(DuneErosionSettings('AdditionalVolume')); %#ok<NASGU>
catch %#ok<CTCH>
    error('DUROSCHECKCONDITIONS:additionalvolume', 'The specification of the additional volume calculation appears to be incorrect.');
end

%%
function checkconditions(varargin)
% sub-function to check whether all input arguments are numeric, non-empty
% and non-nan, otherwise error will be given
for iarg = 1:length(varargin)
    if ~isnumeric(varargin{iarg})
        error('DUROSCHECKCONDITIONS:notnumeric', [inputname(iarg) ' must be numeric']);
    elseif isempty(varargin{iarg})
        error('DUROSCHECKCONDITIONS:empty', [inputname(iarg) ' must be non-empty']);
    elseif isnan(varargin{iarg})
        error('DUROSCHECKCONDITIONS:NaN', [inputname(iarg) ' must be non-NaN']);
    end
end
