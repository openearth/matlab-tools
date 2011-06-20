function [EntryOut,NowError]=ds_trimfile(EntryIn,FileData,FieldNr);
% DS_TRIMFILE is the data stream interface for a Delft3D-trim file
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
    {'morphologic grid X-coordinates'                 'map-const'   'XCOR'
     'morphologic grid Y-coordinates'                 'map-const'   'YCOR'
     'bottom'                                         'map-const'   'DP0'
     'bottom (S1)'                                    'map-const'   'DP0'
     'hydrodynamic grid X-coordinates'                'map-const'   'XZ'
     'hydrodynamic grid Y-coordinates'                'map-const'   'YZ'
     'vorticity'                                      'map-series'  'S1'
     'waterlevel'                                     'map-series'  'S1'
     'bottom in waterlevel points'                    'map-series'  'S1'
     'vel. x-dir in waterlevel points'                'map-series'  'S1'
     'vel. y-dir in waterlevel points'                'map-series'  'S1'
     'velocity U in waterlevel points'                'map-series'  'S1'
     'velocity V in waterlevel points'                'map-series'  'S1'
     'concentration'                                  'map-series'  'S1'
     'velocity magnitude'                             'map-series'  'S1'
     'spiral flow intensity'                          'map-series'  'RSP'
     'flow time'                                      'map-info-series'  'ITMAPC'
     'velocity U'                                     'map-series'  'U1'
     'open U'                                         'map-series'  'KFU'
     'velocity V'                                     'map-series'  'V1'
     'open V'                                         'map-series'  'KFV'
     'vertical eddy viscosity'                        'map-series'  'S1'
     'vertical eddy diffusivity'                      'map-series'  'S1'};

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
  
    EntryOut.EntryParameters.AnimateFields=1:EntryOut.NInputFields;
    EntryOut.EntryParameters.MValues=1:EntryOut.InputSize(1);
    if (length(EntryOut.InputSize)>1),
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
    if (length(EntryOut.InputSize)>2),
      if EntryOut.InputSize(3)>1,
        parm=parm+1;
        P(parm).Name='KValues';
        P(parm).Type='INT';
        P(parm).Value=[1 EntryOut.InputSize(3)];
        Def{parm}=1;
      else,
        EntryOut.EntryParameters.KValues=1;
      end;
    end;
    if (length(EntryOut.InputSize)>4),
      if EntryOut.InputSize(4)>1,
        parm=parm+1;
        P(parm).Name='Property';
        P(parm).Type='INT';
        P(parm).Value=[1 EntryOut.InputSize(4)];
        Def{parm}=EntryOut.EntryParameters.PValues;
      else,
        EntryOut.EntryParameters.PValues=1;
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
  EntryOut=vs_get(FD,'map-const','XCOR','quiet');
  Active=vs_get(FD,'map-const','KCS','quiet');
  Active=conv2(Active==1,[1 1; 1 1],'same');
  EntryOut(Active==0)=NaN;
%  Active=vs_get(FD,'TEMPOUT','CODB','quiet');
%  EntryOut(Active<0)=NaN;
%  X0=vs_get(FD,'GRID','XORI','quiet');
%  EntryOut=EntryOut+X0;
case 'morphologic grid Y-coordinates',
  EntryOut=vs_get(FD,'map-const','YCOR','quiet');
  Active=vs_get(FD,'map-const','KCS','quiet');
  Active=conv2(Active==1,[1 1; 1 1],'same');
  EntryOut(Active==0)=NaN;
%  Active=vs_get(FD,'TEMPOUT','CODB','quiet');
%  EntryOut(Active<0)=NaN;
%  Y0=vs_get(FD,'GRID','YORI','quiet');
%  EntryOut=EntryOut+Y0;
case 'bottom',
  EntryOut=vs_get(FD,'map-const',{FieldNr},'DP0','quiet');
  EntryOut(EntryOut==-999)=NaN;
case 'bottom (S1)',
  Depth=vs_get(FD,'map-const','DP0','quiet');
