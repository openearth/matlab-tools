function binanalysis(filename,mode);
File={};
if nargin==1
  mode='l';
end
fid=fopen(filename,'r',mode);
k=1;
while ~feof(fid) & (k<100),
  k=k+1;
  if ~isempty(File) & (strcmp(File(end,1),'uchar') | strcmp(File(end,1),'linefeed')),
    C=char(fread(fid,1,'uchar'));
    while ~feof(fid) & (k<100) & (C>=32) & (C<=126) | C==10 | C==13,
      if C==10,
        if isequal(File{end,2},char(13)),
          File(end,1:2)={'linefeed','PC'};
        else,
          File(end+1,1:2)={'linefeed','UNIX'};
        end;
      else,
        File(end+1,1:2)={'uchar' C};
      end;
      C=char(fread(fid,1,'uchar'));
      k=k+1;
    end;
  end;
  if ~feof(fid),
    F=fread(fid,1,'float64');
    isF=((F<10^7) & (F>10^(-7))) | ((F>-10^7) & (F<-10^(-7))) | (F==0);
    if isF,
      File(end+1,1:2)={'float64' F};
    else,
      fseek(fid,-8,0);
      F=fread(fid,1,'float32');
      isF=((F<10^7) & (F>10^(-7))) | ((F>-10^7) & (F<-10^(-7))) | (F==0);
      if isF,
        File(end+1,1:2)={'float32' F};
      else,
        fseek(fid,-4,0);
        I=fread(fid,1,'int32');
        isI=(I<10^7) & (I>-10^7);
        if isI,
          File(end+1,1:2)={'int32' I};
        else,
          fseek(fid,-4,0);
          I=fread(fid,1,'int16');
          isI=(I<5000) & (I>-5000);
          if isI,
            if ~isempty(File) & (strcmp(File(end,1),'uchar') | strcmp(File(end,1),'linefeed')) & (I==3338),
              File(end+1,1:2)={'linefeed' 'PC'};
            else,
              File(end+1,1:2)={'int16' I};
            end;
          else,
            fseek(fid,-2,0);
            C=char(fread(fid,1,'uchar'));
            isC=((C>=32) & (C<=126));
            if isC,
              File(end+1,1:2)={'uchar' C};
            else,
              File(end+1,1:2)={'byte' abs(C)};
            end;
          end;
        end;
      end;
    end;
  end;
end;
i=2;
while i<=size(File,1)
  if strcmp(File{i,1},'uchar') & strcmp(File{i-1,1},'uchar')
    File{i-1,2}=cat(2,File{i-1,2},File{i,2});
    File(i,:)=[];
  else
    i=i+1;
  end
end
fclose(fid);
File

function Local_testje,
fid=fopen(filename,'r','ieee-be');

fseek(fid,0,1); % Go to the end of the file
flength=ftell(fid);

fseek(fid,0,-1); % Go to the begin of the file
Block=min(1024,flength);

I1_0=fread(fid,[1 Block],'uchar');
Txt=isletter(I1_0) | isspace(I1_0);

fseek(fid,0,-1); % Go to the begin of the file
BI4_0=fread(fid,[1 floor(Block/4)],'int32');
Is_BI4_0=(BI4_0<10^7) & (BI4_0>-10^7);
Bt_BI4_0=[1;1;1;1]*Is_BI4_0;
Bt_BI4_0=LBF(Bt_BI4_0,Block,4,0);

fseek(fid,1,-1);
BI4_1=fread(fid,[1 floor((Block-1)/4)],'int32');
Is_BI4_1=(BI4_1<10^7) & (BI4_1>-10^7);
Bt_BI4_1=[1;1;1;1]*Is_BI4_1;
Bt_BI4_1=LBF(Bt_BI4_1,Block,4,1);

fseek(fid,2,-1);
BI4_2=fread(fid,[1 floor((Block-2)/4)],'int32');
Is_BI4_2=(BI4_2<10^7) & (BI4_2>-10^7);
Bt_BI4_2=[1;1;1;1]*Is_BI4_2;
Bt_BI4_2=LBF(Bt_BI4_2,Block,4,2);

fseek(fid,3,-1);
BI4_3=fread(fid,[1 floor((Block-3)/4)],'int32');
Is_BI4_3=(BI4_3<10^7) & (BI4_3>-10^7);
Bt_BI4_3=[1;1;1;1]*Is_BI4_3;
Bt_BI4_3=LBF(Bt_BI4_3,Block,4,3);

fseek(fid,0,-1); % Go to the begin of the file
BF4_0=fread(fid,[1 floor(Block/4)],'float32');
Is_BF4_0=((BF4_0<10^7) & (BF4_0>10^(-7))) | ((BF4_0>-10^7) & (BF4_0<-10^(-7))) | (BF4_0==0);
Bt_BF4_0=[1;1;1;1]*Is_BF4_0;
Bt_BF4_0=LBF(Bt_BF4_0,Block,4,0);

fseek(fid,1,-1);
BF4_1=fread(fid,[1 floor((Block-1)/4)],'float32');
Is_BF4_1=((BF4_1<10^7) & (BF4_1>10^(-7))) | ((BF4_1>-10^7) & (BF4_1<-10^(-7))) | (BF4_1==0);
Bt_BF4_1=[1;1;1;1]*Is_BF4_1;
Bt_BF4_1=LBF(Bt_BF4_1,Block,4,1);

fseek(fid,2,-1);
BF4_2=fread(fid,[1 floor((Block-2)/4)],'float32');
Is_BF4_2=((BF4_2<10^7) & (BF4_2>10^(-7))) | ((BF4_2>-10^7) & (BF4_2<-10^(-7))) | (BF4_2==0);
Bt_BF4_2=[1;1;1;1]*Is_BF4_2;
Bt_BF4_2=LBF(Bt_BF4_2,Block,4,2);

fseek(fid,3,-1);
BF4_3=fread(fid,[1 floor((Block-3)/4)],'float32');
Is_BF4_3=((BF4_3<10^7) & (BF4_3>10^(-7))) | ((BF4_3>-10^7) & (BF4_3<-10^(-7))) | (BF4_3==0);
Bt_BF4_3=[1;1;1;1]*Is_BF4_3;
Bt_BF4_3=LBF(Bt_BF4_3,Block,4,3);

fseek(fid,0,-1);
BI2_0=fread(fid,[1 floor(Block/4)],'int16');
Is_BI2_0=(BI2_0<5000) & (BI2_0>-5000);

fseek(fid,1,-1);
BI2_1=fread(fid,[1 floor((Block-1)/4)],'int16');
Is_BI2_1=(BI2_1<5000) & (BI2_1>-5000);

fclose(fid);

Is_BF4=sum(Is_BF4_0)+sum(Is_BF4_1)+sum(Is_BF4_2)+sum(Is_BF4_3);
Is_BI4=sum(Is_BI4_0)+sum(Is_BI4_1)+sum(Is_BI4_2)+sum(Is_BI4_3);
BDet=Is_BF4+Is_BI4;

fid=fopen(filename,'r','ieee-le');

fseek(fid,0,-1); % Go to the begin of the file
LI4_0=fread(fid,[1 floor(Block/4)],'int32');
Is_LI4_0=(LI4_0<10^7) & (LI4_0>-10^7);
Bt_LI4_0=[1;1;1;1]*Is_LI4_0;
Bt_LI4_0=LBF(Bt_LI4_0,Block,4,0);

fseek(fid,1,-1);
LI4_1=fread(fid,[1 floor((Block-1)/4)],'int32');
Is_LI4_1=(LI4_1<10^7) & (LI4_1>-10^7);
Bt_LI4_1=[1;1;1;1]*Is_LI4_1;
Bt_LI4_1=LBF(Bt_LI4_1,Block,4,1);

