%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Add function explanation

function write_subdomain_bc(Upstream, Downstream, Case, Case_type, crsfile, obsfile, shapefile, orderflwfile, fpath_project, ncfilepath)

%% PARSE

%% Create upstream and downstream boundary file
crs_seg = tekal('read', crsfile, 'loaddata');
linknumbers = shp2struct(shapefile,'read_val',true);
%get names and flow link numbers
a = linknumbers.val{1,1};
b = linknumbers.val{1,2};
ObjectID = a.Val;
Flowlinknr = b.Val; 
%Select only relevant flowlinks
idx = startsWith (ObjectID, 'P');
ObjectID = ObjectID(idx);
Flowlinknr = Flowlinknr(idx);
%Store relevant flowlinks
flownumbers = cell(length(Flowlinknr),2);
flownumbers(:,1) = ObjectID;
flownumbers(:,2) = num2cell(Flowlinknr);

%#V: `flownumbers` is not used. ?

[orderflw,flowlinkQ]=write_pli(crs_seg,orderflwfile,fpath_bc);

[Qobs,hobs]=read_obs(obsfile,Qpli,hpli);

read_map()

write_q()

%#V: `clear bc` is slow and prone to error. 

write_h()

write_ext()

end %function

%%
%% FUNCTIONS
%%

function [orderflw,flowlinkQ]=write_pli(crs_seg,orderflwfile,fpath_bc)

% Initialize a new struct to store matching entries
Qpli = struct('Name', {}, 'Data', {});
hpli = struct('Name', {}, 'Data', {});
flowlinkQ = struct('Complete', {}, 'P0000', {}, 'P0001', {}, 'P0002', {},'P0003', {});
% Select relevant segments
plifile = crs_seg.Field;
orderflw= load(orderflwfile);
order_flw = orderflw.orderflw.Complete; %#V: Specific for 4 partitions?
order_flw0000 = orderflw.orderflw.P0000;
order_flw0001 = orderflw.orderflw.P0001;
order_flw0002 = orderflw.orderflw.P0002;
order_flw0003 = orderflw.orderflw.P0003;

for k = 1:numel(plifile)
    if contains(plifile(k).Name, Upstream) 
        Qpli(end+1).Name = plifile(k).Name;
        Qpli(end).Data = plifile(k).Data;
        %order_flw(i).orderedflownumbers
        flowlinkQ(end+1).Complete = order_flw(k).Data; 
        %lowlinkQ(end+1).Complete = Flowlinknr(i); 

    elseif contains(plifile(k).Name, Downstream)
        hpli(end+1).Name = plifile(k).Name;
        hpli(end).Data = plifile(k).Data;
    end 
end 

%Upstream boundary files (needs to be seperate files)
for k = 1 : numel(Qpli)
    uppli = fullfile(fpath_bc,sprintf('%s.pli',Qpli(k).Name));
    tekal('write', [uppli], Qpli(k))
end
%Downstream boundary files (needs to be seperate files)
for k = 1:numel(hpli)
    downpli = fullfile(fpath_bc,sprintf('%s.pli',hpli(k).Name));
    tekal('write', [downpli], hpli(k))
end

