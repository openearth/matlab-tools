function varargout=station(varargin)
% STATION reading D3D observation points.
%     STATION(NFSstruct,Stations,Command,...)
%     performs the indicated command for the specified
%     stations. Stations may be indicated by their name
%     (using a cell array of names) or their number.
%     Valid commands are:
%       'plotMN' : plot in (M,N) coordinate space (cur. axes)
%                  H = STATION(...,'plotMN')
%       'plotXY' : plot in (X,Y) coordinate space (cur. axes)
%                  H = STATION(...,'plotXY')
%       'coordMN': get (M,N) coordinates
%                  MN = STATION(...,'coordMN') or
%                  [M,N] = STATION(...,'coordMN')
%       'coordXY': get (X,Y) coordinates
%                  XY = STATION(...,'coordXY') or
%                  [X,Y] = STATION(...,'coordXY')
%       'name'   : get station name(s)
%                  NAMES = STATION(...,'name')
%       'read'   : read observation data
%                  [Data1,Data2,...] = 
%                     STATION(...,'read',TSTEPS,Prop1,Prop2,...)
%                  where the properties are either 'time' or
%                  valid data fields: ZWL (waterlevel), ZCURU/V/W
%                  (velocity in u/v/w direction), etc.
%                  The TSTEPS are optional (default all).
%     If no NFSstruct is specified the latest opened file is used.
%     If no stations are specified all stations are used.
%
%     CHANGED - 15 Oct 2004: returns data in the requested order and not in
%     the order as stored in the data file. Old behaviour can be regained
%     by adding a asterisk to the command string, e.g. 'read*'.
%
%     Support for TRIH files.

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
if isempty(strmatch(Ctp,'Delft3D-trih'))
   error('Invalid NEFIS file for this action.')
end

% Station
switch Ctp
   case 'Delft3D-trih'
      Info=vs_disp(C,'his-const','NAMST');
      stat=1:Info.SizeDim;                 % <-- default all stations
      stanames=cellstr(vs_get(C,'his-const','NAMST','quiet'));
end
backward_compatible=0;
if nargin>=i
   if isnumeric(varargin{i}) %Station number(s)
      stat=varargin{i}(:)';
      i=i+1;
      if any(stat<1) | any(stat>Info.SizeDim) | any(stat~=round(stat))
         error('Invalid station number encountered.')
      end
   elseif iscell(varargin{i}) %Station names
      N=length(varargin{i});
      stat=zeros(1,N);
      for j=1:N
         Str=varargin{i}{j};
         if ~ischar(Str)
            error(sprintf('Station name %i is invalid.',j))
         end
         st=ustrcmpi(Str,stanames);
         if st>0
            stat(j)=st;
         else
            error(sprintf('Cannot find station with name: %s.',Str))
         end
      end
      i=i+1;
   elseif ischar(varargin{i}) %Station name or command
      Str=varargin{i};
      Cmd=ustrcmpi(Str,cmds);
      if Cmd<0 % Station name
         st=ustrcmpi(Str,stanames);
         if st>0
            stat=st;
         else
            error(sprintf('Cannot find station with name: %s.',Str))
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
if (nargin>=i) & ischar(varargin{i})
   Cmd=ustrcmpi(lower(varargin{i}),cmds);
   if Cmd<0
      error(sprintf('Unrecognized command: %s.',varargin{i}))
   end
   switch cmds{Cmd}
      case 'plotmn*'
         MNSTAT=vs_get(C,'his-const','MNSTAT',{0 stat},'quiet');
         MNSTAT=MNSTAT(:,transform_back);
         h=line(MNSTAT(1,:),MNSTAT(2,:),'linestyle','none','marker','o', ...
            'markeredgecolor','r','markerfacecolor','w');
         h={h};
      case 'plotxy*'
         XYSTAT=vs_get(C,'his-const','XYSTAT',{0 stat},'quiet');
         XYSTAT=XYSTAT(:,transform_back);
         h=line(XYSTAT(1,:),XYSTAT(2,:), ...
            'linestyle','none','marker','o', ...
            'markeredgecolor','r','markerfacecolor','w');
         h={h};
      case 'coordmn*'
         h=vs_get(C,'his-const','MNSTAT',{0 stat},'quiet');
         h=h(:,transform_back);
         if nargout==2
            h={h(1,:) h(2,:)};
         else
            h={h};
         end
      case 'coordxy*'
         h=vs_get(C,'his-const','XYSTAT',{0 stat},'quiet');
         h=h(:,transform_back);
         if nargout==2
            h={h(1,:) h(2,:)};
         else
            h={h};
         end
      case 'name*'
         switch Ctp
            case 'Delft3D-trih'
               h={cellstr(vs_get(C,'his-const','NAMST',{stat},'quiet'))};
               h{1}=h{1}(transform_back);
            otherwise
               h={};
         end
      case 'read*'
         i=i+1;
         Info=vs_disp(C,'his-series',[]);
         idx = 1:Info.SizeDim;                % <-- default all time steps
         if (nargin>=i) & isnumeric(varargin{i})
            idx = varargin{i};
            i=i+1;
         end
         h=cell(1,nargin-i+1);
         for j=0:(nargin-i)
            switch lower(varargin{i+j})
               case 'time'
                  CONSTS=vs_get(C,'his-const','*','quiet');
                  dt=CONSTS.DT*CONSTS.TUNIT;
                  h{j+1}=vs_let(C,'his-info-series',{idx},'ITHISC','quiet')*dt/(24*3600)+tdelft3d(CONSTS.ITDATE);
               otherwise
                  grp=vs_find(C,varargin{i+j});
                  if length(grp)==1
                     Info=vs_disp(C,grp{1},varargin{i+j});
                     if ~isstruct(Info)
                        h{j+1}=[];
                     else
                        elidx(1:Info.NDim)={0};
                        elidx(1)={stat};
                        h{j+1}=vs_let(C,grp{1},{idx},varargin{i+j},elidx,'quiet');
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

if nargout>0
   varargout=h;
end
