function D = donar_dia_read(fname)
%DONAR_DIA_READ   read donar *.dia file into struct (BETA)
%
%   D = donar_dia_read('f:\R\DenHelderJaar2008Debietdia.dia');
%
% with the fields ;datenum' + 'value' and the following (unprocessed) meta-info fields.
%
% CPM = compartiment
% EHD = eenheid
% HDH = hoedanigheid
% ORG = ?
% SGK = ?
% IVS = ?
% BTX = ?
% ANI = ?
% BHI = ?
% BMI = ?
% OGI = ?
% LOC = locatie
% ANA = ?
% BEM = bemonstering
% BEW = bewerking ? 
% VAT = vat? 
% TYP = type? 
% TYD = tijdsspanne ?
% PLT = plaats ?
% STA = statistiek ?
%
%See also: rijkswaterstaat

warning('beta')

% fname = 'f:\R\DenHelderJaar2008Debietdia.dia';

fid   = fopen(fname);

rec   = fgetl(fid);

D.CMT = {};

while ~strcmpi(rec(1:5),'[wrd]')

   if strcmp(rec(1),'[')
   else
      ind = strfind(rec,';');
      key = rec(1:ind(1)-1);
      val = rec(ind(1)+1:end);
      if     strcmpi(key,'cmt');D.CMT   = strvcat(D.CMT,val);
      elseif strcmpi(key,'par');D.(key) = val;
      elseif strcmpi(key,'tyd');D.(key) = val;
      elseif strcmpi(key,'loc');D.(key) = val;
      else                     ;D.(key) = val;
      end

   end

   rec   = fgetl(fid);
   
end

raw       = textscan(fid,'%f%f%s','delimiter',';:'); % ';' inside tuples and '/0:' between tuples

D.datenum = time2datenum(raw{1},raw{2}*100);

D.values  = raw{3};
D.values  = strrep(D.values,'/0',''); % remove remaining '/0' of '/0:' separator
D.values  = strrep(D.values,',','.'); % they use @$~#@%* commas as delimiter ...
D.values  = str2num(char(D.values));

fclose(fid);

% [IDT;*DIF*;A;;20100716]
% CMT;DONAR Interface Module                                      
% CMT;Export vanuit iBever 3.7.105 om: 23:58:23 op 16-7-2010      
% [W3H]
% PAR;Q;Debiet
% CPM;10;Oppervlaktewater
% EHD;E;m3/s
% HDH;NVT;niet van toepassing
% ORG;NVT;Niet van toepassing
% SGK;NVT
% IVS;NVT;Niet van toepassing
% BTX;NVT;NVT;Niet van toepassing
% ANI;EXT.HHNK;EXT.HHNK
% BHI;RIKZITSDHG;RIKZITSDHG
% BMI;NVT;Niet van toepassing
% OGI;WDMET_LABONTW;WDMET_LABONTW
% LOC;DNHLDR;Den Helder;P;RD;11473200;55105300
% ANA;F50;Berekende afvoeren uit spui en maal gegevens
% BEM;NVT;Niet van toepassing
% BEW;GEM24H;GEM24H
% VAT;ONB;Onbekend
% TYP;TN
% [RKS]
% TYD;20080101;1200;20081231;1200
% PLT;NVT;-999999999;11473200;55105300
% [TPS]
% STA;20080101;1200;20081231;1200;O
% [WRD]
% 20080101;1200;,236389E+01/0:20080102;1200;,627361E+01/0:20080103;1200;,313694E+01/0:20080104;1200;,614501E+01/0:
