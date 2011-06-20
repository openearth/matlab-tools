function val1=dps(Nfs,t,dpsopt)
%DPS  Read the bathymetric depth in water level points from file.
%     Currently supports com-file or trim-file.
%
%     DP = DPS(Nfs,t)
%          Nfs: structure obtained from vs_use when opening
%               communication file (required).
%          t  : timestep (default, last timestep).
%
%     For recent Delft3D versions (PARAMS/NFLTYP not filled):
%     DP = DPS(Nfs,t,dpsopt)
%          dpsopt: DPSOPT (former dryingflooding setting) to be
%                  specified as 'max','min' or 'mean' (default)
%          t     : timestep  (required)

info=vs_disp(Nfs,'BOTTIM',[]);
if ~isstruct(info)
  % Note: minus because readdps adds a minus (QP convention).
  if nargin==1
    info=vs_disp(Nfs,'map-sed-series',[]);
    if isstruct(info)
       t=info.SizeDim;
    else
       t=1;
    end
  end
  val1=-readdps(Nfs,t);
  sz=size(val1);
  val1=reshape(val1,sz([2 3]));
  return
end
if nargin==1
  info=vs_disp(Nfs,'BOTTIM',[]);
  t=info.SizeDim;
end
[val1,Chk]=vs_get(Nfs,'BOTTIM',{t},'DP','quiet');
val1(val1==-999)=NaN;

[nfltp,Chk]=vs_get(Nfs,'PARAMS','NFLTYP','quiet');
if nargin==3
   switch lower(dpsopt)
   case 'max'
      nfltp=2;
   case 'min'
      nfltp=3;
   otherwise
      nfltp=0;
   end
end
switch nfltp
case 2 % MAX
  dp22=val1(2:end,2:end);
  dp22=max(val1(1:end-1,1:end-1),dp22);
  dp22=max(val1(2:end,1:end-1),dp22);
  dp22=max(val1(1:end-1,2:end),dp22);
  val1(2:end,2:end)=dp22;
case 3 % MIN
  dp22=val1(2:end,2:end);
  dp22=min(val1(1:end-1,1:end-1),dp22);
  dp22a=val1(2:end,1:end-1);
  dp22a=min(val1(1:end-1,2:end),dp22a);
  val1(2:end,2:end)=(dp22+dp22a)/2;
otherwise % 0, NO, 1, MEAN
  m=2:size(val1,1);
  n=2:size(val1,2);
  val1(m,n)=(val1(m,n)+val1(m-1,n)+val1(m,n-1)+val1(m-1,n-1))/4;
  val1(1,:)=NaN;
  val1(:,1)=NaN;
end

function dp=readdps(Nfs,t)
Info=vs_disp(Nfs,'map-sed-series','DPS');
Info2=vs_disp(Nfs,'map-sed-series','DPSED');
if isstruct(Info),
    [dp,Chk]=vs_let(Nfs,'map-sed-series',{t},'DPS','quiet');
    dp=-dp;
else
    [dp,Chk]=vs_get(Nfs,'map-const','DP0','quiet');
    dp(dp==-999)=NaN;
    [nfltp,Chk]=vs_get(Nfs,'map-const','DRYFLP','quiet');
    nfltp=lower(deblank(nfltp));
    if isempty(nfltp) & isfield(Nfs,'dps'), nfltp=Nfs.dps; end
    switch nfltp
    case 'mean'
        dp=interp2cen(-dp);
    case 'min'
        dp22=dp(2:end,2:end);
        dp22=min(dp(1:end-1,1:end-1),dp22);
        dp22a=dp(2:end,1:end-1);
        dp22a=min(dp(1:end-1,2:end),dp22a);
        dp(2:end,2:end)=(dp22+dp22a)/2; dp=-dp;
    case 'dp'
        dp=-dp; % DP0 is actually DPS !
    otherwise % default 'max'
        dp22=dp(2:end,2:end);
        dp22=max(dp(1:end-1,1:end-1),dp22);
        dp22=max(dp(2:end,1:end-1),dp22);
        dp22=max(dp(1:end-1,2:end),dp22);
        dp(2:end,2:end)=dp22; dp=-dp;
    end
    dp=reshape(dp,[1 size(dp)]);
    if isstruct(Info2)
        dp0=dp;
        [dp,Chk]=vs_let(Nfs,'map-sed-series',{t},'DPSED','quiet');
        if Chk
            for i=1:size(dp,1)
                % (1,1) is a dummy waterlevel point, so, (1,1) should always contain the initial DPSED value
                dp(i,:)=dp0(1,:)+dp(i,:)-dp(i,1);
            end
        end
    end
end