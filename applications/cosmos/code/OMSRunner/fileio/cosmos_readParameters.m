function hm=cosmos_readParameters(hm)

hm.parameters=xml_load([hm.dataDir filesep 'parameters' filesep 'parameters.xml']);
