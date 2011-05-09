function varargout=crosssec(varargin)
% CROSSSEC reading D3D data of cross sections.
%     CROSSSEC(NFSstruct,CrossSec,Command,...)
%     performs the indicated command for the specified
%     cross sections. Cross sections may be indicated by
%     their name (using a cell array of names) or their
%     number.
%     Valid commands are:
%       'names'  : get cross section names
%       'plotMN' : plot in (M,N) coordinate space (cur. axes)
%                  H = CROSSSEC(...,'plotMN')
%       'plotXY' : plot in (X,Y) coordinate space (cur. axes)
%                  H = CROSSSEC(...,'plotXY')
%       'coordMN': get (M,N) coordinates
%                  MN = CROSSSEC(...,'coordMN') or
%                  [M,N] = CROSSSEC(...,'coordMN')
%       'coordXY': get (X,Y) coordinates
%                  XY = CROSSSEC(...,'coordXY') or
%                  [X,Y] = CROSSSEC(...,'coordXY')
%       'name'   : get cross section name(s)
%                  NAMES = CROSSSEC(...,'name')
%       'read'   : read observation data
%                  [Data1,Data2,...] = 
%                     CROSSSEC(...,'read',TSTEPS,Prop1,Prop2,...)
%                  where the properties are either 'time' or
%                  valid data fields: CTR, FLTR (momentary resp.
%                  total discharge through cross section) and
%                  (ATR, DTR) advective and dispersive transport
%                  The TSTEPS are optional (default all).
%
%     If no NFSstruct is specified the latest opened file is used.
%     If no cross sections are specified all cross sections are used.
%
%     Support for TRIH files (TRIM file required for 'plotXY' and 
%     'coordXY' commands).

i=1;
cmds={'plotmn*','plotxy*','coordmn*','coordxy*','read*','name*'};

% NFSstruct
if (nargin>=i) & isstruct(varargin{i})
   C=varargin{i};
   i=i+1;
else
   C=vs_use('lastread');
end

Ctp=vs_type(C);
if isempty(strmatch(Ctp,{'Delft3D-trih','Delft3D-trim'}))
   error('Invalid NEFIS file for this action.')
else
   switch Ctp
      case 'Delft3D-trih'
         CH=C;
         CM=[];
      case 'Delft3D-trim'
         CM=C;
         CH=vs_use(strrep([C.FileName C.DefExt],'trim','trih'),'quiet');
         vs_use(CM);
         if isempty(CM)
            error('Cannot open associated TRIH file.')
         end
         Ctp='Delft3D-trih';
   end
end

% Cross Section
switch Ctp
   case 'Delft3D-trih'
      Info=vs_disp(CH,'his-const','NAMTRA');
      stat=1:Info.SizeDim;                 % <-- default all cross sections
      stanames=cellstr(vs_get(CH,'his-const','NAMTRA','quiet'));
end
backward_compatible=0;
if nargin>=i
   if isnumeric(varargin{i}) %Cross section number(s)
      stat=varargin{i}(:)';
      i=i+1;
      if any(stat<1) | any(stat>Info.SizeDim) | any(stat~=round(stat))
         error('Invalid cross section number encountered.')
      end
   elseif iscell(varargin{i}) %Cross section names
      N=length(varargin{i});
      stat=zeros(1,N);
      for j=1:N
         Str=varargin{i}{j};
         if ~ischar(Str)
            error(sprintf('Cross section name %i is invalid.',j))
         end
         st=ustrcmpi(Str,stanames);
         if st>0
            stat(j)=st;
         else
            error(sprintf('Cannot find cross section with name: %s.',Str))
         end
      end
      i=i+1;
   elseif ischar(varargin{i}) %Cross section name or command
      Str=varargin{i};
      Cmd=ustrcmpi(Str,cmds);
      if Cmd<0 % Cross section name
         st=ustrcmpi(Str,stanames);
         if st>0
            stat=st;
         else
            error(sprintf('Cannot find cross section with name: %s.',Str))
         end
         i=i+1;
      else % Command
         if Str(end)=='*'
            backward_compatible=1;
         end
      end
   end
end

%
% Take care of the implicit "unique" filter in VS_GET/LET:
% Apply unique filter here and keep information for the back
% transformation of the data obtained to the requested order.
%
[stat,dummy,transform_back]=unique(stat);
if backward_compatible
   %
   % Old versions did not correct for "unique" filter. So,
   % in backward compatibility mode do not "unsort" the data
   % obtained from VS_GET/LET. This is achieved here by over-
   % writing the backward transformation with the identity
   % transformation.
   %
   transform_back=1:length(stat);
end

