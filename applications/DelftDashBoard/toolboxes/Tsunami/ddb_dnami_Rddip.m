function ddb_dnami_Rddip()
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth   disloc     foption
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth

fig1 = findobj('name','Tsunami Toolkit');
fdtop= str2num(get(findobj(fig1,'tag','FDtop'),'string'));
if fdtop < 0
   set(findobj(fig1,'tag','FDtop'),'string','0')
   fdtop= 0;
end
for i=1:nseg
   dip(i)   = str2num(get(findobj(fig1,'tag',['Dipstr' num2str(i)]),'string'));
   fdepth(i)= 0.5*fwidth*sin(dip(i)*degrad) +fdtop;
   set(findobj(fig1,'tag',['FDepth' num2str(i)]),'string',int2str(fdepth(i)));
end
