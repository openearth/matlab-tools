function EHY_plotContour(modelFile,varargin)

%% Function plot countour lines of phases from fourier file);
OPT.varContours    = 'bed';
OPT.valContours    = NaN;
OPT.colContours    = [0 0 0; 1 0 0; 0 1 0 ];
OPT.styleContours  = {'-' '--' '-.'};
OPT.widthContours  = 0.5;
OPT                = setproperty(OPT,varargin);

%% Read the data (might be that modelFile already contains the data; noet very elegan.logical nam
if ~isstruct(modelFile)
    [newName,varNameInput] = EHY_nameOnFile(modelFile,OPT.varContours,OPT);
    FI                     = ncinfo(modelFile);
    list                   = {FI.Variables.Name};
    nrVar                  = get_nr(list,newName);
    longName               = FI.Variables(nrVar).Attributes(7).Value;
    
    %% Read (quickplot style)
    FI       = qpfopen(modelFile);
    DATA     = qpread(FI,FI.NumDomains + 2,longName,'griddata');
    if strcmp(OPT.varContours,'bed') DATA.Val = -1*DATA.Val; OPT.valContours = -1*OPT.valContours; end
else
    DATA = modelFile;
end

%% Plot the contours, 1 by 1
for i_cont = 1: length(OPT.valContours)
%    if strcmp(OPT.varContours,'ampphas') && valCountours(i_cont) ==360; DATA.val(Data.val <180) = DATA.val(Data.val <180) + 360; end 
    index = mod(i_cont - 1,length(OPT.styleContours)) + 1;
    
    %% Plot Contour lines, QUICKPLOT style
    Ops                      = struct('version'   , 1.4      , 'axestype','X-Y'       ,'presentationtype','contour lines', ...
                                     'LineParams',{{'linestyle',OPT.styleContours{index},'color',OPT.colContours(index,:) ,'LineWidth',OPT.widthContours}},                     ...
                                     'Thresholds',OPT.valContours(i_cont)                                                                  );
    Ops                      = qp_state_version(Ops);
    
    qp_scalarfield(gca,[],'contour lines','UGRID',DATA,Ops);
end



