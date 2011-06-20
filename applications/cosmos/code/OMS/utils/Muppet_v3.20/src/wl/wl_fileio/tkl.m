function Out=tkl(cmd,varargin);
% TKL   File operations for TEKAL PCT files.
%       tkl('plot',filename);
%
%       tkl('check',filename);
%

if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;

switch cmd,
case 'plot',
  Handle=Local_plot_pct(1,varargin{:});
  if nargout>0,
    Out=Handle;
  end;
case 'check',
  Struct=Local_plot_pct(0,varargin{:});
  if nargout>0,
    Out=Struct;
  end;
otherwise,
  uiwait(msgbox('unknown command','modal'));
end;


function fig=Local_plot_pct(doplot,filename),
fig=[];
Strict=doplot;

if nargin==0,
  [fn,fp]=uigetfile('*.pct');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'rt');

if fid<0,
  return;
end;

Struct.Check='NotOK';
jb=0;
ax=1;
while ~feof(fid),

  jb=jb+1;

  J=[];
  while isempty(J)
    Line=fgetl(fid);
    if ~ischar(Line)
      J=-1;
    elseif length(Line)>=4,
      J=strmatch(Line(1:4), ...
        {'ANNO','ARST','FUND','IMAG','INPI','ISGR','ISOF','ISOL','ISUN', ...
         'LIFU','POLD','PO10','SUBS','SULL','SULT','TEXT','TXAN','TXAR', ...
         'TXLG','WQT1','WQT2'},'exact');
    end
  end
%  if isempty(Line),
%  elseif isempty(J),
%    % skip job
%    if length(Line)>=5,
%      j=1;
%      while isempty(J) & length(Line)>=j+4
%        J=strmatch(Line(j+(1:4)), ...
%          {'ANNO','ARST','FUND','IMAG','INPI','ISGR','ISOF','ISOL','ISUN', ...
%           'LIFU','POLD','PO10','SUBS','SULL','SULT','TEXT','TXAN','TXAR', ...
%           'TXLG','WQT1','WQT2'},'exact');
%        j=j+1;
%      end
%    end
%    if isempty(J),
%      fprintf('Error interpreting line: %s\n',Line);
%      break;
%    end;
%    NL=[10 7 7 4 3 17 8 7 16 5 7 11 2 11 11 4 5 5 6 6 6];
%    for i=1:NL(J),
%      Line=fgetl(fid);
%      if ~ischar(Line), break; end;
%    end;
%    if ~ischar(Line), break; end;
%    jb=jb-1;
%
%  else,
   if J>0
    
    Job=upper(deblank(Line(1:4)));
    if (jb~=1) & strcmp(Job,'INPI'),
      fprintf('Unexpected occurence of INPI job.\n');
      break;
    elseif (jb==1) & ~strcmp(Job,'INPI'),
      fprintf('Expected INPI job.\n');
      break;
    end;
    
    Info=[];
    Info.JobName=Job;
    switch Job,
    case 'ANNO',
%ANNO
% file=                              :type=     :
% coor=    :
%blank=    +       blank=    +       blank=    +       blank=    +
% matr=    :       noval=          :
% xcol=    :        ycol=    :      valcol=    :         pos=  :
% xcol=    :        ycol=    :      valcol=    :         pos=  :
% xcol=    :        ycol=    :      valcol=    :         pos=  :
% xcol=    :        ycol=    :      valcol=    :         pos=  :
%nrsym=  25:       hsymb= 2.0:     pensymb=   1:
% font=   1:       htext= 3.0:     pentext=   1:       nrdig= 0:
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7
    
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 36:42 48], ...
        ' file=                              :type=     :'),
      end;
      Line(75)=' ';
      Info.File=deblank2(Line(7:35));
      Info.Type=upper(deblank2(Line(43:47)));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        ' coor=    :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
    
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 30:42 48:60], ...
        'blank=    +       blank=    +       blank=    +       blank=    +'),
      end;
      Line(75)=' ';
      Info.Blank(1).Name=upper(Line(7:10));
      Info.Blank(1).Type=findstr('+-',Line(11));
      Info.Blank(2).Name=upper(Line(25:28));
      Info.Blank(2).Type=findstr('+-',Line(29));
      Info.Blank(3).Name=upper(Line(43:46));
      Info.Blank(3).Type=findstr('+-',Line(47));
      Info.Blank(4).Name=upper(Line(61:64));
      Info.Blank(4).Type=findstr('+-',Line(65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 35], ...
        ' matr=    :       noval=          :'),
      end;
      Line(75)=' ';
      Info.Matrix=Line(7:10);
      Info.NoVal=str2num(Line(25:34));

      for i=1:4,   
        Line=fgetl(fid);
        if ~ischar(Line), break; end;
        if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47:60 63], ...
           ' xcol=    :        ycol=    :      valcol=    :         pos=  :'),
          break;
        end;
        Info.Anno(i).XCol=str2num(Line(7:10));
        Info.Anno(i).YCol=str2num(Line(25:28));
        Info.Anno(i).ValCol=str2num(Line(43:46));
        Info.Anno(i).Pos=str2num(Line(61:62));
        if isempty(Info.Anno(i).Pos), Info.Anno(i).Pos=1; end
      end;
      if ~ischar(Line), break; end;
      
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47], ...
         'nrsym=    :       hsymb=    :     pensymb=    :'),
      end;
      Line(75)=' ';
      Info.NrSym=str2num(Line(7:10));
      Info.HSym=str2num(Line(25:28));
      Info.PenSym=str2num(Line(43:46));
      
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47:60 63], ...
         ' font=    :       htext=    :     pentext=    :       nrdig=  :'),
      end;
      Line(75)=' ';
      Info.Font=str2num(Line(7:10));
      Info.HText=str2num(Line(25:28));
      Info.PenText=str2num(Line(43:46));
      Info.NrDig=str2num(Line(61:62));
      if isempty(Info.HText), Info.HText=2; end
      if isempty(Info.PenText), Info.PenText=1; end
      if isempty(Info.NrDig), Info.NrDig=1; end

      
    case 'ARST',
%ARST
% file=                              :type=      :
% coor=    :
%blank=    +       blank=    +       blank=    +       blank=    +
% matr=    :
% xcol=    :        ycol=    :        ucol=    :        vcol=    :
%           scale  1 cm =          :  vmin=          :  stip= :
%style=    :         pen=    :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 36:42 49], ...
        ' file=                              :type=      :'),
      end;
      Line(75)=' ';
      Info.File=deblank2(Line(7:35));
      Info.Type=upper(deblank2(Line(43:48)));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        ' coor=    :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 30:42 48:60], ...
        'blank=    +       blank=    +       blank=    +       blank=    +'),
      end;
      Line(75)=' ';
      Info.Blank(1).Name=upper(Line(7:10));
      Info.Blank(1).Type=findstr('+-',Line(11));
      Info.Blank(2).Name=upper(Line(25:28));
      Info.Blank(2).Type=findstr('+-',Line(29));
      Info.Blank(3).Name=upper(Line(43:46));
      Info.Blank(3).Type=findstr('+-',Line(47));
      Info.Blank(4).Name=upper(Line(61:64));
      Info.Blank(4).Type=findstr('+-',Line(65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        ' matr=    :'),
      end;
      Line(75)=' ';
      Info.Matrix=Line(7:10);

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47:60 65], ...
         ' xcol=    :        ycol=    :        ucol=    :        vcol=    :'),
      end;
      Line(75)=' ';
      Info.XCol=str2num(Line(7:10));
      Info.YCol=str2num(Line(25:28));
      Info.UCol=str2num(Line(43:46));
      Info.VCol=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:24 35:42 53:60 62], ...
         '           scale  1 cm =          :  vmin=          :  stip= :'),
      end;
      Line(75)=' ';
      Info.Scale=str2num(Line(25:34));
      Info.Vmin=str2num(Line(43:52));
      Info.Stip=upper(Line(61));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29], ...
         'style=    :         pen=    :'),
      end;
      Line(75)=' ';
      Info.Style=str2num(Line(7:10));
      Info.Pen=str2num(Line(25:28));


    case 'INPI',
%INPI
% size=  :          type=  :
%width=     :     height=     :
%style=    :         pen=    :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 27], ...
        ' size=  :          type=  :'),
      end;
      Line(75)=' ';
      Info.Size=upper(Line(7:8)); % A0, A3, A4
      Info.Type=upper(Line(25:26)); % LV, LD, NO, BO, empty
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 30], ...
        'width=     :     height=     :'),
      end;
      Line(75)=' ';
      Info.Width=str2num(Line(7:11));
      Info.Heigth=str2num(Line(25:29));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29], ...
        'style=    :         pen=    :'),
      end;
      Line(75)=' ';
      Info.Style=str2num(Line(7:10));
      Info.Pen=str2num(Line(25:28));
  
      if isempty(strmatch(Info.Size,{'A0','A3','A4'},'exact')),
        fprintf('Unknown paper size: %s.\n',Info.Size);
      end;
      Line(75)=' ';
      
      if isempty(strmatch(Info.Type,{'LV','LD','NO','BO',''},'exact')),
        fprintf('Unknown paper type: %s.\n',Info.Type);
      end;
      Line(75)=' ';
      
    
    case 'ISGR',
