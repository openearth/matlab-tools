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
%sediment unstructured initial file creation

%INPUT:
%   -
%
%OUTPUT:
%   -a .sed file compatible with D3D is created in file_name

function D3D_sed_u(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

% dire_sim=simdef.D3D.dire_sim;
file_name=simdef.file.sed;
IFORM=simdef.tra.IFORM; %sediment transport flag [-] [integer(1,1)] 2=MPM; 4=MPM-based; 14=AM
sedTrans=simdef.tra.sedTrans;
dk=simdef.sed.dk;
SedTyp=simdef.tra.SedTyp;
FacDSS=1;

node_relations=false;
if isfield(simdef.tra,'node_relations')
    node_relations=simdef.tra.node_relations;
end
    
%other
nf=length(dk); %number of fractions 

%% FILE

%preamble
kl=1;
data{kl,1}='[SedimentFileInformation]'; kl=kl+1;
data{kl,1}='   FileCreatedBy    = V         '; kl=kl+1;
data{kl,1}=sprintf('   FileCreationDate = %s         ',datestr(now)); kl=kl+1;  
data{kl,1}='   FileVersion      = 02.00                        '; kl=kl+1;
data{kl,1}='[SedimentOverall]'; kl=kl+1;
data{kl,1}='   Cref             =  1.6000000e+003      [kg/m3]  CSoil Reference density for hindered settling calculations'; kl=kl+1;
% data{7  ,1}='   IopSus           = 0                             If Iopsus = 1: susp. sediment size depends on local flow and wave conditions';

%fractions
for kf=1:nf
    data{kl,1}=        '[Sediment]'; kl=kl+1;
    data{kl,1}=sprintf('   Name             = #Sediment%d#                   Name of sediment fraction',kf); kl=kl+1;
    switch SedTyp(kf)
        case 1
            SedTyp_str='mud';
        case 2
            SedTyp_str='sand';
        case 3
            SedTyp_str='bedload';
        otherwise
            error('do')
    end
    data{kl,1}=sprintf('   SedTyp           = %s                       Must be "sand", "mud" or "bedload"',SedTyp_str); kl=kl+1;
    data{kl,1}=        '   IniSedThick      =  1.0000000e+000      [m]      Initial sediment layer thickness at bed (overuled if IniComp is prescribed)'; kl=kl+1;
    data{kl,1}=        '   RhoSol           =  2.6500000e+003      [kg/m3]  Specific density'; kl=kl+1;
    data{kl,1}=sprintf('   TraFrm           = %d                            Integer selecting the transport formula',IFORM(kf)); kl=kl+1;
    data{kl,1}=        '   CDryB            =  1.5900000e+003      [kg/m3]  Dry bed density'; kl=kl+1;
    data{kl,1}=sprintf('   FacDSS           = %f                                FacDss*SedDia = Initial suspended sediment diameter [-]      ',FacDSS); kl=kl+1;

    if ~isnan(sedTrans{kf}(1))


    switch IFORM(kf)
        case -4 %SANTOSS
            

            %set everything as default
        case -3 %Partheniades-Krone
            EroPar=sedTrans{kf}(1);
            TcrSed=sedTrans{kf}(2);
            TcrEro=sedTrans{kf}(3);
            ws0=dk(kf); %we use the array of sediment size for settling velocity. 
            wsm=ws0;
            SalMax=100; %no salinity interaction

            data{kl,1}=sprintf('   EroPar                  = %f                                erosion parameter [kg/m2s]                                   ',EroPar); kl=kl+1;
            data{kl,1}=sprintf('   TcrSed                  = %f                                critical shear stress for sedimentation [N/m2]               ',TcrSed); kl=kl+1;
            data{kl,1}=sprintf('   TcrEro                  = %f                                critical shear stress for erosion of bed [N/m2]              ',TcrEro); kl=kl+1;
            data{kl,1}=sprintf('   FacDSS                  = %f                                FacDss*SedDia = Initial suspended sediment diameter [-]      ',FacDSS); kl=kl+1;
            data{kl,1}=sprintf('   WS0                     = %f                                settling velocity fresh water (for default mud settling equation) [m/s]       ',ws0); kl=kl+1;
            data{kl,1}=sprintf('   WSM                     = %f                                settling velocity saline water (for default mud settling equation) [m/s]        ',wsm); kl=kl+1;
            data{kl,1}=sprintf('   SalMax                  = %f                                settling velocity saline water (for default mud settling equation) [m/s]        ',SalMax); kl=kl+1;



        % TcrFluff critical shear stress for erosion of fluff layer [default: 0] N/m2
        % ParFluff0 maximum erosion flux from fluff layer [default: 0] s/m
        % ParFluff1 erosion parameter for fluff layer [default: 0] m s/kg
        % DepEff reduction factor for deposition/sedimentation rate (value between 0 = no sedimentation and 1 = reference sedimentation, or equal to -1 = reduction based on critical shear stress for sedimentation) [default: -1] -
        % PowerN power for the relative critical shear stres for erosion term [default: 1]
        case 1 %Engelund-Hansen
            data{kl,1}=sprintf('   SedDia           =  %0.7e      [m]      sediment diameter (D50)',dk(kf)); kl=kl+1;

            ACal=sedTrans{kf}(1);
            RouKs=sedTrans{kf}(2);
            SusFac=sedTrans{kf}(3);

            data{kl,1}=sprintf('   ACal                    = %f                                calibration coefficient a [-]                ',ACal); kl=kl+1;
            data{kl,1}=sprintf('   RouKs                   = %f                                bed roughness height rk (dummy) [m]          ',RouKs); kl=kl+1;
            data{kl,1}=sprintf('   SusFac                  = %f                                suspended sediment fraction [default: 0] [-] ',SusFac); kl=kl+1;
        case 4 %Generalized Formula
            data{kl,1}=sprintf('   SedDia           =  %0.7e      [m]      sediment diameter (D50)',dk(kf)); kl=kl+1;

            ACal=sedTrans{kf}(1);
            PowerB=0;
            PowerC=sedTrans{kf}(2);
            ThetaC=sedTrans{kf}(3);
            RipFac=1;

            data{kl,1}=sprintf('   ACal                  = %f                                Calibration coefficient                ',ACal); kl=kl+1;
            data{kl,1}=sprintf('   PowerB                = %f                                Power b                                ',PowerB); kl=kl+1;
            data{kl,1}=sprintf('   PowerC                = %f                                Power c                                ',PowerC); kl=kl+1;
            data{kl,1}=sprintf('   RipFac                = %f                                Ripple factor or efficiency factor     ',RipFac); kl=kl+1;
            data{kl,1}=sprintf('   ThetaC                = %f                                Critical mobility factor               ',ThetaC); kl=kl+1;
        case 14 %Ashida-Michiue
            data{kl,1}=sprintf('   SedDia           =  %0.7e      [m]      sediment diameter (D50)',dk(kf)); kl=kl+1;
            
            ACal=sedTrans{kf}(1);
            ThetaC=sedTrans{kf}(2);
            PowerM=1.5;
            PowerP=1;
            PowerQ=1;  

            data{kl,1}=sprintf('   ACal                  = %f                                Calibration coefficient                ',ACal); kl=kl+1;
            data{kl,1}=sprintf('   ThetaC                = %f                                Critical mobility factor               ',ThetaC); kl=kl+1;
            data{kl,1}=sprintf('   PowerM                = %f                                Power b                                ',PowerM); kl=kl+1;
            data{kl,1}=sprintf('   PowerP                = %f                                Power c                                ',PowerP); kl=kl+1;
            data{kl,1}=sprintf('   PowerQ                = %f                                Ripple factor or efficiency factor     ',PowerQ); kl=kl+1;
    end %IFORM

    end %isnan
    if node_relations
        data{kl,1}=        '   NodeRelations         = #table.nrd#                       [ - ]    File with Overall Node Relations(relative path to sed)';    kl=kl+1;
    end %node realations
end

%% WRITE

% file_name=fullfile(dire_sim,'sed.sed');
writetxt(file_name,data,'check_existing',check_existing)
