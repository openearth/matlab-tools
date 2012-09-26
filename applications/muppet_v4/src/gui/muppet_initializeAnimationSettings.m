function handles=muppet_initializeAnimationSettings(handles)

handles.animationsettings.framerate=5;
handles.animationsettings.selectbits=24;
handles.animationsettings.keepfigures=0;
handles.animationsettings.makekmz=0;
handles.animationsettings.avifilename='anim.avi';
handles.animationsettings.prefix='anim';
handles.animationsettings.starttime=[];
handles.animationsettings.stoptime=[];
handles.animationsettings.timestep=3600;

archstr = computer('arch');
switch lower(archstr)
    case{'w32','win32'}
        % win 32
        handles.animationsettings.avioptions.fcchandler=1684633187;
        handles.animationsettings.avioptions.keyframes=0;
        handles.animationsettings.avioptions.quality=10000;
        handles.animationsettings.avioptions.bytespersec=300;
        handles.animationsettings.avioptions.parameters=[99 111 108 114];
    case{'w64','win64'}
        % win 64 - MSVC1
        handles.animationsettings.avioptions.fcchandler=1668707181;
        handles.animationsettings.avioptions.keyframes=15;
        handles.animationsettings.avioptions.quality=7500;
        handles.animationsettings.avioptions.bytespersec=300;
        handles.animationsettings.avioptions.parameters=[75 0 0 0];
end
