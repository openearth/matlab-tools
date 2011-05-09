%
% BSI_READ   Reading of BSI File version 2.0
%            BSI = binary satellite image
%
%            S=BSI_READ('EXAMPLE.BSI') reads the BSI file named EXAMPLE.BSI
%                                      and assigns the contents to S
%
%            If the file contains more than one image, a list is shown
%            and the user is asked for the number of the desired image, or
%            it is read from the second entry IMAGE_I:
%
%            S=BSI_READ('EXAMPLE.BSI',IMAGE_I).
%
%            A part of the image can be read by specifying the desired area
%            by the two vectors ROWS and COLUMNS:
%
%            S=BSI_READ('EXAMPLE.BSI',ROWS,COLUMNS).
%
%            or
%
%            S=BSI_READ('EXAMPLE.BSI',IMAGE_I,ROWS,COLUMNS).
%
function [s]=bsi_read(file,q1,q2,q3);
if (nargin==0);
	[file,pad]=uigetfile('*.bsi');
	file=[pad file];
  nr=-1;
  rows=-1;
  columns=-1;
elseif (nargin==1);
  nr=-1;
  rows=-1;
  columns=-1;
elseif (nargin==2);
  nr=q1;
  rows=-1;
  columns=-1;
elseif (nargin==3);
  nr=-1;
  rows=q1;
  columns=q2;
elseif (nargin==4);
  nr=q1;
  rows=q2;
  columns=q3;
else,
  fprintf(1,'* Too many input parameters\n');
  return;
end;
fid=fopen(file);
if (~(fid==-1));
  a=fread(fid,1,'int8');
  while ((~(a==4)) & (~feof(fid))),
    a=fread(fid,1,'int8');
  end;
  if (~(feof(fid)));
    a=fread(fid,1,'bit24');
    v=fread(fid,1,'int32');
    w=fread(fid,1,'int32');
    l=fread(fid,1,'int32');
    n=fread(fid,1,'int32');
    frewind(fid);
    a=fread(fid,w+2,'int32');
    a=fread(fid,w+2,'int32');
    if (~(n==1));
      fprintf(1,'* The file contains multiple values per pixel\n');
    else
      fprintf(1,'* The file contains one value per pixel\n');
    end;
    a=fread(fid,[w+2,n],'int32');
    for i=1:n;
      if (a(3,i)==0);
        fprintf(1,'* %2i [unused]\n',i)
      elseif (a(3,i)==1);
        fprintf(1,'* %2i binary satellite image (start)\n',i)
      elseif (a(3,i)==2);
        fprintf(1,'* %2i binary satellite image (end)\n',i)
      elseif (a(3,i)==3);
        fprintf(1,'* %2i y distance to water above\n',i)
      elseif (a(3,i)==4);
        fprintf(1,'* %2i y distance to water below\n',i)
      elseif (a(3,i)==5);
        fprintf(1,'* %2i x distance to water left\n',i)
      elseif (a(3,i)==6);
        fprintf(1,'* %2i x distance to water right\n',i)
      elseif (a(3,i)==7);
        fprintf(1,'* %2i average water in a neighbourhood\n',i)
      elseif (a(3,i)==8);
        fprintf(1,'* %2i nearest water pixel [x-coordinate]\n',i)
      elseif (a(3,i)==9);
        fprintf(1,'* %2i nearest water pixel [y-coordinate]\n',i)
      elseif (a(3,i)==10);
        fprintf(1,'* %2i minimum distance to water\n',i)
      elseif (a(3,i)==11);
        fprintf(1,'* %2i angle of minimum distance to water\n',i)
      elseif (a(3,i)==12);
        fprintf(1,'* %2i sine of the angle of minimum distance to water\n',i)
      elseif (a(3,i)==13);
        fprintf(1,'* %2i cosine of the angle of minimum distance to water\n',i)
      elseif (a(3,i)==14);
        fprintf(1,'* %2i continuous valued satellite image\n',i)
      elseif (a(3,i)==15);
        fprintf(1,'* %2i island number\n',i)
      elseif (a(3,i)==16);
        fprintf(1,'* %2i island size\n',i)
      elseif (a(3,i)==17);
        fprintf(1,'* %2i nearest land pixel [x-coordinate]\n',i)
      elseif (a(3,i)==18);
        fprintf(1,'* %2i nearest land pixel [y-coordinate]\n',i)
      elseif (a(3,i)==19);
        fprintf(1,'* %2i minimum distance to land\n',i)
      elseif (a(3,i)==20);
        fprintf(1,'* %2i skeleton of river\n',i)
      elseif (a(3,i)==21);
        fprintf(1,'* %2i skeleton nodes, channels, and endpoints\n',i)
      elseif (a(3,i)==22);
        fprintf(1,'* %2i channel width at skeleton points\n',i)
      elseif (a(3,i)==23);
        fprintf(1,'* %2i nearest skeleton pixel [x-coordinate]\n',i)
      elseif (a(3,i)==24);
        fprintf(1,'* %2i nearest skeleton pixel [y-coordinate]\n',i)
      elseif (a(3,i)==25);
        fprintf(1,'* %2i width of nearest channel\n',i)
      elseif (a(3,i)==26);
        fprintf(1,'* %2i selected training points\n',i)
      elseif (a(2,i)==0);
        fprintf(1,'* %2i unknown contents, integer\n',i)
      else;
        fprintf(1,'* %2i unknown contents, float\n',i)
      end;
    end;
    if ((nargin>1) & (nr==0))
      fprintf(1,'* None loaded\n');
      return;
    end;
    rows=round(rows);
    if (rows==-1);
      rows=1:l;
      place=1:l;
    else;
      [rows,place]=sort(rows);
    end;
    if (columns==-1);
      columns=1:w;
    end;
    if (n==1);
      fp=a(2,1);
      s(length(rows),length(columns))=0;
      start=0;
      j=1;
      while (j<=length(rows))
        for t=start:rows(j)-1;
          if (fp==0);
            a=fread(fid,w+2,'int32');
          else;
            a=fread(fid,w+2,'float');
          end;
        end; 
        start=rows(j);
        s(place(j),:)=a(columns+2)';
        j=j+1;
      end;
    else;
      if (nr<0);
        i=input('Which of these values should be read? : ');
      else
        i=nr;
      end;
      if (i==0);
        fprintf(1,'* None loaded\n');
      else;
        fp=a(2,i);
        s(length(rows),length(columns))=0;
        start=0;
        j=1;
        while (j<=length(rows))
          for t=start:rows(j)-1;
            if (fp==0);
              a=fread(fid,[w+2,n],'int32');
            else;
              a=fread(fid,[w+2,n],'float');
            end;
          end; 
          start=rows(j);
          s(place(j),:)=a(columns+2,i)';
          j=j+1;
        end;
      end;
    end;
  end;
  fclose(fid);
else
  fprintf(1,'* Could not open file\n');
end;
