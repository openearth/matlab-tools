function dataset=muppet_addDatasetAnnotation(opt,dataset)

switch lower(opt)

    case{'read'}
        
        % Do as much as possible here and not in import function
        dataset.adjustname=0;
        [pathstr,name,ext]=fileparts(dataset.filename);    
        dataset.name=name;

    case{'import'}
        
        fid=fopen(dataset.filename);
        
        k=0;
        while 1
            tx0=fgets(fid);
            if and(ischar(tx0), size(tx0>0))
                v0=strread(tx0,'%q');
                if ~strcmp(v0{1}(1),'#')
                    k=k+1;
                    if ~isnan(str2double(v0{1})) && ~isempty(str2double(v0{1}))
                        dataset.x(k)=str2double(v0{1});
                        dataset.y(k)=str2double(v0{2});
                        dataset.z(k)=0;
                        dataset.text{k}=v0{3};
                    else
                        dataset.x(k)=str2double(v0{2});
                        dataset.y(k)=str2double(v0{3});
                        dataset.z(k)=0;
                        dataset.text{k}=v0{1};
                    end
                    if size(v0,1)>=4
                        dataset.rotation(k)=str2double(v0{4});
                    else
                        dataset.rotation(k)=0;
                    end
                    if size(v0,1)>=5
                        dataset.curvature(k)=str2double(v0{5});
                    else
                        dataset.curvature(k)=0;
                    end
                end
            else
                break
            end
        end
        
        fclose(fid);
                
        dataset.type = 'textannotation';
        dataset.tc='c';

end
