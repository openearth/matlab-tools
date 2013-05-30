function muppet_saveSessionFileDatasets(handles,fid)

for id=1:handles.nrdatasets
    
%    if handles.datasets(id).dataset.combineddataset==0

        txt=['Dataset "' handles.datasets(id).dataset.name '"'];
        fprintf(fid,'%s \n',txt);
        
        ift=muppet_findIndex(handles.filetype,'filetype','name',handles.datasets(id).dataset.filetype);
        
        if ~isempty(ift)
            for ii=1:length(handles.filetype(ift).filetype.option)
                idp=muppet_findIndex(handles.dataproperty,'dataproperty','name',handles.filetype(ift).filetype.option(ii).option.name);
                if ~isempty(idp)
                    muppet_writeOption(handles.dataproperty(idp).dataproperty,handles.datasets(id).dataset,fid,3,14);
                end
            end
        end
        
        txt='EndDataset';
        fprintf(fid,'%s \n',txt);
        fprintf(fid,'%s \n','');

%    end
    
end

% for id=1:handles.nrdatasets
%     
%     if handles.datasets(id).dataset.combineddataset
%         
%         dataset=handles.datasets(id).dataset;
%         
%         txt=['CombinedDataset  "' dataset.name '"'];
%         fprintf(fid,'%s \n',txt);
%         
%         txt=['   Operation     ' dataset.operation];
%         fprintf(fid,'%s \n',txt);
%         if dataset.unifopt==1
%             txt=['   UniformValue  ' num2str(dataset.uniformvalue)];
%             fprintf(fid,'%s \n',txt);
%             str=dataset.dataseta.name;
%             txt=['   DatasetA      "' str '"'];
%             fprintf(fid,'%s \n',txt);
%             txt=['   MultiplyA     ' num2str(dataset.dataseta.multiply)];
%             fprintf(fid,'%s \n',txt);
%         else
%             str=dataset.dataseta.name;
%             txt=['   DatasetA      "' str '"'];
%             fprintf(fid,'%s \n',txt);
%             txt=['   MultiplyA     ' num2str(dataset.dataseta.multiply)];
%             fprintf(fid,'%s \n',txt);
%             str=dataset.datasetb.name;
%             txt=['   DatasetB      "' str '"'];
%             fprintf(fid,'%s \n',txt);
%             txt=['   MultiplyB     ' num2str(dataset.datasetb.multiply)];
%             fprintf(fid,'%s \n',txt);
%         end
%         txt='EndCombinedDataset';
%         fprintf(fid,'%s \n',txt);
%         txt='';
%         fprintf(fid,'%s \n',txt);
%         
%     end
%     
% end
