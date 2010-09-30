function ddb_Delft3DFLOW_editKMax

handles=getHandles;

kmax0=handles.Model(md).Input(ad).lastKMax;
kmax=handles.Model(md).Input(ad).KMax;

if kmax~=kmax0

    handles.Model(md).Input(ad).lastKMax=kmax;
    
    handles.Model(md).Input(ad).Thick=[];
    if kmax==1
        handles.Model(md).Input(ad).Thick=100;
    else
        for i=1:kmax
            thick(i)=0.01*round(100*100/kmax);
        end
        sumlayers=sum(thick);
        dif=sumlayers-100;
        thick(kmax)=thick(kmax)-dif;
        for i=1:kmax
            handles.Model(md).Input(ad).Thick(i)=thick(i);
        end
    end
    
    setHandles(handles);
    
    ddb_Delft3DFLOW_computeSumLayers;

    setUIElement('delft3dflow.domain.domainpanel.grid.layertable');

end
