function handles=ddb_saveLTR(handles)

LTRinput=handles.Model(md).Input;

LTR.NumberofClimates = LTRinput.NumberofClimates;
LTR.ORKST = LTRinput.ORKSTfile;
LTR.PROFH = LTRinput.PROFHfile;
LTR.PRO = LTRinput.PROfile;
LTR.CFS = LTRinput.CFSfile;
LTR.CFE = LTRinput.CFEfile;
LTR.SCO = LTRinput.SCOfile;
LTR.RAY = LTRinput.RAYfile;
LTR.MDA = LTRinput.MDAfile;



%%
fname=[handles.Model(md).Input.Runid '.ltr'];

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','Number of Climates');
fprintf(fid,'%s\n', num2str(LTR.NumberofClimates));
fprintf(fid,'%s\n','         ORKST     PROFH     .PRO      .CFS      .CFE      .SCO      .RAY');
    if 	LTR.NumberofClimates>1
    	for ii=1:LTR.NumberofClimates
            fprintf(fid,'     %8.4f    %8.4f   %s  %s  %s  %s  %s \n',LTR.ORKST(ii), LTR.PROFH(ii), LTR.PRO{ii}, LTR.CFS{ii}, LTR.CFE{ii}, LTR.SCO{ii}, LTR.RAY{ii});
        end
    end
fclose(fid);  
end



%{
filename=[runid '.ltr'];
fid = fopen(filename,'wt');
    fprintf(fid,'%s\n','Number of Climates');
    fprintf(fid,'%s\n', num2str(handles.Model(md).Input.NumberofClimates));
    fprintf(fid,'%s\n','         ORKST     PROFH     .PRO      .CFS      .CFE      .SCO      .RAY');
    fprintf(fid,'     %8.2f    %8.2f   ''%s''  ''%s''  ''%s''  ''%s''  ''%s'' \n',handles.Model(md).Input.ORKST, handles.Model(md).Input.PROFH, handles.Model(md).Input.PRO, handles.Model(md).Input.CFS, handles.Model(md).Input.CFE, handles.Model(md).Input.SCO, handles.Model(md).Input.RAY);
fclose(fid);
%}

%{
fname=[handles.Model(md).Input.Runid '.ltr'];

fid=fopen(fname,'w');

Names = fieldnames(LTR);

for i=1:length(Names)
            if ischar(getfield(LTR,Names{i}))
                % string
                str=[Names{i} repmat(' ',1,6-length(Names{i})) '= #' getfield(LTR,Names{i}) '#'];
            else
                % scientific
                n=length(getfield(LTR,Names{i}));
                fmt=[repmat(' %15.7e',1,n)];
                str=[Names{i} repmat(' ',1,6-length(Names{i})) '= ' num2str(getfield(LTR,Names{i}),fmt) ];
            end
            fprintf(fid,'%s\n',str);
end

fclose(fid);
end
%}