%  Active=vs_get(FD,'TEMPOUT','CODB','quiet');
%  Active=Active>0;
  Active=Depth~=-999;
  NAct=conv2(Active,[0 0 0; 0 1 1; 0 1 1],'same');
  NDepth=conv2(Active.*Depth,[0 0 0; 0 1 1; 0 1 1],'same');
  EntryOut=NDepth./max(1,NAct);
  EntryOut(NAct==0)=NaN; % =-99;
  Active=vs_get(FD,'map-const','KCS','quiet');
  EntryOut(Active==0)=NaN;
case 'bottom in waterlevel points',
  Depth=vs_get(FD,'map-const','DP0','quiet');
%  Active=vs_get(FD,'TEMPOUT','CODB','quiet');
%  Active=Active>0;
  Active=Depth~=-999;
  NAct=conv2(Active,[0 0 0; 0 1 1; 0 1 1],'same');
  NDepth=conv2(Active.*Depth,[0 0 0; 0 1 1; 0 1 1],'same');
  EntryOut=NDepth./max(1,NAct);
  EntryOut(NAct==0)=NaN; % =-99;
  if ~isequal(vs_disp(FD,'map-sed-series','DPSED'),-1),
    EntryOut=EntryOut+20-vs_get(FD,'map-sed-series',{FieldNr},'DPSED','quiet');
  end;
  Active=vs_get(FD,'map-const','KCS','quiet');
  EntryOut(Active==0)=NaN;
case 'hydrodynamic grid X-coordinates',
  EntryOut=vs_get(FD,'map-const','XZ','quiet');
  Active=vs_get(FD,'map-const','KCS','quiet');
  EntryOut(Active==0)=NaN;
%  X0=vs_get(FD,'GRID','XORI','quiet');
%  EntryOut=EntryOut+X0;
case 'hydrodynamic grid Y-coordinates',
  EntryOut=vs_get(FD,'map-const','YZ','quiet');
  Active=vs_get(FD,'map-const','KCS','quiet');
  EntryOut(Active==0)=NaN;
%  Y0=vs_get(FD,'GRID','YORI','quiet');
%  EntryOut=EntryOut+Y0;
case 'waterlevel',
  EntryOut=vs_get(FD,'map-series',{FieldNr},'S1','quiet');
  kfu=vs_get(FD,'map-series',{FieldNr},'KFU','quiet');
  kfv=vs_get(FD,'map-series',{FieldNr},'KFV','quiet');
  kfu=conv2([kfu(:,1)>0 kfu>0],[1 1],'valid');
  kfv=conv2([kfv(1,:)>0;kfv>0],[1;1],'valid');
  EntryOut((kfu+kfv)==0)=NaN;
case 'velocity U in waterlevel points',
  U=vs_get(FD,'map-series',{FieldNr},'U1','quiet');
  U=mean(U,3);
  kfu=vs_get(FD,'map-series',{FieldNr},'KFU','quiet');
  U=U.*kfu;
  U=conv2([U(:,1) U],[1 1],'valid');
  kfu=max(1,conv2([kfu(:,1)>0 kfu>0],[1 1],'valid'));
  EntryOut=U./kfu;
case 'vorticity', % in bottom points
  U=vs_get(FD,'map-series',{FieldNr},'U1','quiet');
  U=mean(U,3);
  kfu=vs_get(FD,'map-series',{FieldNr},'KFU','quiet');
  U=U.*kfu;
  U=conv2([U;U(end,:)],[1;-1],'valid');

  V=vs_get(FD,'map-series',{FieldNr},'V1','quiet');
  V=mean(V,3);
  kfv=vs_get(FD,'map-series',{FieldNr},'KFV','quiet');
  V=V.*kfv;
  V=conv2([V V(:,end)],[1 -1],'valid');
  XZ=vs_get(FD,'map-const','XZ','quiet');
  YZ=vs_get(FD,'map-const','YZ','quiet');
  
  XZdY=conv2(XZ,[1 1;-1 -1]/2,'same');
  YZdY=conv2(YZ,[1 1;-1 -1]/2,'same');
