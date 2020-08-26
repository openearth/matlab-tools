%Function to quickly compute mean diameter in µm from VD data.
% usage:
%  diameters = compute_mean(vd, type, transmission)
%
% where vd is volume distribution (in µl/l) in n x 32 matrix
%
% and type is
% 1 for type A (discontinued)
% 2 for type B
% 3 for type C
% 4 for FLOC (discontinued)
% 21 for randomly shaped type B
% 31 for randomly shaped type C.
%
% and transmission (OPTIONAL) is a vector with transmission values.
%
% The OUTPUTS are:
% Column 1: Total Volume Concentration in µl/l
% Column 2: Mean Size in µm
% Column 3: Standard Deviation in µm
% Column 4: NaN. NOTE: Column 4 is NaN in order to comply with the general
% data format for LISST-Portable and LISST-StreamSide, where column 4
% contains the optical transmission. If transmission is input, it will be
% displayed in column 4.
% Column 5: D10 in µm.
% Column 6: D16 in µm.
% Column 7: D50 in µm.
% Column 8: D60 in µm.
% Column 9: D84 in µm.
% Column 10: D90 in µm.
% Column 11: D60/D10 (the Hazen uniformity coefficient).
% Column 12: Surface area in cm2/l
% Column 13: 'Silt Density' - The volume concentration ratio of silt
% particles to the total volume concentration.
% Column 14: Silt Volume - the volume concentration of all particles < 64
% µm.
%
% OAM 11/13/2009
% 12/02/2009 (added info in help).
% 01/26/1010 (added option to add transmission as input and have it output)
% 03/26/1010 (changed output matrix 'md' to 'diameters')

function diameters = compute_mean(vd,type,transmission)
tau = 0;%flag for tau, default is that tau is not submitted

[rows cols]=size(vd);%get the number of rows, i.e. measurements.
if cols~=32;%check if the matrix for some reason has been messed up - it must have 32 columns
    vd=vd';
end
vd(vd<0)=0; % replace negative vc's with 0.

if nargin<2
    error('You must specify as a minimum BOTH a vd matrix AND an instrument type (1-4 for type A,B,C,D, 21 for randomly shaped type B, 31 for randomly shaped type C)!')
end

if nargin==3;%if tau has also been submitted...
    tau = 1;%...set the flag high
    c = size(transmission,2);%get the number of columns in the transmission 
    if c>1
        transmission = transmission';%transpose if there are more than 1 column
    end
    [r1 c1]=size(transmission);%get the number of columns in the transmission again...
    if c1 > 1
       error(['Transmission vector is not a vector, but a ',num2str(r1),' x ',num2str(c1),' matrix!']);%if there are still more than 1 column (after transposing), then it's not a vector
    elseif r1<rows
        error(['Transmission vector has fewer rows (',num2str(r1),') than vd (',num2str(rows),')!']);%if transmission vector has fewer rows than vd; error message
    elseif r1>rows
        error(['Transmission vector has more rows (',num2str(r1),') than vd (',num2str(rows),')!']);%if transmission vector has more rows than vd; error message
    end
end

rho=200^(1/32);

if type==1
    rho=100^(1/32);
    bins(:,1) = 5*rho.^([0:31]); %lower limit for type A
    bins(:,2) = 5*rho.^([1:32]); % upper limit for type A
    bins(:,3) = sqrt(bins(:,1).*bins(:,2));%mid-point for type A
    dias32 = bins(:,3);%The midpoint of the size bins is being used for computation of means and stds
    upperBins = bins(:,2);%Upper bin limits are being used for computing D50 (median) and other percentiles
    bin64 = 17;% this is the bin number containing 64µm particles. It is being used for computing the silt fraction later on.
elseif type==2;
    bins(:,1) = 1.25*rho.^([0:31]); %lower limit for type B
    bins(:,2) = 1.25*rho.^([1:32]); % upper limit for type B
    bins(:,3) = sqrt(bins(:,1).*bins(:,2));%mid-point for type B
    dias32 = bins(:,3);
    upperBins = bins(:,2);
    bin64 = 23;
