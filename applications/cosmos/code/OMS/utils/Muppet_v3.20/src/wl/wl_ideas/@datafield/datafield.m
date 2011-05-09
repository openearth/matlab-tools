function Obj = datafield;
% DATAFIELD creates a data field object
%
%      Six different calls to this function can be expected:
% 
%      1. Obj=DATAFIELD
%         To create an empty datafield.

% Types: MULTIBLOCK, UNIFORM, RECTILINEAR, CURVILINEAR, UNSTRUCTURED, GIS
Obj.Block(1).Type='';    % TYPE
Obj.Block(1).Size=[];    % NCELLS STRUCTURED / UNSTRUCTURED
Obj.Block(1).NDim=[];    % PHYS.DIM. / INDEX DIM. STRUCTURED / UNSTRUCTURED
Obj.Block(1).XCoord=[];  % STRUCTURED
Obj.Block(1).YCoord=[];  % STRUCTURED
Obj.Block(1).ZCoord=[];  % STRUCTURED
Obj.Block(1).Nodes=[];   % UNSTRUCTURED
Obj.Block(1).Cells={};   % UNSTRUCTURED
Obj.Block(1).Var={};     % VARIABLE VALUES PER CELL / VERTEX
Obj.Block(1,:)=[];
Obj.Var(1).Name='';
Obj.Var(1).Type='';
Obj.Var(1,:)=[];
Obj=class(Obj,'datafield');