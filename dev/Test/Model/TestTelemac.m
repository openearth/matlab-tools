
function test_suite = TestTelemac
initTestSuite;
end
% Test writeNetCdf
function TestReadSteering
strFile='testDummy.cas';

params= Telemac.readSteering(strFile);
paramsTest = {    'PARALLEL PROCESSORS'         '16'
    'FORTRAN FILE'                'wind_fortran.f'
    'BOUNDARY CONDITIONS FILE'    'RGM_v401_geo.cli'};

%check if the new file is the same as the previous
assertEqual(params,paramsTest);
end

function TestCotidalMap
tpxoModel = 'Z:\projects\OSU_topex\IndianOcean\Model_IO';

slfFile = 'Z:\\projects\\02122\\CalibRun027\\RES_RGM.slf';

opt.lat0 = 17.5;
opt.lon0 = 57.5;
opt.projection = 'mercatorTelemac';
opt.const = ['k1';'m2';'s2'];
opt.const = ['k1'];
opt.ampRange = {[0 0.8];[0 2];[0 0.8]};
opt.diffRange = {[-.2 0.2];[-0.4 0.4];[-0.4 0.4]};

Telemac.cotidalMap(slfFile,tpxoModel,opt);

end
