function CodedImg=comp_mrle8(UnCodedImg,Mask),
% COMP_MRLE8 encodes an eight bit image using Microsoft Run Length Encoding
%       CodedImg=comp_mrle8(UnCodedImg,Mask)
%       Mask(i,j)==1 if UnCodedImg(i,j) should be encoded,
%       Mask(i,j)==0 if UnCodedImg(i,j) should be skipped.

CodedImg=zeros(1,prod(size(UnCodedImg)));
codenr=0;
Pointer=[1 size(UnCodedImg,1)];
run=zeros(1,255);
runlength=0;
operation=1;
  % 'equal' -> 0
  % 'move' -> 1
  % 'run' -> 2
numequal=0;
value=1;

for vert=size(UnCodedImg,1):-1:1,
  if any(Mask(vert,:)), % anything to coded in this line?
    for horz=1:size(UnCodedImg,2),
      if Mask(vert,horz)==0, % transparent / must be skipped ?
        % start or continue move
        if operation==2, % run?
          % end run
          if runlength>2, % run long enough to be written as run?
            roundedlength=2*round(runlength/2);
            if runlength~=roundedlength,
              wordfill=0;
            else,
              wordfill=[];
            end;
            CodedImg(codenr+(1:(2+roundedlength)))=[0 runlength UnCodedImg(vert,Pointer(1)+(0:(runlength-1))) wordfill];
            codenr=codenr+2+roundedlength;
          elseif runlength==2, % run of two bytes?
            % save as two equals of length one
            CodedImg(codenr+(1:4))=[1 UnCodedImg(vert,Pointer(1)) 1 UnCodedImg(vert,Pointer(1)+1)];
            codenr=codenr+4;
          elseif runlength==1, % run of one byte?
            % save as equal of length one
            CodedImg(codenr+(1:2))=[1 UnCodedImg(vert,Pointer(1))];
            codenr=codenr+2;
          end;
          Pointer(1)=horz;
          runlength=0;
          operation=1; % move!
        elseif operation==0, % equal?
          % end of equal values
          CodedImg(codenr+(1:2))=[numequal value];
          codenr=codenr+2;
          Pointer(1)=horz;
          numequal=0;
          operation=1; % move!
        end;
      else, % not transparent : must be encoded
        if operation==1, % move?
          % end of move
          while (horz>Pointer(1)) | (Pointer(2)>vert),
            if (horz-Pointer(1))>255,
              if (Pointer(2)-vert)>255,
                CodedImg(codenr+(1:4))=[0 2 255 255];
                codenr=codenr+4;
                Pointer(1)=Pointer(1)+255;
                Pointer(2)=Pointer(2)-255;
              else,
                CodedImg(codenr+(1:4))=[0 2 255 Pointer(2)-vert];
                codenr=codenr+4;
                Pointer(1)=Pointer(1)+255;
                Pointer(2)=vert;
              end;
            else,
              if (Pointer(2)-vert)>255,
                CodedImg(codenr+(1:4))=[0 2 horz-Pointer(1) 255];
                codenr=codenr+4;
                Pointer(1)=horz;
                Pointer(2)=Pointer(2)-255;
              else,
                CodedImg(codenr+(1:4))=[0 2 horz-Pointer(1) Pointer(2)-vert];
                codenr=codenr+4;
                Pointer(1)=horz;
                Pointer(2)=vert;
              end;
            end;
          end;
          value=UnCodedImg(vert,horz);
          numequal=1;
          operation=0; % equal!
        elseif operation==0, % equal?
          if value==UnCodedImg(vert,horz), % still equal?
            % continue equal if possible
            if numequal==255, % maximum number of equals reached?
              % end equal and start new
              CodedImg(codenr+(1:2))=[numequal value];
              codenr=codenr+2;
              Pointer(1)=horz;
              numequal=1;
            else,
              % continue equal
              numequal=numequal+1;
            end;
          else, % no longer equal
            % end of equal
            if numequal>1, % is it useful to save equals seperately?
              % save equal continue with run
              CodedImg(codenr+(1:2))=[numequal value];
              codenr=codenr+2;
              Pointer(1)=horz;
              runlength=1;
              numequal=1;
              operation=2; % run!
            else,
              % convert equal to run
              runlength=2;
              operation=2; % run!
              % numequal stays 1
            end;
          end; 
        elseif operation==2, % run?
          if UnCodedImg(vert,horz-1)==UnCodedImg(vert,horz), % equal to previous byte?
            % convert to equal might be possible
            if numequal>2, % equal long enough?
              % end run, continue as equal
              runlength=runlength-numequal;
              if runlength>2, % run long enough?
                % save as run
                roundedlength=2*round(runlength/2);
                if runlength~=roundedlength,
                  wordfill=0;
                else,
                  wordfill=[];
                end;
                CodedImg(codenr+(1:(2+roundedlength)))=[0 runlength UnCodedImg(vert,Pointer(1)+(0:(runlength-1))) wordfill];
                codenr=codenr+2+roundedlength;
              elseif runlength==2, % run of two bytes?
                % save as two equals of length one
                CodedImg(codenr+(1:4))=[1 UnCodedImg(vert,Pointer(1)) 1 UnCodedImg(vert,Pointer(1)+1)];
                codenr=codenr+4;
              elseif runlength==1, % run of one byte?
                % save as equal of length one
                CodedImg(codenr+(1:2))=[1 UnCodedImg(vert,Pointer(1))];
                codenr=codenr+2;
              end;
              Pointer(1)=horz-numequal;
              runlength=0;
              value=UnCodedImg(vert,horz);
              numequal=numequal+1;
              operation=0; % equal!
            else, % not yet long enough equal
              % continue for the moment as run
              runlength=runlength+1;
              numequal=numequal+1;
            end;
          else, % new byte not equal to previous one
            % continue current run if possible
            if runlength==254, % maximum run length
              % write run and start new run as equal
              % for 254 (FE) no word fill necessary, and
              % it is therefore preverable over 255 (FF)!
              CodedImg(codenr+(1:(2+runlength)))=[0 runlength UnCodedImg(vert,Pointer(1)+(0:(runlength-1)))];
              codenr=codenr+2+runlength;
              value=UnCodedImg(vert,horz);
              runlength=0;
              operation=0; % equal!
              numequal=1;
              Pointer(1)=horz;
            else, % less than maximum run length
              % continue run
              runlength=runlength+1;
              numequal=1;
            end;
          end;
        end;
      end;
%      fprintf(1,'%i %s\n',UnCodedImg(vert,horz),operation);
    end;
    if operation~=1 | Pointer(1)>1,
      if operation==2, % run?
        % end run
        if runlength>2,
          % normal save runlength
          roundedlength=2*round(runlength/2);
          if runlength~=roundedlength,
            wordfill=0;
          else,
            wordfill=[];
          end;
          CodedImg(codenr+(1:(2+roundedlength)))=[0 runlength UnCodedImg(vert,Pointer(1)+(0:(runlength-1))) wordfill];
          codenr=codenr+2+roundedlength;
          runlength=0;
          numequal=0;
          operation=1; % move!
        elseif runlength==2, % 2 bytes (not equal)
          CodedImg(codenr+(1:4))=[1 UnCodedImg(vert,Pointer(1)) 1 UnCodedImg(vert,Pointer(1)+1)];
          codenr=codenr+4;
          runlength=0;
          operation=1; % move!
        else, % runlength==1,
          CodedImg(codenr+(1:2))=[1 UnCodedImg(vert,Pointer(1))];
          codenr=codenr+2;
          runlength=0;
          operation=1; % move!
        end;
      elseif operation==0, % equal?
        % end equal
        CodedImg(codenr+(1:2))=[numequal value];
        codenr=codenr+2;
        runlength=0;
        operation=1; % move!
      else, % operation==1 & Pointer(2)>1, % move
        % don't have to do anything
      end;
      if vert==1,
        CodedImg(codenr+(1:2))=[0 1];
        codenr=codenr+2;
      else,
        CodedImg(codenr+(1:2))=[0 0];
        codenr=codenr+2;
        Pointer=[1 Pointer(2)-1];
      end;
    else,
      if vert==1,
        CodedImg(codenr+(1:2))=[0 1];
        codenr=codenr+2;
      end;
    end;
  else
    if vert==1,
      CodedImg(codenr+(1:2))=[0 1];
      codenr=codenr+2;
    end;
  end;
end;
CodedImg=CodedImg(1:codenr);