function [Lout,Lblout]=contourlegend(H,varargin)
%CONTOURLEGEND Contour legend.
%      CONTOURLEGEND(H) puts a legend on the axes H for the
%      contour plot (with auto colored contour lines) in
%      that plot. Alternatively, you may specify the handles
%      of the patch objects composing the contour plot, i.e.
%      CONTOURLEGEND(Hpatches).
%
%      The legend will be based on the contour values. If
%      other labels are required, you may specify the labels
%      using
%      CONTOURLEGEND(H,'string1','string2','string3')
%
%      [HL,LABEL]=CONTOURLEGEND(H);
%      will not create a legend, but it will return object
%      handles HL that can be used as input argument for the
%      LEGEND function. This can be used to create legend
%      for contour data and other lines in one plot. It also
%      returns a cell array of standard labels.

if all(ishandle(H))
   if isequal(size(H),[1 1]) & strcmp(get(H,'type'),'axes')
      ax=H;
      l=findall(ax,'type','patch');
   else
      l=H;
      ax=get(H(1),'parent');
   end
else
   error('Invalid input argument. Handle must be specified.');
end

cdata=get(l,'cdata');
cdata=cat(1,cdata{:});
cdata(isnan(cdata))=[];
[cdata,frw]=unique(cdata);
nucol=length(cdata);

if strcmp(get(l(1),'facecolor'),'none')
   clim=get(ax,'clim');
   fg=get(ax,'parent');
   cmap=get(fg,'colormap');
   rcdata=(cdata-clim(1))/(clim(2)-clim(1));
   Ncol=size(cmap,1);
   icdata=min(floor(rcdata*Ncol),Ncol-1)+1;
   
   cols=cmap(icdata,:);
   L=zeros(1,nucol);
   Lbl=cell(1,nucol);
   for i=nucol:-1:1
      L(i)=line([0 1],1+0.1*i+[0 0],'color',cols(i,:),'vis','off');
      Lbl{i}=num2str(cdata(i));
   end
else
   L=l(frw);
   Lbl=cell(1,nucol);
   for i=nucol:-1:1
      if i==nucol
         % greater than or equal: \geq
         Lbl{i}=['above ' num2str(cdata(i))];
      else
         Lbl{i}=[num2str(cdata(i)) ' - ' num2str(cdata(i+1))];
      end
   end
end

if nargin>1
   Lbl=varargin;
end

if nargout>0
   Lout=L;
   Lblout=Lbl;
else
   legend(L,Lbl{:});
end