% uppli = [fpath_project,'boundary_conditions\',Upstream,'.pli'];
% downpli = [fpath_project,'boundary_conditions\',Downstream,'.pli'];
%     %uppli = 
% % Write an upstream and downstream .pli
% tekal('write', [uppli], hpli);
% tekal('write', [downpli], hpli);

end %function

%%

function [Qobs,hobs]=read_obs(obsfile,Qpli,hpli)

%#V: matrixread, cellread
fid = fopen(obsfile);
data = textscan(fid, '%f %f %s', 'Delimiter', '\t');
NameOBS = data{3};

%Save relevant observation points for Q boundary
Qobs=struct('Name','','X',[],'Y',[]);
for k = 1:numel(Qpli)
    Name = strrep(Qpli(k).Name, 'C_', ''); 
    
    for kobs=1:2
        Qobs(k).Name = sprintf('O_%d_%s',kobs,Name);
        
        idx_str=find(strcmp(Qobs(k).Name, NameOBS));
        Qobs(k).X = data{1}(idx_str);
        Qobs(k).Y = data{2}(idx_str);
    end %kobs
%     for j = 1:length(NameOBS)
%         if strcmp(Qobs(k).Name, NameOBS(j))
%             Qobs(k).X = data{1}(j);
%             Qobs(k).Y = data{2}(j);
%         end
%         if strcmp(Qobs2(k).Name, NameOBS(j))
%             Qobs2(k).X = data{1}(j);
%             Qobs2(k).Y = data{2}(j);
%         end
%     end
end %k

%Save relevant observation points for h boundary
hobs=struct('Name','','X',[],'Y',[]);
for k = 1:numel(hpli)
    Name = strrep(hpli(k).Name, 'C_', ''); 
    hobs(k).Name = ['O_1_', Name];
    idx_str=find(strcmp(hobs(k).Name, NameOBS));
    hobs(k).X = data{1}(idx_str);
    hobs(k).Y = data{2}(idx_str);
%     for j = 1:length(NameOBS)
%         if strcmp(hobs(k).Name, NameOBS(j))
%             hobs(k).X = data{1}(j);
%             hobs(k).Y = data{2}(j);
%         end
%     end
end

end %function

%%

function read_map(fpath_map)

%#V: There is input in the function.
if isfile(fullfile(ncfilepath, 'Maas_map.nc'))
    %Time
    tdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_map.nc'),'','dfm','varName','time');
    t = tdata.val.';
    %Discharge
    qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_map.nc'),'','dfm','varName','mesh2d_q1');
    q = qdata.val.';
    %water level 
    s1data = EHY_getMapModelData(fullfile(ncfilepath, 'Maas_map.nc'),'varName','mesh2d_s1');
    s1 = s1data.val.';
    bldata= EHY_getMapModelData(fullfile(ncfilepath, 'Maas_map.nc'),'varName','mesh2d_flowelem_bl');
    bl = bldata.val.';
    partition = 0;
    %% Load direction of flowlinks
    d3d_qp('openfile',fullfile(ncfilepath, 'Maas_map.nc'));
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face{2} = d3d_qp('loaddata'); 

elseif isfile(fullfile(ncfilepath, 'Maas_0000_map.nc'))
    %Time
    tdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0000_map.nc'),'','dfm','varName','time');
    t = tdata.val.';
    %Discharge2
    qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0000_map.nc'),'','dfm','varName','mesh2d_q1');
    q0000 = qdata.val.';
    qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0001_map.nc'),'','dfm','varName','mesh2d_q1');
    q0001 = qdata.val.';
    qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0002_map.nc'),'','dfm','varName','mesh2d_q1');
    q0002 = qdata.val.';
    qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0003_map.nc'),'','dfm','varName','mesh2d_q1');
    q0003 = qdata.val.';
    %water level 
    s1data = EHY_getMapModelData(fullfile(ncfilepath, 'Maas_0000_map.nc'),'varName','mesh2d_s1');
    s1 = s1data.val.';
    %bed level
    bldata= EHY_getMapModelData(fullfile(ncfilepath, 'Maas_0000_map.nc'),'varName','mesh2d_flowelem_bl');
    bl = bldata.val.';
    
    d3d_qp('selectdomain','partition 0000')    
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face0000{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face0000{2} = d3d_qp('loaddata'); 
    d3d_qp('selectdomain','partition 0001')    
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face0001{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face0001{2} = d3d_qp('loaddata');
    d3d_qp('selectdomain','partition 0002')    
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face0002{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face0002{2} = d3d_qp('loaddata');
    d3d_qp('selectdomain','partition 0003')    
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face0003{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face0003{2} = d3d_qp('loaddata');
    
    d3d_qp('selectfield', 'Topology data of 2D mesh - face indices');
    d3d_qp('selectdomain','partition 0000')
    faces0000 = d3d_qp('loaddata'); 
    d3d_qp('selectdomain','partition 0001')
    faces0001 = d3d_qp('loaddata'); 
    d3d_qp('selectdomain','partition 0002')
    faces0002 = d3d_qp('loaddata'); 
    d3d_qp('selectdomain','partition 0003')    
    faces0003 = d3d_qp('loaddata'); 

    partition = 1 ;
else
    disp('File does not exists')
end

end %function

%%

function write_q()

%Get locations of faces from complete map file
%#V: `faces` only used for writing BC?
%#V: paths should not be in functions
compmapfile = 'p:\archivedprojects\11209261-002-maas-mor-v2\C_Work\01_Model_40m\dflowfm2d-maas-j23_6-v1a\computations\test\S1300\results\Maas_map.nc';
d3d_qp('openfile',compmapfile);
d3d_qp('selectfield', 'Topology data of 2D mesh - face indices');
faces = d3d_qp('loaddata'); 

fname = sprintf('Maas_%s_%s_bnd.bc', ['C_',Upstream], Case);
fpath = fullfile(fpath_project, 'boundary_conditions','test',Case_type, 'flow',Case,fname);
kbc = 0;
if partition == 0
    xrounded = round(faces(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded = round(faces(1).Y,6)
else
    xrounded0 = round(faces0000(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded0 = round(faces0000(1).Y,6);
    xrounded1 = round(faces0001(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded1 = round(faces0001(1).Y,6);
    xrounded2 = round(faces0002(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded2 = round(faces0002(1).Y,6);
    xrounded3 = round(faces0003(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded3 = round(faces0003(1).Y,6);
end

for k = 1:numel(Qobs)
    if partition == 0
        idx = find(xrounded == Qobs(k).X);
        q1 = q(idx);
        flownr = flowlinkQ(k).Complete;
    else
        obsname = Qobs(k).Name(5:end);
        ordered_flw = {order_flw0000, order_flw0001, order_flw0002, order_flw0003};
        q = {q0000, q0001, q0002, q0003};
        xr = {xrounded0, xrounded1, xrounded2, xrounded3};
        yr = {yrounded0, yrounded1, yrounded2, yrounded3};
        ftf = {flowlink_to_face0000, flowlink_to_face0001, flowlink_to_face0002, flowlink_to_face0003};
        shouldbreak = false;
        for k = 1:numel(ordered_flw)
            flwlinks = ordered_flw{k};
            qpart = q{k};
            xrounded = xr{k};
            yrounded = yr{k};
            flowlink_to_face = ftf{k};
            for j = 1:numel(ordered_flw{k}) 
                flownrname = flwlinks(j).Name;
                flownrname = flownrname{1}(3:end);

                if strcmp(flownrname, obsname)
                    idx = find(xrounded == Qobs(k).X);
                    q1 = qpart(idx);
                    shouldbreak = true;
                    flownr = flwlinks(j).Data;
                    break
                end
            end
            if shouldbreak
                break
            end
        end

    end
    if yrounded(idx) == Qobs(k).Y
        kbc = kbc+1;
        bc(kbc).name=strrep(deblank(Qobs(k).Name),'O_1_', 'C_');
        bc(kbc).function='timeseries';
        bc(kbc).time_interpolation='linear';
        bc(kbc).quantity{1}='time';
        bc(kbc).unit{1}='minutes since 2035-01-01 00:00:00 +01:00';
        bc(kbc).quantity{2}='dischargebnd';
        bc(kbc).unit{2}='m3/s';
        
        %Check if sign is correct (SHOULD BE TESTED)
        
        if Qobs(k).X > Qobs2(k).X
            if flowlink_to_face{1}.X(abs(flownr))< flowlink_to_face{2}.X(abs(flownr))
                q1 =  -q1;
            end
        else
            if flowlink_to_face{1}.X(abs(flownr)) > flowlink_to_face{2}.X(abs(flownr))
                q1 = -q1;
            end
        end

        bc(kbc).val = [t([1, end])/60, q1([end,end]).'];

    else
        break
    end
end

D3D_write_bc(fpath,bc)

end %function

%%

function write_h()

clear bc
fname = sprintf('Maas_%s_%s_bnd.bc', ['H_',Downstream], Case);
fpath = fullfile(fpath_project, 'boundary_conditions','test',Case_type, 'flow',Case,fname);
delete(fpath)
kbc = 0;
for k = 1:numel(hobs)
    idx = find(xrounded == hobs(k).X)
    if yrounded(idx) == hobs(k).Y
        kbc = kbc+1;
        bc(kbc).name=strrep(deblank(hobs(k).Name),'O_1_', 'C_');
        bc(kbc).function='timeseries';
        bc(kbc).time_interpolation='linear';
        bc(kbc).quantity{1}='time';
        bc(kbc).unit{1}='minutes since 2035-01-01 00:00:00 +01:00';
        bc(kbc).quantity{2}='waterlevelbnd';
        bc(kbc).unit{2}='m';
        if isnan(s1(idx,[end])) % Replace NaN values with bed level values
            bc(kbc).val = [t([1, end])/60, [bl(idx), bl(idx)].'];
        else
            bc(kbc).val = [t([1, end])/60, s1(idx,[end, end]).'];
        end
    else
        break
    end
end
D3D_write_bc(fpath,bc)

end %function

%%

function write_ext()

base_path = 'p:\11210364-003-maas-mor\C_Work\01_Model_40m\dflowfm2d-maas-j23_6-v1a\computations\test\'
X = D3D_io_input('read', fullfile(base_path, Case, ['Maas_',Case,'_bnd.ext']));
fns = fieldnames(X);
bndc = -1; 
for LL = 1:numel(Qpli)
    bndc = bndc+1
    fn = sprintf('boundary%i',bndc);
    X.(fn).quantity = 'dischargebnd';
    X.(fn).locationfile = sprintf('../../../boundary_conditions/%s.pli', Qpli(LL).Name)
    X.(fn).forcingfile= sprintf('../../../boundary_conditions/test/%s/flow/%s/Maas_%s_%s_bnd.bc', ...
                     Case_type,Case, Upstream, Case);
end

for LL = 1:numel(hobs)
    bndc = bndc+1
    fn = sprintf('boundary%i',bndc);
    X.(fn).quantity = 'waterlevelbnd';
    X.(fn).locationfile = sprintf('../../../boundary_conditions/%s.pli', hpli(LL).Name);
    X.(fn).forcingfile= sprintf('../../../boundary_conditions/test/%s/flow/%s/Maas_%s_%s_bnd.bc', ...
                     Case_type,Case, Downstream, Case);
end
D3D_io_input('write', fullfile(fpath_project, 'computations','test',Case, ['Maas_',strrep(Upstream,'C_','Q_'),'_',Case,'_bnd.ext']), X);

end %function