% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Compute the elevation of the interface of the substrate layers. 

function [Zint_bed,no_bed_layers]=EHY_getMapModelData_construct_Zint_bed(inputFile,modelType,OPT)
        
if strcmp(modelType,'dfm')
    [Zint_bed,no_bed_layers]=EHY_getMapModelData_construct_Zint_bed_fm(inputFile,OPT);   
elseif strcmp(modelType,'d3d')
    [Zint_bed,no_bed_layers]=EHY_getMapModelData_construct_Zint_bed_d3d(inputFile,OPT);
else
    error('sorry, not yet implemented.')
end

    
