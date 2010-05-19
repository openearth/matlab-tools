function ddb_dnami_redrw_Farea()
%
global Mw        lat_epi     lon_epi    fdtop      totflength fwidth   disloc    foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch mrkrpatch flinepatch
global dip       strike      slip       userfaultL tolFlength fdepth
global nseg      faultX      faultY     faultTotL  xvrt       yvrt
global mu        raddeg      degrad     rearth
%
if Mw <= 5
   errordlg('Specifiy Mw first')
   return
end

xf =[0 0 0 0 0 0]; yf =[0 0 0 0 0 0];
ufl=[0 0 0 0 0];   str=[ 0 0 0 0 0];  dp =[0 0 0 0 0];   sl =[0 0 0 0 0]; fd = [0 0 0 0 0];

ishft=0;
nsg  = nseg;
nsegold=nseg;

for i=1:nseg
  val = getifld(['FaultLstr' int2str(i)]);
  if val==0 % delete faultline
     ishft=ishft+1;
     nsg  = nsg -1;
  else
     xf(i-ishft)=faultX(i);
     yf(i-ishft)=faultY(i);
     ufl(i-ishft)=val;
     str(i-ishft)=getifld(['Strikestr' int2str(i)]);
     dp (i-ishft)=getifld(['Dipstr' int2str(i)]);
     sl (i-ishft)=getifld(['Slipstr' int2str(i)]);
     fd (i-ishft)=getifld(['FDepth' int2str(i)]);
  end
end

totufl=sum(ufl);
%
% error in case fault length exceeds 10% of computed fault length through Mw
%
if (abs(totufl-totflength) > tolFlength*totflength)
   errordlg(['Specified fault length: ' int2str(totufl) ' Length computed: ' int2str(totflength)]);
   return
end

%
% redefine polygon coordinates and fault area using new distance and bearing (strike dir)
%
for i=1:nsg
   [xf(i+1),yf(i+1)]=ddb_ddb_det_nxtvrtx(xf(i), yf(i), str(i), ufl(i));
end

%
% Now everything's OK: copy new values to old values
%
nseg = nsg;
faultTotL = totufl;
for i=1:nseg
   faultX(i)=xf(i);
   faultY(i)=yf(i);
   userfaultL(i)=ufl(i);
   strike(i)=str(i);
   dip(i)=dp(i);
   slip(i)=sl(i);
   fdepth(i)=fd(i);
end
faultX(nseg+1)=xf(nseg+1);
faultY(nseg+1)=yf(nseg+1);

%
% Delete fault area form the figure
%
fig2 = (findobj('tag','Figure2'));
if isempty(fig2)
   errordlg('Load Area first');
   return
else
   if ~isempty(fig2)
      for i=1:nsegold
         try
           delete(fltpatch(i));
           delete(flinepatch(i));
         end
      end
   end
end

ddb_dnami_comp_Farea();
ddb_dnami_setValues();
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
ddb_dnami_drwMarker()

%-------------------------------------------------------
function val=getifld(txt)
vstr = get(findobj('Tag',txt),'string');
if isempty(vstr)
   val=0;
else
   val=str2num(vstr);
end
