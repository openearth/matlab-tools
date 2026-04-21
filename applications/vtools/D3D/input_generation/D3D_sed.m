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
%sediment initial file creation

%INPUT:
%   -
%
%OUTPUT:
%   -a .sed file compatible with D3D is created in file_name

function D3D_sed(simdef,varargin)

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

[fid,fname_local]=write_local_and_copy('open',file_name,'overwrite',~check_existing);

%preamble
fprintf(fid,'[SedimentFileInformation]\r\n');
fprintf(fid,'   FileCreatedBy    = V         \r\n');
fprintf(fid,'   FileCreationDate = %s         \r\n',datestr(now));
fprintf(fid,'   FileVersion      = 02.00                        \r\n');
fprintf(fid,'[SedimentOverall]\r\n');
fprintf(fid,'   Cref             =  1.6000000e+003      [kg/m3]  CSoil Reference density for hindered settling calculations\r\n');
% data{7  ,1}='   IopSus           = 0                             If Iopsus = 1: susp. sediment size depends on local flow and wave conditions';

%fractions
for kf=1:nf
    fprintf(fid,'[Sediment]\r\n');
    fprintf(fid,'   Name             = #Sediment%d#                   Name of sediment fraction\r\n',kf);
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
    fprintf(fid,'   SedTyp           = %s                       Must be "sand", "mud" or "bedload"\r\n',SedTyp_str);
    fprintf(fid,'   IniSedThick      =  1.0000000e+002      [m]      Initial sediment layer thickness at bed (overuled if IniComp is prescribed)\r\n');
    fprintf(fid,'   RhoSol           =  2.6500000e+003      [kg/m3]  Specific density\r\n');
    fprintf(fid,'   TraFrm           = %d                            Integer selecting the transport formula\r\n',IFORM(kf));
    fprintf(fid,'   CDryB            =  1.5900000e+003      [kg/m3]  Dry bed density\r\n');
    fprintf(fid,'   FacDSS           = %f                                FacDss*SedDia = Initial suspended sediment diameter [-]      \r\n',FacDSS);

    switch IFORM(kf)
        case -4 %SANTOSS
            fprintf(fid,'   SedDia           =  %0.7e      [m]      sediment diameter (D50)\r\n',dk(kf));

            %set everything as default
        case -3 %Partheniades-Krone
            EroPar=sedTrans{kf}(1);
            TcrSed=sedTrans{kf}(2);
            TcrEro=sedTrans{kf}(3);
            ws0=dk(kf); %we use the array of sediment size for settling velocity. 
            wsm=ws0;
            SalMax=100; %no salinity interaction

            fprintf(fid,'   EroPar                  = %f                                erosion parameter [kg/m2s]                                   \r\n',EroPar);
            fprintf(fid,'   TcrSed                  = %f                                critical shear stress for sedimentation [N/m2]               \r\n',TcrSed);
            fprintf(fid,'   TcrEro                  = %f                                critical shear stress for erosion of bed [N/m2]              \r\n',TcrEro);
            fprintf(fid,'   FacDSS                  = %f                                FacDss*SedDia = Initial suspended sediment diameter [-]      \r\n',FacDSS);
            fprintf(fid,'   WS0                     = %f                                settling velocity fresh water (for default mud settling equation) [m/s]       \r\n',ws0);
            fprintf(fid,'   WSM                     = %f                                settling velocity saline water (for default mud settling equation) [m/s]        \r\n',wsm);
            fprintf(fid,'   SalMax                  = %f                                settling velocity saline water (for default mud settling equation) [m/s]        \r\n',SalMax);



        % TcrFluff critical shear stress for erosion of fluff layer [default: 0] N/m2
        % ParFluff0 maximum erosion flux from fluff layer [default: 0] s/m
        % ParFluff1 erosion parameter for fluff layer [default: 0] m s/kg
        % DepEff reduction factor for deposition/sedimentation rate (value between 0 = no sedimentation and 1 = reference sedimentation, or equal to -1 = reduction based on critical shear stress for sedimentation) [default: -1] -
        % PowerN power for the relative critical shear stres for erosion term [default: 1]
        case 1 %Engelund-Hansen
            fprintf(fid,'   SedDia           =  %0.7e      [m]      sediment diameter (D50)\r\n',dk(kf));

            ACal=sedTrans{kf}(1);
            RouKs=sedTrans{kf}(2);
            SusFac=sedTrans{kf}(3);

            fprintf(fid,'   ACal                    = %f                                calibration coefficient a [-]                \r\n',ACal);
            fprintf(fid,'   RouKs                   = %f                                bed roughness height rk (dummy) [m]          \r\n',RouKs);
            fprintf(fid,'   SusFac                  = %f                                suspended sediment fraction [default: 0] [-] \r\n',SusFac);
        case 4 %Generalized Formula
            fprintf(fid,'   SedDia           =  %0.7e      [m]      sediment diameter (D50)\r\n',dk(kf));

            ACal=sedTrans{kf}(1);
            PowerB=0;
            PowerC=sedTrans{kf}(2);
            ThetaC=sedTrans{kf}(3);
            RipFac=1;

            fprintf(fid,'   ACal                  = %f                                Calibration coefficient                \r\n',ACal);
            fprintf(fid,'   PowerB                = %f                                Power b                                \r\n',PowerB);
            fprintf(fid,'   PowerC                = %f                                Power c                                \r\n',PowerC);
            fprintf(fid,'   RipFac                = %f                                Ripple factor or efficiency factor     \r\n',RipFac);
            fprintf(fid,'   ThetaC                = %f                                Critical mobility factor               \r\n',ThetaC);
        case 14 %Ashida-Michiue
            fprintf(fid,'   SedDia           =  %0.7e      [m]      sediment diameter (D50)\r\n',dk(kf));
            
            ACal=sedTrans{kf}(1);
            ThetaC=sedTrans{kf}(2);
            PowerM=1.5;
            PowerP=1;
            PowerQ=1;  

            fprintf(fid,'   ACal                  = %f                                Calibration coefficient                \r\n',ACal);
            fprintf(fid,'   ThetaC                = %f                                Critical mobility factor               \r\n',ThetaC);
            fprintf(fid,'   PowerM                = %f                                Power b                                \r\n',PowerM);
            fprintf(fid,'   PowerP                = %f                                Power c                                \r\n',PowerP);
            fprintf(fid,'   PowerQ                = %f                                Ripple factor or efficiency factor     \r\n',PowerQ);
    end %IFORM

    if node_relations
        fprintf(fid,'   NodeRelations         = #table.nrd#                       [ - ]    File with Overall Node Relations(relative path to sed)\r\n');
    end %node realations
end

%% WRITE

write_local_and_copy('close',fid,fname_local,file_name)

end %function