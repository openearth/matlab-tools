function [EntryOut,NowError]=ds_comfile(EntryIn,FileData,FieldNr);
% DS_COMFILE is the data stream interface for a Delft3D-com file
%
%      Three different calls to this function can be expected:
% 
%      1. [EntryOut,NowError]=DS_XXX(EntryIn,FileData)
%         To create a LoadField entry interactively or
%         as batch (given EntryName and EntryParameters)
%         based on data stored in FileData or the
%         associated file(s).
%      2. [EntryOut,NowError]=DS_XXX(EntryIn,FileData,'edit')
%         To edit a LoadField entry interactively based
%         on data stored in FileData or the associated file(s).
%      3. [FieldData,NowError]=DS_XXX(Entry,FileData,N)
%         To create and return field N of the LoadField entry based
%         on data stored in FileData or the associated file(s).

Fields=...
    {'morphologic grid X-coordinates'                 'GRID'     'XCOR'
     'morphologic grid Y-coordinates'                 'GRID'     'YCOR'
     'bottom'                                         'BOTTIM'   'DP'
     'bottom time'                                    'BOTTIM'   'TIMBOT'
     'hydrodynamic grid X-coordinates'                'TEMPOUT'  'XWAT'
     'hydrodynamic grid Y-coordinates'                'TEMPOUT'  'YWAT'
     'vorticity'                                      'CURTIM'   'S1'
     'waterlevel'                                     'CURTIM'   'S1'
     'bottom in waterlevel points'                    'BOTTIM'   'TIMBOT'
     'rougness xi-direction'                          'ROUGHNESS' 'CFUROU'
     'rougness eta-direction'                         'ROUGHNESS' 'CFVROU'
     'vel. x-dir in waterlevel points'                'CURTIM'   'U1'
     'vel. y-dir in waterlevel points'                'CURTIM'   'U1'
     'velocity U in waterlevel points'                'CURTIM'   'U1'
     'velocity V in waterlevel points'                'CURTIM'   'U1'
     'velocity magnitude'                             'CURTIM'   'S1'
     'spiral flow intensity'                          'CURTIM'   'RSP'
     'flow time'                                      'CURTIM'   'TIMCUR'
     'velocity U'                                     'CURTIM'   'U1'
     'open U'                                         'KENMTIM'  'KFU'
     'velocity V'                                     'CURTIM'   'V1'
     'open V'                                         'KENMTIM'  'KFV'
     'average bedload transport xi-direction'         'TRANSTIM' 'TTXA'
     'average bedload transport eta-direction'        'TRANSTIM' 'TTYA'
     'average bedload transport'                      'TRANSTIM' 'TTXA'
     'average suspended transport xi-direction'       'TRANSTIM' 'TTXSA'
     'average suspended transport eta-direction'      'TRANSTIM' 'TTYSA'
     'average suspended transport'                    'TRANSTIM' 'TTXSA'
     'average total sediment transport xi-direction'  'TRANSTIM' 'TTXA'
     'average total sediment transport eta-direction' 'TRANSTIM' 'TTYA'
     'average total sediment transport'               'TRANSTIM' 'TTXA'};

