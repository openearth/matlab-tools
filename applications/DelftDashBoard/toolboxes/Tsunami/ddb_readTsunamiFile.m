function handles=ddb_readTsunamiFile(handles,filename)

txt=ReadTextFile(filename);
nseg=0;
nvert=0;
for i=1:length(txt)
    switch(lower(txt{i})),
        case{'magnitude'}
            handles.Toolbox(tb).Input.Magnitude=str2num(txt{i+1});
        case{'depthfromtop'}
            handles.Toolbox(tb).Input.DepthFromTop=str2num(txt{i+1});
        case{'relatedtoepicentre'}
            if strcmp(lower(txt{i+1}(1)),'y')
                handles.Toolbox(tb).Input.RelatedToEpicentre=1;
            else
                handles.Toolbox(tb).Input.RelatedToEpicentre=0;
            end
        case{'latitude'}
            handles.Toolbox(tb).Input.Latitude=str2num(txt{i+1});
        case{'longitude'}
            handles.Toolbox(tb).Input.Longitude=str2num(txt{i+1});
        case{'nrsegments'}
            handles.Toolbox(tb).Input.NrSegments=str2num(txt{i+1});
        case{'segment'}
            nseg=nseg+1;
            handles.Toolbox(tb).Input.Dip(nseg)=str2num(txt{i+1});
            handles.Toolbox(tb).Input.SlipRake(nseg)=str2num(txt{i+2});
        case{'vertex'}
            nvert=nvert+1;
            handles.Toolbox(tb).Input.FaultX(nvert)=str2num(txt{i+1});
            handles.Toolbox(tb).Input.FaultY(nvert)=str2num(txt{i+2});
    end
end
