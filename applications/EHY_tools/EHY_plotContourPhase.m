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
Ops                      = struct('version'   , 1.4      , 'axestype','Lon-Lat','presentationtype','contour lines', ...
                                  'LineParams',{{'linestyle',OPT.linestyle,'color',OPT.Color}},                     ...
                                  'Thresholds',[0:30:360]                                                         );
Ops                      = qp_state_version(Ops);
DATA.Val(DATA.Val > 345) = NaN;
DATA.Val(DATA.Val <  15) = NaN;

qp_scalarfield(gca,[],'contour lines','UGRID',DATA,Ops);

%% Now the 0/360 degrees line (add 180 degrees and plot the 180 degrees line)
DATA.val                 = DATA_org;
                         DATA.Val                 = DATA.Val - 180.;
                         DATA.Val(DATA.Val < 0  ) = DATA.Val(DATA.Val < 0  ) + 360.;
                         DATA.Val(DATA.Val > 345) = NaN;
                         DATA.Val(DATA.Val <  15) = NaN;
Ops                      = struct('version'   , 1.4      , 'axestype','Lon-Lat','presentationtype','contour lines', ...
                                  'LineParams',{{'linestyle',OPT.linestyle,'color',OPT.Color}},                     ...
                                  'Thresholds',[180.]                                                               );
Ops                      = qp_state_version(Ops);
DATA.Val(DATA.Val > 345) = NaN;
DATA.Val(DATA.Val <  15) = NaN;

qp_scalarfield(gca,[],'contour lines','UGRID',DATA,Ops);




    

