function average_trim(source,target,average)
%AVERAGE_TRIM Average fields of a TRIM file
%    AVERAGE_TRIM(TRIM_Source,TRIM_Target)
%    Averages the time dependent data in a TRIM file TRIM_Source and stores
%    the results in a TRIM file called TRIM_Target. The file names may
%    include absolute or relative paths. If the target files exist, they
%    will be overwritten.
%
%    Examples:
%    average_trim('trim-source','trim-target')
%    average_trim('d:\sourcedir\trim-x','p:\targetdir\trim-x')
%
%    AVERAGE_TRIM(TRIM_Source,TRIM_Target,Operation)
%    Uses the specified Operation instead of the default operation for
%    averaging, i.e. 'mean'. Alternative operations are:
%           'std'   : Standard deviation
%           'min'   : Minimum value
%           'max'   : Maximum value
%           'median': Median value
%
%    Notes:
%     * integer data sets (such as thindams) are not averaged. For those
%       data sets, the first field is copied into the new file.
%     * the operation is performed on the individual components of vector
%     quantities. So, for velocities you will obtain std(u) and std(v).

% 2004-09-10: Created by H.R.A. Jagers, WL | Delft Hydraulics

if nargin<3
   average='mean';
end
S=vs_use(source);
T=vs_ini([target,'.dat'],[target,'.def']);

grps={'map-series','map-info-series','map-sed-series','map-infsed-serie','map-rol-series','map-infrol-serie','map-avg-series','map-infavg-serie','map-mor-series','WIND'};
for g=length(grps):-1:1
   Info=vs_disp(S,grps{g},[]);
   if ~isstruct(Info)
      grps(g)=[];
   end
end
%
% copy all fields of non time-dependent groups
%
notgrps=grps;
notgrps(2,:)={[]};
T=vs_copy(S,T,notgrps{:},'quiet');
%
% time-dependent groups: copy only first field
% to be overwritten by average
%
cpgrps=grps;
cpgrps(2,:)={{1}};
T=vs_copy(S,T,'*',[],cpgrps{:},'quiet');
%
% compute averages
%
for g=1:length(grps)
   elms=vs_disp(S,grps{g});
   for e=1:length(elms)
      Info=vs_disp(S,grps{g},elms{e});
      %
      % Only floating point data sets can be averaged
      %
      if Info.TypeVal==5
         Data = vs_let(S,grps{g},elms{e});
         Data = feval(average,Data); % average in first (=time) direction
         T = vs_put(T,grps{g},elms{e},Data);
      end
   end
end