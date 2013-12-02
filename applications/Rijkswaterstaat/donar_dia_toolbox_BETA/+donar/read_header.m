function [result,boh] = read_header(fid)
%read_header  reads donar header from file
%
% struct = donar.read_header(fid)
%
% reads the header from an open donar dia file that 
% it end with [wrd] where the data starts. struct is
% -1 when end-of-file was reached.
%
% [struct,position] = donar.read_header(fid) returns the
% ftell position of the begin of the header.
%
% Example:
%
%   fid = fopen('tst.dia')
%
% See also: scan_block, read_block

%     [IDT;*DIF*;A;CENT;20120510]
%     [W3H]
%     WNS;360
%     PAR;O2;zuurstof;J;7782-44-7
%     CPM;10;Oppervlaktewater
%     EHD;E;mg/l
%     HDH;NVT;Niet van toepassing
%     ORG;NVT;Niet van toepassing
%     SGK;NVT
%     IVS;NVT;Niet van toepassing
%     BTX;NVT;NVT;Niet van toepassing
%     BTN;Niet van toepassing
%     ANI;NZXXMTZRWK;Dienst Noordzee - afdeling WSM te Rijswijk
%     BHI;WDZOUTCHEMIE;RWS WD - afdeling monitoring en laboratorium te Lelystad
%     BMI;NZXXMTZRWK;Dienst Noordzee - afdeling WSM te Rijswijk
%     OGI;WDMON_FERRYBOX;Waterdienst Ferrybox metingen Noordzee
%     GBD;NOORDZE;Noordzee  (internationaal)
%     LOC;NOORDZEW84;Noordzeegrid;G;W84;-5000000;47000000
%     GRD;0
%     ANA;ONB;Onbekend
%     BEM;VELDMTG;Veldmeting, directe bepaling in het veld
%     BEW;NVT;Niet van toepassing
%     VAT;FERRBXNZ;Ferrybox met ingebouwde sensoren (Dir. Noordzee)
%     TYP;D4
%     [RKS]
%     TYD;20050228;1710;20051221;1710
%     PLT;WATSGL
%     SYS;CENT
%     STA;O
%     BGS;2395400;51324559;6372999;55204559
%     [WRD]
%
% into a struct like this:
%
%     WNS: {'7788'}
%     PAR: {'INSLG'  'Instraling'  'J'}
%     CPM: {'80'  'Lucht'}
%     EHD: {'E'  'uE'}
%     HDH: {'NVT'  'Niet van toepassing'}
%     ORG: {'NVT'  'Niet van toepassing'}
%     SGK: {'NVT'}
%     IVS: {'NVT'  'Niet van toepassing'}
%     BTX: {'NVT'  'NVT'  'Niet van toepassing'}
%     BTN: {'Niet van toepassing'}
%     ANI: {'NZXXMTZRWK'  'Dienst Noordzee - afdeling WSM te Rijswijk'}
%     BHI: {'WDZOUTCHEMIE'  'RWS WD - afdeling monitoring en laboratorium te Lelystad'}
%     BMI: {'NZXXMTZRWK'  'Dienst Noordzee - afdeling WSM te Rijswijk'}
%     OGI: {'WDMON_CTD'  'Waterdienst afd. monitoring mbv CTD'}
%     GBD: {'NOORDZE'  'Noordzee  (internationaal)'}
%     LOC: {'NOORDZEW84'  'Noordzeegrid'  'G'  'W84'  '-5000000'  '47000000'}
%     GRD: {'0'}
%     ANA: {'NVT'  'Niet van toepassing'}
%     BEM: {'VELDMTG'  'Veldmeting, directe bepaling in het veld'}
%     BEW: {'NVT'  'Niet van toepassing'}
%     VAT: {'ROSSPR'  'Roset-sampler'}
%     TYP: {'D4'}
%     TYD: {'20070213'  '0736'  '20070213'  '0736'}
%     PLT: {'WATSGL'}
%     SYS: {'CENT'}
%     STA: {'O'}
%     BGS: {'6334679'  '53335821'  '6334679'  '53335821'}

    boh = ftell(fid); % begin of header
    rec = fgetl(fid);
    if rec == -1, result = -1; return; end %Is it the end of the file?
    
    line = 1;
    while ~strcmpi(rec(1:5),'[wrd]')

        rec = fgetl(fid);
        
        HDRnumcol    = length(strfind(rec,';'));
        theHDRformat = '%s';
        for l=1:HDRnumcol
         theHDRformat = ['%s',theHDRformat];
        end

        if ~strcmp(rec(1),'[')
            theinfo = textscan(rec,theHDRformat,'delimiter',';');
            for ifield=2:1:length(theinfo)
             result.(theinfo{1}{1}) = [theinfo{2:end}];
            end
        end
        
        line = line+1;
    end  