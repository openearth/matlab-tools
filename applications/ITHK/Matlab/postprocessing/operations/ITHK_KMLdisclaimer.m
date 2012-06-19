function disclaimer = ITHK_kmldisclaimer

global S

disclaimer1 = S.settings.postprocessing.disclaimer.string1;
disclaimer2 = S.settings.postprocessing.disclaimer.string2;
scaleFAC=1;
figure('visible','off');
set(gcf,'MenuBar','None');
set(gcf,'Position',[50 50 100 30]);
set(gcf,'PaperSize',[10,30]);
set(gcf,'PaperPosition',[0 0 10*scaleFAC 0.6*scaleFAC]);
h1=text(0,0.65,disclaimer1,'FontSize',20,'Color','y');axis off;
h2=text(0,0.25,disclaimer2,'FontSize',20,'Color','y');axis off;
set(gca,'Position',[0,0,1,1]);
print('-dpng',['plot1.png']);
I = imread('plot1.png');
axc = get(gca,'Color');
axc = ceil(axc*255);
alphaMap = ~(I(:,:,1)==axc(1) & I(:,:,2)==axc(2) & I(:,:,3)==axc(3)).*255;
imwrite(I,[S.settings.basedir '\ITviewer\openearthtest\openearthtest\public\images\disclaimer.png'],'Alpha',uint8(alphaMap));
close all
delete('plot1.png')

figtexturl{1} = ['http://127.0.0.1:5000/images/disclaimer.png'];
disclaimer = '';
timeIn    = datenum((S.PP.settings.tvec(1)+S.PP.settings.t0),1,1);
timeOut   = datenum((S.PP.settings.tvec(end)+S.PP.settings.t0),1,1)+364;
timeSpan = KML_timespan('timeIn',timeIn,'timeOut',timeOut);

disclaimer = [disclaimer sprintf([...
    '  <ScreenOverlay>\n'...
    '  <name>budgetbar</name>\n'...
    '  <visibility>1</visibility>\n'...
    '  %s\n'...
    '  <Icon><href>%s</href></Icon>\n'...
    '   <overlayXY x="0" y="0" xunits="fraction" yunits="fraction"/>\n'...
    '   <screenXY  x="0.05" y="0.8" xunits="fraction" yunits="fraction"/>\n'...
    '   <size x="0" y="0.1" xunits="fraction" yunits="fraction"/>\n'... 
    '  </ScreenOverlay>\n'],...
    timeSpan,...
    figtexturl{1})];