function ensemble_average_trim(varargin)
%ENSEMBLE_AVERAGE_TRIM Ensemble average fields of a TRIM files
%    ENSEMBLE_AVERAGE_TRIM(TRIM_Source1,TRIM_Source2, ... ,TRIM_Target)
%    Averages the time dependent data in a TRIM files TRIM_Source1,
%    TRIM_Source2, etc. and stores the results in a TRIM file called
%    TRIM_Target. The file names may include absolute or relative paths.
%    If the target files exist, they will be overwritten.
%
%    Examples:
%    ensemble_average_trim('trim-source1','trim-source2','trim-source3', ...
%                          'trim-target')
%    ensemble_average_trim('d:\source1\trim-x','d:\source2\trim-x', ...
%                          'd:\source3\trim-x','p:\targetdir\trim-x')
%
%    ENSEMBLE_AVERAGE_TRIM(TRIM_Source1,TRIM_Source2, ... ,TRIM_Target,Operation)
%    Uses the specified Operation instead of the default operation for
%    averaging, i.e. 'mean'. Alternative operations are:
%           'std'   : Standard deviation
%           'min'   : Minimum value
%           'max'   : Maximum value
%           'median': Median value
%
%    Notes:
%     * integer data sets (such as thindams) are not averaged. For those
%       data sets, the data of the first source TRIM file are used.
%     * the operation is performed on the individual components of vector
%       quantities. So, for velocities you will obtain std(u) and std(v).

% 2004-09-10: Created by H.R.A. Jagers, WL | Delft Hydraulics

target=varargin{end};
source=varargin(1:end-1);
try
   %
   % if last argument is a function, it must be an Operation
   %
   dummy=feval(target,magic(8));
   if ~isequal(size(dummy),[1 8])
      error('unexpected transformation result')
   end
   average=target;
   fprintf('Using operation: %s.\n',average)
   target=source{end};
   source=source(1:end-1);
catch
   %
   % no Operation specified
   %
   fprintf('Using standard operation: mean.\n')
   average='mean';
end
T=vs_ini([target,'.dat'],[target,'.def']);

S=vs_use(source{1});

%
% check which time-dependent groups exist in the TRIM file
%
grps={'map-series','map-info-series','map-sed-series','map-infsed-serie','map-rol-series','map-infrol-serie','map-avg-series','map-infavg-serie','map-mor-series'};
for g=length(grps):-1:1
   Info=vs_disp(S,grps{g},[]);
   if ~isstruct(Info)
      grps(g)=[];
   end
end

%
% copy first source TRIM file as basis for target TRIM file
%
T=vs_copy(S,T,'quiet');
%
% open all files
%
S={};
NSrc=length(source);
for i=1:NSrc
   S{i}=vs_use(source{i});
end
%
% For each group ...
%
for g=1:length(grps)
   %
   % Get info about group, especially the number of time steps of the group
   %
   Info=vs_disp(S{1},grps{g},[]);
   Ntim=Info.SizeDim;
   %
   % Get the elements of the group
   %
   elms=vs_disp(S{1},grps{g});
   %
   % For each element
   %
   for e=1:length(elms)
      Info=vs_disp(S{1},grps{g},elms{e});
      %
      % Only floating point data sets can be averaged
      %
      if Info.TypeVal==5
         %
         % For each time step ...
         %
         for t=1:Ntim
            %
            % Preallocate Data arrays to store ensemble
            %
            Data=zeros([NSrc Info.SizeDim]);
            all=repmat({':'},1,length(Info.SizeDim));
            %
            % For each file ...
            %
            for i=1:NSrc
               Data(i,all{:}) = vs_let(S{i},grps{g},{t},elms{e},'quiet');
            end
            Data = feval(average,Data); % average in first (=time) direction
            T = vs_put(T,grps{g},{t},elms{e},Data);
         end
      end
   end
end