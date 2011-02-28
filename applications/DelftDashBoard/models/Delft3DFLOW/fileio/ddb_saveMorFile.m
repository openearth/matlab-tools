function handles=ddb_saveMorFile(handles,id)

%%
s.MorphologyFileInformation.FileCreatedBy.value      = ['Delft DashBoard v' handles.delftDashBoardVersion];
s.MorphologyFileInformation.FileCreationDate.value   = datestr(now);
s.MorphologyFileInformation.FileVersion.value        = '02.00';

%%
s.Morphology.EpsPar.value     = handles.Model(md).Input(id).morphology.epsPar;
s.Morphology.EpsPar.type      = 'boolean';
s.Morphology.EpsPar.unit      = '-';
s.Morphology.EpsPar.comment   = 'Vertical mixing distribution according to van Rijn (overrules k-epsilon model)';

s.Morphology.IopKCW.value     = handles.Model(md).Input(id).morphology.iOpKcw;
s.Morphology.IopKCW.type      = 'integer';
s.Morphology.IopKCW.unit      = '-';
s.Morphology.IopKCW.comment   = 'Flag for determining Rc and Rw';

s.Morphology.RDC.value     = handles.Model(md).Input(id).morphology.rdc;
s.Morphology.RDC.type      = 'real';
s.Morphology.RDC.unit      = 'm';
s.Morphology.RDC.comment   = 'Current-related roughness height (only used if IopKCW <> 1)';

s.Morphology.RDW.value     = handles.Model(md).Input(id).morphology.rdw;
s.Morphology.RDW.type      = 'real';
s.Morphology.RDW.unit      = 'm';
s.Morphology.RDW.comment   = 'Wave-related roughness height (only used if IopKCW <> 1)';

s.Morphology.MorFac.value     = handles.Model(md).Input(id).morphology.morFac;
s.Morphology.MorFac.type      = 'real';
s.Morphology.MorFac.unit      = '-';
s.Morphology.MorFac.comment   = 'Morphological scale factor';

s.Morphology.MorStt.value     = handles.Model(md).Input(id).morphology.morStt;
s.Morphology.MorStt.type      = 'real';
s.Morphology.MorStt.unit      = 'min';
s.Morphology.MorStt.comment   = 'Spin-up interval from TStart till start of morphological changes';

s.Morphology.Thresh.value     = handles.Model(md).Input(id).morphology.thresh;
s.Morphology.Thresh.type      = 'real';
s.Morphology.Thresh.unit      = 'm';
s.Morphology.Thresh.comment   = 'Threshold sediment thickness for transport and erosion reduction';

s.Morphology.MorUpd.value     = handles.Model(md).Input(id).morphology.morUpd;
s.Morphology.MorUpd.type      = 'boolean';
s.Morphology.MorUpd.comment   = 'Update bathymetry during Delft3D-FLOW simulation';

s.Morphology.EqmBc.value     = handles.Model(md).Input(id).morphology.eqmBc;
s.Morphology.EqmBc.type      = 'boolean';
s.Morphology.EqmBc.comment   = 'Equilibrium sand concentration profile at inflow boundaries';

s.Morphology.DensIn.value     = handles.Model(md).Input(id).morphology.densIn;
s.Morphology.DensIn.type      = 'boolean';
s.Morphology.DensIn.comment   = 'Include effect of sediment concentration on fluid density';

s.Morphology.AlfaBs.value     = handles.Model(md).Input(id).morphology.alphaBs;
s.Morphology.AlfaBs.type      = 'real';
s.Morphology.AlfaBs.unit      = '-';
s.Morphology.AlfaBs.comment   = 'Streamwise bed-gradient factor for bed load transport';

s.Morphology.AlfaBn.value     = handles.Model(md).Input(id).morphology.alphaBn;
s.Morphology.AlfaBn.type      = 'real';
s.Morphology.AlfaBn.unit      = '-';
s.Morphology.AlfaBn.comment   = 'Transverse bed-gradient factor for bed load transport';

s.Morphology.Sus.value     = handles.Model(md).Input(id).morphology.sus;
s.Morphology.Sus.type      = 'real';
s.Morphology.Sus.unit      = '-';
s.Morphology.Sus.comment   = 'Calibration factor current-related suspended transport';

s.Morphology.Bed.value     = handles.Model(md).Input(id).morphology.bed;
s.Morphology.Bed.type      = 'real';
s.Morphology.Bed.unit      = '-';
s.Morphology.Bed.comment   = 'Calibration factor current-related bedload transport';

s.Morphology.SusW.value     = handles.Model(md).Input(id).morphology.susW;
s.Morphology.SusW.type      = 'real';
s.Morphology.SusW.unit      = '-';
s.Morphology.SusW.comment   = 'Calibration factor wave-related suspended transport';

s.Morphology.BedW.value     = handles.Model(md).Input(id).morphology.bedW;
s.Morphology.BedW.type      = 'real';
s.Morphology.BedW.unit      = '-';
s.Morphology.BedW.comment   = 'Calibration factor wave-related bedload transport';

s.Morphology.SedThr.value     = handles.Model(md).Input(id).morphology.sedThr;
s.Morphology.SedThr.type      = 'real';
s.Morphology.SedThr.unit      = 'm';
s.Morphology.SedThr.comment   = 'Minimum water depth for sediment computations';

s.Morphology.ThetSD.value     = handles.Model(md).Input(id).morphology.thetSd;
s.Morphology.ThetSD.type      = 'real';
s.Morphology.ThetSD.unit      = '-';
s.Morphology.ThetSD.comment   = 'Factor for erosion of adjacent dry cells';

s.Morphology.HMaxTh.value     = handles.Model(md).Input(id).morphology.hMaxTh;
s.Morphology.HMaxTh.type      = 'real';
s.Morphology.HMaxTh.unit      = 'm';
s.Morphology.HMaxTh.comment   = 'Max depth for variable THETSD. Set < SEDTHR to use global value only';

s.Morphology.FWFac.value     = handles.Model(md).Input(id).morphology.fwFac;
s.Morphology.FWFac.type      = 'real';
s.Morphology.FWFac.unit      = '-';
s.Morphology.FWFac.comment   = 'Wave-streaming factor';

ddb_saveDelft3D_keyWordFile(handles.Model(md).Input(id).morFile,s)
