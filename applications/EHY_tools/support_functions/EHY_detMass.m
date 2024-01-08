function [times,mass] = EHY_detMass(fileInp,varargin)

%% Determine time series of mass inside a polygon 
%  Initialise
OPT.varName = 'sal';
OPT.filePol = '';
OPT.zTop    = NaN;
OPT.zBot    = NaN;
OPT         = setproperty(OPT,varargin);

%% load polygon
if ~isempty(OPT.filePol)
    % Load the polygon
    pol      = readldb(OPT.filePol);
    Xpol     = pol.x;
    Ypol     = pol.y;
else
    Xpol = [];
    Ypol = [];
end

%% Partition numbers
partitionNrs = EHY_findPartitionNumbers(fileInp,'xrange',[min(Xpol) max(Xpol)],'yrange',[min(Ypol) max(Ypol)]);

%% load grid data
Info     = EHY_getGridInfo(fileInp,{'XYcen','area','no_layers'},'disp',0,'mergePartitionNrs',partitionNrs);
Xcen     = Info.Xcen;
Ycen     = Info.Ycen;
area     = Info.area;
kmax     = Info.no_layers;

%% Inside polygon ?
inside(1:length(Xcen)) = true;
if ~isempty(Xpol) && ~isempty(Ypol)
    inside   = inpolygon(Xcen,Ycen,Xpol,Ypol);
end

%% times
times                  = EHY_getmodeldata_getDatenumsFromOutputfile(fileInp);
mass(1: length(times)) = 0.;

%% Interface heights and values
Info_z = EHY_getMapModelData(fileInp,'varName','Zcen_int','mergePartitionNrs',partitionNrs);
Info   = EHY_getMapModelData(fileInp,'varName','sal'     ,'mergePartitionNrs',partitionNrs);

%% for each time
for i_time = 1: length(times)
    
    % All points inside polygon
    for i_pnt = 1:length(inside)
        if inside(i_pnt)
            for k = 1: kmax
                
                % Heights and volumes of computational segments
                height = Info_z.val(i_time,i_pnt,k+1) - Info_z.val(i_time,i_pnt,k);
                
                % Above zTop
                if ~isnan(OPT.zTop)
                    if Info_z.val(i_time,i_pnt,k)> OPT.zTop
                        height = NaN;
                    elseif  Info_z.val(i_time,i_pnt,k)<= OPT.zTop && Info_z.val(i_time,i_pnt,k+1) > OPT.zTop
                        height = OPT.zTop -  Info_z.val(i_time,i_pnt,k);
                    end
                end
                
                % Below zBot
                if ~isnan(OPT.zBot)
                    if Info_z.val(i_time,i_pnt,k + 1) < OPT.zBot
                        height = NaN;
                    elseif  Info_z.val(i_time,i_pnt,k + 1) >= OPT.zBot && Info_z.val(i_time,i_pnt,k) < OPT.zBot
                        height = Info_z.val(i_time,i_pnt,k + 1) - OPT.zBot;
                    end
                end
                 
                vol    = area(i_pnt)*height;
                
                % Add to mass
                if ~isnan(height)
                    mass(i_time)     = mass(i_time) + Info.val(i_time,i_pnt,k)*vol;
                end
            end
        end
    end 
end