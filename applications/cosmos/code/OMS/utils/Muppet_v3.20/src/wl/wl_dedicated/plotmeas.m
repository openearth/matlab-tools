function plotmeas(caseid,qty)
% PLOTMEAS(CASEID,QTY)
% CASEID = 'A1','A2','B1'
% A1: 1:3 krib 25cm waterdiepte
% A2: 1:3 krib 30cm waterdiepte
% B1: 1:6 krib 25cm waterdiepte
% QTY = 3 (u),4 (v),5 (u'),6 (v'), 7 (vec)

if nargin==0
  caseid='A1';
  qty=5;
end

% de files A1_1 t/m A1_4 zijn identiek
% de files A2_1 t/m A2_4 zijn identiek
% de files B1_1 t/m B1_4 zijn identiek
% alle juiste matrices zitten in de files A2_1 t/m A2_4
if isunix
  load /u/schijnd/octopus/TUD-data/PTV/A2_1
else
  load u:/u/schijnd/octopus/TUD-data/PTV/A2_1
end
switch qty,
case 3, % u
  thresh=-0.15:.025:0.35;
  mult=1;
  var='u snelheid';
case 4, % v
  thresh=-0.05:.01:0.15;
  mult=1;
  var='v snelheid';
case 5, % u'
  thresh=0:.005:0.06;
  mult=-1;
  var='u snelheidsfluctuaties';
case 6, % v'
  thresh=0:.005:0.06;
  mult=-1;
  var='v snelheidsfluctuaties';
case 7, % u,v quiver
  thresh=[];
  mult=0.3;
  var='snelheidsvectoren';
end
figure
M1=eval([caseid '_1']);
M2=eval([caseid '_2']);
M3=eval([caseid '_3']);
M4=eval([caseid '_4']);
if qty<7
  contourf(M4(:,:,1),M4(:,:,2),mult*M4(:,:,qty),thresh)
  hold on
  contourf(M3(:,:,1),M3(:,:,2),mult*M3(:,:,qty),thresh)
  contourf(M2(:,:,1),M2(:,:,2),mult*M2(:,:,qty),thresh)
  contourf(M1(:,:,1),M1(:,:,2),mult*M1(:,:,qty),thresh)
  classbar(colorbar,thresh)
elseif qty==7
  quiver(M4(:,:,1),M4(:,:,2),mult*M4(:,:,3),mult*M4(:,:,4),0)
  hold on
  quiver(M3(:,:,1),M3(:,:,2),mult*M3(:,:,3),mult*M3(:,:,4),0)
  quiver(M2(:,:,1),M2(:,:,2),mult*M2(:,:,3),mult*M2(:,:,4),0)
  quiver(M1(:,:,1),M1(:,:,2),mult*M1(:,:,3),mult*M1(:,:,4),0)
end
set(gca,'xlim',[-0.6 4.1],'ylim',[2.1 5.0],'da',[1 1 1])
title({caseid,var})
