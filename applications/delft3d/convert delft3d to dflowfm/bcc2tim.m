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

% Name bct-file
bccid                    = get(handles.listbox9,'Value');
bccentry                 = get(handles.listbox9,'String');
bccshort                 = bccentry(bccid,:);
bccshort(bccshort==' ')  = [];
bccshort(end-3:end)      = [];
ddbcc                    = [pathin,'/',bccshort,'.bcc'];

% Name pli-file
pliid       = get(handles.listbox10,'Value');
aantpli     = length(pliid);
for i=1:aantpli;
    plientry                     = get(handles.listbox10,'String');
    plishortls                   = plientry(pliid(i),:);
    plishortls(plishortls==' ')  = [];
    plishortls(end-3:end)        = [];
    plishort(i,:)                = plishortls;
end
plibasis          = plishort(1,1:end-7);

% Read location names from pli-file
teller            = 1;
for i=1:aantpli;
    plifile       = [pathout,'/',plishort(i,:),'.pli'];
    fid2          = fopen(plifile,'r');
    tline         = fgetl(fid2);
    tline         = fgetl(fid2);
    tlinenum      = str2num(tline);
    J             = tlinenum(1);
    for j=1:J;
        tline          = fgetl(fid2);
        tline          = textscan(tline,'%s%s%s');
        loc{teller}    = tline{3};
        teller         = teller + 1;
        perm(teller,1) = str2num(plishort(i,end-5:end-4));
        perm(teller,2) = j;
    end
end
perm(1,:) = [];
fclose all;

% Read the bcc-file
fid1        = fopen(ddbcc,'r');
I           = 1e8;
J           = 1e8;
JJ          = 1e8;
tellerA     = 1;
tellerB     = 2;
dataA       = zeros(1,2);
dataB       = zeros(1,2);
wb          = waitbar(0,'Writing tim-files for constituents ...');
for i=1:I;
    tline   = fgetl(fid1);
	if tline<0;
	    break;
	else
	    if strcmp(tline( 1:20),'location            ');
		    location                 = tline(21:end);
            location(location=='''') = [];
            location(location==' ')  = [];
            if strcmp(location,loc{tellerA});
                for j=1:J;
                    tline                  = fgetl(fid1);
                    bcctype                = tline(21:end);
                    bcctype(bcctype=='''') = [];
                    bcctype(bcctype==' ')  = [];
                    if strcmp(bcctype(end-4:end),'[ppt]');
                        for jj=1:JJ;
                            tline                  = fgetl(fid1);
                            if strcmp(tline( 1:20),'records-in-table    ');
                                aantrecords  = str2num(tline(22:end));
                                for k=1:aantrecords;
                                    tline           = fgetl(fid1);
                                    tlinenum        = str2num(tline);
                                    tlinedata       = tlinenum(2:end);
                                    tlinedataA      = tlinedata(                    1:length(tlinedata)/2);  % prevents crash if data is 3D
                                    tlinedataB      = tlinedata(length(tlinedata)/2+1:end                );  % prevents crash if data is 3D
                                    if tlinedataB(end)==9.9999900e+002;
                                        tlinedataB(end)    = tlinedataA(end);
                                    end
                                    dataA           = [dataA; tlinenum(1) tlinedataA(end)];
                                    dataB           = [dataB; tlinenum(1) tlinedataB(end)];
                                end
                                dataA(1,:)   = [];
                                dataB(1,:)   = [];
                                nametimA     = [pathout,'/',plibasis,'_',num2str(perm(tellerA,1),'%0.2d'),'_sal_',num2str(perm(tellerA,2),'%0.4d'),'.tim'];
                                nametimB     = [pathout,'/',plibasis,'_',num2str(perm(tellerB,1),'%0.2d'),'_sal_',num2str(perm(tellerB,2),'%0.4d'),'.tim'];
                                dlmwrite(nametimA,dataA,'delimiter','\t','precision','%1.7e');
                                dlmwrite(nametimB,dataB,'delimiter','\t','precision','%1.7e');
                                dataA        = zeros(1,2);
                                dataB        = zeros(1,2);
                                waitbar(tellerA/size(perm,1),wb);
                                tellerA      = tellerA + 2;
                                tellerB      = tellerB + 2;
                                if tellerA>size(perm,1);
                                    close(wb);
                                    msgbox('Timeserie files for constituents have succesfully been generated.','Message');
                                    return;
                                end
                                break;
                            end
                        end
                        break;
                    end
                end
            end
        end
    end
end