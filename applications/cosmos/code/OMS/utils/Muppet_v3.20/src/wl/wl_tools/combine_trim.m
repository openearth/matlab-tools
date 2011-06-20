function combine_trim(varargin)
%COMBINE_TRIM Combine TRIM files
%    COMBINE_TRIM(TRIM_Source1,TRIM_Source2, ..., TRIM_Target)
%    Combines the data in TRIM files TRIM_Source1,TRIM_Source2, etc. into
%    one TRIM file called TRIM_Target. The file name may include absolute
%    or relative paths. If the target files exist, they will be
%    overwritten.
%
%    Examples:
%    combine_trim('trim-1','trim-2','trim-3','trim-4','trim-target')
%    combine_trim('subdir1\trim-x','subdir2\trim-x','trim-target')

% 2004-09-10: Created by H.R.A. Jagers, WL | Delft Hydraulics

target=varargin{end};
T=vs_ini([target,'.dat'],[target,'.def']);

source=varargin(1:end-1);
for i=1:length(source)
   S=vs_use(source{i});
   if i==1
      T=vs_copy(S,T,'quiet');
   else
      grps={'map-series','map-info-series','map-sed-series','map-infsed-serie','map-rol-series','map-infrol-serie','map-avg-series','map-infavg-serie','map-mor-series','WIND'};
      for g=length(grps):-1:1
         Info=vs_disp(S,grps{g},[]);
         if ~isstruct(Info)
            grps(g)=[];
         end
      end
      if ~isempty(grps)
         T=vs_copy(S,T,'-append','*',[],grps{:},'quiet');
      end
   end
end