function GSDdata = get_lisst_GSDparameters(VolDistr, type, shape, percentiles)

% This script computes the statistical grain size distrubution of a lisst
% dataset (based on compute_mean by sequoia)
%
% get_lisst_GSDparameters(VolDistr, type, shape, percentiles)
% 
% INPUTS: - volume disstribution: nx32 or nx36 matrix in µl/l
%          - type of instrument
%         - optional:
%           * shape: random or spherical
%           * percentile intervals: default [.1 .16 .5 .6 .84 .9];
%
% OUTPUTS: standardised IMDC data structure with parameter fields as described
%          by IMDC.
%        TotVol: Total Volume Concentration in µl/l
%        Dmean: Mean Size in µm
%        DmeanStd: Standard Deviation in µm
%        Percentile: percentiles in µm
%        Surface area in cm2/l
%        'Silt Density' - The volume concentration ratio of silt
%                  particles to the total volume concentration.
%         Silt Volume - the volume concentration of all particles < 64µm.
% STEPS:-
%
% International Marine and Dredging Consultants, IMDC
% Antwerp Belgium
%
%
%% Written by: JCA (based on sequoia)
%
% Date: 10/2017
% Modified by:
% Date:


%% defaults
[rows, cols] = size(VolDistr);%get the number of rows, i.e. measurements.
%VolDistr=VolDistr';

VolDistr(VolDistr<0)=0; % replace negative vc's with 0.
if nargin < 3
    shape = 1;
end
if nargin < 4
    percentiles = [.1 .16 .5 .6 .84 .9];
end


%% calculate the GSD parameters
% find the bins
[midBins, upperBins, lowerBins, bin64] = get_lisst_bins(type, shape);

rho=midBins(2)/midBins(1);
RemSize64BinNum = log(64/upperBins(bin64))/log(rho);%see MeanSize and PercentileSize below for how this equation comes about; used to compute silt volume

MeanSize = ones(rows,1);
std = ones(rows,1);
PercentileSize = ones(rows,length(percentiles));
SurfaceArea = ones(rows,1);
SiltVolume = ones(rows,1);
SiltDensity = ones(rows,1);

