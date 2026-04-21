%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%morphological initial file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_mor(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

file_name=simdef.file.mor;

nf=numel(simdef.sed.dk);

%% FILE

[fid,fname_local]=write_local_and_copy('open',file_name,'overwrite',~check_existing);

%%
fprintf(fid,'[MorphologyFileInformation]\r\n');
fprintf(fid,'   FileCreatedBy    = V\r\n');
fprintf(fid,'   FileCreationDate = %s\r\n',datestr(datetime('now')));
fprintf(fid,'   FileVersion      = 02.00\r\n');

%%
fprintf(fid,'\r\n');
fprintf(fid,'[Morphology]\r\n');
fprintf(fid,'   MorFac           =  %0.12E               [-]      Morphological scale factor\r\n',simdef.mor.MorFac);
% fprintf(fid,'   MorStt           =  %0.12E               [s]      Spin-up interval from TStart till start of morphological changes\r\n',simdef.mor.MorStt);
fprintf(fid,'   BedUpdStt        =  %0.12E               [s]      Spin-up interval from TStart till start of bed level changes\r\n',simdef.mor.MorStt);
fprintf(fid,'   CmpUpdStt        =  %0.12E               [s]      Spin-up interval from TStart till start of composition changes\r\n',simdef.mor.MorStt);
fprintf(fid,'   SedTransStt      =  %0.12E               [s]      Spin-up interval from TStart till start of sediment transport\r\n',0);
fprintf(fid,'   Thresh           =  1.0000000e-003      [m]      Threshold sediment thickness for transport and erosion reduction\r\n');
fprintf(fid,'   BedUpd           = %i                            Update bed levels during FLOW simulation\r\n',simdef.mor.BedUpd);
fprintf(fid,'   CmpUpd           = %i                            Update bed composition during flow run\r\n',simdef.mor.CmpUpd);
fprintf(fid,'   NeuBcMud         = 1\r\n');
fprintf(fid,'   NeuBcSand        = 1\r\n');
fprintf(fid,'   DensIn           = 0    Include effect of sediment concentration on fluid density\r\n');
fprintf(fid,'   ISlope = %d         [ - ] Flag for bed slope effect\r\n',simdef.mor.ISlope);
fprintf(fid,'                            1          : None\r\n');
fprintf(fid,'                            2 (default): Bagnold\r\n');
fprintf(fid,'                            3          : Koch & Flokstra\r\n');
fprintf(fid,'   AShld  = %f       [ - ] Bed slope parameter Koch & Flokstra\r\n',simdef.mor.AShld);
fprintf(fid,'   BShld  = %f       [ - ] Bed slope parameter Koch & Flokstra\r\n',simdef.mor.BShld);
fprintf(fid,'   CShld  = %f       [ - ] Bed slope parameter Koch & Flokstra\r\n',simdef.mor.CShld);
fprintf(fid,'   DShld  = %f       [ - ] Bed slope parameter Koch & Flokstra\r\n',simdef.mor.DShld);
fprintf(fid,'   AlfaBs           =  %0.7E      [-]      Streamwise bed gradient factor for bed load transport\r\n',simdef.mor.AlfaBs);
fprintf(fid,'   AlfaBn           =  0.0000000e+000      [-]      Transverse bed gradient factor for bed load transport\r\n');
fprintf(fid,'   CoulFri          = 0\r\n');
fprintf(fid,'   FlFdRat          = 0                      \r\n');
fprintf(fid,'   ThetaCr          = 0                      \r\n');
fprintf(fid,'   IHidExp= %d        [ - ] Flag for hiding & exposure\r\n',simdef.mor.IHidExp);
fprintf(fid,'                            1 (default): none\r\n');
fprintf(fid,'                            2          : Egiazaroff\r\n');
fprintf(fid,'                            3          : Ashida & Michiue, modified Egiazaroff\r\n');
fprintf(fid,'                            4          : Soehngen, Kellermann, Loy\r\n');
fprintf(fid,'                            5          : Wu, Wang, Jia\r\n');
fprintf(fid,'   ASKLHE = %0.7E\r\n',simdef.mor.ASKLHE);
fprintf(fid,'   MWWJHE                = 1                      \r\n');
if simdef.mdf.secflow
    fprintf(fid,'   Espir  = 1.0       [ - ] Calibration factor spiral flow\r\n');
else
    fprintf(fid,'   Espir  = 0.0       [ - ] Calibration factor spiral flow\r\n');
end
fprintf(fid,'   Sus              =  1.0000000e+000      [-]      Multiplication factor for suspended sediment reference concentration\r\n');
fprintf(fid,'   Bed              =  1.0000000e+000      [-]      Multiplication factor for bed-load transport vector magnitude\r\n');
fprintf(fid,'   SusW             =  1.0000000e+000      [-]      Wave-related suspended sed. transport factor\r\n');
fprintf(fid,'   BedW             =  1.0000000e+000      [-]      Wave-related bed-load sed. transport factor\r\n');
fprintf(fid,'   SedThr           =  %0.7E      [m]      Minimum water depth for sediment computations\r\n',simdef.mor.SedThr);
fprintf(fid,'   ThetSD           =  %0.7E      [-]      Factor for erosion of adjacent dry cells\r\n',simdef.mor.ThetSD);
fprintf(fid,'   HMaxTH           =  %0.7E      [m]      Max depth for variable THETSD. Set < SEDTHR to use global value only\r\n',simdef.mor.HMaxTH);
if any(simdef.mor.IBedCond==[2,3,5,7])
    fprintf(fid,'   BcFil  = bcm.bcm\r\n');
else
    fprintf(fid,'   BcFil  =        \r\n');
end
%
% data{kl,1}=        '   EpsPar           = false                         Vertical mixing distribution according to van Rijn (overrules k-epsilon model)'; kl=kl+1;
% data{kl,1}=        '   IopKCW           = 1                             Flag for determining Rc and Rw'; kl=kl+1;
% data{kl,1}=        '   RDC              = 0.01                 [m]      Current related roughness height (only used if IopKCW <> 1)'; kl=kl+1;
% data{kl,1}=        '   RDW              = 0.02                 [m]      Wave related roughness height (only used if IopKCW <> 1)'; kl=kl+1;
% data{kl,1}=        '   EqmBc            = true                          Equilibrium sand concentration profile at inflow boundaries'; kl=kl+1;
% data{kl,1}=        '   AksFac           =  1.0000000e+000      [-]      van Rijn''s reference height = AKSFAC * KS'; kl=kl+1;
% data{kl,1}=        '   RWave            =  1.0000000e+000      [-]      Wave related roughness = RWAVE * estimated ripple height. Van Rijn Recommends range 1-3'; kl=kl+1;
% data{kl,1}=        '   FWFac            =  1.0000000e+000      [-]      Vertical mixing distribution according to van Rijn (overrules k-epsilon model)'; kl=kl+1;
% data{kl,1}=        '   EpsPar = false     [T/F] Only for waves in combination with k-epsilon turbulence model'; kl=kl+1;
% data{kl,1}=        '                            TRUE : Van Rijn''s parabolic-linear mixing distribution for current-related mixing '; kl=kl+1;
% data{kl,1}=        '                            FALSE: Vertical sediment mixing values from K-epsilon turbulence model'; kl=kl+1;
% data{kl,1}=        '   IopKCW = 1         [ - ] Flag for determining Rc and Rw'; kl=kl+1;
% data{kl,1}=        '                            1 (default): Rc from flow, Rw=RWAVE*0.025'; kl=kl+1;
% data{kl,1}=        '                            2          : Rc=RDC and Rw=RDW as read from this file'; kl=kl+1;
% data{kl,1}=        '                            3          : Rc=Rw determined from mobility'; kl=kl+1;
% data{kl,1}=        '   RDC    = 0.01      [ - ] Rc in case IopKCW = 2'; kl=kl+1;
% data{kl,1}=        '   RDW    = 0.02      [ - ] Rw in case IopKCW = 2'; kl=kl+1;
%%
for kn=1:simdef.mor.upstream_nodes
    
    switch simdef.D3D.structure
        case 1
            fprintf(fid,'\r\n');
            fprintf(fid,'[Boundary]\r\n');
            fprintf(fid,'  Name = Upstream_%02d\r\n',kn);
            fprintf(fid,'  IBedCond = %d\r\n',simdef.mor.IBedCond);
            fprintf(fid,'  ICmpCond = %d\r\n',simdef.mor.ICmpCond);
        case 2
            fprintf(fid,'\r\n');
            fprintf(fid,'[Boundary]\r\n');
            fprintf(fid,'  Name = %s_%02d\r\n',simdef.pli.fname_u,kn);
            fprintf(fid,'  IBedCond = %d\r\n',simdef.mor.IBedCond);
            fprintf(fid,'  ICmpCond = %d\r\n',simdef.mor.ICmpCond);
    end

end %kn

% data{kl,1}=        ''; kl=kl+1;
% data{kl,1}=        '[Boundary]'; kl=kl+1;
% data{kl,1}=        '  Name = Downstream'; kl=kl+1;
% data{kl,1}=        '  IBedCond = 0'; kl=kl+1;
% data{kl,1}=        '  ICmpCond = 0'; kl=kl+1;
%% OUTPUT
fprintf(fid,'\r\n');
fprintf(fid,'[Output]\r\n');
fprintf(fid,'  OutDefault = 1\r\n'); %default is all morphodynamic output unless you set it to false.
fprintf(fid,'  Dm = 1\r\n');
fprintf(fid,'  Dg = 1\r\n');
fprintf(fid,'  HidExp = 1\r\n');
% data{kl,1}=        '  Percentiles = 10'; kl=kl+1;
fprintf(fid,'  Bedslope = 1\r\n');
% data{kl,1}=sprintf('  HiranoIllposed = %d',HiranoCheck); kl=kl+1; %if we test for ill-posedness, we save the variable `hirano_illposed`
% data{kl,1}=sprintf('  Derivatives = %d',0); kl=kl+1; %if we test for ill-posedness, we save the variable `hirano_illposed`
% data{kl,1}=sprintf('  fIk = %d',0); kl=kl+1; %if we test for ill-posedness, we save the variable `hirano_illposed`
% data{kl,1}=sprintf('  RegularizationLocations = %d',0); kl=kl+1; %if we test for ill-posedness, we save the variable `hirano_illposed`
fprintf(fid,'  VelocMagAtZeta = 1\r\n'); %to get “mesh1d_umod�?
fprintf(fid,'  RawTransportAtZeta = 1\r\n');
fprintf(fid,'  SourceSinkTerms = 1\r\n');

fprintf(fid,'\r\n');
fprintf(fid,'[Numerics]\r\n');
% data{kl,1}=sprintf('  HiranoCheck = %d       [ - ] Flag for well-posedness of Hirano check',HiranoCheck); kl=kl+1;
% data{kl,1}=        '                            0 (default): Off'; kl=kl+1;
% data{kl,1}=        '                            1          : On'; kl=kl+1;
% data{kl,1}=sprintf('  HiranoCheckPertubation = %0.7E',HiranoCheckPerturbation); kl=kl+1;
% data{kl,1}=sprintf('  HiranoCheckEigThr = %0.7E',HiranoCheckEigThr); kl=kl+1;

if ~isnan(simdef.mor.UpwindBedload)
    fprintf(fid,'  UpwindBedload = %d\r\n',simdef.mor.UpwindBedload);
else
    fprintf(fid,'  BedloadScheme = #%s#\r\n',simdef.mor.BedloadScheme);
% BedloadScheme = #upwsb#  !default upwind
% BedloadScheme = #central#  !central (old Upwind=false)
% BedloadScheme = #upwind# !Mart's scheme
end
%   MaximumWaterdepth = true
%   MaximumWaterdepthFraction = 0.25

%% HiranoIllposed
% data{kl,1}=        ''; kl=kl+1;
% data{kl,1}=        '[HiranoIllposed]'; kl=kl+1;
% data{kl,1}=sprintf('  HiranoCheck = %d',HiranoCheck); kl=kl+1;
% data{kl,1}=sprintf('  HiranoRegularize = %d',HiranoRegularize); kl=kl+1;
% data{kl,1}=sprintf('  HiranoDiffusion = %0.7E',HiranoDiffusion); kl=kl+1;
% data{kl,1}=sprintf('  RegularizationRadious = %0.7E',RegularizationRadious); kl=kl+1;
% data{kl,1}=sprintf('  SedTransDerivativesComputation = %d',SedTransDerivativesComputation); kl=kl+1;

%% UNDERLAYER
fprintf(fid,'\r\n');
fprintf(fid,'[Underlayer]\r\n');
fprintf(fid,'  IUnderLyr = %d       [ - ] Flag for underlayer concept\r\n',simdef.mor.IUnderLyr);
fprintf(fid,'                            1 (default): one fully mixed layer\r\n');
fprintf(fid,'                            2          : graded sediment underlayers\r\n');
if nf>1
    [~,fname,fext]=fileparts(simdef.file.mini);
    fprintf(fid,'  IniComp          = %s%s\r\n',fname,fext);
    fprintf(fid,'  ExchLyr = false     [T/F] Switch for exchange layer\r\n');
    fprintf(fid,'  TTLForm = 1         [ - ] Transport layer thickness formulation\r\n');
    fprintf(fid,'                            1 (default): constant (user-specified) thickness\r\n');
    fprintf(fid,'  ThTrLyr = %0.7E       [ m ] Thickness of the transport layer\r\n',simdef.mor.ThTrLyr);
    fprintf(fid,'  MxNULyr = %d          [ - ] Number of underlayers (excluding final well mixed layer)\r\n',simdef.mor.MxNULyr);
    fprintf(fid,'  ThUnLyr = %0.7E       [ m ] Thickness of each underlayer\r\n',simdef.mor.ThUnLyr);
end

%% WRITE

write_local_and_copy('close',fid,fname_local,file_name)

end %function