%ISGR
% file=                              :type=      :
% coor=    :
%  reg=                              rgcol=    :       rgpen=    :
%blank=                              blcol=    :       blpen=    :
% matr=    :        type=          :
% xcol=    :        ycol=    :        vcol=    :      indcol=    :
%xdcol=    :       ydcol=    :      kfucol=    :      kfvcol=    :
% xleg=          :  yleg=          :  aleg=          : order=    :
% hleg=          :  wleg=          :ftnleg=    :      penleg=    :
% frmt= :           deci=    :       below=          : above=          :
%line....h..l..s.. line....h..l..s.. line....h..l..s.. line....h..l..s..
%                 :                 :                 :                 :
%                 :                 :                 :                 :
%                 :                 :                 :                 :
%                 :                 :                 :                 :
%                 :                 :                 :                 :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 36:42 49], ...
        ' file=                              :type=      :'),
      end;
      Line(75)=' ';
      Info.File=deblank2(Line(7:35));
      Info.Type=CheckStr(upper(Line(43:48)),{'ASCII','BINAIR'},0);

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        ' coor=    :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 37:42 47:60 65], ...
        '  reg=                              rgcol=    :       rgpen=    :'),
      end;
      Line(75)=' ';
      Info.Reg=deblank2(Line(7:36));
      Info.RegCol=str2num(Line(43:46));
      Info.RegPen=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 37:42 47:60 65], ...
        'blank=                              blcol=    :       blpen=    :'),
      end;
      Line(75)=' ';
      Info.Blank=deblank2(Line(7:36));
      Info.BlCol=str2num(Line(43:46));
      Info.BlPen=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 35], ...
        ' matr=    :        type=          :'),
      end;
      Line(75)=' ';
      Info.Matrix=Line(7:10);
      Info.Type=strcmp(deblank2(upper(Line(25:34))),'TRISULA');
   
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47:60 65], ...
         ' xcol=    :        ycol=    :        vcol=    :      indcol=    :'),
      end;
      Line(75)=' ';
      Info.XCol=str2num(Line(7:10));
      Info.YCol=str2num(Line(25:28));
      Info.VCol=str2num(Line(43:46));
      Info.IndexCol=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47:60 65], ...
         'xdcol=    :       ydcol=    :      kfucol=    :      kfvcol=    :'),
      end;
      Line(75)=' ';
      Info.XDCol=str2num(Line(7:10));
      Info.YDCol=str2num(Line(25:28));
      Info.KfuCol=str2num(Line(43:46));
      Info.KfvCol=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 17:24 35:42 53:60 65], ...
         ' xleg=          :  yleg=          :  aleg=          : order=    :'),
      end;
      Line(75)=' ';
      Info.XLeg=str2num(Line(7:16));
      Info.YLeg=str2num(Line(25:34));
      Info.AngleLeg=str2num(Line(43:52));
      Info.OrderLeg=str2num(Line(61:64));
      if isempty(Info.OrderLeg),
        Info.OrderLeg=0;
      else
        Info.OrderLeg=Info.OrderLeg>0;
      end

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 17:24 35:42 47:60 65], ...
         ' hleg=          :  wleg=          :ftnleg=    :      penleg=    :'),
      end;
      Line(75)=' ';
      Info.HLeg=str2num(Line(7:16));
      if isempty(Info.HLeg),
        Info.HLeg=30;
      end
      Info.WLeg=str2num(Line(25:34));
      if isempty(Info.WLeg),
        Info.WLeg=30;
      end
      Info.FontLeg=str2num(Line(43:46));
      Info.PenLeg=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 8:24 29:42 53:60 71], ...
         ' frmt= :           deci=    :       below=          : above=          :'),
      end;
      Line(75)=' ';
      Info.FormatLeg=upper(Line(7));
      Info.DeciLeg=str2num(Line(25:28));
      Info.BelowStr=Line(43:52);
      if isempty(deblank(Info.BelowStr)), Info.BelowStr='below'; end;
      Info.AboveStr=Line(61:70);
      if isempty(deblank(Info.AboveStr)), Info.AboveStr='above'; end;

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:71], ...
         'line....h..l..s.. line....h..l..s.. line....h..l..s.. line....h..l..s..'),
      end;
      Line(75)=' ';

      Info.ThresVal=zeros(20,1);
      Info.ThresCol=zeros(20,3);
      for i=0:4,
        Line=fgetl(fid);
        if ~ischar(Line), break; end;
        if Strict & ~CheckLine(Line,[18 36 54], ...
           '                 :                 :                 :                 :'),
          break;
        end;

        TmpClr=str2num(Line(1:8));
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresVal(i*4+1)=TmpClr;
        TmpClr=str2num(Line(9:11))/360;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+1,1)=TmpClr;
        TmpClr=str2num(Line(12:14))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+1,2)=TmpClr;
        TmpClr=str2num(Line(15:17))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+1,3)=TmpClr;

        TmpClr=str2num(Line(19:26));
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresVal(i*4+2)=TmpClr;
        TmpClr=str2num(Line(27:29))/360;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+2,1)=TmpClr;
        TmpClr=str2num(Line(30:32))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+2,2)=TmpClr;
        TmpClr=str2num(Line(33:35))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+2,3)=TmpClr;

        TmpClr=str2num(Line(37:44));
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresVal(i*4+3)=TmpClr;
        TmpClr=str2num(Line(45:47))/360;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+3,1)=TmpClr;
        TmpClr=str2num(Line(48:50))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+3,2)=TmpClr;
        TmpClr=str2num(Line(51:53))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+3,3)=TmpClr;

        TmpClr=str2num(Line(55:62));
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresVal(i*4+4)=TmpClr;
        TmpClr=str2num(Line(63:65))/360;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+4,1)=TmpClr;
        TmpClr=str2num(Line(66:68))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+4,2)=TmpClr;
        TmpClr=str2num(Line(69:71))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+4,3)=TmpClr;
      end;
      if ~ischar(Line), break; end;
      Info.ThresCol=hls2rgb(Info.ThresCol);
      
      
    case 'ISOF',
%ISOF
% file=                              :type=      :
% coor=    :
%blank=    +       blank=    +       blank=    +       blank=    +
% matr=    :        dumv=          :
% xcol=    :        ycol=    :        vcol=    :        icol=    :
%   v0=          :    dv=          :    vn=          :
%style=    :         pen=    :
% ndec=  :        intval=     :     height=    :       angle=     :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 36:42 49], ...
        ' file=                              :type=      :'),
      end;
      Line(75)=' ';
      Info.File=deblank2(Line(7:35));
      Info.Type=upper(deblank2(Line(43:48)));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        ' coor=    :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 30:42 48:60], ...
        'blank=    +       blank=    +       blank=    +       blank=    +'),
      end;
      Line(75)=' ';
      Info.Blank(1).Name=upper(Line(7:10));
      Info.Blank(1).Type=findstr('+-',Line(11));
      Info.Blank(2).Name=upper(Line(25:28));
      Info.Blank(2).Type=findstr('+-',Line(29));
      Info.Blank(3).Name=upper(Line(43:46));
      Info.Blank(3).Type=findstr('+-',Line(47));
      Info.Blank(4).Name=upper(Line(61:64));
      Info.Blank(4).Type=findstr('+-',Line(65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 35], ...
        ' matr=    :        dumv=          :'),
      end;
      Line(75)=' ';
      Info.Matrix=Line(7:10);
      Info.DummyValue=str2num(Line(25:34));
   
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47:60 65], ...
         ' xcol=    :        ycol=    :        vcol=    :        icol=    :'),
      end;
      Line(75)=' ';
      Info.XCol=str2num(Line(7:10));
      Info.YCol=str2num(Line(25:28));
      Info.VCol=str2num(Line(43:46));
      Info.IndexCol=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 17:24 34:42 53], ...
        '   v0=          :    dv=          :    vn=          :'),
      end;
      Line(75)=' ';
      Info.Start=str2num(Line(7:16));
      Info.Step=str2num(Line(25:33));
      Info.End=str2num(Line(43:52));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29], ...
        'style=    :         pen=    :'),
      end;
      Line(75)=' ';
      Info.Style=str2num(Line(7:10));
      Info.Pen=str2num(Line(25:28));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 30:42 47:60 66], ...
        ' ndec=  :        intval=     :     height=    :       angle=     :'),
      end;
      Line(75)=' ';
      Info.NDec=str2num(Line(7:8));
      Info.IntVal=str2num(Line(25:29));
      Info.Height=str2num(Line(43:46));
      Info.Angle=str2num(Line(61:65));


    case 'LIFU',
%LIFU
% coor=    :
%blank=    +       blank=    +       blank=    +       blank=    +
%namex=    :       namey=    :
% code=  :         begin=          :   end=          :
%style=    :         pen=    :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        ' coor=    :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 30:42 48:60], ...
        'blank=    +       blank=    +       blank=    +       blank=    +'),
      end;
      Line(75)=' ';
      Info.Blank(1).Name=upper(Line(7:10));
      Info.Blank(1).Type=findstr('+-',Line(11));
      Info.Blank(2).Name=upper(Line(25:28));
      Info.Blank(2).Type=findstr('+-',Line(29));
      Info.Blank(3).Name=upper(Line(43:46));
      Info.Blank(3).Type=findstr('+-',Line(47));
      Info.Blank(4).Name=upper(Line(61:64));
      Info.Blank(4).Type=findstr('+-',Line(65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29], ...
        'namex=    :       namey=    :'),
      end;
      Line(75)=' ';
      Info.PolyNameX=upper(Line(7:10));
      Info.PolyNameY=upper(Line(25:28));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 35:42 53], ...
        ' code=  :         begin=          :   end=          :'),
      end;
      Line(75)=' ';
      Info.Code=str2num(Line(7:8));
      Info.Begin=str2num(Line(25:34));
      Info.End=str2num(Line(43:52));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29], ...
        'style=    :         pen=    :'),
      end;
      Line(75)=' ';
      Info.Style=str2num(Line(7:10));
      Info.Pen=str2num(Line(25:28));


    case 'PO10',
%PO10
%polyg=plus: 
%   x1=            :  y1=            :
%   x2=            :  y2=            :
%   x3=            :  y3=            :
%   x4=            :  y4=            :
%   x5=            :  y5=            :
%   x6=            :  y6=            :
%   x7=            :  y7=            :
%   x8=            :  y8=            :
%   x9=            :  y9=            :
%  x10=            : y10=            :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        'polyg=    :'),
      end;
      Line(75)=' ';
      Info.Polygon=upper(Line(7:10));

      Info.Coord=zeros(10,2);
      for i=1:9,
        Line=fgetl(fid);
        if ~ischar(Line), break; end;
        if Strict & ~CheckLine(Line,[1:6 19:24 37], ...
          sprintf('   x%i=            :  y%i=            :',i,i)),
          break;
        end;
        TmpCrd=str2num(Line(7:18));
        if isempty(TmpCrd), TmpCrd=NaN; end
        Info.Coord(i,1)=TmpCrd;
        TmpCrd=str2num(Line(25:36));
        if isempty(TmpCrd), TmpCrd=NaN; end
        Info.Coord(i,2)=TmpCrd;
      end;
      if ~ischar(Line), break; end;

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 19:24 37], ...
        '  x10=            : y10=            :'),
      end;
      Line(75)=' ';
      TmpCrd=str2num(Line(7:18));
      if isempty(TmpCrd), TmpCrd=NaN; end
      Info.Coord(10,1)=TmpCrd;
      TmpCrd=str2num(Line(25:36));
      if isempty(TmpCrd), TmpCrd=NaN; end
      Info.Coord(10,2)=TmpCrd;

      
    case 'POLD',
