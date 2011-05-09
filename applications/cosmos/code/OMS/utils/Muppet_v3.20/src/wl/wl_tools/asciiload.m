function z=asciiload(filename);
%ASCIILOAD  A compiler compatible version of LOAD -ASCII
%        X=ASCIILOAD('FileName')
%        Load data from specified ASCII file into the
%        variable X.

% (c) 2002-2004, H.R.A. Jagers
%     WL | Delft Hydraulics, Delft, The Netherlands

fid=fopen(filename,'r');
z={};
i=0;
ll=0;
prevcomma=0;
while ~feof(fid)
   i=i+1;
   txt=fgetl(fid);
   cni=0;
   perc=findstr(txt,'%');
   if ~isempty(perc)
      str=txt(1:perc-1);
   else
      str=txt;
   end
   [values,n,err,ni]=sscanf(str,'%f',[1 inf]);
   while ni<=length(str)
      cni=cni+ni-1;
      str=str(ni:end);
      if str(1)==','
         if ~prevcomma
            cni=cni+1;
            str=str(2:end);
            prevcomma=1;
            [values2,n,err,ni]=sscanf(str,'%f',[1 inf]);
            if n>0
               prevcomma=0;
               values=cat(2,values,values2);
            end
         else
            spaces=repmat(' ',1,cni-1);
            Err=sprintf('Missing data between comma''s on line %i of ASCII file %s:\n%s\n%s^',i,filename,txt,spaces);
            fclose(fid);
            error(Err)
         end
      else
         %
         % --- begin of "obsolete code" ---
         % In recent versions of MATLAB, the sscanf command above
         % will read Inf's and NaN's. The code below is for compatibility
         % with MATLAB 5.3.
         kyw=0;
         if length(str)>3 
           if strcmp(lower(str(1:4)),'-inf')
              kyw=4;
              kywval=-inf;
           end
         end
         if length(str)>2
           if strcmp(lower(str(1:3)),'inf')
              kyw=3;
              kywval=inf;
           elseif strcmp(lower(str(1:3)),'nan')
              kyw=3;
              kywval=NaN;
           end
         end
         if kyw>0
            if length(str)>kyw
              switch str(kyw+1)
              case {' ',char(9),','}
              otherwise
                 kyw=0;
              end
            end
         end
         if kyw>0
            prevcomma=0;
            values=cat(2,values,kywval);
            cni=cni+kyw;
            str=str(kyw+1:end);
            [values2,n,err,ni]=sscanf(str,'%f',[1 inf]);
            if n>0
               values=cat(2,values,values2);
            end
         else
         % --- end of "obsolete code" ---
         %
            spaces=repmat(' ',1,cni);
            Err=sprintf('Unknown text on line number %i of ASCII file %s:\n%s\n%s^',i,filename,txt,spaces);
            fclose(fid);
            error(Err)
         %
         % --- begin of "obsolete code" ---
         end
         % --- end of "obsolete code" ---
         %
      end
   end
   if prevcomma
      spaces=repmat(' ',1,cni);
      Err=sprintf('Missing value after comma at end of line %i of ASCII file %s:\n%s\n%s^',i,filename,txt,spaces);
      fclose(fid);
      error(Err)
   end
   if ~isempty(values),
      if ll>0 & length(values)~=ll
         Err=sprintf('Number of columns of ASCII file %s do not match.\nLine %i has %i columns, whereas the preceeding lines have %i columns:\n%s',filename,i,length(values),ll,txt);
         fclose(fid);
         error(Err)
      else
         ll=length(values);
         z{end+1}=values;
      end
   %else
      % empty line, skip it
   end
end
fclose(fid);
z=cat(1,z{:});