%  XZdY=conv2([XZ;XZ(end,:)],[1 1;-1 -1]/2,'valid');
%  YZdY=conv2([YZ;YZ(end,:)],[1 1;-1 -1]/2,'valid');
  distUU=sqrt(XZdY.^2+YZdY.^2);
  distUU(distUU==0)=1;
  XZdX=conv2(XZ,[1 -1;1 -1]/2,'same');
  YZdX=conv2(YZ,[1 -1;1 -1]/2,'same');
%  XZdX=conv2([XZ XZ(:,end)],[1 -1;1 -1]/2,'valid');
%  YZdX=conv2([YZ YZ(:,end)],[1 -1;1 -1]/2,'valid');
  distVV=sqrt(XZdX.^2+YZdX.^2);
  distVV(distVV==0)=1;
  EntryOut=(V./distVV-U./distUU);
case 'velocity V in waterlevel points',
  V=vs_get(FD,'map-series',{FieldNr},'V1','quiet');
  V=mean(V,3);
  kfv=vs_get(FD,'map-series',{FieldNr},'KFV','quiet');
  V=V.*kfv;
  V=conv2([V(1,:);V],[1;1],'valid');
  kfv=max(1,conv2([kfv(1,:)>0;kfv>0],[1;1],'valid'));
  EntryOut=V./kfv;
case 'vel. x-dir in waterlevel points',
  [U,NowError]=Local_eval(FD,'velocity U in waterlevel points',FieldNr);
  [V,NowError]=Local_eval(FD,'velocity V in waterlevel points',FieldNr);
  alfa=vs_get(FD,'map-const','ALFAS','quiet');
  alfa0=vs_get(FD,'map-const','GRDANG','quiet');
  alfa=alfa+alfa0;
  alfa=alfa*pi/180;
  EntryOut=U.*cos(alfa)-V.*sin(alfa);
case 'vel. y-dir in waterlevel points',
  [U,NowError]=Local_eval(FD,'velocity U in waterlevel points',FieldNr);
  [V,NowError]=Local_eval(FD,'velocity V in waterlevel points',FieldNr);
  alfa=vs_get(FD,'map-const','ALFAS','quiet');
  alfa0=vs_get(FD,'map-const','GRDANG','quiet');
  alfa=alfa+alfa0;
  alfa=alfa*pi/180;
  EntryOut=U.*sin(alfa)+V.*cos(alfa);
case 'velocity U',
  EntryOut=vs_get(FD,'map-series',{FieldNr},'U1','quiet');
  EntryOut=mean(EntryOut,3);
case 'open U',
  EntryOut=vs_get(FD,'map-series',{FieldNr},'KFU','quiet');
case 'velocity V',
  EntryOut=vs_get(FD,'map-series',{FieldNr},'V1','quiet');
  EntryOut=mean(EntryOut,3);
case 'open V',
  EntryOut=vs_get(FD,'map-series',{FieldNr},'KFV','quiet');
case 'concentration',
  EntryOut=vs_get(FD,'map-series',{FieldNr},'R1',{0 0 1 1},'quiet');
case 'velocity magnitude',
  U=vs_get(FD,'map-series',{FieldNr},'U1','quiet');
  U=mean(U,3);
  V=vs_get(FD,'map-series',{FieldNr},'V1','quiet');
  V=mean(V,3);
  kfu=vs_get(FD,'map-series',{FieldNr},'KFU','quiet');
  kfv=vs_get(FD,'map-series',{FieldNr},'KFV','quiet');
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
  EntryOut=vs_get(FD,'map-series',{FieldNr},'RSP','quiet');
case 'flow time',
  EntryOut=vs_get(FD,'map-info-series',{FieldNr},'ITMAPC','quiet');
  DT=vs_get(FD,'map-const','DT','quiet');
  TUNIT=vs_get(FD,'map-const','TUNIT','quiet');
  EntryOut=EntryOut*DT*TUNIT/(60*60*24);
case 'vertical eddy viscosity',
  EntryOut=vs_get(FD,'map-series',{FieldNr},'VICWW',{0 0 2},'quiet');
case 'vertical eddy diffusivity',
  EntryOut=vs_get(FD,'map-series',{FieldNr},'DICWW',{0 0 2},'quiet');
otherwise,
  EntryOut=[];
  return;
end;
NowError=0;
