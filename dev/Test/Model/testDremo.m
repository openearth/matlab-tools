opt.dremoXls = 'dremo_input_TEST.xlsx';

sctEqmod = Dremo.xls2eqmod(opt);

sctOptions.strFile = 'testoutput';
sctOptions.ddMode = 'dumping';
sctOptions.numBoot = 1000;
sctOptions.bPlot = true;
Dremo.dremo(sctEqmod,sctOptions);