EntryOut=[];
NowError=0;
if (nargin==2) | ((nargin==3) & isequal('edit',FieldNr)), % cases 1 & 2
  Edit=(nargin==3);
  Interactive=Edit | ~isfield(EntryIn.EntryParameters,'AnimateFields');
  EntryOut=EntryIn;

  if ~Edit,
    %  determine EntryName
    DataSets=strvcat(Fields{:,1});
    if isempty(EntryOut.EntryName),
      EntryName=ui_type('dataset',DataSets);
      if isempty(EntryName), % cancel
        return;
      end;
      EntryOut.EntryName=EntryName;
    end;
    
    % determine EntryParameters and Fields
    i=strmatch(EntryOut.EntryName,Fields(:,1),'exact');
    GrpInfo=vs_disp(FileData,Fields{i,2},[]);
    TotalNFields=GrpInfo.SizeDim;
    EntryOut.NInputFields=TotalNFields;
    ElmInfo=vs_disp(FileData,Fields{i,2},Fields{i,3});
    EntryOut.InputSize=ElmInfo.SizeDim;
    
    if ~isfield(EntryOut,'EntryParameters') | ~isfield(EntryOut.EntryParameters,'AnimateFields'),
       EntryOut.EntryParameters.AnimateFields=1:EntryOut.NInputFields;
    end;
    if ~isfield(EntryOut.EntryParameters,'MValues'),
       EntryOut.EntryParameters.MValues=1:EntryOut.InputSize(1);
    end;
    if (length(EntryOut.InputSize)>1) & ~isfield(EntryOut.EntryParameters,'NValues'),
      EntryOut.EntryParameters.NValues=1:EntryOut.InputSize(2);
    end;
  end;
  
  % Now edit parameters
  if Interactive,
    parm=0;
    if EntryOut.NInputFields>1,
      parm=parm+1;
      P(parm).Name='AnimateFields';
      P(parm).Type='INTARR';
      P(parm).Value=[1 EntryOut.NInputFields];
      Def{parm}=EntryOut.EntryParameters.AnimateFields;
    else,
      EntryOut.EntryParameters.AnimateFields=1;
    end;
    if EntryOut.InputSize(1)>1,
      parm=parm+1;
      P(parm).Name='MValues';
      P(parm).Type='INTARR';
      P(parm).Value=[1 EntryOut.InputSize(1)];
      Def{parm}=EntryOut.EntryParameters.MValues;
    else,
      EntryOut.EntryParameters.MValues=1;
    end;
    if (length(EntryOut.InputSize)>1),
      if EntryOut.InputSize(2)>1,
        parm=parm+1;
        P(parm).Name='NValues';
        P(parm).Type='INTARR';
        P(parm).Value=[1 EntryOut.InputSize(2)];
        Def{parm}=EntryOut.EntryParameters.NValues;
      else,
        EntryOut.EntryParameters.NValues=1;
      end;
    end;

    if Edit,
      Values=ui_param(P,Def);
      if ~isempty(Values),
        for parm=1:length(P),
          EntryOut.EntryParameters=setfield(EntryOut.EntryParameters,P(parm).Name,Values{parm});
        end;
        NowError=0;
      end;
    end;
  end;
  EntryOut.NumberOfFields=length(EntryOut.EntryParameters.AnimateFields);
  if length(EntryOut.InputSize)>1,
    EntryOut.FieldSize=[length(EntryOut.EntryParameters.MValues) length(EntryOut.EntryParameters.NValues)];
  else,
    EntryOut.FieldSize=length(EntryOut.EntryParameters.MValues);
  end;

elseif (nargin==3), % case 3
  if abs(FieldNr-round(FieldNr))<1e-2,
    FieldNr=EntryIn.EntryParameters.AnimateFields(round(FieldNr));
    [EntryOut,NowError]=Local_eval(FileData,EntryIn.EntryName,FieldNr);
  else,
    FloorNr=EntryIn.EntryParameters.AnimateFields(floor(FieldNr));
    CeilNr=EntryIn.EntryParameters.AnimateFields(ceil(FieldNr));
    EntryOut=[];
    [Entry1,NowError]=Local_eval(FileData,EntryIn.EntryName,FloorNr);
    if ~NowError,
      [Entry2,NowError]=Local_eval(FileData,EntryIn.EntryName,CeilNr);
      if ~NowError,
        try,
          EntryOut=Entry1+(Entry2-Entry1)*(FieldNr-floor(FieldNr));
        catch,
          NowError=1;
        end;
      end;
    end;
  end;
end;

function [EntryOut,NowError]=Local_eval(FD,Name,FieldNr);
NowError=1;
switch Name,
case 'morphologic grid X-coordinates',
  EntryOut=vs_get(FD,'GRID','XCOR','quiet');
  Active=vs_get(FD,'TEMPOUT','CODB','quiet');
  EntryOut(Active<0)=NaN;
  X0=vs_get(FD,'GRID','XORI','quiet');
  EntryOut=EntryOut+X0;
case 'morphologic grid Y-coordinates',
  EntryOut=vs_get(FD,'GRID','YCOR','quiet');
  Active=vs_get(FD,'TEMPOUT','CODB','quiet');
  EntryOut(Active<0)=NaN;
  Y0=vs_get(FD,'GRID','YORI','quiet');
  EntryOut=EntryOut+Y0;
case 'rougness xi-direction',
  EntryOut=vs_get(FD,'ROUGHNESS',{FieldNr},'CFUROU','quiet');
  EntryOut(EntryOut==-999)=NaN;
case 'rougness eta-direction',
  EntryOut=vs_get(FD,'ROUGHNESS',{FieldNr},'CFVROU','quiet');
  EntryOut(EntryOut==-999)=NaN;
case 'bottom',
  EntryOut=vs_get(FD,'BOTTIM',{FieldNr},'DP','quiet');
  EntryOut(EntryOut==-999)=NaN;
