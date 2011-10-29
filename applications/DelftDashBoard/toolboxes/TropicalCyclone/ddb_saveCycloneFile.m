function ddb_saveCycloneFile(handles,filename)
% DDB - Saves cyclone track to cyc file

inp=handles.Toolbox(tb).Input;

fid = fopen(filename,'w');

% time=clock;
datestring=datestr(datenum(clock),31);

usrstring='- Unknown user';
usr=getenv('username');

if size(usr,1)>0
    usrstring=[' - File created by ' usr];
end

txt=['# Tropical Cyclone Toolbox - DelftDashBoard v' handles.delftDashBoardVersion usrstring ' - ' datestring];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

txt=['Name              "' inp.name '"'];
fprintf(fid,'%s \n',txt);

txt=['Method            ' num2str(inp.method)];
fprintf(fid,'%s \n',txt);

txt=['InitialEyeSpeed   ' num2str(inp.initSpeed)];
fprintf(fid,'%s \n',txt);

txt=['InitialEyeDir     ' num2str(inp.initDir)];
fprintf(fid,'%s \n',txt);

txt=['SpiderwebRadius   ' num2str(inp.radius)];
fprintf(fid,'%s \n',txt);

txt=['NrRadialBins      ' num2str(inp.nrRadialBins)];
fprintf(fid,'%s \n',txt);

txt=['NrDirectionalBins ' num2str(inp.nrDirectionalBins)];
fprintf(fid,'%s \n',txt);

if strcmpi(inp.quadrantOption,'uniform')
    txt='InputPerQuadrant  0';
else
    txt='InputPerQuadrant  1';
end
fprintf(fid,'%s \n',txt);

fprintf(fid,'%s\n','');            

%     inp.trackVMax(isnan(inp.trackVMax))=-999;
%     inp.trackRMax(isnan(inp.trackRMax))=-999;
%     inp.trackPDrop(isnan(inp.trackPDrop))=-999;
%     inp.trackA(isnan(inp.trackA))=-999;
%     inp.trackB(isnan(inp.trackB))=-999;
%     inp.trackR100(isnan(inp.trackR100))=-999;
%     inp.trackR65(isnan(inp.trackR65))=-999;
%     inp.trackR50(isnan(inp.trackR50))=-999;
%     inp.trackR35(isnan(inp.trackR35))=-999;

if strcmpi(inp.quadrantOption,'uniform')
    
    % Comment
    switch inp.method
        case 1
            txt1='#             Date   Time      Lat      Lon     Vmax     ParB     ParA';
        case 2
            txt1='#             Date   Time      Lat      Lon     Vmax      R35      R50      R65     R100';
        case 3
            txt1='#             Date   Time      Lat      Lon     Vmax     Rmax    Pdrop';
        case 4
            txt1='#             Date   Time      Lat      Lon     Vmax    Pdrop';
        case 5
            txt1='#             Date   Time      Lat      Lon     Vmax     Rmax';
        case 6
            txt1='#             Date   Time      Lat      Lon     Vmax';
    end
    fprintf(fid,'%s\n',txt1);
    
    for i=1:inp.nrTrackPoints
        txt=['TrackData ' datestr(inp.trackT(i),'yyyymmdd HHMMSS')];
        switch inp.method
            case 1
                fmt='%s %8.3f %8.3f %8.1f %8.3f %8.3f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i),inp.trackVMax(i),inp.trackB(i),inp.trackA(i));
            case 2
                fmt='%s %8.3f %8.3f %8.1f %8.1f %8.1f %8.1f %8.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i),inp.trackVMax(i),inp.trackR35(i,1),inp.trackR50(i,1),inp.trackR65(i,1),inp.trackR100(i,1));
            case 3
                fmt='%s %8.3f %8.3f %8.1f %8.1f %8.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i),inp.trackVMax(i,1),inp.trackRMax(i,1),inp.trackPDrop(i,1));
            case 4
                fmt='%s %8.3f %8.3f %8.1f %8.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i),inp.trackVMax(i,1),inp.trackPDrop(i,1));
            case 5
                fmt='%s %8.3f %8.3f %8.1f %8.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i),inp.trackVMax(i,1),inp.trackRMax(i,1));
            case 6
                fmt='%s %8.3f %8.3f %8.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i),inp.trackVMax(i,1));
        end
    end
    
