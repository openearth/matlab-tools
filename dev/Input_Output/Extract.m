% Class ciombining import and export.
%
% @author SDO
%

classdef Extract < handle
    %Stactic methods
    methods (Static)
        function ExtractNetCDF(strfilein, strfileout, Restrictions)
            % Restrictions : Structure with restrictions on dimensions of the netcdf file 
            %       Name   : Name of the dimension on which to put the restriction
            %%%       index  : index of the dimension in the netcdf file.
            %       mnVal  : Minimum value 
            %       mxVal  : Maximum value
            %%%       indmn  : index of minimal value
            %%%       indmx  : index of maximal value
%             if exist(strfileout)
%                 ans = questdlg('outputfile already exists, overwrite?');
%                 switch ans
%                     case{'Yes'}
%                     case{'No', 'Cancel'}
%                         return
%                 end
%             end
            meta = ncinfo(strfilein);
            Dimensions = meta.Dimensions;
            for idim = 1:numel(Dimensions) 
                % check if dimension has a restriction
                strdim = Dimensions(idim).Name; 
                data   = ncread(strfilein, strdim); 
                ind = find(arrayfun(@(x) strcmp(x.Name, strdim), Restrictions));
                if isempty(ind)
                    Dimensions(idim).start = 1; 
                    Dimensions(idim).step  = 1;  
                    Dimensions(idim).stop  = Dimensions(idim).Length; 
                    Dimensions(idim).split = false;
                    Dimensions(idim).count = Dimensions(idim).stop;
                else  
                    if issorted(data)
                        Dimensions(idim).start = find(data<=Restrictions(ind).mnVal ,1, 'last'); 
                        Dimensions(idim).step  = 1;  
                        Dimensions(idim).stop  = find(data>=Restrictions(ind).mxVal ,1, 'first');
                    else 
                        Dimensions(idim).stop  = find(data<=Restrictions(ind).mnVal ,1, 'first'); 
                        Dimensions(idim).step  = 1;  
                        Dimensions(idim).start = find(data>=Restrictions(ind).mxVal ,1, 'last');
                        
                    end
                    if Restrictions(ind).mnVal > Restrictions(ind).mxVal
                        Dimensions(idim).split = true;
                        Dimensions(idim).count1 = Dimensions(idim).Length-Dimensions(idim).start+1; 
                        Dimensions(idim).count2 = Dimensions(idim).stop;
                        Dimensions(idim).count  = Dimensions(idim).count1 + Dimensions(idim).count2;  
                    else
                        Dimensions(idim).split = false;
                        Dimensions(idim).count = Dimensions(idim).stop-(Dimensions(idim).start-1);
                    end
                end
                 
                meta.Dimensions(idim).Length = Dimensions(idim).count;
            end
            cDim = {Dimensions.Name};
            for ivar = 1:numel(meta.Variables)
                strvar = meta.Variables(ivar).Name; 
                dimvar = {meta.Variables(ivar).Dimensions.Name}; 
                [~, indvar, inddim] = intersect(dimvar, cDim);
                sinddim = inddim(indvar); % sorted in order of dimensions!
                if numel(indvar)<numel(dimvar) 
                    errordlg('There is something wrong with the dimensions of the original file');
                end
                for idim = 1:numel(sinddim)
                    meta.Variables(ivar).Dimensions(idim).Length   = Dimensions(sinddim(idim)).count;
                end
            end
            
            ncwriteschema(strfileout,meta);
            SPC = [Dimensions(sinddim).split];
            for ivar = 1:numel(meta.Variables)
                strvar = meta.Variables(ivar).Name; 
                dimvar = {meta.Variables(ivar).Dimensions.Name}; 
                [~, indvar, inddim] = intersect(dimvar, cDim);
                sinddim = inddim(indvar); % sorted in order of dimensions!
                split = any(SPC(sinddim));
                start   = arrayfun(@(x) x.start, Dimensions(sinddim)); 
%                 stride  = arrayfun(@(x) x.step , Dimensions(sinddim)); 
                count   = arrayfun(@(x) x.count, Dimensions(sinddim));  
                if split
                    indsplit = find(SPC(sinddim)); 
                    if numel(indsplit)>1; error('ERROR : there should be only one dimension that is circular, in principle this shouls be longitude'); end
                    start(indsplit) = Dimensions(sinddim(indsplit)).start;
                    count(indsplit) = Dimensions(sinddim(indsplit)).count1;
                    data1   = ncread(strfilein, strvar, start, count);
                    start(indsplit) = 1;
                    count(indsplit) = Dimensions(sinddim(indsplit)).count2;
                    data2   = ncread(strfilein, strvar, start, count);
                    switch strvar
                        case{'longitude'}
                            data1 = mod(data1,360)-360;
                            data2 = mod(data2,360);
                        otherwise
                            warning(sprintf('Split variable : %s', strvar))
                    end     
                    data = cat(indsplit, data1, data2);
                else
                    data   = ncread(strfilein, strvar, start, count); 
                end
                ncwrite(strfileout, strvar, data);
            end
            for iatt = 1:numel(meta.Attributes)
                ncwriteatt(strfileout, '/', meta.Attributes(iatt).Name, meta.Attributes(iatt).Value)
            end
%             ncwriteatt(strfileout, '/', 'mfilename', mfilename)
%             ncwriteatt(strfileout, '/', 'username', getenv('username'))
%             ncwriteatt(strfileout, '/', 'date', datestr(now))
               
        end

    end
end