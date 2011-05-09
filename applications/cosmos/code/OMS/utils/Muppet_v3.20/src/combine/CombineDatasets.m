function [DataProperties,NrAvailableDatasets,CombinedDatasetProperties]=CombineDatasets(DataProperties,NrAvailableDatasets,CombinedDatasetProperties,NrCombinedDatasets);
 
for i=1:NrCombinedDatasets
    NrAvailableDatasets=NrAvailableDatasets+1;
    DataProperties=Combine(DataProperties,CombinedDatasetProperties,NrAvailableDatasets,i);
end