% Command
MNTRA=vs_get(CH,'his-const','MNTRA','quiet');
MNTRA=MNTRA(:,transform_back);

if (nargin>=i) & ischar(varargin{i})
   Cmd=ustrcmpi(lower(varargin{i}),cmds);
   if isempty(Cmd)
      error(sprintf('Unrecognized command: %s.',varargin{i}))
   end
   switch cmds{Cmd}
      case {'plotmn*','coordmn*'} % plotmn, coordmn
         MTRA=[];
         NTRA=[];
         for i=1:size(MNTRA,2)
            if MNTRA(1,i)==MNTRA(3,i) % M1==M2
               N=((min(MNTRA([2 4],i))-1):max(MNTRA([2 4],i)))';
               M=repmat(MNTRA(1,i),size(N));
            else % N1==N2
               M=((min(MNTRA([1 3],i))-1):max(MNTRA([1 3],i)))';
               N=repmat(MNTRA(2,i),size(M));
            end
            MTRA=[MTRA; M; NaN];
            NTRA=[NTRA; N; NaN];
         end
         if Cmd==1 % plotMN
            h=line(MTRA,NTRA,'linestyle','-', ...
               'linewidth',3,'color','r');
            h={h};
         else % coordMN
            if nargout==2,
               h={MTRA NTRA};
            else
               h={[MTRA NTRA]};
            end
         end
      case {'plotxy*','coordxy*'} % plotxy, coordxy
         XTRA=[];
         YTRA=[];
         if isempty(CM)
            CM=vs_use(strrep([C.FileName C.DefExt],'trih','trim'),'quiet');
            vs_use(CH);
            if isempty(CM)
               error('Cannot open associated TRIM file.')
            end
         end
         X=vs_get(CM,'map-const','XCOR','quiet');
         Y=vs_get(CM,'map-const','YCOR','quiet');
         for i=1:size(MNTRA,2)
            if MNTRA(1,i)==MNTRA(3,i) % M1==M2
               M=MNTRA(1,i);
               N=max(1,min(MNTRA([2 4],i))-1): ...
                  min(size(X,1),max(MNTRA([2 4],i)));
               XTRA=[XTRA; X(N,M); NaN];
               YTRA=[YTRA; Y(N,M); NaN];
            else % N1==N2
               M=max(1,min(MNTRA([1 3],i))-1): ...
                  min(size(X,2),max(MNTRA([1 3],i)));
               N=MNTRA(2,i);
               XTRA=[XTRA; transpose(X(N,M)); NaN];
               YTRA=[YTRA; transpose(Y(N,M)); NaN];
            end
         end
         if Cmd==2 % plotXY
            h=line(XTRA,YTRA,'linestyle','-', ...
               'linewidth',3,'color','r');
            h={h};
         else % coordXY
            if nargout==2
               h={XTRA YTRA};
            else
               h={[XTRA YTRA]};
            end
         end
      case 'name*'
         switch Ctp
            case 'Delft3D-trih'
               h={cellstr(vs_get(C,'his-const','NAMTRA',{stat},'quiet'))};
               h{1}=h{1}(transform_back);
            otherwise
               h={};
         end
      case 'read*' % read
         i=i+1;
         Info=vs_disp(CH,'his-series',[]);
         idx = 1:Info.SizeDim;                % <-- default all time steps
         if (nargin>=i) & isnumeric(varargin{i})
            idx = varargin{i};
            i=i+1;
         end
         h=cell(1,nargin-i+1);
         for j=0:(nargin-i)
            switch lower(varargin{i+j})
               case 'time'
                  CONSTS=vs_get(CH,'his-const','*','quiet');
                  dt=CONSTS.DT*CONSTS.TUNIT;
                  h{j+1}=vs_let(CH,'his-info-series',{idx},'ITHISC','quiet')*dt/(24*3600)+tdelft3d(CONSTS.ITDATE);
               otherwise
                  grp=vs_find(CH,varargin{i+j});
                  if length(grp)==1
                     Info=vs_disp(CH,grp{1},varargin{i+j});
                     if ~isstruct(Info)
                        h{j+1}=[];
                     else
                        elidx(1:Info.NDim)={0};
                        elidx(1)={stat};
                        h{j+1}=vs_let(CH,grp{1},{idx},varargin{i+j},elidx,'quiet');
                        transform=repmat({':'},1,1+Info.NDim);
                        transform{2}=transform_back;
                        h{j+1}=h{j+1}(transform{:});
                     end
                  end
            end
         end
      otherwise
         error(sprintf('Command "%s" has not yet been implemented.',cmds{Cmd}))
   end
else
   error('Not enough input arguments: no command string found.')
end

if nargout>0,
   varargout=h;
end
