function varargout=realset(varargin);
%REALSET 
%
%      [SetStruct,SimplifiedSetString]=REALSET(SetString)
%
%      SetString=REALSET(SetStruct)
%
%      Y=REALSET(SetStruct,X)

if nargin==2
   % apply SetStruct
   str=varargin{1};
   X=varargin{2};
   if ischar(str)
      str=realset(str);
   end
   c1=str;
   if isfinite(c1.min)
      if c1.minkeep
         X(X<c1.min)=NaN;
      else
         X(X<=c1.min)=NaN;
      end
   end
   if isfinite(c1.max)
      if c1.maxkeep
         X(X>c1.max)=NaN;
      else
         X(X>=c1.max)=NaN;
      end
   end
   if ~isempty(c1.val)
      X(ismember(X(:),c1.val(:)))=NaN;
   end
   for i=1:size(c1.range,1)
      Y=X(:)>c1.range(i,1) | (X(:)==c1.range(i,1) & ~c1.rangeminmaxkeep(i,1));
      Y=Y & (X(:)<c1.range(i,2) | (X(:)==c1.range(i,2) & ~c1.rangeminmaxkeep(i,2)));
      X(Y)=NaN;
   end
   varargout={X};
elseif ischar(varargin{1})
   str=varargin{1};
   clipstruct.val=[];
   clipstruct.range=zeros(0,2);
   clipstruct.rangeminmaxkeep=zeros(0,2);
   clipstruct.min=-inf;
   clipstruct.minkeep=0;
   clipstruct.max=inf;
   clipstruct.maxkeep=0;
   str1='';
   while ~isempty(str) | ~isempty(str1)
      if isempty(str)
         str=' ';
      end
      [v,N,err,i] = sscanf(str,' %f',[1 inf]);
      switch str1
      case {'',' '}
         if ~isempty(v)
            clipstruct.val=cat(2,clipstruct.val,v);
         end
      case {'>','>='}
         if isequal(str(1),' ')
            error('A value should directly follow a > sign.');
         else
            clipstruct.max=cat(1,clipstruct.max,v(1));
            clipstruct.maxkeep=cat(1,clipstruct.maxkeep,length(str1)==1);
            if N>1
               clipstruct.val=cat(2,clipstruct.val,v(2:end));
            end
         end
      case {'<','<='}
         if isequal(str(1),' ')
            error('A value should directly follow a < sign.');
         else
            clipstruct.min=cat(1,clipstruct.min,v(1));
            clipstruct.minkeep=cat(1,clipstruct.minkeep,length(str1)==1);
            if N>1
               clipstruct.val=cat(2,clipstruct.val,v(2:end));
            end
         end
      case {'[','('}
         if isequal(size(v),[1 2])
            if i>length(str) | (~strcmp(str(i),']') & ~strcmp(str(i),')'))
               error('Missing closing bracket ] or ) for range');
            end
            clipstruct.range=cat(1,clipstruct.range,sort(v));
            rangeminkeep=strcmp(str1,'(');
            rangemaxkeep=strcmp(str(i),')');
            clipstruct.rangeminmaxkeep=cat(1,clipstruct.rangeminmaxkeep,[rangeminkeep rangemaxkeep]);
            str(i)=' ';
         else
            error('A range should consist of 2 values.');
         end
      otherwise
         error(sprintf('Unexpected character: %s.',str1));
      end
      if i>length(str)
         str=cat(2,str,' ');
      end
      str1=str(i);
      str0=' ';
      if i>1
         str0=str(i-1);
      end
      if ~isequal(str0,' ') & (strcmp(str1,'<') | strcmp(str1,'>'))
         error(sprintf('There should be a space before a %s sign.',str1));
      end
      str=str(i+1:end);
      if strcmp(str1,'>') | strcmp(str1,'<')
         if ~isempty(str) & strcmp(str(1),'='),
            str1=[str1 '='];
            str=str(2:end);
         end
      end
      if strcmp(str1,' ') & isempty(str)
         break
      end
   end
   clipstruct.val=unique(clipstruct.val);
   
   newmin=max(clipstruct.min);
   i=find(clipstruct.min==newmin);
   if length(i)>1
      clipstruct.minkeep=all(clipstruct.minkeep(i));
      clipstruct.min=clipstruct.min(i(1));
   else
      clipstruct.minkeep=clipstruct.minkeep(i);
      clipstruct.min=clipstruct.min(i);
   end
   newmax=min(clipstruct.max);
   i=find(clipstruct.max==newmax);
   if length(i)>1
      clipstruct.maxkeep=all(clipstruct.maxkeep(i));
      clipstruct.max=clipstruct.max(i(1));
   else
      clipstruct.maxkeep=clipstruct.maxkeep(i);
      clipstruct.max=clipstruct.max(i);
   end
   c1=clipstruct;
   c2=[];
   while ~isequal(c1,c2)
      c2=c1;
      if c1.maxkeep
         if any(c1.val>c1.max)
            c1.val=c1.val(c1.val<=c1.max);
         end
         if ~isempty(c1.val) & any(c1.val==c1.max)
            c1.val=c1.val(c1.val~=c1.max);
            c1.maxkeep=0;
         end
      else
         if any(c1.val>=c1.max)
            c1.val=c1.val(c1.val<c1.max);
         end
      end
      if c1.maxkeep
         I=c1.range>c1.max | (c1.range==c1.max & ~c1.rangeminmaxkeep);
      else
         I=c1.range>=c1.max;
      end
      II=any(I,2); III=all(I,2); JJ=c1.range(II&~III,1); JJkeep=c1.rangeminmaxkeep(II&~III,1);
      c1.rangeminmaxkeep(II,:)=[];
      c1.range(II,:)=[];
      if ~isempty(JJ)
         [c1.max,jj]=min(JJ(:));
         c1.maxkeep=JJkeep(jj);
      end
      %-------   
      if c1.minkeep
         if any(c1.val<c1.min)
            c1.val=c1.val(c1.val>=c1.min);
         end
         if ~isempty(c1.val) & any(c1.val==c1.min)
            c1.val=c1.val(c1.val~=c1.min);
            c1.minkeep=0;
         end
      else
         if any(c1.val<=c1.min)
            c1.val=c1.val(c1.val>c1.min);
         end
      end
      I=c1.range<=c1.min;
      if c1.minkeep
         I=c1.range<c1.min | (c1.range==c1.min & ~c1.rangeminmaxkeep);
      else
         I=c1.range<=c1.min;
      end
      II=any(I,2); III=all(I,2); JJ=c1.range(II&~III,2); JJkeep=c1.rangeminmaxkeep(II&~III,2);
      c1.rangeminmaxkeep(II,:)=[];
      c1.range(II,:)=[];
      if ~isempty(JJ)
         [c1.min,jj]=max(JJ(:));
         c1.minkeep=JJkeep(jj);
      end
      %------- convert ranges with min==max to value
      i=1;
      while i<=size(c1.range,1)
          if c1.range(i,1)==c1.range(i,2)
              c1.val(1,end+1)=c1.range(i,1);
              c1.range(i,:)=[];
          else
              i=i+1;
          end
      end
      %-------   
      i=1;
      while i<=size(c1.range,1)
         if ~isempty(c1.val)
            II=(c1.val>c1.range(i,1) | (c1.val==c1.range(i,1) & ~c1.rangeminmaxkeep(i,1))) & ...
               (c1.val<c1.range(i,2) | (c1.val==c1.range(i,2) & ~c1.rangeminmaxkeep(i,2)));
            if any(II), c1.val=c1.val(~II); end
         end
         if ~isempty(c1.val)
            if c1.val==c1.range(i,1)
               c1.rangeminmaxkeep(i,1)=0;
               c1.val(c1.val==c1.range(i,1))=[];
            end
            if ~isempty(c1.val)
               if c1.val==c1.range(i,2)
                  c1.rangeminmaxkeep(i,2)=0;
                  c1.val(c1.val==c1.range(i,2))=[];
               end
            end
         end
         j=i+1;
         while j<=size(c1.range,1)
            if (c1.range(j,1)>c1.range(i,1) | (c1.range(j,1)==c1.range(i,1) & (~c1.rangeminmaxkeep(i,1) | ~c1.rangeminmaxkeep(j,1)) )) & ...
                  (c1.range(j,1)<c1.range(i,2) | (c1.range(j,1)==c1.range(i,2) & (~c1.rangeminmaxkeep(i,2) | ~c1.rangeminmaxkeep(j,1)) )) % j overlaps at max, j inside i
               if c1.range(i,1)==c1.range(j,1)
                  c1.rangeminmaxkeep(i,1)=all(c1.rangeminmaxkeep([i j],1));
               end
               if c1.range(i,2)<c1.range(j,2)
                  c1.range(i,2)=c1.range(j,2);
                  c1.rangeminmaxkeep(i,2)=c1.rangeminmaxkeep(j,2);
               elseif c1.range(i,2)==c1.range(j,2)
                  c1.rangeminmaxkeep(i,2)=all(c1.rangeminmaxkeep([i j],2));
               end
               c1.range(j,:)=[];
               c1.rangeminmaxkeep(j,:)=[];
            elseif (c1.range(j,2)>c1.range(i,1) | (c1.range(j,2)==c1.range(i,1) & (~c1.rangeminmaxkeep(i,1) | ~c1.rangeminmaxkeep(j,2)) )) & ...
                  (c1.range(j,2)<c1.range(i,2) | (c1.range(j,2)==c1.range(i,2) & (~c1.rangeminmaxkeep(i,2) | ~c1.rangeminmaxkeep(j,2)) )) % j overlaps at min
               if c1.range(i,1)>c1.range(j,1)
                  c1.range(i,1)=c1.range(j,1);
                  c1.rangeminmaxkeep(i,1)=c1.rangeminmaxkeep(j,1);
               elseif c1.range(i,1)==c1.range(j,1)
                  c1.rangeminmaxkeep(i,1)=all(c1.rangeminmaxkeep([i j],1));
               end
               c1.range(j,:)=[];
               c1.rangeminmaxkeep(j,:)=[];
            elseif (c1.range(i,1)>c1.range(j,1) | (c1.range(i,1)==c1.range(j,1) & (~c1.rangeminmaxkeep(i,1) | ~c1.rangeminmaxkeep(j,1)) )) & ...
                  (c1.range(i,1)<c1.range(j,2) | (c1.range(i,1)==c1.range(j,2) & (~c1.rangeminmaxkeep(i,1) | ~c1.rangeminmaxkeep(j,2)) )) % i inside j
               c1.range(i,:)=[];
               c1.rangeminmaxkeep(i,:)=[];
               i=i-1;
               break
            else
               j=j+1;
            end
         end
         i=i+1;
      end
   end
   if c1.min>c1.max
      c1.min=c1.max;
      c1.maxkeep=c1.maxkeep & ~c1.minkeep;
   end
   if nargout>1
      varargout={c1 realset(c1)};
   else
      varargout={c1};
   end
