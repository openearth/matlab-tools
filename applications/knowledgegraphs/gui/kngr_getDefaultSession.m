function kngr_getDefaultSession

global session %#ok<NUSED>

try % default session should be the last used session file
    load([fileparts(which('DelftConStruct')) filesep 'lastsession.mat']);
catch % or a very basic default session
    addRelation('Felix'   ,'name'   ,3) % ali
    addRelation('name'    ,'cat'    ,4) % par
    addRelation('cat'     ,'animal' ,2) % sub
end