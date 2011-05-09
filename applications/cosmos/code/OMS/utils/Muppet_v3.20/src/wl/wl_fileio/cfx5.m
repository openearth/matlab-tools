function S=cfx5(filename)
if nargin==0
   filename='c:\app\cfx\cfx-5.5\examples\5.5\staticmixer.res';
end
S.FileName=filename;
S.Check='NotOK';

debug=1;
  if debug,
    debug=fopen([tempdir 'cfx5.dbg'],'w');
    if debug<=0,
      debug=0;
      warning(sprintf('Cannot open debug file: %scfx5.dbg.',tempdir));
    else,
      fprintf(1,'Writing to debug file: %scfx5.dbg ...\n',tempdir);
    end;
    YesNoStr={'No' 'Yes'};
  end;
  
fid=fopen(filename,'r','l');
if debug,
  fprintf(debug,'Opened file: %s\n',filename);
  fprintf(debug,'Opened using filehandle: %i.\n\n',fid);
end
if ~isequal(fgetl(fid),'*INFO')
   fclose(fid);
   if debug
      fprintf(debug,'File does not start with *INFO.\n');
      fclose(debug)
   end
   return;
end
S.FileSize=sscanf(fgetl(fid),'%i'); % file size
fseek(fid,0,1);
FileSize=ftell(fid);
if ~isequal(FileSize,S.FileSize)
   fclose(fid);
   if debug
      fprintf(debug,'File size mentioned in file: %i.\n',S.FileSize);
      fprintf(debug,'Real file size: %i.\n',FileSize);
      fprintf(debug,'Stopping because sizes don''t match.\n');
      fclose(debug)
   end
   return;
end
if debug
  fprintf(debug,'File size mentioned in file is correct: %i.\n\n',S.FileSize);
  fprintf(debug,'Jumping to 10 characters before end of file and\n');
  fprintf(debug,'reading offset of file index ...\n');
end
fseek(fid,-10,1);
Offset=fscanf(fid,'%i',1);
if debug
  fprintf(debug,'\nOffset read: %i.\n',Offset);
  fprintf(debug,'Jumping to start of index...\n');
end
fseek(fid,Offset,-1);
TMP=fgetl(fid); % empty line
if debug
  fprintf(debug,'\nReading start of index:\n%s\n',TMP);
end
TMP=fgetl(fid); % 6341
if debug
  fprintf(debug,'%s\n',TMP);
end
TMP=fgetl(fid); % *INDEX
if debug
  fprintf(debug,'%s\n',TMP);
end
NItem=sscanf(fgetl(fid),'%i');
if debug
  fprintf(debug,'%i items in index:\n\n',NItem);
end
j=0; j1=0;
fprintf(debug,'YN %-25s %-10s %10s %10s %10s\n','What','Where','When','RecSize','Offset');
for i=1:NItem
   Tmp=multiline(fgetl(fid),char(27),'cell');
   j=j+1;
   S.Field(j).YN=Tmp{1};
   S.Field(j).What=Tmp{2};
   S.Field(j).Where=Tmp{3};
   S.Field(j).When=str2num(Tmp{4});
   S.Field(j).RecordSize=str2num(Tmp{5});
   S.Field(j).Offset=str2num(Tmp{6});
   if debug
     fprintf(debug,'%2s %-25s %-10s %10i %10i %10i\n',S.Field(j).YN,S.Field(j).What,S.Field(j).Where,S.Field(j).When,S.Field(j).RecordSize,S.Field(j).Offset);
   end
end
TMP=fgetl(fid); % *ENDINDEX
if debug
  fprintf(debug,'\nAll index entries read, should now finish with *ENDINDEX\n');
  fprintf(debug,'%s\n\n\n',TMP);
end

if debug
  fprintf(debug,'Reading data entries:\n\n');