%POLD
% file=                              :type=      :
% matr=    :        time=     :
%polyg=    :        xcol=    :        ycol=    :
%polyg=    :        xcol=    :        ycol=    :
%polyg=    :        xcol=    :        ycol=    :
%polyg=    :        xcol=    :        ycol=    :
%polyg=    :        xcol=    :        ycol=    :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 36:42 49], ...
        ' file=                              :type=      :'),
      end;
      Line(75)=' ';
      Info.File=deblank2(Line(7:35));
      Info.Type=upper(deblank2(Line(43:48)));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 30], ...
        ' matr=    :        time=     :'),
      end;
      Line(75)=' ';
      Info.Matrix=Line(7:10);
      Info.Time=deblank2(upper(Line(25:29))); % ANGLO

      for i=1:5,
        Line=fgetl(fid);
        if ~ischar(Line), break; end;
        if Strict & ~CheckLine(Line,[1:6 11:24 30], ...
          'polyg=    :        xcol=    :        ycol=    :'),
        end;
        Info.Poly(i).Name=deblank2(upper(Line(7:10)));
        Info.Poly(i).XCol=str2num(Line(25:28));
        Info.Poly(i).YCol=str2num(Line(43:46));
      end;
      if ~ischar(Line), break; end;
      
    
    case 'SUBS',
%SUBS                                                                            
% coor=    :           x=          :     y=          : angle=     :              
% cmco=    :       width=     :     height=     :                                
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 35:42 53:60 66], ...
        ' coor=    :           x=          :     y=          : angle=     :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
      Info.X=str2num(Line(25:34));
      Info.Y=str2num(Line(43:52));
      Info.Angle=str2num(Line(61:65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 30:42 48], ...
        ' cmco=    :       width=     :     height=     :'),
      end;
      Line(75)=' ';
      Info.CmName=upper(Line(7:10));
      Info.XLength=str2num(Line(25:29));
      Info.YLength=str2num(Line(43:47));


    case 'SULL',
%SULL                                                                            
% coor=    :           x=          :     y=          : angle=     :              
% cmco=    :        loco=    :                                                   
%blank=    +       blank=    +       blank=    +       blank=    +               
% lenx=     :         x0=          :    dx=          :    xn=          : 
% ndec=  :         power=  :        offset=          :  xlog=   :                
% draw=   :        axpen=    :      height=    :                                 
% xras=  :         style=    :      raspen=    :                                 
% leny=     :         y0=          :    dy=          :    yn=          : 
% ndec=  :         power=  :        offset=          :  ylog=   :                
% draw=   :        axpen=    :      height=    :                                 
% yras=  :         style=    :      raspen=    :                                 
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7

% draw=   :        axpen=    :      height=    :        oppo=   :
% OPPO (YES/NO, NO as default)
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 35:42 53:60 66], ...
        ' coor=    :           x=          :     y=          : angle=     :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
      Info.X=str2num(Line(25:34));
      Info.Y=str2num(Line(43:52));
      Info.Angle=str2num(Line(61:65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29], ...
        ' cmco=    :        loco=    :'),
      end;
      Line(75)=' ';
      Info.CmName=upper(Line(7:10));
      Info.LoName=upper(Line(25:28));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 30:42 48:60], ...
        'blank=    +       blank=    +       blank=    +       blank=    +'),
      end;
      Line(75)=' ';
      Info.Blank(1).Name=upper(Line(7:10));
      Info.Blank(1).Type=findstr('+-',Line(11));
      Info.Blank(2).Name=upper(Line(25:28));
      Info.Blank(2).Type=findstr('+-',Line(29));
      Info.Blank(3).Name=upper(Line(43:46));
      Info.Blank(3).Type=findstr('+-',Line(47));
      Info.Blank(4).Name=upper(Line(61:64));
      Info.Blank(4).Type=findstr('+-',Line(65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 35:42 53:60 71], ...
        ' lenx=     :         x0=          :    dx=          :    xn=          :'),
      end;
      Line(75)=' ';
      Info.XLength=str2num(Line(7:11));
      Info.XStart=str2num(Line(25:34));
      Info.XStep=str2num(Line(43:52));
      Info.XEnd=str2num(Line(61:70));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 27:42 53:60 64], ...
        ' ndec=  :         power=  :        offset=          :  xlog=   :'),
      end;
      Line(75)=' ';
      Info.XLblNDec=str2num(Line(7:8));
      Info.XPower=str2num(Line(25:26));
      if isempty(Info.XPower), Info.XPower=0; end
      Info.XOffset=str2num(Line(43:52));
      Info.XLog=CheckStr(upper(Line(61:63)),{'YES','NO'},0,'NO')==1;

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 10:24 29:42 47], ...
        ' draw=   :        axpen=    :      height=    :'),
      end;
      Line(75)=' ';
      Info.XVisible=CheckStr(upper(Line(7:9)),{'YES','NO'},0);
      Info.XPen=str2num(Line(25:28));
      Info.XHeight=str2num(Line(43:46));
      if isempty(Info.XHeight), Info.XHeight=2; end

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 29:42 47], ...
        ' xras=  :         style=    :      raspen=    :'),
      end;
      Line(75)=' ';
      Info.XGrid=str2num(Line(7:8));
      Info.XStyle=str2num(Line(25:28));
      Info.XGridPen=str2num(Line(43:46));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 35:42 53:60 71], ...
        ' leny=     :         y0=          :    dy=          :    yn=          :'),
      end;
      Line(75)=' ';
      Info.YLength=str2num(Line(7:11));
      Info.YStart=str2num(Line(25:34));
      Info.YStep=str2num(Line(43:52));
      Info.YEnd=str2num(Line(61:70));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 27:42 53:60 64], ...
        ' ndec=  :         power=  :        offset=          :  ylog=   :'),
      end;
      Line(75)=' ';
      Info.YLblNDec=str2num(Line(7:8));
      Info.YPower=str2num(Line(25:26));
      if isempty(Info.YPower), Info.YPower=0; end
      Info.YOffset=str2num(Line(43:52));
      Info.YLog=CheckStr(upper(Line(61:63)),{'YES','NO'},0,'NO')==1;

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 10:24 29:42 47], ...
        ' draw=   :        axpen=    :      height=    :'),
      end;
      Line(75)=' ';
      Info.YVisible=CheckStr(upper(Line(7:9)),{'YES','NO'},0);
      Info.YPen=str2num(Line(25:28));
      Info.YHeight=str2num(Line(43:46));
      if isempty(Info.YHeight), Info.YHeight=2; end

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 29:42 47], ...
        ' yras=  :         style=    :      raspen=    :'),
      end;
      Line(75)=' ';
      Info.YGrid=str2num(Line(7:8));
      Info.YStyle=str2num(Line(25:28));
      Info.YGridPen=str2num(Line(43:46));


    case 'SULT',
%SULT
% coor=    :           x=          :     y=          : angle=     :
% cmco=    :        loco=    :        time=     :
%blank=    +       blank=    +       blank=    +       blank=    +
% lent=     :     offset=          : date0=      :     time0=      :
%   dt=      :  dt unity=       :    daten=      :     timen=      :       
%tdraw=   :        axpen=    :      height=    :
% tras=  :         style=    :      raspen=    :
% leny=     :         y0=          :    dy=          :    yn=          :
% ndec=  :         power=  :        offset=          :  ylog=   :       
%ydraw=   :        axpen=    :      height=    :
% yras=  :         style=    :      raspen=    :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 35:42 53:60 66], ...
        ' coor=    :           x=          :     y=          : angle=     :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
      Info.X=str2num(Line(25:34));
      Info.Y=str2num(Line(43:52));
      Info.Angle=str2num(Line(61:65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 48], ...
        ' cmco=    :        loco=    :        time=     :'),
      end;
      Line(75)=' ';
      Info.CmName=upper(Line(7:10));
      Info.LoName=upper(Line(25:28));
      Info.Time=upper(Line(43:47)); % ANGLO

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 30:42 48:60], ...
        'blank=    +       blank=    +       blank=    +       blank=    +'),
      end;
      Line(75)=' ';
      Info.Blank(1).Name=upper(Line(7:10));
      Info.Blank(1).Type=findstr('+-',Line(11));
      Info.Blank(2).Name=upper(Line(25:28));
      Info.Blank(2).Type=findstr('+-',Line(29));
      Info.Blank(3).Name=upper(Line(43:46));
      Info.Blank(3).Type=findstr('+-',Line(47));
      Info.Blank(4).Name=upper(Line(61:64));
      Info.Blank(4).Type=findstr('+-',Line(65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 35:42 51:60 67], ...
        ' lent=     :     offset=          : date0=      :     time0=      :'),
      end;
      Line(75)=' ';
      Info.XLength=str2num(Line(7:11));
      Info.XOffset=str2num(Line(25:34));
      Info.T0Time=str2num(Line(61:66));
      if strcmp(Line(49),':')
        Info.T0Date=str2num(Line(43:48));
        Info.XStart=tdelft3d(19000000+Info.T0Date,Info.T0Time);
      else
        Info.T0Date=str2num(Line(43:50));
        Info.XStart=tdelft3d(Info.T0Date,Info.T0Time);
      end
      Info.XPower=0;
      Info.XLog=0;

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 13:24 32:42 51:60 67], ...
        '   dt=      :  dt unity=       :    daten=      :     timen=      :'),
      end;
      Line(75)=' ';
      Info.Dt=str2num(Line(7:12));
      Info.DtUnit=deblank2(upper(Line(25:31))); %DAYS
      Info.T1Time=str2num(Line(61:66));
      if strcmp(Line(49),':')
        Info.T1Date=str2num(Line(43:48));
        Info.XEnd=tdelft3d(19000000+Info.T1Date,Info.T1Time);
      else
        Info.T1Date=str2num(Line(43:50));
        Info.XEnd=tdelft3d(Info.T1Date,Info.T1Time);
      end

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 30:42 47], ...
        'tdraw=   :        axpen=    :      height=    :'),
      end;
      Line(75)=' ';
      Info.TVisible=CheckStr(upper(Line(7:9)),{'YES','NO'},0);
      Info.AxPen=upper(Line(25:29));
      Info.XHeight=str2num(Line(43:46));
      if isempty(Info.XHeight), Info.XHeight=2; end
      
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 29:42 47], ...
        ' tras=  :         style=    :      raspen=    :'),
      end;
      Line(75)=' ';
      Info.TGrid=str2num(Line(7:8));
      Info.TStyle=str2num(Line(25:28));
      Info.TGridPen=str2num(Line(43:46));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 35:42 53:60 71], ...
        ' leny=     :         y0=          :    dy=          :    yn=          :'),
      end;
      Line(75)=' ';
      Info.YLength=str2num(Line(7:11));
      Info.YStart=str2num(Line(25:34));
      Info.YStep=str2num(Line(43:52));
      Info.YEnd=str2num(Line(61:70));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 27:42 53:60 64], ...
        ' ndec=  :         power=  :        offset=          :  ylog=   :'),
      end;
      Line(75)=' ';
      Info.YLblNDec=str2num(Line(7:8));
      Info.YPower=str2num(Line(25:26));
      Info.YOffset=str2num(Line(43:52));
      Info.YLog=CheckStr(upper(Line(61:63)),{'YES','NO'},0,'NO')==1;

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 10:24 29:42 47], ...
        'ydraw=   :        axpen=    :      height=    :'),
      end;
      Line(75)=' ';
      Info.YVisible=CheckStr(upper(Line(7:9)),{'YES','NO'},0);
      Info.YPen=str2num(Line(25:28));
      Info.YHeight=str2num(Line(43:46));
      if isempty(Info.YHeight), Info.YHeight=2; end

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 9:24 29:42 47], ...
        ' yras=  :         style=    :      raspen=    :'),
      end;
      Line(75)=' ';
      Info.YGrid=str2num(Line(7:8));
      Info.YStyle=str2num(Line(25:28));
      Info.YGridPen=str2num(Line(43:46));


    case 'TEXT',