fseek(fid,2,-1);
LI4_2=fread(fid,[1 floor((Block-2)/4)],'int32');
Is_LI4_2=(LI4_2<10^7) & (LI4_2>-10^7);
Bt_LI4_2=[1;1;1;1]*Is_LI4_2;
Bt_LI4_2=LBF(Bt_LI4_2,Block,4,2);

fseek(fid,3,-1);
LI4_3=fread(fid,[1 floor((Block-3)/4)],'int32');
Is_LI4_3=(LI4_3<10^7) & (LI4_3>-10^7);
Bt_LI4_3=[1;1;1;1]*Is_LI4_3;
Bt_LI4_3=LBF(Bt_LI4_3,Block,4,3);

fseek(fid,0,-1); % Go to the begin of the file
LF4_0=fread(fid,[1 floor(Block/4)],'float32');
Is_LF4_0=((LF4_0<10^7) & (LF4_0>10^(-7))) | ((LF4_0>-10^7) & (LF4_0<-10^(-7))) | (LF4_0==0);
Bt_LF4_0=[1;1;1;1]*Is_LF4_0;
Bt_LF4_0=LBF(Bt_LF4_0,Block,4,0);

fseek(fid,1,-1);
LF4_1=fread(fid,[1 floor((Block-1)/4)],'float32');
Is_LF4_1=((LF4_1<10^7) & (LF4_1>10^(-7))) | ((LF4_1>-10^7) & (LF4_1<-10^(-7))) | (LF4_1==0);
Bt_LF4_1=[1;1;1;1]*Is_LF4_1;
Bt_LF4_1=LBF(Bt_LF4_1,Block,4,1);

fseek(fid,2,-1);
LF4_2=fread(fid,[1 floor((Block-2)/4)],'float32');
Is_LF4_2=((LF4_2<10^7) & (LF4_2>10^(-7))) | ((LF4_2>-10^7) & (LF4_2<-10^(-7))) | (LF4_2==0);
Bt_LF4_2=[1;1;1;1]*Is_LF4_2;
Bt_LF4_2=LBF(Bt_LF4_2,Block,4,2);

fseek(fid,3,-1);
LF4_3=fread(fid,[1 floor((Block-3)/4)],'float32');
Is_LF4_3=((LF4_3<10^7) & (LF4_3>10^(-7))) | ((LF4_3>-10^7) & (LF4_3<-10^(-7))) | (LF4_3==0);
Bt_LF4_3=[1;1;1;1]*Is_LF4_3;
Bt_LF4_3=LBF(Bt_LF4_3,Block,4,3);

fseek(fid,0,-1);
LI2_0=fread(fid,[1 floor(Block/2)],'int16');
Is_LI2_0=(LI2_0<5000) & (LI2_0>-5000);

fseek(fid,1,-1);
LI2_1=fread(fid,[1 floor((Block-1)/2)],'int16');
Is_LI2_1=(LI2_1<5000) & (LI2_1>-5000);

fclose(fid);

Is_LF4=sum(Is_LF4_0)+sum(Is_LF4_1)+sum(Is_LF4_2)+sum(Is_LF4_3);
Is_LI4=sum(Is_LI4_0)+sum(Is_LI4_1)+sum(Is_LI4_2)+sum(Is_LI4_3);
LDet=Is_LF4+Is_LI4;


BtLFAny=Bt_LF4_0|Bt_LF4_1|Bt_LF4_2|Bt_LF4_3;
BtLIAny=Bt_LI4_0|Bt_LI4_1|Bt_LI4_2|Bt_LI4_3;
BtBFAny=Bt_BF4_0|Bt_BF4_1|Bt_BF4_2|Bt_BF4_3;
BtBIAny=Bt_BI4_0|Bt_BI4_1|Bt_BI4_2|Bt_BI4_3;

sum(BtLIAny|BtLFAny|Txt)>sum(BtBIAny|BtBFAny|Txt)
BDet
LDet
keyboard

function DataOut=LBF(Data,Block,RS,Offset),
x=Block-Offset-floor((Block-Offset)/RS)*RS;
DataOut=[zeros(1,Offset) transpose(Data(:)) zeros(1,x)];
