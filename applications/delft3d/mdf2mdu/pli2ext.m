fclose all; 
clc       ;

% Check if the directories have been set
pathin      = get(handles.edit1,'String');
pathout     = get(handles.edit2,'String');
if isempty(pathin);
    errordlg('The input directory has not been assigned','Error');
    return;
end
if isempty(pathout);
    errordlg('The output directory has not been assigned','Error');
    return;
end
if exist(pathin,'dir')==0;
    errordlg('The input directory does not exist.','Error');
    return;
end
if exist(pathout,'dir')==0;
    errordlg('The output directory does not exist.','Error');
    return;
end

% Read the name of the ext-file and open it
extnameread = get(handles.edit3,'String');
if isempty(extnameread);
    errordlg('The ext-file name has not been assigned','Error');
    return;
end
if length(extnameread)>3;
    if strcmp(extnameread(end-3:end),'.ext');
        extname   = extnameread(1:end-4);
    else
        extname   = extnameread;
    end
else
    extname = extnameread;
end
pliid       = get(handles.listbox5,'Value');       % listbox5 contains all pli-file (bct, bca, bcc)
plientry    = get(handles.listbox5,'String');
fid1        = fopen([pathout,'/',extname,'.ext'],'w');

% Write header of ext file
fprintf(fid1,'%s\n','* QUANTITY    : waterlevelbnd, velocitybnd, dischargebnd, tangentialvelocitybnd, normalvelocitybnd  filetype=9         method=2,3');
fprintf(fid1,'%s\n','*             : salinitybnd                                                                         filetype=9         method=2,3');
fprintf(fid1,'%s\n','*             : lowergatelevel, damlevel                                                            filetype=9         method=2,3');
fprintf(fid1,'%s\n','*             : frictioncoefficient, horizontaleddyviscositycoefficient, advectiontype              filetype=4,10      method=4');
fprintf(fid1,'%s\n','*             : initialwaterlevel, initialsalinity                                                  filetype=4,10      method=4');
fprintf(fid1,'%s\n','*             : windx, windy, windxy, rain, atmosphericpressure                                     filetype=1,2,4,7,8 method=1,2,3');
fprintf(fid1,'%s\n','*');
fprintf(fid1,'%s\n','* kx = Vectormax = Nr of variables specified on the same time/space frame. Eg. Wind magnitude,direction: kx = 2');
fprintf(fid1,'%s\n','* FILETYPE=1  : uniform              kx = 1 value               1 dim array      uni');
fprintf(fid1,'%s\n','* FILETYPE=2  : unimagdir            kx = 2 values              1 dim array,     uni mag/dir transf to u,v, in index 1,2');
fprintf(fid1,'%s\n','* FILETYPE=3  : svwp                 kx = 3 fields  u,v,p       3 dim array      nointerpolation');
fprintf(fid1,'%s\n','* FILETYPE=4  : arcinfo              kx = 1 field               2 dim array      bilin/direct');
fprintf(fid1,'%s\n','* FILETYPE=5  : spiderweb            kx = 3 fields              3 dim array      bilin/spw');
fprintf(fid1,'%s\n','* FILETYPE=6  : curvi                kx = ?                                      bilin/findnm');
fprintf(fid1,'%s\n','* FILETYPE=7  : triangulation        kx = 1 field               1 dim array      triangulation');
fprintf(fid1,'%s\n','* FILETYPE=8  : triangulation_magdir kx = 2 fields consisting of Filetype=2      triangulation in (wind) stations');
fprintf(fid1,'%s\n','* FILETYPE=9  : poly_tim             kx = 1 field  consisting of Filetype=1      line interpolation in (boundary) stations');
fprintf(fid1,'%s\n','* FILETYPE=10 : inside_polygon       kx = 1 field                                uniform value inside polygon for INITIAL fields');

fprintf(fid1,'%s\n','*');
fprintf(fid1,'%s\n','* METHOD  =0  : provider just updates, another provider that pointers to this one does the actual interpolation');
fprintf(fid1,'%s\n','*         =1  : intp space and time (getval) keep  2 meteofields in memory');
fprintf(fid1,'%s\n','*         =2  : first intp space (update), next intp. time (getval) keep 2 flowfields in memory');
fprintf(fid1,'%s\n','*         =3  : save weightfactors, intp space and time (getval),   keep 2 pointer- and weight sets in memory');
fprintf(fid1,'%s\n','*         =4  : only spatial interpolation');
fprintf(fid1,'%s\n','*');
fprintf(fid1,'%s\n','* OPERAND =+  : Add');
fprintf(fid1,'%s\n','*         =O  : Override');
fprintf(fid1,'%s\n','*');
fprintf(fid1,'%s\n','* VALUE   =   : Offset value for this provider');
fprintf(fid1,'%s\n','*');
fprintf(fid1,'%s\n','* FACTOR  =   : Conversion factor for this provider');
fprintf(fid1,'%s\n','*');
fprintf(fid1,'%s\n\n','**************************************************************************************************************');

% Find all pli-files in directory
for i=1:length(pliid);
    file              = plientry(pliid(i),:);
    file(file==' ')   = [];
    if strcmp(file(end-2:end),'pli');
        if     strcmp(file(end-7:end-4),'_tem');
            type  = 'temperaturebnd';                    % not supported by FM
        elseif strcmp(file(end-7:end-4),'_sal');
            type  = 'salinitybnd';
        else
            polyline      = file(1:end-3);
            fid2          = fopen([pathout,'/',file],'r');
            for j=1:3;
                tline     = fgetl(fid2);
            end
            tlinecell     = textscan(tline,'%s%s%s%s%s%s%s');
            tlinestr      = cell2mat(tlinecell{4});
            switch tlinestr;
                case 'Z';
                    type  = 'waterlevelbnd';
                case 'C';
                    type  = 'velocitybnd';
                case 'N';
                    type  = 'neumannbnd';                % not supported by FM
                case 'Q';
                    type  = 'dischargepergridcellbnd';   % not supported by FM
                case 'T';
                    type  = 'dischargebnd';
                case 'R';
                    type  = 'riemannbnd';
            end
        end
        fprintf(fid1,['QUANTITY='  ,type,'\n']);
        fprintf(fid1,['FILENAME='  ,file,'\n']);
        fprintf(fid1,['FILETYPE=9'      ,'\n']);
        fprintf(fid1,['METHOD=3'        ,'\n']);
        fprintf(fid1,['OPERAND=O'       ,'\n']);
        fprintf(fid1,[                  ' \n']);
    end
end
fclose all;

% Message
msgbox('Boundary conditions have correctly been assigned.','Message');