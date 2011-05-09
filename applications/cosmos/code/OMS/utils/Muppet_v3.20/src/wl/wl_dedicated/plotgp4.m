function plotgp4(App,Nr,Left)
%PLOTGP4 Plotting routine for the Grens Project
%
%        PLOTGP4(AppendixCharacter,StartNumber)
%        creates 4 PS-files for the Grens Project
%        all pages: right pages
%
%        PLOTGP4(AppendixCharacter,StartNumber,'left')
%        creates 4 PS-files for the Grens Project
%        alternating pages left and right starting with
%        left (similar for starting right).
%

if nargin<2,
  error('Missing Appendix character or figure number. Use: plotgp4(''A'',4)');
end

if nargin==3
  switch lower(Left)
  case 'left'
    Left=1;
  case 'right'
    Left=-1;
  end
else
  Left=0;
end

I.PrtID='PS file';
I.Method=1;
I.DPI=150;
I.AllFigures=1;
I.Color=1;
         
A=findobj(gcf,'tag','plotax');
t2=findobj(gcf,'tag','plottext2');
t3=findobj(gcf,'tag','plottext3');
t6=findobj(gcf,'tag','plottext6');
B=get(t2,'parent');

Loc=pwd;

%upstream
set(A,'xlim',[2527000,2535000],'ylim',[5727000 5737000],'view',[90 90])
if Left>0, set(B,'ydir','reverse'); else, set(B,'ydir','normal'); end, Left=-Left;
set(t2,'string',{'Section 1'})
set(t3,'string',{'Rkm 825-837'})
set(t6,'string',{sprintf('Figure %s-%i',App,Nr)})
fn=sprintf('%s/%s-%i.ps',Loc,App,Nr);
md_print(gcf,I,fn)

Nr=Nr+1;
%Rees-Dornick
set(A,'xlim',[2520000,2528000],'ylim',[5734000 5744000],'view',[90 90])
if Left>0, set(B,'ydir','reverse'); else, set(B,'ydir','normal'); end, Left=-Left;
set(t2,'string',{'Section 2'})
set(t3,'string',{'Rkm 837-849'})
set(t6,'string',{sprintf('Figure %s-%i',App,Nr)})
fn=sprintf('%s/%s-%i.ps',Loc,App,Nr);
md_print(gcf,I,fn)

Nr=Nr+1;
%Emmerich
set(A,'xlim',[2510000,2520000],'ylim',[5741000 5749000],'view',[0 90])
if Left>0, set(B,'ydir','reverse'); else, set(B,'ydir','normal'); end, Left=-Left;
set(t2,'string',{'Section 3'})
set(t3,'string',{'Rkm 849-859'})
set(t6,'string',{sprintf('Figure %s-%i',App,Nr)})
fn=sprintf('%s/%s-%i.ps',Loc,App,Nr);
md_print(gcf,I,fn)

Nr=Nr+1;
%downstream
set(A,'xlim',[2500000,2510000],'ylim',[5743000 5751000],'view',[0 90])
if Left>0, set(B,'ydir','reverse'); else, set(B,'ydir','normal'); end, Left=-Left;
set(t2,'string',{'Section 4'})
set(t3,'string',{'Rkm 859-867'})
set(t6,'string',{sprintf('Figure %s-%i',App,Nr)})
fn=sprintf('%s/%s-%i.ps',Loc,App,Nr);
md_print(gcf,I,fn)
