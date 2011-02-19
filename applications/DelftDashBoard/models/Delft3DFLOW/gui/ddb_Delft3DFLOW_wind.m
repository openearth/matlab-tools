function ddb_Delft3DFLOW_wind(varargin)

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.wind');
else
    handles=getHandles;
    opt=varargin{1};
    switch lower(opt)
        case{'openwndfile'}
            handles=ddb_readWndFile(handles,ad);
            setHandles(handles);
            setUIElement('delft3dflow.physicalparameters.physicalparameterspanel.wind.timeseriestable');
        case{'savewndfile'}
            ddb_saveWndFile(handles,ad);
        case{'changewinddrag'}
            nrp=handles.Model(md).Input(ad).nrWindStressBreakpoints;
            coef=handles.Model(md).Input(ad).windStressCoefficients;
            spds=handles.Model(md).Input(ad).windStressSpeeds;
            if nrp==2
                handles.Model(md).Input(ad).windStress(1:4)=[coef(1) spds(1) coef(2) spds(2)];                
            else
                handles.Model(md).Input(ad).windStress=[coef(1) spds(1) coef(2) spds(2) coef(3) spds(3)];                
            end
            setHandles(handles);
            setUIElement('delft3dflow.physicalparameters.physicalparameterspanel.wind.dragcoeftable');
        case{'changenrbreakpoints'}
            nrp=handles.Model(md).Input(ad).nrWindStressBreakpoints;
            strs=handles.Model(md).Input(ad).windStress;
            if nrp==2
                handles.Model(md).Input(ad).windStressCoefficients=[strs(1);strs(3)];
                handles.Model(md).Input(ad).windStressSpeeds=[strs(2);strs(4)];
            else
                handles.Model(md).Input(ad).windStressCoefficients=[strs(1);strs(3);strs(5)];
                handles.Model(md).Input(ad).windStressSpeeds=[strs(2);strs(4);strs(6)];
            end
            setHandles(handles);
            setUIElement('delft3dflow.physicalparameters.physicalparameterspanel.wind.dragcoeftable');
    end
end
