function hm=cosmos_readParameters(hm)

hm.Parameters=xml_load([hm.MainDir filesep 'data' filesep 'parameters' filesep 'parameters.xml']);