case 'bottom in waterlevel points',
  Depth=vs_get(FD,'BOTTIM',{FieldNr},'DP','quiet');
  Active=vs_get(FD,'TEMPOUT','CODB','quiet');
  Active=Active>0;
  NAct=conv2(Active,[0 0 0; 0 1 1; 0 1 1],'same');
  NDepth=conv2(Active.*Depth,[0 0 0; 0 1 1; 0 1 1],'same');
  EntryOut=NDepth./max(1,NAct);
  EntryOut(NAct==0)=NaN; % =-99;
case 'bottom time',
  EntryOut=vs_get(FD,'BOTTIM',{FieldNr},'TIMBOT','quiet');
  TScale=vs_get(FD,'PARAMS','TSCALE','quiet');
  EntryOut=EntryOut*TScale/(60*60*24);
case 'hydrodynamic grid X-coordinates',
  EntryOut=vs_get(FD,'TEMPOUT','XWAT','quiet');
  Active=vs_get(FD,'TEMPOUT','CODW','quiet');
  EntryOut(Active<0)=NaN;
  X0=vs_get(FD,'GRID','XORI','quiet');
  EntryOut=EntryOut+X0;
case 'hydrodynamic grid Y-coordinates',
  EntryOut=vs_get(FD,'TEMPOUT','YWAT','quiet');
  Active=vs_get(FD,'TEMPOUT','CODW','quiet');
  EntryOut(Active<0)=NaN;
  Y0=vs_get(FD,'GRID','YORI','quiet');
  EntryOut=EntryOut+Y0;
case 'waterlevel',
  EntryOut=vs_get(FD,'CURTIM',{FieldNr},'S1','quiet');
  kfu=vs_get(FD,'KENMTIM',{FieldNr},'KFU','quiet');
  kfv=vs_get(FD,'KENMTIM',{FieldNr},'KFV','quiet');
  kfu=conv2([kfu(:,1)>0 kfu>0],[1 1],'valid');
  kfv=conv2([kfv(1,:)>0;kfv>0],[1;1],'valid');
  EntryOut((kfu+kfv)==0)=NaN;
case 'velocity U in waterlevel points',
  U=vs_get(FD,'CURTIM',{FieldNr},'U1','quiet');
  kfu=vs_get(FD,'KENMTIM',{FieldNr},'KFU','quiet');
  U=U.*kfu;
  U=conv2([U(:,1) U],[1 1],'valid');
  kfu=max(1,conv2([kfu(:,1)>0 kfu>0],[1 1],'valid'));
  EntryOut=U./kfu;
case 'vorticity', % in bottom points
  U=vs_get(FD,'CURTIM',{FieldNr},'U1','quiet');
  kfu=vs_get(FD,'KENMTIM',{FieldNr},'KFU','quiet');
  U=U.*kfu;
  U=conv2([U;U(end,:)],[-1;1],'valid');
  GUV=vs_get(FD,'GRID','GUV','quiet');
  GUV(GUV==0)=1;

  V=vs_get(FD,'CURTIM',{FieldNr},'V1','quiet');
  kfv=vs_get(FD,'KENMTIM',{FieldNr},'KFV','quiet');
  V=V.*kfv;
  V=conv2([V V(:,end)],[-1 1],'valid');
  GVU=vs_get(FD,'GRID','GVU','quiet')+realmin;
  GVU(GVU==0)=1;
  EntryOut=(V./GVU-U./GUV);
case 'velocity V in waterlevel points',
  V=vs_get(FD,'CURTIM',{FieldNr},'V1','quiet');
  kfv=vs_get(FD,'KENMTIM',{FieldNr},'KFV','quiet');
  V=V.*kfv;
  V=conv2([V(1,:);V],[1;1],'valid');
  kfv=max(1,conv2([kfv(1,:)>0;kfv>0],[1;1],'valid'));
  EntryOut=V./kfv;
case 'vel. x-dir in waterlevel points',
  [U,NowError]=Local_eval(FD,'velocity U in waterlevel points',FieldNr);
  [V,NowError]=Local_eval(FD,'velocity V in waterlevel points',FieldNr);
  alfa=vs_get(FD,'GRID','ALFAS','quiet');
  alfa0=vs_get(FD,'GRID','ALFORI','quiet');
  alfa=alfa+alfa0;
  alfa=alfa*pi/180;
  EntryOut=U.*cos(alfa)-V.*sin(alfa);
