function fig2eps(varargin)
%FIG2EPS  Create EPS files for FIG files
%      FIG2EPS('d:\Sub\App*.fig')
%      Creates EPS files for all the figure files in
%      d:\Sub directory starting with App. The EPS files
%      will be written to the same directory and they
%      will have the same name except for the extension.
%
%      FIG2EPS
%      Works on all FIG files in the current directory.

% (c) 2002, H.R.A. Jagers
%           WL | Delft Hydraulics, Delft, The Netherlands

format='eps';
asifprinted=0;
makeall=0;
processed=logical(zeros(1,nargin));
i=1;
while i<=length(varargin)
   Prop=varargin{i};
   switch lower(Prop)
   case 'format'
      format=varargin{i+1};
      processed(i:i+1)=1;
      i=i+1;
   case 'asifprinted'
      processed(i)=1;
      asifprinted=1;
   case 'makeall'
      processed(i)=1;
      makeall=1;
   end
   i=i+1;
end
figfiles=varargin(~processed);
if length(figfiles)>1
   error('Unrecognized input arguments.');
elseif isempty(figfiles)
   figfiles='*.fig';
else
   figfiles=figfiles{1};
end
opt={};
switch format
case {'eps','eps2','epsc','epsc2'}
   fileext='eps';
   if asifprinted
      opt={'-tiff'};
   else
      opt={'previewtiff','yes'};
   end
case {'ps','ps2','psc','psc2'}
   fileext='ps';
case 'jpeg',
   fileext='jpg';
case 'png',
   fileext='png';
case 'tiff'
   fileext='tif';
end
d=dir(figfiles);
for i=1:length(d)
   create=0;
   epsfig=[d(i).name(1:end-3) fileext];
   if ~exist(epsfig) | makeall
      create=1;
   else % exists
      de=dir(epsfig); de=datenum(de.date);
      df=dir(d(i).name); df=datenum(df.date);
      if de<df % target file is older than fig file => recreate!
         create=1;
      end
   end
   if create
      F=hgload(d(i).name);
      ordersurf; %gcf -> F
      if asifprinted
         print(F,epsfig,['-d' format],'-cmyk','-painters',opt{:});
      else
         set(F,'paperunits','inch');
         exportfig(F,epsfig,'color','cmyk','renderer','painters',opt{:},'width',8,'format',format);
      end
      f=findall(F,'deletefcn','colorbar(''delete'',''peer'',get(gcbf,''currentaxes''))');
      set(f,'deletefcn','colorbar(''delete'')');
      delete(F);
   end
end