%TEXT
% coor=    :           x=          :     y=          : angle=     :
% text=                                                                  :
% font=   :       height=    :        just=    :
%txpen=    :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 35:42 53:60 66], ...
        ' coor=    :           x=          :     y=          : angle=     :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
      Info.X=str2num(Line(25:34));
      Info.Y=str2num(Line(43:52));
      Info.Angle=str2num(Line(61:65));
      if isempty(Info.Angle), Info.Angle=0; end
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6], ...
        ' text='),
      end;
      Line(75)=' ';
      Info.Text=deblank(Line(7:min(length(Line),72)));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 10:24 29], ...
        ' font=   :       height=    :'),
      end;
      Just=0;
      if length(Line)>=42
        Just=1;
        if Strict & CheckLine(Line,[1:6 10:24 29:42 47], ...
               ' font=   :       height=    :        just=    :'),
        end
      end;
      Line(75)=' ';
      Info.Font=str2num(Line(7:9));
      Info.Height=str2num(Line(25:28));
      if Just
        Info.Just=str2num(Line(43:46));
      else
        Info.Just=0;
      end
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        'txpen=    :'),
      end;
      Line(75)=' ';
      Info.TxPen=str2num(Line(7:10));


    case 'TXAN',
%TXAN
% file=                              :type=     :
% coor=    :        matr=    :
%blank=    +       blank=    +       blank=    +       blank=    +
%nrsym=    :       hsymb=    :     pensymb=    :
% font=    :       htext=    :     pentext=    :     textpos=      :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 36:42 49], ...
        ' file=                              :type=      :'),
      end;
      Line(75)=' ';
      Info.File=deblank2(Line(7:35));
      Info.Type=upper(deblank2(Line(43:48)));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29], ...
        ' coor=    :        matr=    :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
      Info.Matrix=upper(Line(25:28));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 12:24 30:42 48:60], ...
        'blank=    +       blank=    +       blank=    +       blank=    +'),
      end;
      Line(75)=' ';
      Info.Blank(1).Name=upper(Line(7:10));
      Info.Blank(1).Type=findstr('+-',Line(11));
      Info.Blank(2).Name=upper(Line(25:28));
      Info.Blank(2).Type=findstr('+-',Line(29));
      Info.Blank(3).Name=upper(Line(43:46));
      Info.Blank(3).Type=findstr('+-',Line(47));
      Info.Blank(4).Name=upper(Line(61:64));
      Info.Blank(4).Type=findstr('+-',Line(65));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47], ...
         'nrsym=    :       hsymb=    :     pensymb=    :'),
      end;
      Line(75)=' ';
      Info.NrSym=str2num(Line(7:10));
      Info.HSym=str2num(Line(25:28));
      Info.PenSym=str2num(Line(43:46));
      
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47:60 67], ...
         ' font=    :       htext=    :     pentext=    :     textpos=      :'),
      end;
      Line(75)=' ';
      Info.Font=str2num(Line(7:10));
      Info.HText=str2num(Line(25:28));
      Info.PenText=str2num(Line(43:46));
      Info.Pos=deblank2(upper(Line(61:68)));
      if isempty(Info.HText), Info.HText=2; end
      if isempty(Info.PenText), Info.PenText=1; end
      Info.Pos=ustrcmpi(Info.Pos,{'ABOVE','AFTER','BEFORE','BELOW'});
      if Info.Pos==-1, Info.Pos=1; end


    case 'TXAR',
%TXAR
% coor=    :           x=          :     y=          : angle=     :
% text=
% font=   :       height=    :
%txpen=    :
%arpos=      :     ardir= :          arlen=    :       arpen=    :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 35:42 53:60 66], ...
        ' coor=    :           x=          :     y=          : angle=     :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
      Info.X=str2num(Line(25:34));
      Info.Y=str2num(Line(43:52));
      Info.Angle=str2num(Line(61:65));
      if isempty(Info.Angle), Info.Angle=0; end
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6], ...
        ' text='),
      end;
      Line(75)=' ';
      Info.Text=deblank(Line(7:min(length(Line),72)));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 10:24 29], ...
        ' font=   :       height=    :'),
      end;
      Line(75)=' ';
      Info.Font=str2num(Line(7:9));
      Info.Height=str2num(Line(25:28));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        'txpen=    :'),
      end;
      Line(75)=' ';
      Info.TxPen=str2num(Line(7:10));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 13:24 26:42 47:60 65], ...
        'arpos=      :     ardir= :          arlen=    :       arpen=    :'),
      end;
      Line(75)=' ';
      Info.ArrowPos=CheckStr(upper(Line(7:12)),{'BEFORE','AFTER'},0);
      Info.ArrowDir=CheckStr(Line(25),{'+','-'},1);
      Info.ArrowLen=str2num(Line(43:46));
      Info.ArrowPen=str2num(Line(61:64));

    case 'TXLG',
%TXLG
% coor=    :           x=          :     y=          : angle=     :
% text=
% font=   :       height=    :
%txpen=    :
%lgpos=      :    xstyle=    :         len=    :      height=    :
%lgpen=    :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 35:42 53:60 66], ...
        ' coor=    :           x=          :     y=          : angle=     :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
      Info.X=str2num(Line(25:34));
      Info.Y=str2num(Line(43:52));
      Info.Angle=str2num(Line(61:65));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6], ...
        ' text='),
      end;
      Line(75)=' ';
      Info.Text=deblank(Line(7:min(length(Line),72)));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 10:24 29], ...
        ' font=   :       height=    :'),
      end;
      Line(75)=' ';
      Info.Font=str2num(Line(7:9));
      Info.Height=str2num(Line(25:28));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        'txpen=    :'),
      end;
      Line(75)=' ';
      Info.TxPen=str2num(Line(7:10));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 13:24 29:42 47:60 65], ...
        'lgpos=      :    xstyle=    :         len=    :      height=    :'),
      end;
      Line(75)=' ';
      Info.LgPos=CheckStr(upper(Line(7:12)),{'BEFORE','AFTER'},0);
      Info.LgStyle=str2num(Line(25:28));
      Info.LgLen=str2num(Line(43:46));
      Info.LgHeight=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        'lgpen=    :'),
      end;
      Line(75)=' ';
      Info.LgPen=str2num(Line(7:10));

    case 'IMAG',
%IMAG
% file=                              :type=      :
% coor=    :
%begin=    :         end=    :
%style=    :        mpen=    :
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 37:42 49], ...
        ' file=                              :type=      :'),
      end;
      Line(75)=' ';
      Info.File=deblank2(Line(7:36));
      Info.Type=upper(deblank2(Line(43:48)));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11], ...
        ' coor=    :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29], ...
        'begin=    :         end=    :'),
      end;
      Line(75)=' ';
      Info.Begin=deblank2(Line(7:10));
      Info.End=deblank2(Line(25:28));
  
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29], ...
        'style=    :        mpen=    :'),
      end;
      Line(75)=' ';
      Info.Style=str2num(Line(7:10));
      Info.MPen=str2num(Line(25:28));

    case 'ISUN',