for ik = 1:rows%rows is the total number of measurements, so loop through each measurement. Use ik as counter
    dSum = 0;
    for x = 1:cols;
        dSum = dSum+x*VolDistr(ik,x);%Multiply the volume concentration in each size class with the size class NUMBER (i.e. 1:32); then sum it up
    end
    vc(ik) = sum(VolDistr(ik,:));% compute the total volume concentration for the measurement
    if (isnan(dSum)) || (isnan(vc(ik)));%Check if by any chance we have a NaN value in dSum or vc. If so, set MeanSize, std and vc to 0
        MeanSize(ik) = NaN;
        std(ik) = NaN;
        vc(ik) = NaN;
        PercentileSize(ik,1:length(percentiles)) = NaN;
        SurfaceArea(ik) = NaN;
        SiltVolume(ik) = NaN;
        SiltDensity(ik) = NaN;
    else
        
        %Compute mean size
        MeanSizeBinNum = dSum/vc(ik);%Definition of mean size (in units of size class number, not microns yet). We now have the mean size in terms of bin number (eg. mean size = bin # 17.654)
        IntMeanSizeBinNum = fix(MeanSizeBinNum);%Get the integer (rounded towards zero) for the mean size class number
        RemMeanSizeBinNum = MeanSizeBinNum - IntMeanSizeBinNum;%Now get the remainder...
        MeanSize(ik) = midBins(IntMeanSizeBinNum)*(rho)^RemMeanSizeBinNum;%...and compute the *actual* mean in microns.
        
        %Compute std
        dSum = 0;
        for x = 1:cols;
            dDiff = midBins(x)-MeanSize(ik);
            dSum = dSum + (dDiff^2*VolDistr(ik,x));
        end
        std(ik)=sqrt(dSum/vc(ik));
        
        %Now compute median size (VolDistr must be monotonous for this)...
        zeroes = (VolDistr(ik,:)<=1e-3);
        VolDistr(ik,zeroes) = 1e-6;%...so if we have any zeroes in the VolDistr matrix they must be weeded out.
        
        zeroes = isnan(VolDistr(ik,:));
        VolDistr(ik,zeroes) = 1e-7;...same with NaN's. 
        
      
        %By statistical definition, the median (and other percentiles) are
        %computed using the *UPPER* size bin limits
        for x = 1:length(percentiles)
            MeanSizeBinNum(x) = interp1((cumsum(VolDistr(ik,:))./sum(VolDistr(ik,:))),1:cols,percentiles(x));%compute the cumulative VolDistr curve, then do a linear interpolation on the 6 percentiles on size bins 1:32
            if isnan(MeanSizeBinNum)%It is possible that the first or last size class has all volume (if the data are bad)...
                PercentileSize(ik,x) = NaN;%...in that case set the size to NaN to avoid errors.
            else%Once that check has been done, the other computations are similar to the ones for the mean size
                IntMeanSizeBinNum(x) = fix(MeanSizeBinNum(x));
                RemMeanSizeBinNum(x) = MeanSizeBinNum(x) - IntMeanSizeBinNum(x);
                PercentileSize(ik,x) = upperBins(IntMeanSizeBinNum(x))*(rho)^RemMeanSizeBinNum(x);
            end
        end
        
        % Now compute surface area
        SurfaceArea(ik) = sum((VolDistr(ik,:)./midBins').*(3e-3/2).*10000);%cross-sectional surface area in cm2/l
        
        % Now compute silt volume concentration (less than or equal to 64 µm)
        % First, figure out what 64 µm is in 'decimal bin numbers':
        % upperBin # 21 is 61.57µm, so it must be 21.xx
        %
        SiltVolume(ik)=sum(VolDistr(ik,1:bin64))+(VolDistr(ik,bin64+1)*RemSize64BinNum);
        
        % Now Silt Density
        SiltDensity(ik) = SiltVolume(ik)/vc(ik);%This is NOT the density in g/cm3 or similar; it is the volume fraction that the silt makes up of the total volume.
    end
end

GSDdata = Dataset.createDataset(1); GSDdata = rmfield(GSDdata,'metaData');
GSDdata = Dataset.addDefaultVariableFields(GSDdata, 'VolConc');
GSDdata.VolConc.longname = 'Total Volume Concentration';
GSDdata.VolConc.unit = 'µl/l';
GSDdata.VolConc.dim = {'T','dp'};
GSDdata.VolConc.data=vc';

GSDdata = Dataset.addDefaultVariableFields(GSDdata, 'Dmean');
GSDdata.Dmean.longname = 'Mean Diameter';
GSDdata.Dmean.unit = 'µm';
GSDdata.Dmean.dim = {'T','dp'};
GSDdata.Dmean.data= MeanSize';

GSDdata = Dataset.addDefaultVariableFields(GSDdata, 'DmeanStd');
GSDdata.DmeanStd.longname = 'Standard deviation on the mean Diameter';
GSDdata.DmeanStd.unit = 'µm';
GSDdata.DmeanStd.dim = {'T','dp'};
GSDdata.DmeanStd.data =std';

GSDdata = Dataset.addDefaultVariableFields(GSDdata, 'Percentile');
GSDdata.Percentile.longname = 'Percentile';
GSDdata.Percentile.unit = 'µm';
GSDdata.Percentile.dim = {'T','dp'};
GSDdata.Percentile.data = PercentileSize;
GSDdata.Percentile.columns = percentiles;

GSDdata = Dataset.addDefaultVariableFields(GSDdata, 'SurfaceArea');
GSDdata.SurfaceArea.longname = 'Cross-sectional surface area';
GSDdata.SurfaceArea.unit = 'cm²/l';
GSDdata.SurfaceArea.dim = {'T','dp'};
GSDdata.SurfaceArea.data = SurfaceArea;

GSDdata = Dataset.addDefaultVariableFields(GSDdata, 'SiltDensity');
GSDdata.SiltDensity.longname = 'Volume fraction of silt';
GSDdata.SiltDensity.unit = '%';
GSDdata.SiltDensity.dim = {'T','dp'};
GSDdata.SiltDensity.data = SiltDensity;

GSDdata = Dataset.addDefaultVariableFields(GSDdata, 'SiltVolume');
GSDdata.SiltVolume.longname = 'Silt volume concentration';
GSDdata.SiltVolume.unit = 'µl/l';
GSDdata.SiltVolume.dim = {'T','dp'};
GSDdata.SiltVolume.data = SiltVolume;



