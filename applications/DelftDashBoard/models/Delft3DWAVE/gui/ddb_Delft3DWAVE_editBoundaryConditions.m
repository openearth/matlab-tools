function ddb_Delft3DWAVE_editBoundaryConditions(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch varargin{ii}
            case{'addsegment'}
                addSegment;
            case{'deletesegment'}
                deleteSegment;
        end
    end
end

%%
function addSegment

handles=gui_getUserData;
iac=handles.Model(md).Input.activeboundary;
nrseg=handles.Model(md).Input.boundaries(iac).nrsegments;
handles.Model(md).Input.boundaries(iac).segments(nrseg+1).condspecatdist=handles.Model(md).Input.boundaries(iac).segments(nrseg).condspecatdist;
handles.Model(md).Input.boundaries(iac).segments(nrseg+1).waveheight=handles.Model(md).Input.boundaries(iac).segments(nrseg).waveheight;
handles.Model(md).Input.boundaries(iac).segments(nrseg+1).period=handles.Model(md).Input.boundaries(iac).segments(nrseg).period;
handles.Model(md).Input.boundaries(iac).segments(nrseg+1).direction=handles.Model(md).Input.boundaries(iac).segments(nrseg).direction;
handles.Model(md).Input.boundaries(iac).segments(nrseg+1).dirspreading=handles.Model(md).Input.boundaries(iac).segments(nrseg).dirspreading;
handles.Model(md).Input.boundaries(iac).nrsegments=nrseg+1;
handles.Model(md).Input.boundaries(iac).activesegment=nrseg+1;
for ii=1:nrseg+1
    handles.Model(md).Input.boundaries(iac).segmentnames{ii}=['Segment ' num2str(ii)];
end
gui_setUserData(handles);

%%
function deleteSegment

handles=gui_getUserData;
iac=handles.Model(md).Input.activeboundary;
nrseg=handles.Model(md).Input.boundaries(iac).nrsegments;
if nrseg>1
    handles.Model(md).Input.boundaries(iac).segments=removeFromStruc(handles.Model(md).Input.boundaries(iac).segments,handles.Model(md).Input.boundaries(iac).activesegment);
    handles.Model(md).Input.boundaries(iac).nrsegments=handles.Model(md).Input.boundaries(iac).nrsegments-1;
    handles.Model(md).Input.boundaries(iac).activesegment=min(handles.Model(md).Input.boundaries(iac).activesegment,handles.Model(md).Input.boundaries(iac).nrsegments);
    handles.Model(md).Input.boundaries(iac).segmentnames=[];
    for ii=1:nrseg-1
        handles.Model(md).Input.boundaries(iac).segmentnames{ii}=['Segment ' num2str(ii)];
    end
    gui_setUserData(handles);
end