%ISUN
% file=                              :type=      :
% coor=    :        text=    :        hleg=    :
%blank=          : blcol=    : regulardata=                      :
% matr=    :        tiep=    :      ngridx=    :      ngridy=    :
% xcol=    :        ycol=    :        zcol=    :       fault=    :
%   v0=          :    dv=          :    vn=          : inter=    :
%  nov=          :smoot1=          :radius=          :smooth=          :
% xleg=          :  yleg=          :  ndec=    :         iop=    :
%xlimi=          : xlima=          : ylimi=          : ylima=          :
%heigh=          :   gap=          :  ndec=    :        qual=    :
%line....h..l..s.. line....h..l..s.. line....h..l..s.. line....h..l..s..
%
%
%
%
%
%1234567890123456789012345678901234567890123456789012345678901234567890123
%         1         2         3         4         5         6         7


      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 36:42 49], ...
        ' file=                              :type=      :'),
      end;
      Line(75)=' ';
      Info.File=deblank2(Line(7:35));
      Info.Type=CheckStr(upper(Line(43:48)),{'ASCII','BINAIR'},0);

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47], ...
        ' coor=    :        text=    :        hleg=    :'),
      end;
      Line(75)=' ';
      Info.Parent=upper(Line(7:10));
      Info.Language=upper(Line(25:28));
      Info.LegHeight=str2num(Line(43:46));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 17:24 29:42 65], ...
        'blank=          : blcol=    : regulardata=                      :'),
      end;
      Line(75)=' ';
      Info.Blank=deblank2(Line(7:16));
      Info.BlCol=str2num(Line(25:28));
      Info.RegDataOutput=deblank2(Line(43:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47:60 65], ...
        ' matr=    :        tiep=    :      ngridx=    :      ngridy=    :'),
      end;
      Line(75)=' ';
      Info.Matrix=Line(7:10);
      Info.Type=deblank2(upper(Line(25:28)));
      Info.NGridX=str2num(Line(43:46));
      Info.NGridY=str2num(Line(61:64));
   
      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 11:24 29:42 47:60], ...
         ' xcol=    :        ycol=    :        zcol=    :       fault=    '),
      end;
      Line(75)=' ';
      Info.XCol=str2num(Line(7:10));
      Info.YCol=str2num(Line(25:28));
      Info.ZCol=str2num(Line(43:46));
      Info.Fault=str2num(Line(61:64));
      Info.DrawFault=Line(65)~='-';

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 17:24 35:42 53:60 65], ...
         '   v0=          :    dv=          :    vn=          : inter=    :'),
      end;
      Line(75)=' ';
      Info.V0=str2num(Line(7:16));
      Info.DV=str2num(Line(25:34));
      Info.VN=str2num(Line(43:52));
      Info.InterpMeth=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 17:24 35:42 53:60 71], ...
         '  nov=          :smoot1=          :radius=          :smooth=          :'),
      end;
      Line(75)=' ';
      Info.MissingValue=str2num(Line(7:16));
      Info.SmoothMeth=str2num(Line(25:34));
      Info.InterpRadius=str2num(Line(43:52));
      Info.SmoothPar=str2num(Line(61:70));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 17:24 35:42 47:60 65], ...
         ' xleg=          :  yleg=          :  ndec=    :         iop=    :'),
      end;
      Line(75)=' ';
      Info.XLeg=str2num(Line(7:16));
      Info.YLeg=str2num(Line(25:34));
      Info.LegNumDec=str2num(Line(43:46));
      Info.OrderLeg=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 17:24 35:42 53:60 71], ...
         'xlimi=          : xlima=          : ylimi=          : ylima=          :'),
      end;
      Line(75)=' ';
      Info.XLim1=str2num(Line(7:16));
      Info.XLim2=str2num(Line(25:34));
      Info.YLim1=str2num(Line(43:52));
      Info.YLim2=str2num(Line(61:70));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:6 17:24 35:42 47:60 65], ...
         'heigh=          :   gap=          :  ndec=    :        qual=    :'),
      end;
      Line(75)=' ';
      Info.IsoValHeight=str2num(Line(7:16));
      Info.IsoValGap=str2num(Line(25:34));
      Info.IsoValNumDec=str2num(Line(43:46));
      Info.IsoValOpt=str2num(Line(61:64));

      Line=fgetl(fid);
      if ~ischar(Line), break; end;
      if Strict & ~CheckLine(Line,[1:71], ...
         'line....h..l..s.. line....h..l..s.. line....h..l..s.. line....h..l..s..'),
      end;
      Line(75)=' ';

      Info.ThresVal=zeros(20,1);
      Info.ThresCol=zeros(20,3);
      for i=0:4,
        Line=fgetl(fid);
        if ~ischar(Line), break; end;
        if Strict & ~CheckLine(Line,[18 36 54], ...
           '                 :                 :                 :                 '),
          break;
        end;
        Line(75)=' ';

        TmpClr=str2num(Line(1:8));
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresVal(i*4+1)=TmpClr;
        TmpClr=str2num(Line(9:11))/360;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+1,1)=TmpClr;
        TmpClr=str2num(Line(12:14))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+1,2)=TmpClr;
        TmpClr=str2num(Line(15:17))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+1,3)=TmpClr;

        TmpClr=str2num(Line(19:26));
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresVal(i*4+2)=TmpClr;
        TmpClr=str2num(Line(27:29))/360;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+2,1)=TmpClr;
        TmpClr=str2num(Line(30:32))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+2,2)=TmpClr;
        TmpClr=str2num(Line(33:35))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+2,3)=TmpClr;

        TmpClr=str2num(Line(37:44));
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresVal(i*4+3)=TmpClr;
        TmpClr=str2num(Line(45:47))/360;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+3,1)=TmpClr;
        TmpClr=str2num(Line(48:50))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+3,2)=TmpClr;
        TmpClr=str2num(Line(51:53))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+3,3)=TmpClr;

        TmpClr=str2num(Line(55:62));
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresVal(i*4+4)=TmpClr;
        TmpClr=str2num(Line(63:65))/360;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+4,1)=TmpClr;
        TmpClr=str2num(Line(66:68))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+4,2)=TmpClr;
        TmpClr=str2num(Line(69:71))/100;
        if isempty(TmpClr), TmpClr=NaN; end
        Info.ThresCol(i*4+4,3)=TmpClr;
      end;
      if ~ischar(Line), break; end;
      Info.ThresCol=hls2rgb(Info.ThresCol);

    otherwise,
      J=strmatch(Job, ...
        {'ANNO','ARST','FUND','IMAG','INPI','ISGR','ISOF','ISOL','ISUN', ...
         'LIFU','POLD','PO10','SUBS','SULL','SULT','TEXT','TXAN','TXAR', ...
         'TXLG','WQT1','WQT2'},'exact');
      if isempty(J),
        fprintf('Error interpreting line: %s\n',Line);
        break;
      end;
      fprintf('Skipping: %s\n',Job);
      NL=[10 7 7 4 3 16 8 7 17 5 7 11 2 11 11 4 5 5 6 6 6];
      for i=1:NL(J),
        Line=fgetl(fid);
        if ~ischar(Line), break; end;
      end;
      if ~ischar(Line), break; end;
    end;
    Struct.Job(jb).Info=Info;
    Struct.Job(jb).Name=Info.JobName;
  end;
  if feof(fid),
    Struct.Check='OK';
  end;
end;

fclose(fid);

if ~doplot | strcmp(Struct.Check,'NotOK'),
  return;
end;

%Create figure
Info=Struct.Job(1).Info;
[fig,AxInfo]=Local_INPI(Info);
%Create windows
Local_WINDOWS(Struct.Job,AxInfo,fig);
LineTable=cell(0,3);

%Preload line data ...
for jb=2:length(Struct.Job),
  Info=Struct.Job(jb).Info;
  switch Info.JobName,
  case 'POLD',
    TKL=tekal('open',Info.File);
    data=tekal('read',TKL,upper(Info.Matrix));
    for i=1:5,
      if ~isempty(Info.Poly(i).Name)
        j=size(LineTable,1)+1;
        LineTable{j,1}=Info.Poly(i).Name;
        switch Info.Time
        case 'ANGLO'
          ymd=data(:,Info.Poly(i).XCol);
          d=ymd-floor(ymd/100)*100;
          ymd=floor(ymd/100);
          m=ymd-floor(ymd/100)*100;
          y=floor(ymd/100);
          hms=data(:,Info.Poly(i).XCol+1);
          s=hms-floor(hms/100)*100;
          hms=floor(hms/100);
          mn=hms-floor(hms/100)*100;
          h=floor(hms/100);
          LineTable{j,2}=datenum(y,m,d,h,mn,s);
        case 'EURO'
          ymd=data(:,Info.Poly(i).XCol);
          if any(ymd>999999)
            y=ymd-floor(ymd/10000)*10000;
            ymd=floor(ymd/10000);
          else
            y=ymd-floor(ymd/100)*100;
            ymd=floor(ymd/100);
          end
          m=ymd-floor(ymd/100)*100;
          d=floor(ymd/100);
          hms=data(:,Info.Poly(i).XCol+1);
          s=hms-floor(hms/100)*100;
          hms=floor(hms/100);
          mn=hms-floor(hms/100)*100;
          h=floor(hms/100);
          LineTable{j,2}=datenum(y,m,d,h,mn,s);
        otherwise
          LineTable{j,2}=data(:,Info.Poly(i).XCol);
        end
        LineTable{j,3}=data(:,Info.Poly(i).YCol);
      end
    end
  case 'PO10'
    j=size(LineTable,1)+1;
    data=Info.Coord;
    data(isnan(data(:,1))|isnan(data(:,2)),:)=[];
    LineTable{j,1}=Info.Polygon;
    LineTable{j,2}=data(:,1);
    LineTable{j,2}=data(:,2);
  end
end

