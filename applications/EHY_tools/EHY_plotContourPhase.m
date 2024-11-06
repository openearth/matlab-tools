function EHY_plotContourPhase(modelFile,varargin)

%% Function plot countour lines of phases from fourier file);

OPT.Color     = [0 0 1];
OPT.linestyle = '-';
OPT.fouStart  = NaN;
OPT.fouStop   = NaN;
OPT           = setproperty(OPT,varargin);
OPT.fouType  = 'phs';

%% Read the data
[newName,varNameInput] = EHY_nameOnFile(modelFile,'wl',OPT);
FI                     = ncinfo(modelFile);
list                   = {FI.Variables.Name};
nrVar                  = get_nr(list,newName);
longName               = FI.Variables(nrVar).Attributes(6).Value;

%% Read (quickplot style)
FI       = qpfopen(modelFile);
DATA     = qpread(FI,FI.NumDomains + 2,longName,'griddata');
DATA_org = DATA.Val;

%% Plot Contour lines, QUICKPLOT style, from 0 until 360 degrees. To avoid thick 0 degrees phase line file with NAN vulue in between 345 and 15 degrees
DATA.Val(DATA.Val > 345) = NaN;
DATA.Val(DATA.Val <  15) = NaN;
EHY_plotContour(DATA,'varContours','phs','valContours',30:30:330,'colContours',OPT.Color,'styleContours',{OPT.linestyle});

%% Now the 0/360 degrees line 
DATA.Val                   = DATA_org;
DATA.Val(DATA.Val < 180  ) = DATA.Val(DATA.Val < 180  ) + 360.;
EHY_plotContour(DATA,'varContours','phs','valContours',360,'colContours',OPT.Color,'styleContours',{OPT.linestyle});
    

