%% RUNSCRIPT [matlab version: 7.6.0 (R2008a)]
% --------------------------------------------------
% input data
% - see below
%
% output data
% - ascii file of the same format
% - figure with the converted parameters [png format]
% ---------------------------------------------------

function ouputPNG = TransformFunction(v1,v2,v3,v4,v5)

% v1 = '11/01/2010';
% v2 = '12/12/2010';
% v3 = 52;             
% v4 = 3.5;             
% v5 = 'tst.asc'; 

geoIn = [v3 v4];
rdOut=geo2rd(geoIn);

%% parameters
s.StartDate         = datenum(v1,23);
s.EndDate           = datenum(v2,23);
s.Loc.X             = rdOut(1);             % x-coordinates RD >> make sure it is in the model domain
s.Loc.Y             = rdOut(2);             % y-coordinates RD >> make sure it is in the model domain
s.OutputFile        = v5;          % name of outputfile

%% run
outputPNG = Transform(s);