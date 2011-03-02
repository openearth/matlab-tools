function ddb_dnami_loadArea()
%
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth    disloc    foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch  mrkrpatch
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth
%
global progdir   datadir    workdir     tooldir ldbfile

%
[name,pat]=uigetfile([datadir '*.png; *.jpg'],'Select file');
if name==0
    return
end

%
% Set the present directory as the work directory
%
filename = [pat name];
set(findobj(gcbf,'tag','AreaFilename'),'string',filename);
[pathstr, name, ext] = fileparts(filename);

%
% Reinitialise all values
%
ddb_dnami_initValues()

%
% Read from file the header (area limitation of the image)
%
[fid,errmsg] = fopen([name '.hdr'],'r');

if fid == -1
  fprintf (1,'Error opening file %s\n',[name '.hdr']);
  disp (errmsg)
  error
end

%
% read Xleft Ytop & then Xright Ybottom
%
s = fgetl(fid); [hk,count] =  sscanf(s, '%f %f %s %s',4);
xareaGeo(1)=hk(1);
yareaGeo(1)=hk(2);
s = fgetl(fid); [hk,count] =  sscanf(s, '%f %f %s %s',4);
xareaGeo(2)=hk(1);
yareaGeo(2)=hk(2);
s = fgetl(fid); [ldbfile,count] =  sscanf(s, '%s',1);

overviewpic = imread([pat name ext]);

Figopen = (findobj('tag','Figure2'));
if (isempty(Figopen))
    fig2 = figure('Tag','Figure2','Name', [name ext],'CloseRequestFcn','ddb_fig2Quit()');
end
try
   set(fig2,'Position',[1 1 550 700])
end

image(xareaGeo,yareaGeo,overviewpic)
set(gca,'YDir','normal')
set(gca,'XDir','normal')
axis image;
iarea = 1;

ddb_dnami_drawpolygon();
if (nseg > 0 & Mw > 0)
   figure(fig2);
   for i=1:nseg
      xx = [];
      yy = [];
      for k=1:5
         xx(k) = xvrt(i,k);
         yy(k) = yvrt(i,k);
      end
      fltpatch(i) = patch(xx,yy,'w');
   end
end
%
% Set all values
%


return
%imtool(overviewpic);
