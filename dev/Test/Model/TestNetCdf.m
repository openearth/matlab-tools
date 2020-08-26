
function test_suite = TestNetCdf
initTestSuite;

% Test writeNetCdf
function TestWriteNetCdfData
strFile='z:\projects\OFS\operationSystem\05_output\000_testruns\20140627123940_run_47525_T\iCSM\WL.nc';

sctOptions.AttFunction = @ConvertPropertiesWheatstone;
sctOptions.fieldFunction = @ConvertPropertiesWheatstone;

netCdfObj = NetCdf;

[dataset, sctOptions] = netCdfObj.readNetCdfHeader(strFile,sctOptions);
dataset = netCdfObj.readNetCdf(strFile,dataset,sctOptions);

sctOptions.propertyNameFunction = @ConvertPropertiesWheatstone;
sctOptions.fieldNameFunction = @ConvertPropertiesWheatstone;

strFileOut = 'z:\projects\OFS\operationSystem\05_output\000_testruns\20140627123940_run_47525_T\iCSM\WL_copy.nc';
sctFile = netCdfObj.writeNetCdfHeader(dataset,strFileOut,sctOptions);
netCdfObj.writeNetCdfData(dataset,sctFile,sctOptions);


[dataset2, sctOptions] = netCdfObj.readNetCdfHeader(strFileOut,sctOptions);
dataset2 = netCdfObj.readNetCdf(strFile,dataset2,sctOptions);

%check if the new file is the same as the previous
assertEqual(dataset2,dataset);
