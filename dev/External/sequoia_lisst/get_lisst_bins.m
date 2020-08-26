function [midBins, upperBins, lowerBins, bin64] = get_lisst_bins(type, shape)
%% Information
% This script calculates the bin sizes of the several lisst types (in µm)
% and is based on Sequaoi script 'compute_mean'.
% 
% [midBins, upperBins, lowerBins, bin64] = compute_bins(type, shape)
% 
% # INPUT
% 
%  type = instrument type (A,B,C,200)
%  shape = shape model (random or spherical)

% # OUTPUT
%  midBins = the midpoint of the size bins is being used for computation of means and stds
% upperBins = Upper bin limits are being used for computing D50 (median) and other percentiles
% lowerBins = lower bin limit
% bin64 =  this is the bin number containing 64µm particles. It is being used for computing the silt fraction later on.
%
% WRITTEN by: sequaoi (compute_mean)
% MOdified by:  JCA (22/11/2017): adding LISST 200x
%
%-------------------------------------

rho=200^(1/32);

if (strcmpi(type,'100xA') || strcmpi(type,'A'))
    rho=100^(1/32);
    bins(:,1) = 5*rho.^([0:31]); %lower limit for type A
    bins(:,2) = 5*rho.^([1:32]); % upper limit for type A
    bins(:,3) = sqrt(bins(:,1).*bins(:,2));%mid-point for type A
    dias32 = bins(:,3);%The midpoint of the size bins is being used for computation of means and stds
    upperBins = bins(:,2);%Upper bin limits are being used for computing D50 (median) and other percentiles
    bin64 = 17;% this is the bin number containing 64µm particles. It is being used for computing the silt fraction later on.
    lowerBins = bins(:,1);
elseif (strcmpi(type,'100xB') || strcmpi(type,'B')) && (shape == 0 || strcmpi(shape,'spherical'))
    bins(:,1) = 1.25*rho.^([0:31]); %lower limit for type B
    bins(:,2) = 1.25*rho.^([1:32]); % upper limit for type B
    bins(:,3) = sqrt(bins(:,1).*bins(:,2));%mid-point for type B
    dias32 = bins(:,3);
    upperBins = bins(:,2);
    bin64 = 23;
    lowerBins = bins(:,1);
    
elseif (strcmpi(type,'100xB') || strcmpi(type,'C')) && (shape == 0 || strcmpi(shape,'spherical'))
    bins(:,1) = 2.5*rho.^([0:31]); %lower limit for type C
    bins(:,2) = 2.5*rho.^([1:32]); % upper limit for type C
    bins(:,3) = sqrt(bins(:,1).*bins(:,2));%mid-point for type C
    dias32 = bins(:,3);
    upperBins = bins(:,2);
    bin64 = 19;
    lowerBins = bins(:,1);
    
elseif (strcmpi(type,'FLOC'))
    bins(:,1) = 7.5*rho.^([0:31]); %lower limit for type FLOC
    bins(:,2) = 7.5*rho.^([1:32]); %upper limit for type FLOC
    bins(:,3) = sqrt(bins(:,1).*bins(:,2));%mid-point for type FLOC
    dias32 = bins(:,3);
    upperBins = bins(:,2);
    bin64 = 12;
elseif (strcmpi(type,'100xB') || strcmpi(type,'B')) && (shape == 1 || strcmpi(shape,'random'))
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
    lowerBins = [];
    
elseif (strcmpi(type,'100xB') || strcmpi(type,'C')) && (shape == 1 || strcmpi(shape,'random'))
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
    lowerBins = [];
    
elseif (strcmpi(type,'200x') || strcmpi(type,'200')) % both spherical as randomly
%         rho=500^(1/36);
%         bins(:,1) = 1*rho.^([0:35]);
%         bins(:,2) = 1*rho.^([1:36]);
    %     bins(:,3) = sqrt(bins(:,1).*bins(:,2));
    dias32 = [1.214530988422740; 1.602399475216770; 1.890941012875900; 2.231439768596040; 2.633251596409650;
        3.107417044178910; 3.666964713747540; 4.327269246675160; 5.106473771896180; 6.025988422860210;
        7.111078621865020; 8.391559295818240; 9.902614098332810; 11.685762147848600; 13.789998844757700;
        16.273142113664200; 19.203421061357300; 22.661350701910900; 26.741944260566100; 31.557323843672000;
        37.239801207831300; 43.945513278271200; 51.858712309253500; 61.196828566880200; 72.216444641180700;
        85.220345543121700; 1.005658383014290e+02; 1.186745696560420e+02; 1.400441116080930e+02; 
        1.652616331615360e+02; 1.950200339136560e+02; 2.301369827956870e+02; 2.726269331663140e+02;
        3.242098886627520e+02; 3.855527063519850e+02; 4.585020216023360e+02];
    %data = load('MidBins_LISST_200x.mat');
    %dias32 = data.midBins';
 
    bin64 = 24;
    lowerBins = [1;1.48;1.74;2.05;2.42;2.86;3.38;3.98;4.70;5.55;6.55;7.72;9.12;10.8;12.7;15.0;17.7;...
        20.9;24.6;29.1;34.3;40.5;47.7;56.3;66.5;78.4;92.6;109;129;152;180;212;250;297;354;420];
    upperBins = [lowerBins(2:end);500];
else
    error('Wrong input');
end

midBins = dias32;
