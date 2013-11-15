function writeCFS(filename, transp_formula, varargin)
%write CFS : Writes a unibest transport parameter file
%
%   Syntax:
%     function writeCFS(filename,transp_formula,varargin)
% 
%   Input:
%     filename              string with filename for output CFS file
%     transp_formula        string with transport_formula (respectively : 'BIJ', 'RIJ', 'R93', 'R04', 'SRY', 'CER', 'KAM', 'GRA')
%     + an additional number of input parameters (varies per transport formula):
%     
%     Parameters for Bijker (1967, 1971) formula:
%     Default naming is 'BIJ'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       Rc                   Bottom roughness (m)
%       WVal                 Sediment fall velocity (m/s)
%       Crit_d               Criterion deep water, Hsig/h (-)
%       B_d1                 Coefficient b deep water (-)
%       Crit_s               Criterion shallow water, Hsig/h (-)
%       B_d2                 Coefficient b shallow water (-)
%     
%
%     Parameters for Van Rijn (1992) formula:
%     Default naming is 'RIJ'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       RhoS                 Sediment density (kg/m3)
%       Rc                   Current related bottom roughness (m)
%       Rw                   Wave related bottom roughness (m)
%       Wval                 Sediment fall velocity (m/s)
%       Visc                 Viscosity []*10e-6
%       Alfrij               Correction factor (-)
%       Arij                 Relative bottom transport layer thickness (-)
%       Por                  Porosity (-)
%
%
%     Parameters for Van Rijn (1993) formula:
%     Default naming is 'R93'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       DSS                  50% grain diameter of suspended sediment (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       Rc                   Current related bottom roughness (m)
%       Rw                   Wave related bottom roughness (m)
%       T                    Temperature (deg C)
%       Sal.                 Salinity (PPM)
%       CurSTF               Current related suspended transport factor (-)
%       CurBTF               Current related bedload transport factor (-)
%       WaveSTF              Wave related suspended transport factor (-)
%       WaveBTF              Wave related bedload transport factor (-)
%
%
%     Parameters for Van Rijn (2004) formula:
%     Default naming is 'R04'
%
%       D10                  D10, 10% grain diameter (µm)
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       DSS                  50% grain diameter of suspended sediment (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       T                    Temperature (deg C)
%       Sal.                 Salinity (PPM)
%       CurSTF               Current related suspended transport factor (-)
%       CurBTF               Current related bedload transport factor (-)
%       WaveSTF              Wave related suspended transport factor (-)
%       WaveBTF              Wave related bedload transport factor (-)
%     
%
%     Parameters for Soulsby/Van Rijn formula:
%     Default naming is 'SRY'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       Rc                   Current related bottom roughness (m)
%       Visc                 Kinematic viscosity of water (m2s * 10^-6) (def. = 1) 
%       CalF                 Calibration Factor (-)
%
%
%     Parameters for CERC formula:
%     Default naming is 'CER'
%
%       ACERc                Coefficient A (-)
%       Gamc                 Wave breaking coefficient gamma (-)
%       RhoS                 Sediment density (kg/m3)
%
%
%     Parameters for Kamphuis formula:
%     Default naming is 'KAM'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       Gamc                 Wave breaking coefficient gamma (-)
%
%
%     Parameters for van der Meer & Pilarczyk formula:
%     Default naming is 'GRA' (as linked to gravel)
%
%       DN50                 Dn50 nominal diameter (m)
%       D90Ks                Roughness lenght (m)
%       RhoGr                Density of material (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       ShKrit               Shields number (-)
%       GrFac                Multiplication factor (-)
%  
%   Output:
%     .cfs file
%
%   Examples (for each formula):
%     writeCFS('test.cfs','BIJ',D50,D90,RhoS,RhoW,Por,Rc,Wval,Crit_d,B_d1,Crit_s,B_d2);
%     writeCFS('test.cfs','RIJ',D50,D90,RhoS,Rc,Rw,Wval,Visc,Alfrij,Arij,Por);
%     writeCFS('test.cfs','R93',D50,D90,DSS,RhoS,RhoW,Por,Rc,Rw,T,Sal,CurSTF,CurBTF,WaveSTF,WaveBTF);
%     writeCFS('test.cfs','R04',D10,D50,D90,DSS,RhoS,RhoW,Por,T,Sal,CurSTF,CurBTF,WaveSTF,WaveBTF);
%     writeCFS('test.cfs','SRY',D50,D90,RhoS,RhoW,Por,Rc,Visc,CalF);
%     writeCFS('test.cfs','CER',ACERc,Gamc,RhoS);
%     writeCFS('test.cfs','KAM',D50,RhoS,RhoW,Por,Gamc);
%     writeCFS('test.cfs','GRA',Dn50,D90Ks,RhoGr,RhoW,ShKrit,GrFac);
%
%   Example (along with the usage of readCFS)
%     CFS_data = readCFS('vanRijn.cfs');
%     CFS_data.D50 = CFS_data.D50 + 10; CFS_data.D50 = CFS_data.D90 + 15;
%     writeCFS('vanRijn_courser_sediment.cfs',...
%              CFS_data.TRANSPORT_FORMULA,...
%              CFS_data.D50,...
%              CFS_data.D90,...
%              CFS_data.RhoS,...
%              CFS_data.Rc,...
%              CFS_data.Rw,...
%              CFS_data.Wval,...
%              CFS_data.Visc,...
%              CFS_data.Alfrij,...
%              CFS_data.Arij,...
%              CFS_data.Por);
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Freek Scheel
%
%       freek.scheel@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%-----------Write data to file--------------
%-------------------------------------------

%Bijker (1967, 1971)
if ~isempty(strfind(lower(transp_formula),'bij'))
    if nargin==10;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''BIJ''\n',transp_formula);
        fprintf(fid,'D50_CFS  D90_CFS   rc_CFS    wval_CFS  crit_d_CFSb_d1_CFS  crit_s_CFSb_d2_CFS\n');
        fprintf(fid,'%7.2f %7.2f %6.3f %7.4f %6.3f %3.1f %6.3f %3.1f\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6} varargin{7} varargin{8}]');
        fclose(fid);
    end

%Van Rijn 2004
elseif ~isempty(strfind(lower(transp_formula),'rij'))
    if nargin==12;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''RIJ''\n',transp_formula);
        fprintf(fid,'D50_CFS  D90_CFS  Rhos_CFS  Rc_CFS  Rw_CFS  wval_CFS  Visc_CFS  Alfrij_CFS  Arij_CFS  Por_CFS\n');
        fprintf(fid,'%7.2f %7.2f %7.2f %6.3f %6.3f %7.5f %10.8f %6.4f %6.4f %6.4f\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6} varargin{7} varargin{8} varargin{9} varargin{10}]');
        fclose(fid);
    end

% GRAVEL van der Meer / Pilarczyk
elseif ~isempty(strfind(lower(transp_formula),'gra'))

    if nargin==7;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''GRA''\n',transp_formula);
        fprintf(fid,'DN50_CFS D90_ks_CFSrhogr_CFS shkrit_CFSgrfac_CFS\n');
        fprintf(fid,'%7.4f %7.4f %7.2f %8.5f %5.2f\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5}]');
        fclose(fid);
    end

% CERC 1984
elseif ~isempty(strfind(lower(transp_formula),'cer'))
    if nargin==4;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''CER''\n',transp_formula);
        fprintf(fid,'ACErc_CFSgamc_CFS\n');
        fprintf(fid,'%8.5f %7.4f\n',[varargin{1} varargin{2}]');
        fclose(fid);
    end

else
    fprintf('\n warning: transport formula not correctly specified!\n');
end
