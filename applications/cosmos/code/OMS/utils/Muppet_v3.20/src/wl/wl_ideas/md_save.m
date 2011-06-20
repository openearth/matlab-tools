function md_save(fig)

if nargin<1, return; end;
[mfile,mpath]=uiputfile('*.fig','Save as ...');
if ischar(mfile),
  filename=[mpath mfile];
  hgsave(fig,filename);
end;
