mtr = MTestRunner;
mtr.MainDir = oetroot;
% mtr.MainDir = 'F:\OpenEarthTools\matlab\maintenance\1_automated_Testing\Mtest\definition_examples\';
mtr.TargetDir = tempdir;
mtr.IncludeCoverage = false;
% mtr.Exclusions{end+1} = '1_automated_Testing';
mtr.Publish = true;
mtr.Template = 'oet';
mtr.Verbose = true;
mtr.run