for jb=2:length(Struct.Job),
  Info=Struct.Job(jb).Info;
  if isempty(strmatch(Info.JobName,{'POLD','PO10','SUBS','SULL','SULT'})) & isfield(Info,'Parent'),
    if strcmp(Info.Parent,'    '),
      parent=findobj(fig,'type','axes','tag','****');
    else,
      parent=findobj(fig,'type','axes','tag',Info.Parent);
    end;
    if isempty(parent),
      fprintf('Unknown coordinate system: %s.\n',Info.Parent);
      break;
    end;
    parent=copyobj(parent,fig);
    AxInfo=get(parent,'userdata');
    set(parent,'userdata',[],'tag','');
  end;
  
  switch Info.JobName,
  case 'ANNO'
    TKL=tekal('open',Info.File,1);
    data=tekal('read',TKL,Info.Matrix);
    [RGB,Width]=penclr(Info.PenSym);
    RGBt=penclr(Info.PenText);
    if Info.NrSym<0
      Marker='';
    else
      [Marker,Filled,Line]=xstyle(Info.NrSym);
      if Filled, MFC=RGB; else, MFC='none'; end
    end
    Format=sprintf('%%.%if',Info.NrDig);
    for a=1:4
      if ~isempty(Info.Anno(a).XCol)
        x=data(:,Info.Anno(a).XCol);
        y=data(:,Info.Anno(a).YCol);
        z=data(:,Info.Anno(a).ValCol);
        blank=zeros(size(x));
        for i=1:4,
          if ~isempty(deblank(Info.Blank(i).Name))
            ib=strmatch(Info.Blank(i).Name,LineTable(:,1),'exact');
            xb=LineTable{ib,2};
            yb=LineTable{ib,3};
            if isequal(Info.Blank(i).Type,1) % inside
              blank = blank | inpolygon(x,y,xb,yb);
            else % outside
              blank = blank | ~inpolygon(x,y,xb,yb);
            end
          end
        end
        x=x(~blank);
        y=y(~blank);
        z=z(~blank);
        if ~isempty(Marker)
          line(x,y,'parent',parent,'color',RGB,'linewidth',Width,'linestyle',Line,'marker',Marker,'markerfacecolor',MFC,'markersize',Info.HSym/0.4);
        end
        opt={};
        switch Info.Anno(a).Pos,
        case 1,
          opt={'horizontalalignment','right','verticalalignment','baseline'};
          dx=-sqrt(0.5);
          dy=sqrt(0.5);
        case 2,
          opt={'horizontalalignment','center','verticalalignment','bottom'};
          dx=0;
          dy=1;
        case 3,
          opt={'horizontalalignment','left','verticalalignment','baseline'};
          dx=sqrt(0.5);
          dy=sqrt(0.5);
        case 4,
          opt={'horizontalalignment','right','verticalalignment','middle'};
          dx=-1;
          dy=0;
        case 5,
          opt={'horizontalalignment','left','verticalalignment','middle'};
          dx=1;
          dy=0;
        case 6,
          opt={'horizontalalignment','right','verticalalignment','cap'};
          dx=-sqrt(0.5);
          dy=-sqrt(0.5);
        case 7,
          opt={'horizontalalignment','center','verticalalignment','top'};
          dx=0;
          dy=-1;
        case 8,
          opt={'horizontalalignment','left','verticalalignment','cap'};
          dx=sqrt(0.5);
          dy=-sqrt(0.5);
        end;
        dx=dx*3*Info.HSym/10;
        dy=dy*3*Info.HSym/10;
        x=x+dx;
        y=y+dy;
        for i=1:length(x)
          text(x(i),y(i),sprintf(Format,z(i)), ...
               'parent',parent, ...
               'fontunits','centimeters', ...
               'fontsize',1.35*Info.HText/10, ...
               'clipping','on', ...
               'color',RGBt, opt{:});
        end
      end
    end


  case 'POLD',
    % nothing to plot

  case 'PO10'
    % nothing to plot

  case 'IMAG'
    TKL=tekal('open',Info.File,1);
    iB=strmatch(Info.Begin,{TKL.Field.Name});
    iE=strmatch(Info.End,{TKL.Field.Name});
    [RGB,Width]=penclr(Info.MPen);
    [Marker,Filled,Line]=xstyle(Info.Style);
    if Filled, MFC=RGB; else, MFC='none'; end
    for i=iB:iE
      data=tekal('read',TKL,i);
      if ~isempty(data)
        x=data(:,1);
        y=data(:,2);
        x(x==999.999)=NaN;
        y(y==999.999)=NaN;
        line(x,y,'parent',parent,'color',RGB,'linewidth',Width,'linestyle',Line,'marker',Marker,'markerfacecolor',MFC,'tag','IMAG');
      end
    end

  case 'LIFU',
    ix=strmatch(Info.PolyNameX,LineTable(:,1),'exact');
    iy=strmatch(Info.PolyNameY,LineTable(:,1),'exact');
    if ~isempty(ix) & ~isempty(iy)
      x=LineTable{ix,2};
      x(x==999.999)=NaN;
      y=LineTable{iy,3};
      y(y==999.999)=NaN;
      [RGB,Width]=penclr(Info.Pen);
      line(x,y,'parent',parent,'color',RGB,'linewidth',Width,'tag','LIFU');
    else
      error('Either X or Y of LIFU field not found.');
    end

  case 'TXLG',
    if Info.LgPos==1, % before
      [RGB,Width]=penclr(Info.LgPen);
      line(Info.X+[0 Info.LgLen],Info.Y+[0 0],'parent',parent,'clipping','off','color',RGB,'linewidth',Width);
  
      T=text(Info.X+Info.LgLen,Info.Y,[' 'Info.Text], ...
        'parent',parent, ...
        'rotation',AxInfo.Angle+Info.Angle, ...
        'fontunits','centimeters', ...
        'fontsize',1.35*Info.Height/10, ...
        'color',penclr(Info.TxPen));
    else, % after
      T=text(Info.X,Info.Y,[Info.Text ' '], ...
        'parent',parent, ...
        'rotation',AxInfo.Angle+Info.Angle, ...
        'fontunits','centimeters', ...
        'fontsize',1.35*Info.Height/10, ...
        'color',penclr(Info.TxPen));
      sz=get(T,'extent');
      [RGB,Width]=penclr(Info.LgPen);
      [Marker,Filled,Line]=xstyle(Info.LgStyle);
      if Filled, MFC=RGB; else, MFC='none'; end
      line(Info.X+sz(3)+[0 Info.LgLen],Info.Y+[0 0],'parent',parent,'clipping','off','color',RGB,'linewidth',Width,'linestyle',Line,'marker',Marker,'markerfacecolor',MFC);
    end;

  case 'ISGR',
    TKL=tekal('open',Info.File);
    data=tekal('read',TKL,Info.Matrix);
    X=data(:,:,Info.XCol);
    Y=data(:,:,Info.YCol);
    Z=data(:,:,Info.VCol);
    I=data(:,:,Info.IndexCol);
    Z(I<=0)=NaN;
    Z(isnan(X) | isnan(Y))=NaN;
    X(isnan(X))=mean(X(~isnan(X)));
    Y(isnan(Y))=mean(Y(~isnan(Y)));
    hold on;
    minZ=min(Z(:));
    if minZ<min(Info.ThresVal)
      Thresholds=[minZ;Info.ThresVal];
    else
      Thresholds=Info.ThresVal;
    end
    Thresholds=Thresholds(~isnan(Thresholds));
    [c,h]=contourfcorr(X,Y,Z,Thresholds);
    set(h,'clipping','on','edgecolor','none','parent',parent);
    for i=1:length(h),
      Thres=get(h(i),'cdata');
      j=min(find(Thresholds==Thres),size(Info.ThresCol,1));
      if isequal(size(j),[1 1])
        set(h(i),'facecolor',Info.ThresCol(j,:));
      end
    end;
    
  case 'ISOF',
    TKL=tekal('open',Info.File);
    data=tekal('read',TKL,Info.Matrix);
    X=data(:,:,Info.XCol);
    Y=data(:,:,Info.YCol);
    Z=data(:,:,Info.VCol);
    I=data(:,:,Info.IndexCol);
    Z(I<=0)=NaN;
    hold on;
    [c,h]=contour(X,Y,Z,Info.Start:Info.Step:Info.End,'k');
    set(h,'clipping','off');
    h=my_clabel(c,h);
    set(h,'clipping','off');
    
  case 'ISUN',
    TKL=tekal('open',Info.File);
    data=tekal('read',TKL,Info.Matrix);
    X=data(:,Info.XCol);
    Y=data(:,Info.YCol);
    Z=data(:,Info.ZCol);
    if Info.DV==0
      ThresVal=Info.ThresVal(~isnan(Info.ThresVal));
    else
      ThresVal=Info.V0:Info.DV:Info.VN;
    end
    [x,y]=meshgrid(Info.XLim1+(0:Info.NGridX)*(Info.XLim2-Info.XLim1)/Info.NGridX, ...
                   Info.YLim1+(0:Info.NGridY)*(Info.YLim2-Info.YLim1)/Info.NGridY);
    switch Info.Type
    case 'DOTT'
    case 'GRID'
      z=repmat(NaN,size(x)-1);
      m=floor(Info.NGridX*(X-Info.XLim1)/(Info.XLim2-Info.XLim1))+1;
      n=floor(Info.NGridY*(Y-Info.YLim1)/(Info.YLim2-Info.YLim1))+1;
      valid=m>0 & m<=Info.NGridX & n>0 & n<=Info.NGridY;
      NContrib=sparse(n(valid),m(valid),1,Info.NGridY,Info.NGridX);
      Sum=sparse(n(valid),m(valid),Z(valid),Info.NGridY,Info.NGridX);
      z(NContrib>0)=Sum(NContrib>0)./NContrib(NContrib>0);
      zz=cont2class(z,ThresVal);
      zz=reshape(Info.ThresCol(zz+1,:),[size(z) 3]);
      zz(isnan(z))=NaN;
      surface(x,y,0*y,zz,'parent',parent,'edgecolor','none')
    case 'LINE'
    case 'CONT'
    case 'COLI'
    end

  case 'SUBS'
    % nothing to plot
    
  case 'SULL',
    ax=findobj(fig,'type','axes','tag',Info.LoName);
    ax=copyobj(ax,fig);
    XLim=sort([Info.XStart Info.XEnd]);
    XDir=logicalswitch(Info.XStart<Info.XEnd,'normal','reverse');
    XTick=XLim(1):Info.XStep:XLim(2);
    XGrid=logicalswitch(Info.XGrid>1,'on','off');
    YLim=sort([Info.YStart Info.YEnd]);
    YDir=logicalswitch(Info.YStart<Info.YEnd,'normal','reverse');
    YTick=YLim(1):Info.YStep:YLim(2);
    YGrid=logicalswitch(Info.YGrid>1,'on','off');

    if Info.XLblNDec<0
      frmt='%1.0f';
    else
      frmt=sprintf('%%1.%if',Info.XLblNDec);
    end
    XTickL=cell(1,length(XTick));
    for i=1:length(XTick),
      XTickL{i}=sprintf(frmt,XTick(i));
    end;
    XTick=XTick*10^(Info.XPower);
    if Info.XHeight<=0, XTickL(:)={''}; end

    if Info.YLblNDec<0
      frmt='%1.0f';
    else
      frmt=sprintf('%%1.%if',Info.YLblNDec);
    end
    YTickL=cell(1,length(YTick));
    for i=1:length(YTick),
      YTickL{i}=sprintf(frmt,YTick(i));
    end;
    YTick=YTick*10^(Info.YPower);
    if Info.YHeight<=0, YTickL(:)={''}; end

    fHeight=Info.XHeight;
    if Info.XHeight<=0, fHeight=Info.YHeight; end
    if fHeight<=0, fHeight=1; end
    
    Visible='on';
    if (Info.XVisible==2) & (Info.YVisible==2)
      Visible='off';
    end
    
    [XRGB,XWidth]=penclr(Info.XPen);
    [YRGB,YWidth]=penclr(Info.YPen);
    set(ax,'userdata',[], ...
           'tag','', ...
           'color','none', ...
           'xcolor',XRGB, ...
           'xdir',XDir, ...
           'xtick',XTick, ...
           'xticklabel',XTickL, ...
           'xgrid',XGrid, ...
           'ycolor',YRGB, ...
           'ydir',YDir, ...
           'ytick',YTick, ...
           'yticklabel',YTickL, ...
           'ygrid',YGrid, ...
           'fontunits','centimeters', ...
           'fontsize',1.35*fHeight/10, ...
           'visible',Visible);

  case 'SULT',
    ax=findobj(fig,'type','axes','tag',Info.LoName);
    ax=copyobj(ax,fig);
    TStart=Info.XStart;
    TEnd=Info.XEnd;
    TStep=Info.Dt;
    switch upper(Info.DtUnit),
    case 'DAYS'
      TStep=TStep*1;
    end
    TLim=sort([TStart TEnd]);
    TDir=logicalswitch(TStart<TEnd,'normal','reverse');
    TTick=TLim(1):TStep:TLim(2);
    TGrid=logicalswitch(Info.TGrid>1,'on','off');
    YLim=sort([Info.YStart Info.YEnd]);
    YDir=logicalswitch(Info.YStart<Info.YEnd,'normal','reverse');
    YTick=YLim(1):Info.YStep:YLim(2);
    YGrid=logicalswitch(Info.YGrid>1,'on','off');

    if Info.YLblNDec<0
      frmt='%1.0f';
    else
      frmt=sprintf('%%1.%if',Info.YLblNDec);
    end
    YTickL=cell(1,length(YTick));
    for i=1:length(YTick),
      YTickL{i}=sprintf(frmt,YTick(i));
    end;
    YTick=YTick*10^(Info.YPower);
    if Info.YHeight<=0, YTickL(:)={''}; end

    fHeight=Info.XHeight;
    if Info.XHeight<=0, fHeight=Info.YHeight; end
    if fHeight<=0, fHeight=1; end

    Visible='on';
    if (Info.TVisible==2) & (Info.YVisible==2)
      Visible='off';
    end

    set(ax,'userdata',[], ...
           'tag','', ...
           'color','none', ...
           'xdir',TDir, ...
           'xtick',TTick, ...
           'xgrid',TGrid, ...
           'ydir',YDir, ...
           'ytick',YTick, ...
           'yticklabel',YTickL, ...
           'ygrid',YGrid, ...
           'fontunits','centimeters', ...
           'fontsize',1.35*fHeight/10, ...
           'visible',Visible);
     axes(ax)
     if Info.XHeight>0,
       hold on
       datetick('x');
     end

  case 'TEXT',
    T=text(Info.X,Info.Y,Info.Text, ...
      'parent',parent, ...
      'rotation',AxInfo.Angle+Info.Angle, ...
      'fontunits','centimeters', ...
      'fontsize',1.35*Info.Height/10, ...
      'color',penclr(Info.TxPen));

    switch Info.Just,
    case 0,
      set(T,'horizontalalignment','left','verticalalignment','baseline');
    case 1,
      set(T,'horizontalalignment','center','verticalalignment','baseline');
    case 2,
      set(T,'horizontalalignment','right','verticalalignment','baseline');
    case 3,
      set(T,'horizontalalignment','left','verticalalignment','middle');
    case 4,
      set(T,'horizontalalignment','center','verticalalignment','middle');
    case 5,
      set(T,'horizontalalignment','right','verticalalignment','middle');
    case 6,
      set(T,'horizontalalignment','left','verticalalignment','top');
    case 7,
      set(T,'horizontalalignment','center','verticalalignment','top');
    case 8,
      set(T,'horizontalalignment','right','verticalalignment','top');
    end;

  case 'TXAN',
    TKL=tekal('open',Info.File,1);
    data=tekal('read',TKL,Info.Matrix);
    [RGB,Width]=penclr(Info.PenSym);
    RGBt=penclr(Info.PenText);
    if Info.NrSym<0
      Marker='';
    else
      [Marker,Filled,Line]=xstyle(Info.NrSym);
      if Filled, MFC=RGB; else, MFC='none'; end
    end
    x=data{1}(1,:);
    y=data{1}(2,:);
    Str=data{2};
    blank=zeros(size(x));
    for i=1:4,
      if ~isempty(deblank(Info.Blank(i).Name))
        ib=strmatch(Info.Blank(i).Name,LineTable(:,1),'exact');
        xb=LineTable{ib,2};
        yb=LineTable{ib,3};
        if isequal(Info.Blank(i).Type,1) % inside
          blank = blank | inpolygon(x,y,xb,yb);
        else % outside
          blank = blank | ~inpolygon(x,y,xb,yb);
        end
      end
    end
    x=x(~blank);
    y=y(~blank);
    Str=Str(~blank);
    if ~isempty(Marker)
      line(x,y,'parent',parent,'color',RGB,'linewidth',Width,'linestyle',Line,'marker',Marker,'markerfacecolor',MFC,'markersize',Info.HSym/0.4);
    end
    opt={};
    switch Info.Pos,
    case 1,
      opt={'horizontalalignment','center','verticalalignment','bottom'};
      dx=0;
      dy=1;
    case 2,
      opt={'horizontalalignment','left','verticalalignment','middle'};
      dx=1;
      dy=0;
    case 3,
      opt={'horizontalalignment','right','verticalalignment','middle'};
      dx=-1;
      dy=0;
    case 4,
      opt={'horizontalalignment','center','verticalalignment','top'};
      dx=0;
      dy=-1;
    end;
    dx=dx*3*Info.HSym/10;
    dy=dy*3*Info.HSym/10;
    x=x+dx;
    y=y+dy;
    for i=1:length(x)
      text(x(i),y(i),Str{i}, ...
           'parent',parent, ...
           'fontunits','centimeters', ...
           'fontsize',1.35*Info.HText/10, ...
           'clipping','on', ...
           'color',RGBt, opt{:});
    end

  case 'TXAR',
    if Info.ArrowPos==1, % before
      if Info.ArrowDir==1, % +
        Txt=['\rightarrow ' Info.Text];
      else, % -
        Txt=['\leftarrow ' Info.Text];
      end;
    else, % after
      if Info.ArrowDir==1, % +
        Txt=[Info.Text ' \leftarrow'];
      else, % -
        Txt=[Info.Text ' \rightarrow'];
      end;
    end;
    T=text(Info.X,Info.Y,Txt, ...
      'parent',parent, ...
      'rotation',AxInfo.Angle+Info.Angle, ...
      'fontunits','centimeters', ...
      'fontsize',1.35*Info.Height/10);

  otherwise,
    fprintf('Cannot plot: %s\n',Info.JobName);
  end;
