function bibtex,

%@ARTICLE{Rea85,
% author={C. J. Read},
% title={A solution to the invariant subspace problem on the space $l_1$},
% journal={Bull. London Math. Soc.},
% volume={17},
% year={1985},
% pages={305-317},
%}

fin=fopen('d:\reference','r');

fout=fopen('d:\bib','w');
%try,
while ~feof(fin),
  Line=fgetl(fin);
  if ~isempty(findstr(Line,'(Ed')), %INBOOK
    %Ammentorp, H.C., Jørgensen, G.H., and Kalken, T. van, 1998. 'FLOOD WATCH - A GIS based decision support system'  in Babovic, V., Larsen, L.C. (Eds.), Hydroinformatics '98, Proceedings of the third international conference on hydroinformatics, Copenhagen, Den-mark, 24-26 August 1998, Balkema, Rotterdam, 489-494.
    Quotes=findstr(Line,'''');
    if length(Quotes)>=2, %ARTICLE
      NamesYear=Line(1:(Quotes(1)-1)); %Ammentorp, H.C., Jørgensen, G.H., and Kalken, T. van, 1998. 
      Title=Line((Quotes(1)+1):(Quotes(2)-1)); %FLOOD WATCH - A GIS based decision support system
      BookPages=Line((Quotes(2)+1):end); %  in Babovic, V., Larsen, L.C. (Eds.), Hydroinformatics '98, Proceedings of the third international conference on hydroinformatics, Copenhagen, Den-mark, 24-26 August 1998, Balkema, Rotterdam, 489-494.
      Comma=findstr(NamesYear,',');
      Names=NamesYear(1:(Comma(end)-1)); %Ammentorp, H.C., Jørgensen, G.H., and Kalken, T. van
      Year=NamesYear((Comma(end)+1):end); % 1998. 
      Year=eval(Year,'0'); % 1998
      IN=findstr(BookPages,'in');
      BookPages=BookPages((IN(1)+3):end); % Babovic, V., Larsen, L.C. (Eds.), Hydroinformatics '98, Proceedings of the third international conference on hydroinformatics, Copenhagen, Den-mark, 24-26 August 1998, Balkema, Rotterdam, 489-494.
      RBrace=findstr(BookPages,')');
      Editors=deblank2(BookPages(1:RBrace)); %Babovic, V., Larsen, L.C. (Eds.)
      LBrace=findstr(Editors,'(');
      Editors=deblank2(Editors(1:(LBrace(1)-1))); %Babovic, V., Larsen, L.C.
      BookPages=BookPages((RBrace+1):end); %, Hydroinformatics '98, Proceedings of the third international conference on hydroinformatics, Copenhagen, Den-mark, 24-26 August 1998, Balkema, Rotterdam, 489-494.
      Comma=findstr(BookPages,',');
      Pages=BookPages((Comma(end)+1):end); % 489-494.
      Pages=deblank2(strrep(Pages,'.',' ')); % 489-494
      Book=BookPages((Comma(1)+1):(Comma(end)-1)); % Hydroinformatics '98, Proceedings of the third international conference on hydroinformatics, Copenhagen, Den-mark, 24-26 August 1998, Balkema, Rotterdam
      Comma=findstr(Book,',');
      if length(Comma)<2,
        fprintf(1,'%s\n',Line);
      else,
        Publisher=deblank2(Book((Comma(end-1)+1):end)); %Hydroinformatics '98, Proceedings of the third international conference on hydroinformatics, Copenhagen, Den-mark, 24-26 August 1998
        Book=deblank2(Book(1:(Comma(end-1)-1))); %Balkema, Rotterdam
              
        Ref=sprintf('%s%i',Names(1:3),mod(Year,100));
        Ref(Ref==',')=[];
        Ref(isspace(Ref))=[];
        CRef=sprintf('%s%i',Editors(1:3),mod(Year,100));
        CRef(CRef==',')=[];
        CRef(isspace(CRef))=[];
  
        fprintf(fout,'\n@INBOOK{%s,\n',Ref);
        fprintf(fout,'  crossref={%s},\n',CRef);
        fprintf(fout,'  author={%s},\n',Names);
        fprintf(fout,'  title={%s},\n',Title);
        fprintf(fout,'  year={%i},\n',Year);
        fprintf(fout,'  pages={%s},\n',Pages);
        fprintf(fout,'}\n');
  
        fprintf(fout,'\n@BOOK{%s,\n',CRef);
        fprintf(fout,'  editor={%s},\n',Editors);
        fprintf(fout,'  title={%s},\n',Book);
        fprintf(fout,'  publisher={%s},\n',Publisher);
        fprintf(fout,'  year={%i},\n',Year);
        fprintf(fout,'}\n');
      end;
    else,
      %Launder, B.E., and Spalding, D.B. (Eds.), 1972. Lectures in Mathematical Models of Turbulence, Academic Press, London.
      Points=findstr(Line,'.');
      NamesYear=Line(1:(Points(end-1)-1)); %Launder, B.E., and Spalding, D.B. (Eds.), 1972
      Book=Line((Points(end-1)+1):(Points(end)-1)); % Lectures in Mathematical Models of Turbulence, Academic Press, London

      Comma=findstr(NamesYear,',');
      Names=NamesYear(1:(Comma(end)-1)); %Launder, B.E., and Spalding, D.B. (Eds.)
      LBrace=findstr(Names,'(');
      Names=deblank2(Names(1:(LBrace(1)-1))); %Launder, B.E., and Spalding, D.B.
      Year=NamesYear((Comma(end)+1):end); % 1972
      Year=eval(Year,'0'); % 1972

      Comma=findstr(Book,',');
      if length(Comma)<2,
        fprintf(1,'%s\n',Line);
      else,
        Publisher=deblank2(Book((Comma(end-1)+1):end)); %Academic Press, London
        Book=deblank2(Book(1:(Comma(end-1)-1))); %Lectures in Mathematical Models of Turbulence
        
        Ref=sprintf('%s%i',Names(1:3),mod(Year,100));
        Ref(Ref==',')=[];
        Ref(isspace(Ref))=[];
  
        fprintf(fout,'\n@BOOK{%s,\n',Ref);
        fprintf(fout,'  editor={%s},\n',Names);
        fprintf(fout,'  title={%s},\n',Book);
        fprintf(fout,'  publisher={%s},\n',Publisher);
        fprintf(fout,'  year={%i},\n',Year);
        fprintf(fout,'}\n');
      end;
    end;
  else,
    Quotes=findstr(Line,'''');
    if length(Quotes)>=2, %ARTICLE
      %Ackers, P., 1991. 'Discussion', Journal of Hydraulic Research, 29:2, 263-271.
      NamesYear=Line(1:(Quotes(1)-1)); %Ackers, P., 1991. 
      Title=Line((Quotes(1)+1):(Quotes(2)-1)); %Discussion
      JournalPages=Line((Quotes(2)+1):end); %, Journal of Hydraulic Research, 29:2, 263-271.
      Comma=findstr(NamesYear,',');
      Names=NamesYear(1:(Comma(end)-1)); %Ackers, P.
      Year=NamesYear((Comma(end)+1):end); % 1991. 
      Year=eval(Year,'0'); % 1991
      Comma=findstr(JournalPages,',');
      if length(Comma)<3,
        fprintf(1,'%s\n',Line),
      else,
        Journal=deblank2(JournalPages((Comma(1)+1):(Comma(2)-1))); %Journal of Hydraulic Research
        Volume=JournalPages((Comma(2)+1):(Comma(3)-1)); % 29:2
        Colon=findstr(Volume,':');
        if ~isempty(Colon),
          Number=Volume((Colon(1)+1):end);
          Volume=Volume(1:(Colon(1)-1));
        else,
          Number='';
        end;
        Volume=deblank2(Volume); %263-271
        Number=deblank2(Number); %263-271
        Pages=JournalPages((Comma(3)+1):end); % 263-271.
        Pages=strrep(Pages,'.',' ');
        Pages=deblank2(Pages); %263-271
      
        Ref=sprintf('%s%i',Names(1:3),mod(Year,100));
        Ref(Ref==',')=[];
        Ref(isspace(Ref))=[];
        
        fprintf(fout,'\n@ARTICLE{%s,\n',Ref);
        fprintf(fout,'  author={%s},\n',Names);
        fprintf(fout,'  title={%s},\n',Title);
        fprintf(fout,'  journal={%s},\n',Journal);
        fprintf(fout,'  year={%i},\n',Year);
        fprintf(fout,'  volume={%s},\n',Volume);
        if ~isempty(Number),
          fprintf(fout,'  number={%s},\n',Number);
        end;
        fprintf(fout,'  pages={%s},\n',Pages);
        fprintf(fout,'}\n');
      end;
    else, % @BOOK
      %Launder, B.E., and Spalding, D.B., 1972. Lectures in Mathematical Models of Turbulence, Academic Press, London.
      Points=findstr(Line,'.');
      NamesYear=Line(1:(Points(end-1)-1)); %Launder, B.E., and Spalding, D.B., 1972
      Book=Line((Points(end-1)+1):(Points(end)-1)); % Lectures in Mathematical Models of Turbulence, Academic Press, London

      Comma=findstr(NamesYear,',');
      Names=NamesYear(1:(Comma(end)-1)); %Launder, B.E., and Spalding, D.B.
      Year=NamesYear((Comma(end)+1):end); % 1972
      Year=eval(Year,'0'); % 1972

      Comma=findstr(Book,',');
      if length(Comma)<2,
        fprintf(1,'%s\n',Line);
      else,
        Publisher=deblank2(Book((Comma(end-1)+1):end)); %Academic Press, London
        Book=deblank2(Book(1:(Comma(end-1)-1))); %Lectures in Mathematical Models of Turbulence
        
        Ref=sprintf('%s%i',Names(1:3),mod(Year,100));
        Ref(Ref==',')=[];
        Ref(isspace(Ref))=[];
  
        fprintf(fout,'\n@BOOK{%s,\n',Ref);
        fprintf(fout,'  author={%s},\n',Names);
        fprintf(fout,'  title={%s},\n',Book);
        fprintf(fout,'  publisher={%s},\n',Publisher);
        fprintf(fout,'  year={%i},\n',Year);
        fprintf(fout,'}\n');
      end;
    end;
  end;
end;
try,
catch,
  fprintf(1,'ERROR while processing:\n');
  fprintf(1,'%s\n',Line);
  warning(lasterr);
end;
fclose(fin);
fclose(fout);

function StrOut=deblank2(StrIn);
  StrOut=deblank(StrIn);
  FirstNonSpace=min(find(~isspace(StrOut)));
  StrOut(1:(FirstNonSpace-1))=[];