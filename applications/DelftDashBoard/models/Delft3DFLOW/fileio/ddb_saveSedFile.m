function handles=ddb_saveSedFile(handles,id)

%%
s.SedimentFileInformation.FileCreatedBy.value      = ['Delft DashBoard v' handles.delftDashBoardVersion];
s.SedimentFileInformation.FileCreationDate.value   = datestr(now);
s.SedimentFileInformation.FileVersion.value        = '02.00';

%%
s.SedimentOverall.Cref.value     =  1.6000000e+003;
s.SedimentOverall.Cref.type      =  'real';
s.SedimentOverall.Cref.unit      = 'kg/m3';
s.SedimentOverall.Cref.comment   = 'CSoil Reference density for hindered settling calculations';

s.SedimentOverall.IopSus.value   =  0;
s.SedimentOverall.IopSus.type    =  'integer';
s.SedimentOverall.IopSus.comment =  'If Iopsus = 1: susp. sediment size depends on local flow and wave conditions';

%%
for i=1:handles.Model(md).Input(id).nrSediments
    
    switch lower(handles.Model(md).Input(id).sediment(i).type)
        case{'non-cohesive'}
            tp='sand';
        case{'cohesive'}
            tp='mud';
    end
    
    s.Sediment(i).Name.value     =  handles.Model(md).Input(id).sediment(i).name;
    s.Sediment(i).Name.comment   =  'Name of sediment fraction';
    
    s.Sediment(i).SedTyp.value   =  tp;
    s.Sediment(i).SedTyp.comment =  'Must be "sand", "mud" or "bedload"';
    
    s.Sediment(i).RhoSol.value   =  handles.Model(md).Input(id).sediment(i).rhoSol;
    s.Sediment(i).RhoSol.unit    = 'kg/m3';
    s.Sediment(i).RhoSol.type    =  'real';
    s.Sediment(i).RhoSol.comment =  'Specific density';

    s.Sediment(i).CDryB.value    =  handles.Model(md).Input(id).sediment(i).cDryB;
    s.Sediment(i).CDryB.unit     = 'kg/m3';
    s.Sediment(i).CDryB.type     = 'real';
    s.Sediment(i).CDryB.comment  = 'Dry bed density';

    if handles.Model(md).Input(id).sediment(i).uniformThickness
        s.Sediment(i).IniSedThick.value    =  handles.Model(md).Input(id).sediment(i).iniSedThick;
        s.Sediment(i).IniSedThick.unit     = 'm';
        s.Sediment(i).IniSedThick.type     = 'real';
        s.Sediment(i).IniSedThick.comment  = 'Initial sediment layer thickness at bed (uniform value or filename)';
    else
        s.Sediment(i).IniSedThick.value    =  handles.Model(md).Input(id).sediment(i).sdbFile;
        s.Sediment(i).IniSedThick.unit     = 'm';
        s.Sediment(i).IniSedThick.type     = 'string';
        s.Sediment(i).IniSedThick.comment  = 'Initial sediment layer thickness at bed (uniform value or filename)';
    end

    s.Sediment(i).FacDSS.value    =  handles.Model(md).Input(id).sediment(i).facDSS;
    s.Sediment(i).FacDSS.unit     = '-';
    s.Sediment(i).FacDSS.type     = 'real';
    s.Sediment(i).FacDSS.comment  = 'FacDss * SedDia = Initial suspended sediment diameter. Range [0.6 - 1.0]';
    
    switch lower(handles.Model(md).Input(id).sediment(i).type)

        case{'non-cohesive'}
            s.Sediment(i).SedDia.value    =  handles.Model(md).Input(id).sediment(i).sedDia/1000;
            s.Sediment(i).SedDia.unit     = 'm';
            s.Sediment(i).SedDia.type     = 'real';
            s.Sediment(i).SedDia.comment  = 'Median sediment diameter (D50)';

        case{'cohesive'}
            s.Sediment(i).SalMax.value    =  handles.Model(md).Input(id).sediment(i).salMax;
            s.Sediment(i).SalMax.unit     = 'ppt';
            s.Sediment(i).SalMax.type     = 'real';
            s.Sediment(i).SalMax.comment  = 'Salinity for saline settling velocity';

            s.Sediment(i).WS0.value    =  handles.Model(md).Input(id).sediment(i).wS0/1000;
            s.Sediment(i).WS0.unit     = 'm/s';
            s.Sediment(i).WS0.type     = 'real';
            s.Sediment(i).WS0.comment  = 'Settling velocity fresh water';

            s.Sediment(i).WSM.value    =  handles.Model(md).Input(id).sediment(i).wSM/1000;
            s.Sediment(i).WSM.unit     = 'm/s';
            s.Sediment(i).WSM.type     = 'real';
            s.Sediment(i).WSM.comment  = 'Settling velocity saline water';

            
            if handles.Model(md).Input(id).sediment(i).uniformEroPar
                s.Sediment(i).EroPar.value = handles.Model(md).Input(id).sediment(i).eroPar;
                s.Sediment(i).EroPar.unit     = 'kg/m2/s';
                s.Sediment(i).EroPar.type     = 'real';
                s.Sediment(i).EroPar.comment  = 'Erosion Parameter';
            else
                s.Sediment(i).EroPar.value = handles.Model(md).Input(id).sediment(i).eroFile;
                s.Sediment(i).EroPar.unit     = 'kg/m2/s';
                s.Sediment(i).EroPar.type     = 'string';
                s.Sediment(i).EroPar.comment  = 'Erosion Parameter';
            end

            if handles.Model(md).Input(id).sediment(i).uniformTCrSed
                s.Sediment(i).TcrSed.value    = handles.Model(md).Input(id).sediment(i).tCrSed;
                s.Sediment(i).TcrSed.unit     = 'N/m2';
                s.Sediment(i).TcrSed.type     = 'real';
                s.Sediment(i).TcrSed.comment  = 'Critical bed shear stress for sedimentation (uniform value or filename)';
            else
                s.Sediment(i).TcrSed.value = handles.Model(md).Input(id).sediment(i).tcdFile;
                s.Sediment(i).TcrSed.unit     = 'N/m2';
                s.Sediment(i).TcrSed.type     = 'string';
                s.Sediment(i).TcrSed.comment  = 'Critical bed shear stress for sedimentation (uniform value or filename)';
            end

            if handles.Model(md).Input(id).sediment(i).uniformTCrEro
                s.Sediment(i).TcrEro.value    = handles.Model(md).Input(id).sediment(i).tCrEro;
                s.Sediment(i).TcrEro.unit     = 'N/m2';
                s.Sediment(i).TcrEro.type     = 'real';
                s.Sediment(i).TcrEro.comment  = 'Critical bed shear stress for erosion (uniform value or filename)';
            else
                s.Sediment(i).TcrEro.value = handles.Model(md).Input(id).sediment(i).tceFile;
                s.Sediment(i).TcrEro.unit     = 'N/m2';
                s.Sediment(i).TcrEro.type     = 'string';
                s.Sediment(i).TcrEro.comment  = 'Critical bed shear stress for erosion (uniform value or filename)';
            end
            
    end
    
end

ddb_saveDelft3D_keyWordFile(handles.Model(md).Input(id).sedFile,s)