end;

fig=Struct;


function OK=CheckLine(Line,Index,Str),
OK=1;
if ~ischar(Line),
  fprintf('Unexpected end of file.\n');
  OK=0;
end;
if length(Line)<max(Index),
  fprintf('The line                : "%s"\nis shorter than         : "%s"\n\n',Line,Str);
  OK=0;
elseif ~strcmp(lower(Line(Index)),Str(Index)),
  [c,ia,ib]=intersect(Index,[6 24 42 60]);
  ia=[ia ia+1];
  ia=ia(ia<=length(Index));
  if ~strcmp(lower(Line(Index(ia))),Str(Index(ia))),
    fprintf('The datafields in       : "%s"\nare shifted relative to : "%s"\n\n',Line,Str);
  else,
    fprintf('The keywords in the line: "%s"\ndo not match            : "%s"\n\n',Line,Str);
  end;
  OK=0;
end;


function Str=deblank2(StrIn);
nsp=find(~isspace(StrIn));
minsp=min(nsp);
if ~isempty(minsp),
  maxsp=max(nsp);
  Str=StrIn(minsp:maxsp);
else,
  Str='';
end;


function Yes=CheckStr(Str,Strs,Exact,Default),
if Exact,
  Exact={'exact'};
else,
  Exact={};
end;
Str=deblank2(Str);
if isempty(Str),
  if nargin>3,
    Default=deblank2(Default);
    Yes=strmatch(Default,Strs,Exact{:});
    if isempty(Yes),
      error(sprintf('Invalid default string: %s.\n',Default));
    end;
  else,
    Yes=[];
    if isempty(Yes),
      error(sprintf('No default specified.\n'));
    end;
  end;
else,
  Yes=strmatch(Str,Strs,Exact{:});
  if isempty(Yes),
    error(sprintf('Invalid input string: %s.\n',Str));
  end;
end;


function [fig,AxInfo]=Local_INPI(Info),
switch Info.Size,
case 'A0',
  fig=figure('papertype','a0', ...
             'color','w', ...
             'paperunits','centimeters', ...
             'paperposition',[0 0 Info.Width Info.Height]);
case 'A4',
  fig=figure('papertype','a4', ...
             'color','w', ...
             'paperunits','normalized');
  set(fig,'paperposition',[0 0 1 1]);
  set(fig,'paperunits','centimeters');
case 'A3',
  fig=figure('papertype','a3', ...
             'color','w', ...
             'paperunits','normalized');
  set(fig,'paperposition',[0 0 1 1]);
  set(fig,'paperunits','centimeters');
end;

