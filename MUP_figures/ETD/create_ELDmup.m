%script to generate a Muppet file for Marsdiep ETD
clear all close all
%%
nr = 1; %number of rows
nc = 1; %number of colums
tsteps = nr*nc %number of plots

runp    = {'eld'};
dataset = {'eld'};
grid    = {'ELD.grd'}

rpath = ['c:\Waddenzee\paper\figures\create_inlet_figures\ETD\' char(runp(1)) '\']
rpath2 = ['"c:\\Waddenzee\\paper\\figures\\create_inlet_figures\\ETD\\' char(runp(1)) '\\']
rpath3 = ['"c:\\Waddenzee\\paper\\figures\\create_inlet_figures\\polygons\\']

cd(rpath);
%script to write muppet files
year = {'1926','1971','1976','1981','1987','1991','1993','1996','1999','2000','2003','2005','2006'};
year = {'1926','1971','1976','1981','1987','1993','1996','1999','2000','2003','2006'};

for Y = 1:length(year)
    fid = fopen(['plot-' char(runp) '-' char(year(Y)) '.mup'],'w');
    fprintf(fid, '# Muppet v3.21 - File created by eelias-pr - 2010-07-06 10:50:23\n');
    %get the depth file
    fprintf(fid, ['Dataset   "' char(dataset) char(year(Y)) '"']);fprintf(fid,'\n');
    fprintf(fid, 'FileType  "D3Ddepth"\n');
    fprintf(fid, ['File     ' char(rpath2) char(dataset) char(year(Y)) '.dep"']);fprintf(fid,'\n');
    fprintf(fid, ['GrdFile     ' char(rpath2) char(grid) '"']);fprintf(fid,'\n');

    fprintf(fid, 'EndDataset\n');fprintf(fid,'\n');

    %get the landboundary
    fprintf(fid, ['Dataset   "nedlijnp.ldb"']);fprintf(fid,'\n');
    fprintf(fid, 'FileType  "Polyline"\n');
    fprintf(fid, ['File     ' char(rpath3) 'nedlijnp.ldb"']);fprintf(fid,'\n');
    fprintf(fid, 'EndDataset\n');fprintf(fid,'\n');
    %get the landboundary
    fprintf(fid, ['Dataset   "Md_buiten_tot.ldb"']);fprintf(fid,'\n');
    fprintf(fid, 'FileType  "Polyline"\n');
    fprintf(fid, ['File     ' char(rpath3) 'Eld_buiten_tot.ldb"']);fprintf(fid,'\n');
    fprintf(fid, 'EndDataset\n');fprintf(fid,'\n');

    y = 25.04;  %letter 8'5 x 11"  minus 1" margins
    x = 19.05;

    marginx        = 1.5; marginy         = 1.5;
    subplotmarginx = .1 ; subplotmarginy = .1

    fprintf(fid, 'Figure "1"\n');fprintf(fid, '\n');
    fprintf(fid, 'Orientation p\n');
    fprintf(fid, ['PaperSize   ' num2str(x) ' ' num2str(y)]);fprintf(fid,'\n');
    fprintf(fid, 'Frame       none\n');fprintf(fid, '\n');

    plotsizex = (x - (2*marginx+((nc-1)*subplotmarginx)))/nc
    plotsizey = (y - (2*marginy+((nr-1)*subplotmarginy)))/nr
    yt = y-marginy-plotsizey;
    tel = 1;
    for i = 1:nr
        xt = marginx;
        for j = 1: nc
            x1(tel) = xt;
            y1(tel) = yt;
            dx(tel) = plotsizex;
            dy(tel) = plotsizey;

            xt = xt + plotsizex+subplotmarginx;
            tel = tel+1
        end
        yt = yt - plotsizey-subplotmarginy;
    end

    %for spl = 1
    fprintf(fid, ['Subplot   "Subplot 1"']);fprintf(fid, '\n');
    fprintf(fid, ['Position   ' num2str(x1(1)) ' ' num2str(y1(1)) ' ' num2str(dx(1)) ' ' num2str(dy(1))]);fprintf(fid,'\n');
    fprintf(fid, 'PlotType   "2d"\n');
    fprintf(fid, 'XAxis      103355.7552 125507.4158\n');
    fprintf(fid, 'YAxis      563131.0585 593549.9121\n');
    fprintf(fid, 'XTick      5000\n');
    fprintf(fid, 'YTick      5000\n');
    fprintf(fid, 'DecimalsX  -1\n');
    fprintf(fid, 'DecimalsY  -1\n');
    fprintf(fid, 'XTickMultiply 0.001\n');
    fprintf(fid, 'YTickMultiply 0.001\n');
    fprintf(fid, 'Scale     145461.455\n');
    fprintf(fid, ['Title      "Eierlandse Gat ' char(year(Y)) '"']);fprintf(fid, '\n');
    fprintf(fid, 'XLabel     "X [km]"\n');
    fprintf(fid, 'YLabel     "Y [km]"\n');
    fprintf(fid, 'Colormap   "jet"\n');
    fprintf(fid, 'ColorBar   yes\n');
    fprintf(fid, 'ColorBarPosition 2.5           10          0.5           12.5\n');
    fprintf(fid, 'ColorBarLabel "bed level [m to NAP]"\n');
    fprintf(fid, 'BarDecim   -1\n');
    fprintf(fid, 'Contours   -40 10 10\n');

    fprintf(fid, ['Dataset "' char(dataset) char(year(Y)) '"']);fprintf(fid, '\n');
    fprintf(fid, 'PlotRoutine   "PlotShadesMap"\n');
    fprintf(fid, 'EndDataset\n');fprintf(fid, '\n');

    fprintf(fid, 'Dataset "nedlijnp.ldb"\n');
    fprintf(fid, 'PlotRoutine   "PlotPolyline"\n');
    fprintf(fid, 'LineStyle     "-" \n');
    fprintf(fid, 'LineWidth     0.5\n');
    fprintf(fid, 'LineColor     "Black"\n');
    fprintf(fid, 'FillPolygons  yes\n');
    fprintf(fid, 'FillColor     "LightGreen"\n');
    fprintf(fid, 'EndDataset\n');fprintf(fid, '\n');

    fprintf(fid, 'Dataset "Md_buiten_tot.ldb"\n');
    fprintf(fid, 'PlotRoutine   "PlotPolyline"\n');
    fprintf(fid, 'LineStyle     "--" \n');
    fprintf(fid, 'LineWidth     0.5\n');
    fprintf(fid, 'LineColor     "Black"\n');
    fprintf(fid, 'EndDataset\n');fprintf(fid, '\n');

    fprintf(fid, 'EndSubplot\n');fprintf(fid, '\n');
    
    fprintf(fid, ['OutputFile "' char(dataset) char(year(Y)) '.png"']); fprintf(fid, '\n');
    fprintf(fid, 'Format     "png"\n');
    fprintf(fid, 'Resolution 300\n');
    fprintf(fid, 'Renderer   "zbuffer"\n');
    fprintf(fid, 'EndFigure\n');
    %end
    fclose(fid)

    dos(['c:\Delft3D\w32\muppet\bin\muppet.exe plot-' char(runp) '-' char(year(Y)) '.mup']);
end