else

    % Comment
    switch inp.method
        case 1
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW) ParB (NE) ParB (NW) ParB (SW) ParB (SE) ParA (NE) ParA (NW) ParA (SW) ParA (SE)';
        case 2
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW)  R35 (NE)  R35 (NW)  R35 (SW)  R35 (SE)  R50 (NE)  R50 (NW)  R50 (SW)  R50 (SE)  R65 (NE)  R65 (NW)  R65 (SW)  R65 (SE) R100 (NE) R100 (NW) R100 (SW) R100 (SE)';
        case 3
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW) Rmax (NE) Rmax (NW) Rmax (SW) Rmax (SE) Pdrop(NE) Pdrop(NW) Pdrop(SW) Pdrop(SE)';
        case 4
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW) Pdrop(NE) Pdrop(NW) Pdrop(SW) Pdrop(SE)';
        case 5
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW) Rmax (NE) Rmax (NW) Rmax (SW) Rmax (SE)';
        case 6
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW)';
    end
    fprintf(fid,'%s\n',txt1);
    
    for i=1:inp.nrTrackPoints
        txt=['TrackData ' datestr(inp.trackT(i),'yyyymmdd HHMMSS')];
        switch inp.method
            case 1
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i), ...
                    inp.trackVMax(i,1),inp.trackVMax(i,2),inp.trackVMax(i,3),inp.trackVMax(i,4), ...
                    inp.trackB(i,1),inp.trackB(i,2),inp.trackB(i,3),inp.trackB(i,4),inp.trackA(i,1),inp.trackA(i,2),inp.trackA(i,3),inp.trackA(i,4));
            case 2
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i), ...
                    inp.trackVMax(i,1),inp.trackVMax(i,2),inp.trackVMax(i,3),inp.trackVMax(i,4), ...
                    inp.trackR35(i,1),inp.trackR35(i,2),inp.trackR35(i,3),inp.trackR35(i,4), ...
                    inp.trackR50(i,1),inp.trackR50(i,2),inp.trackR50(i,3),inp.trackR50(i,4), ...
                    inp.trackR65(i,1),inp.trackR65(i,2),inp.trackR65(i,3),inp.trackR65(i,4), ...
                    inp.trackR100(i,1),inp.trackR100(i,2),inp.trackR100(i,3),inp.trackR100(i,4));
            case 3
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i), ...
                    inp.trackVMax(i,1),inp.trackVMax(i,2),inp.trackVMax(i,3),inp.trackVMax(i,4), ...
                    inp.trackRMax(i,1),inp.trackRMax(i,2),inp.trackRMax(i,3),inp.trackRMax(i,4), ...
                    inp.trackPDrop(i,1),inp.trackPDrop(i,2),inp.trackPDrop(i,3),inp.trackPDrop(i,4));
            case 4
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i), ...
                    inp.trackVMax(i,1),inp.trackVMax(i,2),inp.trackVMax(i,3),inp.trackVMax(i,4), ...
                    inp.trackPDrop(i,1),inp.trackPDrop(i,2),inp.trackPDrop(i,3),inp.trackPDrop(i,4));
            case 5
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i), ...
                    inp.trackVMax(i,1),inp.trackVMax(i,2),inp.trackVMax(i,3),inp.trackVMax(i,4), ...
                    inp.trackRMax(i,1),inp.trackRMax(i,2),inp.trackRMax(i,3),inp.trackRMax(i,4));
            case 6
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,inp.trackY(i),inp.trackX(i),inp.trackVMax(i,1),inp.trackVMax(i,2),inp.trackVMax(i,3),inp.trackVMax(i,4));
        end
    end

end

fclose(fid);