elseif type==3;
    bins(:,1) = 2.5*rho.^([0:31]); %lower limit for type C
    bins(:,2) = 2.5*rho.^([1:32]); % upper limit for type C
    bins(:,3) = sqrt(bins(:,1).*bins(:,2));%mid-point for type C
    dias32 = bins(:,3);
    upperBins = bins(:,2);
    bin64 = 19;
elseif type==4;
    bins(:,1) = 7.5*rho.^([0:31]); %lower limit for type FLOC
    bins(:,2) = 7.5*rho.^([1:32]); %upper limit for type FLOC
    bins(:,3) = sqrt(bins(:,1).*bins(:,2));%mid-point for type FLOC
    dias32 = bins(:,3);
    upperBins = bins(:,2);
    bin64 = 12;
elseif type==21;
    dias32 = [1.0863095E+00  1.1800684E+00; 1.2819196E+00  1.3925615E+00; 1.5127528E+00  1.6433178E+00;...
        1.7851518E+00  1.9392274E+00; 2.1066013E+00  2.2884211E+00; 2.4859336E+00  2.7004934E+00;...
        2.9335718E+00  3.1867670E+00; 3.4618154E+00  3.7606031E+00; 4.0851790E+00  4.4377689E+00;...
        4.8207907E+00  5.2368710E+00; 5.6888629E+00  6.1798660E+00; 6.7132474E+00  7.2926647E+00;...
        7.9220913E+00  8.6058433E+00; 9.3486097E+00  1.0155484E+01; 1.1031999E+01  1.1984166E+01;...
        1.3018514E+01  1.4142136E+01; 1.5362737E+01  1.6688688E+01; 1.8129081E+01  1.9693793E+01;...
        2.1393555E+01  2.3240023E+01; 2.5245859E+01  2.7424818E+01; 2.9791841E+01  3.2363161E+01;...
        3.5156411E+01  3.8190744E+01; 4.1486970E+01  4.5067691E+01; 4.8957463E+01  5.3182959E+01;...
        5.7773156E+01  6.2759530E+01; 6.8176276E+01  7.4060540E+01; 8.0452671E+01  8.7396504E+01;...
        9.4939656E+01  1.0313385E+02; 1.1203529E+02  1.2170500E+02; 1.3220931E+02  1.4362023E+02;
        1.5601603E+02  1.6948170E+02; 1.8410959E+02  2.0000000E+02];%mid points (column 1) and upper bins (column 2) for type B, randomly shaped

    upperBins = dias32(:,2);
    dias32(:,2) = [];
    bin64 = 25;
elseif type==31;
    dias32 = [2.05970200000000,2.24514560000000;2.43230210000000,2.64942550000000;2.87230560000000,3.12650330000000;...
        3.39190560000000,3.68948780000000;4.00550140000000,4.35384800000000;4.73009660000000,5.13783860000000;...
        5.58577110000000,6.06300100000000;6.59623700000000,7.15475600000000;7.78949630000000,8.44310160000000;...
        9.19861620000000,9.96343760000000;10.8626460000000,11.7575380000000;12.8276990000000,13.8746990000000;...
        15.1482290000000,16.3730940000000;17.8885440000000,19.3213720000000;21.1245810000000,22.8005400000000;...
        24.9460180000000,26.9061980000000;29.4587530000000,31.7511540000000;34.7878410000000,37.4685340000000;...
        41.0809620000000,44.2154340000000;48.5125080000000,52.1772370000000;57.2884200000000,61.5727100000000;...
        67.6518960000000,72.6600100000000;79.8901240000000,85.7437830000000;94.3422470000000,101.183530000000;...
        111.408760000000,119.403490000000;131.562600000000,140.904290000000;155.362280000000,166.276700000000;...
        183.467320000000,196.217880000000;216.656550000000,231.550520000000;255.849720000000,273.245460000000;...
        302.132940000000,322.448340000000;356.788790000000,380.511100000000];%mid points (column 1) and upper bins (column 2) for type C, randomly shaped

    upperBins = dias32(:,2);
    dias32(:,2) = [];
    bin64 = 21;