end
for i=1:length(S.Field)
   if debug
     fprintf(debug,'Entry %i (%s):\n',i,S.Field(i).What);
     fprintf(debug,'  Jumping to %i\n',S.Field(i).Offset);
   end
   fseek(fid,S.Field(i).Offset,-1);
   %S.Field(i).Offset=ftell(fid);
   u5=char(fread(fid,[1 3],'uchar'));
   if debug
     fprintf(debug,'  State = %i %i %i (%s) - YN = %s\n',abs(u5),u5(1:2),S.Field(i).YN);
   end
   
   N1=fread(fid,1,'int32');
   %  S.Field(i).RecordSize=N1;
   DATASET=char(fread(fid,[1 8],'uchar')); % *DATASET
   if ~strcmp(DATASET,'*DATASET')
      if debug
        fprintf(debug,'  Expected: *DATASET\n');
        fprintf(debug,'  String read: %s\n',DATASET);
        fprintf(debug,'  Stopping because of mismatch.\n');
        fclose(debug)
      end
      fclose(fid)
      return;
   else
      if debug
        fprintf(debug,'  Dataset Flag OK\n');
      end
   end
   bytesread=8;
   
   Nheader=fread(fid,1,'int32');
   Str=char(fread(fid,[1 Nheader],'uchar')); % *HEADER
   bytesread=bytesread+4+Nheader;
   if debug
     if ~strcmp(Str,'*HEADER')
        fprintf(debug,'  Expected: *HEADER\n');
        fprintf(debug,'  String read: %s\n',Str);
        fprintf(debug,'  Stopping because of mismatch.\n');
        fclose(debug)
      fclose(fid)
      return;
     else
        fprintf(debug,'  Header Flag OK\n');
     end
   end
   
   Nwhat=fread(fid,1,'int32');
   Str=char(fread(fid,[1 Nwhat],'uchar'));
   %  S.Field(i).What=Str(6:end);
   bytesread=bytesread+4+Nwhat;
   if debug
     if ~strcmp(S.Field(i).What,Str(6:end))
        fprintf(debug,'  WHAT :\n  Expected: %s\n',S.Field(i).What);
        fprintf(debug,'  String read: %s\n',Str(6:end));
        fprintf(debug,'  Stopping because of mismatch.\n');
        fclose(debug);
      fclose(fid);
      return;
     else
        fprintf(debug,'  WHAT : Match,');
     end
   end
   
   Nwhere=fread(fid,1,'int32');
   Str=char(fread(fid,[1 Nwhere],'uchar'));
   %  S.Field(i).Where=Str(7:end);
   bytesread=bytesread+4+Nwhere;
   if debug
     if ~strcmp(S.Field(i).Where,Str(7:end))
        fprintf(debug,' WHERE:\n  Expected: %s\n',S.Field(i).Where);
        fprintf(debug,'  String read: %s\n',Str(7:end));
        fprintf(debug,'  Stopping because of mismatch.\n');
        fclose(debug);
      fclose(fid);
      return;
     else
        fprintf(debug,' WHERE: Match,');
     end
   end
   
   Nwhen=fread(fid,1,'int32');
   Str=char(fread(fid,[1 Nwhen],'uchar'));
   %  S.Field(i).When=Str(6:end);
   bytesread=bytesread+4+Nwhen;
   if debug
     if ~isequal(S.Field(i).When,str2num(Str(6:end)))
        fprintf(debug,' WHEN :\n  Expected: %i\n',S.Field(i).When);
        fprintf(debug,'  String read: %s\n',Str(6:end));
        fprintf(debug,'  Stopping because of mismatch.\n');
        fclose(debug);
      fclose(fid);
      return;
     else
        fprintf(debug,' WHEN : Match\n');
     end
   end
   
   Nattrib=fread(fid,1,'int32');
   Str=char(fread(fid,[1 Nattrib],'uchar'));
   NumAttrib=str2num(Str(10:end));
   if debug
     fprintf(debug,'  Number of attributes: %i\n',NumAttrib);
   end
   bytesread=bytesread+4+Nattrib;
   for j=1:NumAttrib
      N=fread(fid,1,'int32');
      Str=char(fread(fid,[1 N],'uchar'));
      if debug
        fprintf(debug,'  [%i]- %-20s =>',j,Str);
      end
      S.Field(i).Attrib(1:2,j)=multiline(Str,[char(27) '=|'],'cell');
      if debug
        fprintf(debug,'  %s:%s\n',S.Field(i).Attrib{1:2,j});
      end
      bytesread=bytesread+4+N;
   end
   
   Ndatatype=fread(fid,1,'int32');
   Str=char(fread(fid,[1 Ndatatype],'uchar'));
   S.Field(i).DataType=Str(10:end);
   bytesread=bytesread+4+Ndatatype;
   if debug
     fprintf(debug,'  Datatype: %s\n',S.Field(i).DataType);
   end
   
   Nnumber=fread(fid,1,'int32');
   Str=char(fread(fid,[1 Nnumber],'uchar'));
   S.Field(i).Number=str2num(Str(8:end));
   bytesread=bytesread+4+Nnumber;
   if debug
     fprintf(debug,'  Number: %i\n',S.Field(i).Number);
   end
   
   Nblock=fread(fid,1,'int32');
   Str=char(fread(fid,[1 Nblock],'uchar'));
   S.Field(i).BlockFactor=str2num(Str(13:end));
   bytesread=bytesread+4+Nblock;
   if debug
     fprintf(debug,'  Number of elements per block: %i\n',S.Field(i).BlockFactor);
   end
   
   Ndata=fread(fid,1,'int32');
   Str=char(fread(fid,[1 Ndata],'uchar')); % *DATA
   bytesread=bytesread+4+Ndata;
   Ndatabytes=N1-bytesread-11;
   if debug
     if ~strcmp(Str,'*DATA')
        fprintf(debug,'  Expected: *DATA\n');
        fprintf(debug,'  String read: %s\n',Str);
        fprintf(debug,'  Stopping because of mismatch.\n');
        fclose(debug)
      fclose(fid)
      return;
     else
        fprintf(debug,'  Data Flag OK\n');
     end
   end
   
   S.Field(i).DataOffset=ftell(fid);
   if length(S.Field(i).DataType)>4 & strcmp(S.Field(i).DataType(1:4),'STRC')
      subfields=S.Field(i).DataType(6:end-1);
      subfields=multiline(subfields,' ','cell');
      S.Field(i).DataType=[];
      S.Field(i).DataType.Number=0;
      datatypebytes=0;
     if debug
       fprintf(debug,'  Structure\n');
      end
      for c=1:length(subfields)
         subf=subfields{c};
         cln=findstr(subf,':');
         S.Field(i).DataType(c).Type=subf(1:cln-1);
         S.Field(i).DataType(c).Number=str2num(subf(cln+1:end));
         if debug
           fprintf(debug,'    +- %i %s\n',S.Field(i).DataType(c).Number,S.Field(i).DataType(c).Type);
         end
         switch S.Field(i).DataType(c).Type
         case 'STRI'
            datatypebytes=datatypebytes+S.Field(i).DataType(c).Number;
         case 'INTR'
            datatypebytes=datatypebytes+4*S.Field(i).DataType(c).Number;
         case 'REAL'
            datatypebytes=datatypebytes+4*S.Field(i).DataType(c).Number;
         case 'DBLE'
            datatypebytes=datatypebytes+8*S.Field(i).DataType(c).Number;
         end
      end
      S.Field(i).DataTypeBytes=datatypebytes;
      S.Field(i).Compressed=(S.Field(i).DataTypeBytes*S.Field(i).Number)~=Ndatabytes;
   else
      switch S.Field(i).DataType
      case 'STRI'
         S.Field(i).DataTypeBytes=80;
         S.Field(i).Compressed=logical(0);
      case 'DBLE'
         S.Field(i).DataTypeBytes=8;
         S.Field(i).Compressed=(S.Field(i).DataTypeBytes*S.Field(i).Number)~=Ndatabytes;
      case 'REAL'
         S.Field(i).DataTypeBytes=4;
         S.Field(i).Compressed=(S.Field(i).DataTypeBytes*S.Field(i).Number)~=Ndatabytes;
      case 'INTR'
         S.Field(i).DataTypeBytes=4;
         S.Field(i).Compressed=(S.Field(i).DataTypeBytes*S.Field(i).Number)~=Ndatabytes;
      case 'CHAR'
         S.Field(i).DataTypeBytes=1;
         S.Field(i).Compressed=(S.Field(i).DataTypeBytes*S.Field(i).Number)~=Ndatabytes;
      otherwise
         S.Field(i).DataTypeBytes=NaN;
         S.Field(i).Compressed=(S.Field(i).DataTypeBytes*S.Field(i).Number)~=Ndatabytes;
      end
         S.Field(i).Compressed=(S.Field(i).DataTypeBytes*S.Field(i).Number)~=Ndatabytes;
   end
         if debug
           fprintf(debug,'  Number of bytes per element: %i\n',S.Field(i).DataTypeBytes);
           fprintf(debug,'  Total number of bytes : %i\n',S.Field(i).DataTypeBytes*S.Field(i).Number);
           fprintf(debug,'  Number of bytes in use: %i\n',Ndatabytes);
           if S.Field(i).Compressed
              fprintf(debug,'  Conclusion: data is compressed.\n');
           else
              fprintf(debug,'  Number of bytes match.\n');
           end
           fprintf(debug,'  Reading data ...\n');
       end
   if S.Field(i).Compressed
      nread=0;
      b=0;
      while nread<Ndatabytes
         % A maximum of BlockFactor elements is stored per block 
         NBytesComp=fread(fid,1,'int32');
         b=b+1;
         if debug
            fprintf(debug,'    Block %i: %i bytes\n',b,NBytesComp);
         end
         S.Field(i).Data{b}=char(fread(fid,[1 NBytesComp],'uchar'));
         if debug
            fprintf(debug,'             First two bytes: [%i %i]\n',S.Field(i).Data{b}(1:2));
         end
         nread=nread+4+NBytesComp;
      end  
   elseif isstruct(S.Field(i).DataType)
      S.Field(i).Data=char(fread(fid,[1 Ndatabytes],'uchar'));
   else
      switch S.Field(i).DataType
      case 'STRI'
         S.Field(i).Data=cellstr(char(fread(fid,[80 S.Field(i).Number],'uchar'))');
         for c=1:length(S.Field(i).Data)
            tstr=S.Field(i).Data{c};
            if ~isempty(tstr) & any(tstr==0)
               S.Field(i).Data{c}=tstr(1:(min(find(tstr==0))-1));
            end
         end
      case 'DBLE'
        S.Field(i).Data=fread(fid,[1 S.Field(i).Number],'float64');
      case 'REAL'
        S.Field(i).Data=fread(fid,[1 S.Field(i).Number],'float32');
      case 'INTR'
        S.Field(i).Data=fread(fid,[1 S.Field(i).Number],'int32');
      otherwise
        S.Field(i).Data=char(fread(fid,[1 Ndatabytes],'uchar'));
      end
   end
   Str=char(fread(fid,[1 11],'uchar')); % *ENDDATASET
   if debug
     if ~strcmp(Str,'*ENDDATASET')
        fprintf(debug,'  Expected: *ENDDATASET\n');
        fprintf(debug,'  String read: %s\n',Str);
        fprintf(debug,'  Stopping because of mismatch.\n');
        fclose(debug)
      fclose(fid)
      return;
     else
        fprintf(debug,'  End of dataset Flag OK\n');
     end
   end
   N2=fread(fid,1,'int32');
   if ~isequal(N1,N2),
     if debug
        fprintf(debug,'  End of record marker does not match opening marker.\n');
        fprintf(debug,'  Start: %i   End: %i\n',N1,N2);
        fprintf(debug,'  Stopping because of mismatch.\n');
        fclose(debug)
      end
      fclose(fid)
      return;
   end
   if debug
     fprintf(debug,'\n');
   end
end

fclose(fid);
if debug
  fprintf(debug,'-------------------------------------------------------\n');
  fprintf(debug,'Successfully finished reading CFX5 file.\n');
  fprintf(debug,'-------------------------------------------------------\n');
  fclose(debug);
end
S.Check='OK';
