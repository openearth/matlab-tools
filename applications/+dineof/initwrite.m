function initwrite(T,initfile)
%initwrite  saves file with DINEOF setings
%
%    T = dineof.initwrite(T, initfile) 
%
% saves struct T with dineof settings to initfile.
%
%See also: DINEOF

OPT.comments = 0;

%% load 

   [T0,E0] = dineof.init();
   
   fields = fieldnames(T0);
   
   T = mergestructs(T0,T); % add non-exisitng fields

%% save

   fid = fopen(initfile,'w');
   
   fprintf(fid,'! Created with $HeadURL$ $Id$ \n');
   
   for ifld=1:length(fields)

     fld = fields{ifld};

     if ischar(T.(fld));
        fmt = '%s';
     else
        fmt = '%d';
     end
     
     if     (strcmp(fld,'clouds')           & isempty(T.(fld))), continue
     elseif (strcmp(fld,'number_cv_points') & isempty(T.(fld))), continue
     else
     
       if OPT.comments
       for j=1:length(E0.(fld))
         fprintf(fid,'! %s\n',E0.(fld){j});
       end
       end
       
       fprintf(fid,['%s = ',fmt,'\n'],pad(fld,11),T.(fld));
     
     end
       
   end
   
   fclose(fid);

   