else
   c1=varargin{1};
   str='';
   eql='=';
   if c1.minkeep, eql=''; end
   if isfinite(c1.min), str=sprintf('<%s%g ',eql,c1.min); end
   val=c1.val;
   range=c1.range;
   rangeminmaxkeep=c1.rangeminmaxkeep;
   while ~isempty(val) | ~isempty(range)
      if isempty(val)
         K=range(:,1);
      elseif isempty(range)
         K=val;
      else
         K=cat(2,val,range(:,1)');
      end
      [mnk,k]=min(K);
      if k>length(val)
         i=k-length(val);
         lrkeep='[';
         if rangeminmaxkeep(i,1), lrkeep='('; end
         urkeep=']';
         if rangeminmaxkeep(i,2), urkeep=')'; end
         str=cat(2,str,sprintf('%s%g %g%s ',lrkeep,range(i,:),urkeep));
         range(i,:)=[];
         rangeminmaxkeep(i,:)=[];
      else
         str=cat(2,str,sprintf('%g ',mnk));
         val(k)=[];
      end
   end
   eql='=';
   if c1.maxkeep, eql=''; end
   if isfinite(c1.max), str=cat(2,str,sprintf('>%s%g ',eql,c1.max)); end
   if isempty(str)
      varargout={''};
   else
      varargout={str(1:end-1)}; % remove last space
   end
end