units0=get(0,'units');
set(0,'units','centimeters');
maxdim=get(0,'screensize');
maxdim=maxdim(3:4);
orientation='portrait';
if strcmp(orientation,'landscape'),
  pos1=round([29.6774 20.984]*min(maxdim./[29.6774 20.984]));
  pos2=round([29.6774 20.984]*min(fliplr(maxdim)./[29.6774 20.984]));
  pos=min(pos1,pos2);
else, % 'portrait'
  pos1=round([20.984 29.6774]*min(fliplr(maxdim)./[20.984 29.6774]));
  pos2=round([20.984 29.6774]*min(maxdim./[20.984 29.6774]));
  pos=min(pos1,pos2);
end;   
pos=pos*0.85;
pos=[(maxdim(1)-pos(1))/2 (maxdim(2)-pos(2))/2 pos];
set(fig, ...
   'units','centimeters', ...
   'position',pos);
set(fig,'units','pixels');
set(0,'units',units0);

PPos=get(fig,'paperposition');
PaperWidth=PPos(3);
PaperHeight=PPos(4);

PlotAreaWidth=PaperWidth-3;
PlotAreaHeight=PaperHeight-2.7;
PlotAreaXOffset=1.5;
PlotAreaYOffset=1.35;  
Pos=[PlotAreaXOffset/PaperWidth PlotAreaYOffset/PaperHeight PlotAreaWidth/PaperWidth PlotAreaHeight/PaperHeight];
ax=axes('units','normalized', ...
  'position',Pos, ...
  'tag','****', ...
  'parent',fig, ...
  'xlimmode','manual', ...
  'ylimmode','manual', ...
  'xlim',[0 PlotAreaWidth], ...
  'ylim',[0 PlotAreaHeight], ...
  'xgrid','on', ...
  'ygrid','on', ...
  'xtick',[0:PlotAreaWidth], ...
  'ytick',[0:PlotAreaHeight], ...
  'color','none', ...
  'visible','off');

AxInfo.Name='****';
AxInfo.PosLL=[PlotAreaXOffset PlotAreaYOffset];
AxInfo.Angle=0;
AxInfo.Size=[PlotAreaWidth PlotAreaHeight];
AxInfo.XLim=[0 PlotAreaWidth];
AxInfo.YLim=[0 PlotAreaHeight];
AxInfo.XLog=0;
AxInfo.YLog=0;
set(ax,'userdata',AxInfo);
AxInfo(2)=AxInfo;
AxInfo(2).Name='    ';

[RGB,Width]=penclr(Info.Pen);
[Marker,Filled,Line]=xstyle(Info.Style);
if Filled, MFC=RGB; else, MFC='none'; end
%...,'color',RGB,'linewidth',Width,'linestyle',Line,'marker',Marker,'markerfacecolor',MFC);

switch Info.Type,
case {'LV','LD'},
  ax1=copyobj(ax,get(ax,'parent'));
  set(ax1,'userdata',[],'tag','');
  line(PlotAreaWidth*[0 1 1 0 0],PlotAreaHeight*[0 0 1 1 0], ...
    'clipping','off', ...
    'parent',ax1, ...
    'color',RGB,'linewidth',Width,'linestyle',Line,'marker',Marker,'markerfacecolor',MFC);
  line(PlotAreaWidth*[0 1 1 0 NaN 0.71 0.71 0.71 1],[0.9 0.9 2.7 2.7 NaN 0 2.7 1.8 1.8], ...
    'clipping','off', ...
    'parent',ax1, ...
    'color',RGB,'linewidth',Width,'linestyle',Line,'marker',Marker,'markerfacecolor',MFC);
  line(PlotAreaWidth*[0.86 0.86 NaN 0.86 0.86],[0 0.9 NaN 1.8 2.7], ...
    'clipping','off', ...
    'parent',ax1, ...
    'color',RGB,'linewidth',Width,'linestyle',Line,'marker',Marker,'markerfacecolor',MFC);
case {'NO',''},
case 'BO',
  ax1=copyobj(ax,get(ax,'parent'));
  set(ax1,'userdata',[],'tag','');
  line(PlotAreaWidth*[0 1 1 0 0],PlotAreaHeight*[0 0 1 1 0], ...
    'clipping','off', ...
    'parent',ax1, ...
    'color',RGB,'linewidth',Width,'linestyle',Line,'marker',Marker,'markerfacecolor',MFC);
end;



function Local_WINDOWS(Job,AxInfo,fig);
SULL=ismember({Job.Name},{'SUBS','SULL','SULT'});
if ~any(SULL),
  return;
end;
SULL={Job(SULL).Info};

Parents={'****','    '};
while ~isempty(SULL),
  SrchParent={};
  for i=1:length(SULL)
    SrchParent{i}=SULL{i}.Parent;
  end
  Available=ismember(SrchParent,Parents);
  if ~any(Available),
    error('Undefined coordinate system: %s.\n',SrchParent{i});
  end;
  i=min(find(Available));
  j=strmatch(SrchParent(i),Parents);
  n=length(AxInfo)+1;
  AxInfo(n).Name=SULL{i}.CmName;
  if length(j)>1, j=j(1); end
  AxInfo(n).PosLL(1)=AxInfo(j).PosLL(1)+ ...
               cos(AxInfo(j).Angle*pi/180)*SULL{i}.X-...
               sin(AxInfo(j).Angle*pi/180)*SULL{i}.Y;
  AxInfo(n).PosLL(2)=AxInfo(j).PosLL(2)+ ...
               sin(AxInfo(j).Angle*pi/180)*SULL{i}.X+...
               cos(AxInfo(j).Angle*pi/180)*SULL{i}.Y;
  AxInfo(n).Angle=mod(SULL{i}.Angle+AxInfo(j).Angle,360);
  AxInfo(n).Size=[SULL{i}.XLength SULL{i}.YLength];
  AxInfo(n).XLim=[0 SULL{i}.XLength];
  AxInfo(n).YLim=[0 SULL{i}.YLength];
  AxInfo(n).XLog=0;
  AxInfo(n).YLog=0;
  ax=absaxes(fig,AxInfo(n).PosLL,AxInfo(n).Angle,AxInfo(n).Size,AxInfo(n).XLim,AxInfo(n).YLim);
  set(ax,'tag',SULL{i}.CmName,'visible','off','userdata',AxInfo(n));
  Parents{end+1}=SULL{i}.CmName;
  if ~strcmp(SULL{i}.JobName,'SUBS'),
    n=n+1;
    AxInfo(n)=AxInfo(n-1);
    AxInfo(n).Name=SULL{i}.LoName;
    AxInfo(n).XLim=sort([SULL{i}.XStart SULL{i}.XEnd]*10^(SULL{i}.XPower));
    XDir=logicalswitch(SULL{i}.XStart<SULL{i}.XEnd,'normal','reverse');
    AxInfo(n).YLim=sort([SULL{i}.YStart SULL{i}.YEnd]*10^(SULL{i}.YPower));
    YDir=logicalswitch(SULL{i}.YStart<SULL{i}.YEnd,'normal','reverse');
    AxInfo(n).XLog=SULL{i}.XLog;
    AxInfo(n).YLog=SULL{i}.YLog;
    ax=absaxes(fig,AxInfo(n).PosLL,AxInfo(n).Angle,AxInfo(n).Size,AxInfo(n).XLim,AxInfo(n).YLim);
    set(ax,'tag',SULL{i}.LoName,'visible','off','userdata',AxInfo(n),'xdir',XDir,'ydir',YDir);
    Parents{end+1}=SULL{i}.LoName;
  end;
  
  SULL(i)=[];
end;

function [RGB,Width]=penclr(Pen),
rPen=mod(Pen-1,10)+1;
tPen=(Pen-mod(Pen-1,10)-1)/10;
Width=0.5*tPen;
if Width==0, Width=1e-5; end
switch rPen
case 1,
  RGB=[0 0 0];
case 2,
  RGB=[1 0 0];
case 3,
  RGB=[0 1 0];
case 4,
  RGB=[0 0 1];
case 5,
  RGB=[0 1 1];
case 6,
  RGB=[1 0 1];
case 7,
  RGB=[1 1 0];
case 8,
  RGB=[1 0.5 0];
case 9,
  RGB=[0.5 1 0];
case 10,
  RGB=[0 1 0.5];
otherwise
  RGB=[0 0 1];
  warning(sprintf('unknown pen: %i',Pen))
end

function [Marker,Filled,Line]=xstyle(mNr),
Marker='none';
Filled=0;
Line='-';
switch mNr
case 1,
  Line='-';
case 2,
  Line='--';
case 3,
  Line='-.';
case 4, % replacement
  Line='--';
  Marker='.';
case 5, % replacement
  Line=':';
  Marker='.';
case 6, % replacement
  Line='-.';
  Marker='.';
case 7, % replacement
  Line='--';
  Marker='o';
case 8,
  Line=':';
case 9, % replacement
  Line=':';
  Marker='o';
case 10, % replacement
  Line='-.';
  Marker='o';
otherwise,
  if mNr<40
    Line='none';
  else
    Line='-';
  end
end
if mNr>10
  if mNr>40, mNr=mNr-20; end
  switch mNr
  case 20,
    Marker='o';
    Filled=0;
  case 21,
    Marker='s';
    Filled=0;
  case 22,
    Marker='^';
    Filled=0;
  case 23,
    Marker='d';
    Filled=0;
  case 24,
    Marker='p';
    Filled=0;
  case 25,
    Marker='+';
    Filled=0;
  case 26,
    Marker='x';
    Filled=0;
  case 27,
    Marker='*';
    Filled=0;
  case 28,
    Marker='o';
    Filled=1;
  case 29,
    Marker='s';
    Filled=1;
  case 30,
    Marker='^';
    Filled=1;
  case 31,
    Marker='v';
    Filled=1;
  case 32,
    Marker='p';
    Filled=1;
  case 33,
    Marker='<';
    Filled=1;
  case 34,
    Marker='.';
    Filled=0;
  case 35,
    Marker='>';
    Filled=1;
  otherwise
    Marker='>';
    Filled=0;
    warning(sprintf('unknown marker: %i',mNr))
  end
end