function LTR=ddb_readLTRText(filename)

LTR=ddb_initializeLTR;

fid=fopen(filename);

k=0;
n=1;

for i=1:2
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        if  i==1
            v0=strread(tx0,'%s','delimiter','=');
            charv0 = char(v0);
            tf = ~isspace(charv0);
            ActiveField = charv0(tf);
        end
        if  i==2
            v0=strread(tx0,'%s','delimiter','=');
            if      ~isnan(str2double(v0{1}))
                    LTR.(ActiveField)=str2double(v0{1});
            end
        end
    else
         v0='';
    end
end
clear ActiveField

for i=3:LTR.NumberofClimates+3
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
       if  i==3
            f0=strread(tx0,'%s','delimiter','. ');
            for jj = 1:length(f0)
                ActiveField(jj)=deblank(f0(jj));
            end
        else
            v0=strread(tx0,'%s');
            val1(i-3) = str2double(v0{1});
            val2(i-3) = str2double(v0{2});
            LTR.PRO{i-3}=v0{3};
            LTR.CFS{i-3}=v0{4};
            LTR.CFE{i-3}=v0{5};
            LTR.SCO{i-3}=v0{6};
            LTR.RAY{i-3}=v0{7};
        end  
    else
        v0='';
    end
end
LTR.ORKST=val1;
LTR.PROFH=val2;

fclose(fid);
end