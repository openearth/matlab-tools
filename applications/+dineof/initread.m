function [T,E0] = initread(initfile)
%initread reads file with DINEOF setings
%
%    T = dineof.initread(initfile) 
%
% returns struct T with dineof settings from initfile
%
%   [T,E] = dineof.initread(..) also returns struct E with explanations
%
%See also: DINEOF

%% load 

   T0 = dineof.init();
   
   fields = fieldnames(T0);

   T = inivalue(initfile,nan,struct('commentchar','!'));

%% process numeric fields

   for ifld=1:length(fields)
     fld = fields{ifld};
     if ~ischar(T0.(fld))
       if isfield(T,fld)
         comment_start = strfind(T.(fld),'!'); 
         if ~isempty(comment_start)
         T.(fld) = T.(fld)(1:comment_start-1);
         end
         T.(fld) = str2num(T.(fld));
       end
     end
   end
