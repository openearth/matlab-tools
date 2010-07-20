function varargout = ddb_dnami_compute()

%
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth    disloc     foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch  mrkrpatch flinepatch
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth

global progdir   datadir    workdir     tooldir ldbfile
global ngfile    d3dfilgrd  d3dfildep
global xgrdarea  ygrdarea   grdsize
%

fig1 = gcbf;
fig2 = findobj('tag','Figure2');

for i=1:nseg
  val = getifld(['FaultLstr' int2str(i)]);
  userfaultL(i)=getifld(['FaultLstr' int2str(i)]);
  strike    (i)=getifld(['Strikestr' int2str(i)]);
  dip       (i)=getifld(['Dipstr' int2str(i)]);
  slip      (i)=getifld(['Slipstr' int2str(i)]);
end

ddb_dnami_setValues()

nogocomp = 1;
nogocomp = nogocomp & Mw >5;
nogocomp = nogocomp & totflength>0;
nogocomp = nogocomp & fwidth>0;
nogocomp = nogocomp & disloc>0;
nogocomp = nogocomp & nseg>0;
st=get(findobj(fig1,'tag','FDtop'), 'string');
nogocomp = nogocomp & ~isempty(st);
nogocomp = nogocomp & fdtop>=0;
if foption(1:1)=='C'
   nogocomp = nogocomp & lat_epi~=0;
   nogocomp = nogocomp & lon_epi~=0;
end

if ~nogocomp
   errordlg('Not all Earthquake parameters are correctly specified; Check the fields')
   return
end

nogocomp = nogocomp & (abs(faultTotL-totflength) < tolFlength*totflength)>0;

try
   for i=1:nseg
      userfaultL(i)=str2num(get(findobj('tag',['FaultLstr' num2str(i)]),'String'));
      nogocomp     =nogocomp & userfaultL(i)>0;
      strike(i)    =str2num(get(findobj('tag',['Strikestr' num2str(i)]),'String'));
      nogocomp     =nogocomp & strike(i)>0;
      dip(i)       =str2num(get(findobj('tag',['Dipstr'    num2str(i)]),'String'));
      nogocomp     =nogocomp & dip(i)>0;
      nogocomp     =nogocomp & dip(i)<90;
      slip(i)      =str2num(get(findobj('tag',['Slipstr'  num2str(i)]),'String'));
      nogocomp = nogocomp & slip(i)>0;
      nogocomp = nogocomp & slip(i)<180;
   end
catch
end

if faultX(1)==0 & faultY(1)==0
   errordlg('Fault line not drawn, draw them first')
   return
end
%
% Write data to file 1; ; fault input for the OKADA model
%
filout=[workdir filesep 'dtt_out.txt'];
fid=fopen(filout,'w');


fprintf(fid,'%s %s\n','* East   North  strike    area   depth  dip   lambda         mu', .....
                      '    U1    U2      U3     L     W     name     Figure');
fprintf(fid,'%s %s \n','* (km)   (km)  (deg CW N)  0/1  (km)   (deg)         ', .....
            '             (mm)   (mm)    (mm)  (km)   (km)            ');
%
% assume strike and fault direction are identical (as in the rest of the program)
% i.e. U3 == 0 always
%

utmz = fix( ( faultX(1) / 6 ) + 31);
for i=1:nseg
% [x,y] = ddb_deg2utm(faultX(i),faultY(i),utmz);
%   xvrt(i,1:4)
%   yvrt(i,1:4)
%   xl= 0.25*(sum(xvrt(i,1:4)))
%   yl= 0.25*(sum(yvrt(i,1:4)))
%   [x,y] = ddb_deg2utm(xl,yl,utmz)

%   [x,y] = ddb_deg2utm(xvrt(i,1),yvrt(i,1),utmz);
%   fd = fdepth(i);
[x,y] = ddb_deg2utm(xvrt(i,4),yvrt(i,4),utmz);   
fd = fwidth*sin(dip(i)*degrad) + fdtop;

%x=x/1000-166;
%y=y/1000-166;
 x=x/1000;
 y=y/1000;
 U1=disloc*cos(slip(i)*degrad)*1000;
 U2=disloc*sin(slip(i)*degrad)*1000;
 U3=0;
 txt=['Segment' int2str(i)];
 fprintf(fid,'%s %6.1f %6.1f %6.1f %2s %6.1f %6.1f %s %6.0f %6.0f %6.0f %6.1f %6.1f %s %s\n', ......
             ' ',x,y,strike(i), '        1',fd,dip(i),' 4.39e+9   3.64e+9 ', ......
             U1,U2,U3,userfaultL(i),fwidth,txt,' xxx');
end
fclose(fid);

%
% Write data to file 2; grid input for the OKADA model
%
filout=[workdir filesep 'gridspec.txt'];
fid=fopen(filout,'w');
%
% First the zone
%
fprintf(fid,'%s %4.0f %6.1f %6.1f\n', 'Z ', utmz,((utmz-1)*6-180),ygrdarea(1));
%
% Siple Grid; single file no mask
%
Mg=fix((xgrdarea(2)-xgrdarea(1))/grdsize) + 1;
Ng=fix((ygrdarea(2)-ygrdarea(1))/grdsize) + 1;
fprintf(fid,'%s %12.5f %12.5f %12.5f %12.5f %5s %5s\n', 'G ', .....
        xgrdarea(1),ygrdarea(1),grdsize,grdsize,int2str(Mg),int2str(Ng));
%
% Delft3D Grid File; mask file: depth file
%
ngfile    =str2num(getINIValue('DTT_config.txt','NoGridFile'));
for i=1:ngfile
  dum2=getINIValue('DTT_config.txt',['grf' int2str(i)]);
  fprintf(fid,'%s %s\n', 'S ', dum2);
  dum2=getINIValue('DTT_config.txt',['dpf' int2str(i)]);
  fprintf(fid,'%s %s\n', 'D ', dum2);
end
fclose(fid);
pause(2);
%
% execute program
%
olddir=pwd;
cd (workdir);
evaltxt=['!' progdir 'rngchn_init.exe gridspec.txt dtt_out.txt disp.xyz ascii'];
eval(evaltxt)
%
%present result only on the simple grid file
%
LDB=ddb_readldb([datadir ldbfile], -999.000);
fig3 = figure('Tag','Figure3','Name', 'Result');
%LDB.x(LDB.x == -999)  = NaN;
%LDB.y(LDB.y == -999)  = NaN;

xrange = xgrdarea(1):grdsize:xgrdarea(2); M = length(xrange);
yrange = ygrdarea(1):grdsize:ygrdarea(2); N = length(yrange);
[X Y] = meshgrid(yrange, xrange);
dp=ddb_wldep('read','disp.ini',[M N]);
pcolor(Y,X,dp), grid on, hold on;
shading interp
xlabel ('X');
ylabel ('Y');
axis image;
patch(LDB.x, LDB.y,'k');

cd (olddir);

%-------------------------------------------------------
function val=getifld(txt)
vstr = get(findobj('Tag',txt),'string');
if isempty(vstr)
   val=0;
else
   val=str2num(vstr);
end
