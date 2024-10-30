function EHY_plotContour(modelFile,Contours,varargin)

%% Function plot countour lines of phases from fourier file);
OPT.Color     = [0 0 0; 1 0 0; 0 1 0 ];
OPT.LineStyle = {'-' '--' '-.'};
OPT.LineWidth = 0.5;
OPT           = setproperty(OPT,varargin);

%% Read the data
[newName,varNameInput] = EHY_nameOnFile(modelFile,'bed',OPT);
FI                     = ncinfo(modelFile);
list                   = {FI.Variables.Name};
nrVar                  = get_nr(list,newName);
longName               = FI.Variables(nrVar).Attributes(7).Value;

%% Read (quickplot style)
FI       = qpfopen(modelFile);
DATA     = qpread(FI,FI.NumDomains + 2,longName,'griddata');
DATA.Val = -1*DATA.Val;

for i_cont = 1: length(Contours)
    index = mod(i_cont - 1,3) + 1;
    
    %% Plot Contour lines, QUICKPLOT style, from 0 until 360 degrees. To avoid thick 0 degrees phase line file with NAN vulue in between 345 and 15 degrees
    Ops                      = struct('version'   , 1.4      , 'axestype','X-Y'       ,'presentationtype','contour lines', ...
                                     'LineParams',{{'linestyle',OPT.LineStyle{index},'color',OPT.Color(index,:) ,'LineWidth',OPT.LineWidth}},                     ...
                                     'Thresholds',-1*Contours(i_cont)                                                                  );
    Ops                      = qp_state_version(Ops);
    
    qp_scalarfield(gca,[],'contour lines','UGRID',DATA,Ops);
end