else
    error(['You must specify a number: 1-4, 21 or 31, NOT ',num2str(type),'.']);
end
clear bins

rho=dias32(2)/dias32(1);
RemSize64BinNum = log(64/upperBins(bin64))/log(rho);%see MeanSize and PercentileSize below for how this equation comes about; used to compute silt volume

MeanSize = ones(rows,1);
std = ones(rows,1);
percentiles = [.1 .16 .5 .6 .84 .9];
PercentileSize = ones(rows,length(percentiles));
SurfaceArea = ones(rows,1);
SiltVolume = ones(rows,1);
SiltDensity = ones(rows,1);

for ik = 1:rows%rows is the total number of measurements, so loop through each measurement. Use ik as counter
    dSum = 0;
    for x = 1:32;
        dSum = dSum+x*vd(ik,x);%Multiply the volume concentration in each size class with the size class NUMBER (i.e. 1:32); then sum it up
    end
    vc(ik) = sum(vd(ik,:));% compute the total volume concentration for the measurement
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
        MeanSize(ik) = dias32(IntMeanSizeBinNum)*(rho)^RemMeanSizeBinNum;%...and compute the *actual* mean in microns.
        
        %Compute std
        dSum = 0;
        for x = 1:32;
            dDiff = dias32(x)-MeanSize(ik);
            dSum = dSum + (dDiff^2*vd(ik,x));
        end
        std(ik)=sqrt(dSum/vc(ik));
        
        %Now compute median size (vd must be monotonous for this)...
        zeroes = (vd(ik,:)<=1e-3);
        vd(ik,zeroes) = 1e-6;%...so if we have any zeroes in the VD matrix they must be weeded out.
        
        zeroes = isnan(vd(ik,:));
        vd(ik,zeroes) = 1e-7;...same with NaN's. 
        
      
        %By statistical definition, the median (and other percentiles) are
        %computed using the *UPPER* size bin limits
        for x = 1:length(percentiles)
            MeanSizeBinNum(x) = interp1((cumsum(vd(ik,:))./sum(vd(ik,:))),1:32,percentiles(x));%compute the cumulative VD curve, then do a linear interpolation on the 6 percentiles on size bins 1:32
            if isnan(MeanSizeBinNum)%It is possible that the first or last size class has all volume (if the data are bad)...
                PercentileSize(ik,x) = NaN;%...in that case set the size to NaN to avoid errors.
            else%Once that check has been done, the other computations are similar to the ones for the mean size
                IntMeanSizeBinNum(x) = fix(MeanSizeBinNum(x));
                RemMeanSizeBinNum(x) = MeanSizeBinNum(x) - IntMeanSizeBinNum(x);
                PercentileSize(ik,x) = upperBins(IntMeanSizeBinNum(x))*(rho)^RemMeanSizeBinNum(x);
            end
        end
        
        % Now compute surface area
        SurfaceArea(ik) = sum((vd(ik,:)./dias32').*(3e-3/2).*10000);%cross-sectional surface area in cm2/l
        
        % Now compute silt volume concentration (less than or equal to 64 µm)
        % First, figure out what 64 µm is in 'decimal bin numbers':
        % upperBin # 21 is 61.57µm, so it must be 21.xx
        %
        SiltVolume(ik)=sum(vd(ik,1:bin64))+(vd(ik,bin64+1)*RemSize64BinNum);
        
        % Now Silt Density
        SiltDensity(ik) = SiltVolume(ik)/vc(ik);%This is NOT the density in g/cm3 or similar; it is the volume fraction that the silt makes up of the total volume.
    end
end

diameters(:,1)=vc';
diameters(:,2)=MeanSize';
diameters(:,3)=std';
if tau==1
    diameters(:,4)=transmission;
else
    diameters(:,4)=NaN;
end
for x=1:length(percentiles);
    diameters(:,4+x)=PercentileSize(:,x);
end
diameters(:,11) = diameters(:,8)./diameters(:,5);%D60/D10
diameters(:,12) = SurfaceArea;
diameters(:,13) = SiltDensity;
diameters(:,14) = SiltVolume;