case 'vel. y-dir in waterlevel points',
  [U,NowError]=Local_eval(FD,'velocity U in waterlevel points',FieldNr);
  [V,NowError]=Local_eval(FD,'velocity V in waterlevel points',FieldNr);
  alfa=vs_get(FD,'GRID','ALFAS','quiet');
  alfa0=vs_get(FD,'GRID','ALFORI','quiet');
  alfa=alfa+alfa0;
  alfa=alfa*pi/180;
  EntryOut=U.*sin(alfa)+V.*cos(alfa);
case 'velocity U',
  EntryOut=vs_get(FD,'CURTIM',{FieldNr},'U1','quiet');
case 'open U',
  EntryOut=vs_get(FD,'KENMTIM',{FieldNr},'KFU','quiet');
case 'velocity V',
  EntryOut=vs_get(FD,'CURTIM',{FieldNr},'V1','quiet');
case 'open V',
  EntryOut=vs_get(FD,'KENMTIM',{FieldNr},'KFV','quiet');
case 'velocity magnitude',
  U=vs_get(FD,'CURTIM',{FieldNr},'U1','quiet');
  V=vs_get(FD,'CURTIM',{FieldNr},'V1','quiet');
  kfu=vs_get(FD,'KENMTIM',{FieldNr},'KFU','quiet');
  kfv=vs_get(FD,'KENMTIM',{FieldNr},'KFV','quiet');
  U=U.*kfu;
  V=V.*kfv;
  U=conv2([U(:,1) U],[1 1],'valid');
  kfu=max(1,conv2([kfu(:,1)>0 kfu>0],[1 1],'valid'));
  V=conv2([V(1,:);V],[1;1],'valid');
  kfv=max(1,conv2([kfv(1,:)>0;kfv>0],[1;1],'valid'));
  U=U./kfu;
  V=V./kfv;
  EntryOut=sqrt(U.^2+V.^2);
case 'spiral flow intensity',
  EntryOut=vs_get(FD,'CURTIM',{FieldNr},'RSP','quiet');
case 'flow time',
  EntryOut=vs_get(FD,'CURTIM',{FieldNr},'TIMCUR','quiet');
  TScale=vs_get(FD,'PARAMS','TSCALE','quiet');
  EntryOut=EntryOut*TScale/(60*60*24);
case 'average bedload transport xi-direction',
  EntryOut=vs_get(FD,'TRANSTIM',{FieldNr},'TTXA','quiet');
case 'average bedload transport eta-direction',
  EntryOut=vs_get(FD,'TRANSTIM',{FieldNr},'TTYA','quiet');
case 'average bedload transport',
  TX=vs_get(FD,'TRANSTIM',{FieldNr},'TTXA','quiet');
  TY=vs_get(FD,'TRANSTIM',{FieldNr},'TTYA','quiet');
  EntryOut=sqrt(TX.^2+TY.^2);
case 'average suspended transport xi-direction',
  EntryOut=vs_get(FD,'TRANSTIM',{FieldNr},'TTXSA','quiet');
case 'average suspended transport eta-direction',
  EntryOut=vs_get(FD,'TRANSTIM',{FieldNr},'TTYSA','quiet');
case 'average suspended transport',
  TX=vs_get(FD,'TRANSTIM',{FieldNr},'TTXSA','quiet');
  TY=vs_get(FD,'TRANSTIM',{FieldNr},'TTYSA','quiet');
  EntryOut=sqrt(TX.^2+TY.^2);
case 'average total sediment transport xi-direction',
  TXb=vs_get(FD,'TRANSTIM',{FieldNr},'TTXA','quiet');
  TXs=vs_get(FD,'TRANSTIM',{FieldNr},'TTXSA','quiet');
  EntryOut=TXb+TXs;
case 'average total sediment transport eta-direction',
  TYb=vs_get(FD,'TRANSTIM',{FieldNr},'TTYA','quiet');
  TYs=vs_get(FD,'TRANSTIM',{FieldNr},'TTYSA','quiet');
  EntryOut=TYb+TYs;
case 'average total sediment transport',
  TXb=vs_get(FD,'TRANSTIM',{FieldNr},'TTXA','quiet');
  TXs=vs_get(FD,'TRANSTIM',{FieldNr},'TTXSA','quiet');
  TYb=vs_get(FD,'TRANSTIM',{FieldNr},'TTYA','quiet');
  TYs=vs_get(FD,'TRANSTIM',{FieldNr},'TTYSA','quiet');
  EntryOut=sqrt((TXb+TXs).^2+(TYb+TYs).^2);
otherwise,
  EntryOut=[];
  return;
end;
NowError=0;
