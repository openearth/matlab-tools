function fig2eps(figfiles,opt)
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

if nargin==0
  figfiles='*.fig';
end
if nargin<2
    opt='eps';
end
d=dir(figfiles);
for i=1:length(d)
  create=0;
  epsfig=[d(i).name(1:end-3) opt];
  if ~exist(epsfig)
    create=1;
  else % exists
    de=dir(epsfig); de=datenum(de.date);
    df=dir(d(i).name); df=datenum(df.date);
    if de<df % eps is older than fig file => recreate!
      create=1;
    end
  end
  if create
    F=hgload(d(i).name);
    ordersurf;
    f=findall(gcf,'deletefcn','colorbar(''delete'',''peer'',get(gcbf,''currentaxes''))');
    set(f,'deletefcn','colorbar(''delete'')');
    switch opt
    case 'eps'
        set(gcf,'paperunits','inch');
        exportfig(gcf,epsfig,'color','cmyk','renderer','painters','previewtiff','yes','width',8);
    case 'ps'
        PrintInfo.PrtID='PS file';
        PrintInfo.Method=1; % painters
        PrintInfo.DPI=150; % dummy
        PrintInfo.AllFigures=1;
        PrintInfo.Color=1;
        md_print(gcf,PrintInfo,epsfig);
    otherwise
        close(F);
        error(['Don''t know how to convert to ',opt]);
    end
    close(F);
  end
end
