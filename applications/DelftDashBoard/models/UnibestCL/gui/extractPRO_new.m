function [PROdata]=extractPRO_new(XYZdata,RAYlocdata,XYZfile,PROdata)
                   
% function extractPRO(input_data,ray_file,z_dynbound,water_level,path_out,no_samples,pro_file)
%
% Extracts and writes a unibest profile file (also computes location of shoreline, dynamic boundary and grid settings)
% 
% input:
% input_data           struct with filenames, with for each field a string with filename OR cellstring with filenames
%                        define either a grid with depth field or a wavm field, optional to define an input_path
%                        - input_data.grid & input_data.depth
%                        - input_data.wavm
%                        - input_data.path (optional, default = '')
% ray_file             string with filename of polygon defining rays (ray1=[x1,y1;x2,y2], ray2=[x4,y4;x5,y5], etc) (x3,y3=NaN)
% z_dynbound           depth at which dynamic boudnary is defined (optional; default = 8)
% reference_level      reference level (optional; default = 0)
% path_out             struct with output_paths for png and pro files (optional parameter, default = 'png\' & 'pro\')
%                        - path_out.pro  : string
%                        - path_out.png  : string
% z_limits             (optional) maximum and minimum z-level (sepcify as bottom level!) included in profile ([zmin zmax])
% no_samples           (optional) calibration parameter defining number of steps in x-direction (not advised to change, default = 20)
% 
% output:
% .pro-files
% .png-figures with used samples and schematisation
% .txt-file with used grids
% 
%-------------------------------------------------------------------------
%---------------------------------INPUT-----------------------------------
%-------------------------------------------------------------------------

%------------general settings------------
NANvalue   = -99;
replaceNAN = -3;

%------------read ray data------------
X1 = RAYlocdata.X1; 
Y1 = RAYlocdata.Y1;
X2 = RAYlocdata.X2;
Y2 = RAYlocdata.Y2;
Rayname = RAYlocdata.Ray;

%------------read pro data------------
z_min = PROdata.zmin;
z_max = PROdata.zmax;
z_limits = [z_min z_max];
h_dynbound = PROdata.hdynbound;
water_level = PROdata.waterlevel;
z_dynbound = -h_dynbound+water_level;

%------------adjust z_dynbound if single value is specified--------------
if length(z_dynbound)<length(X1)
    z_dynbound = repmat(z_dynbound,[length(X1),1]);
end

%------------read xyz data------------
X = XYZdata.X;
Y = XYZdata.Y;
Z = XYZdata.Z;

%------------initialize output------------
path_out.png = 'PROfigures\';
path_out.pro = 'PROfiles\';
if ~exist(path_out.pro,'dir')
    mkdir(path_out.pro);
end
ray = struct;

legendtext = {'original samples',...
              'reduced sample set (smallest distance to sample only)',...
              'resampled profile 1 (1st order)',...
              'resampled profile 2 (2nd order)',...
              'water level',...
              'dynamic boundary'};

%-------------------------------------------------------------------------
%--------------------------------PROGRAM----------------------------------
%-------------------------------------------------------------------------
for ray_no = 1 : length(X1)
    
    %----settings profile schematisation-----
    %----------------------------------------
    minimum_no_points_truncation    = 10;    % minimum number of points before truncation above a specified level
    max_distance_between_gridpoints = 4;    % the specified ray (e.g. 2 points) is densified with this discretisation step 
    max_dist_from_line_factor       = 2;     % 'nearest depth samples' are only included if distance between sample is smaller than 'this factor' x 'gridcellsize'
    z_stepsize                      = 1;     % the stepsize in z-direction of the resampled cross-shore profile (determining the schematised number of depth points)
    resample_refine_factor          = 1;     % calibration parameter: profile is resampled to 'resample_refine_factor' times the 'no_samples' in the preprocessing of the profile schematisation (note: set to 1 to cancel preprocessing) 
    %not implemented yet :   truncation_depth = 4;    % depth larger than ..m not included in the resampling (note: if depth is defined as a bottom level a negative value should be used)
    no_samples = 20;           %calibration parameter: number of steps in x-direction for initial horizontal discretisation
  
    %-----------------interpolate samples-----------------
    ray.X0{ray_no} = [X1(ray_no);X2(ray_no)];
    ray.Y0{ray_no} = [Y1(ray_no);Y2(ray_no)];
    xy0 = add_equidist_Points(max_distance_between_gridpoints,[ray.X0{ray_no},ray.Y0{ray_no}]);
    xy0 = [xy0(2:end-1,1) , xy0(2:end-1,2)];
    ray.X1{ray_no} = xy0(:,1);
    ray.Y1{ray_no} = xy0(:,2);

    %--------get sample point for each grid point---------
    %-----------------------------------------------------
    for xloc = 1: size(ray.X1{ray_no},1)
        dx   = X - ray.X1{ray_no}(xloc);
        dy   = Y - ray.Y1{ray_no}(xloc);
        dist = sqrt(dx.^2+dy.^2);
        id2  = find(dist==min(min(dist)));
        idn  = ceil(id2/size(X,1));
        idm  = mod(id2,size(X,1));

        ray.Z1{ray_no}(xloc)   = Z(idm,idn);
        ray.dist2sample1{ray_no}(xloc) = dist(idm,idn);
    end    
    
    %----select only those depthsamples closest to ray----
    %-----------------------------------------------------
    for iii=1:size(ray.Z1{ray_no},2)
        id3 = find(ray.Z1{ray_no} == ray.Z1{ray_no}(iii));
        unique_id(iii) = find(ray.dist2sample1{ray_no} == min(ray.dist2sample1{ray_no}(id3)));
    end
    dist_offset = (unique_id(1)-1)*max_distance_between_gridpoints;
    ray.X2{ray_no}   = ray.X1{ray_no}(unique(unique_id));
    ray.Y2{ray_no}   = ray.Y1{ray_no}(unique(unique_id));
    ray.Z2{ray_no}   = ray.Z1{ray_no}(unique(unique_id))';
    ray.dist2sample2{ray_no} = ray.dist2sample1{ray_no}(unique(unique_id));
    
    %------remove sample points far away from line--------
    %-----------------------------------------------------
    max_distance_from_line = max_dist_from_line_factor * sqrt( (X(2)-X(1)).^2 + (Y(2)-Y(1)).^2);
    
    if exist('max_distance_from_line','var')
        id4      = find(ray.dist2sample2{ray_no} < max_distance_from_line);
        ray.X2{ray_no}    = ray.X2{ray_no}(id4);
        ray.Y2{ray_no}    = ray.Y2{ray_no}(id4);
        ray.Z2{ray_no}    = ray.Z2{ray_no}(id4)';
        ray.dist2sample2{ray_no} = ray.dist2sample2{ray_no}(id4);
    end

    %--------determine sample size for each grid----------
    %-----------------------------------------------------
    samplesize{ray_no} = size(ray.Z2{ray_no},2);
    
    %------------Compute cross-shore distance-------------
    %-----------------------------------------------------
    ray.distcross2{ray_no}=[];
    ray.distcross3{ray_no}=[];
    ray.distcross3B{ray_no}=[];
    ray.Z3{ray_no} = [];
    ray.Z3B{ray_no} = [];
    [ray.distcross1{ray_no}]=distXY(ray.X1{ray_no},ray.Y1{ray_no});
    if size(ray.Z2{ray_no},2)>1
        [ray.distcross2{ray_no}]=distXY(ray.X2{ray_no},ray.Y2{ray_no},dist_offset);

        %-----------------Schematise profile------------------
        %-----------------------------------------------------
        id_deep = find(ray.Z2{ray_no}==max(ray.Z2{ray_no}));
        id_land = find(ray.Z2{ray_no}==min(ray.Z2{ray_no}));
        %if id1(1)>id_land(1)
        %id3 = find(ray.Z2{ray_no}<truncation_depth);
        %id_sorted=sort( ismember([id3(1),id2(1)],[id1(1),id2(1)]));
        id_sorted=sort([id_deep;id_land]);

        xdata  = ray.distcross2{ray_no}(id_sorted(1):id_sorted(2));
        zdata  = ray.Z2{ray_no}(id_sorted(1):id_sorted(2));

        if ~isempty(z_limits) && length(xdata)>minimum_no_points_truncation
            id_truncate = find(zdata < -z_limits(1) & zdata > -z_limits(2));
            xdata = xdata(id_truncate);
            zdata = zdata(id_truncate);
        end
        
        % ------ pre-processing with fine resolution ----
        xnew                       = [min(xdata):round((max(xdata)-min(xdata))/no_samples):max(xdata)];
        znew                       = [min(zdata):z_stepsize/resample_refine_factor:max(zdata)];
        if length(zdata)>1
            xnew                   = sort(interp1(zdata,xdata,znew,'cubic'));
        end

        % ------ step 1, horizontal interpolation ----
        ray.distcross3{ray_no}     = xnew;
        ray.Z3{ray_no}             = interp1(xdata,zdata,xnew,'cubic');
        % ------ step 2, vertical interpolation ----            
        znew                       = sort(ray.Z3{ray_no});
        znew                       = [min(znew):z_stepsize:max(znew)];
        xnew                       = sort(interp1(zdata,xdata,znew,'cubic'));
        xdata                      = ray.distcross3{ray_no};
        zdata                      = ray.Z3{ray_no};
        ray.Z3B{ray_no}            = interp1(xdata,zdata,xnew,'cubic'); 
        ray.distcross3B{ray_no}    = xnew;
        
        
    
        %-----------------plot cross-section------------------
        %-----------------------------------------------------
%         hgraph = figure;
%         plot(ray.distcross1{ray_no},ray.Z1{ray_no},'k.');hold on;
%         plot(ray.distcross2{ray_no},ray.Z2{ray_no},'b-');
%         plot(ray.distcross3{ray_no},ray.Z3{ray_no},'r-.');
%         plot(ray.distcross3B{ray_no},ray.Z3B{ray_no},'g--');   
%         
%         %Plot reference lvl and dyn boundary
%         x_dynbound = find0crossing(ray.distcross3B{ray_no},ray.Z3B{ray_no},z_dynbound(ray_no));
%         xlimits = xlim;
%         zlimits = ylim;
%         plot([xlimits(1) xlimits(2)],[water_level water_level],'b--');
%         plot([x_dynbound x_dynbound],[zlimits(1) zlimits(2)],'r--');
% 
%         
%         h_title = title(['xyz file: ',XYZfile,', ray: ',Rayname{ray_no}]);
%         set(h_title,'interpreter','none');
%         h_leg = legend(legendtext{1:length(get(gca,'Children'))});
%         set(h_leg,'FontSize',7,'Location','NorthWest');
%         h_xlabel = xlabel('cross-shore distance (m)');
%         set(h_xlabel,'FontSize',10);
%         h_ylabel = ylabel('z (m) w.r.t. ref level');
%         set(h_xlabel,'FontSize',10);
%         
%         if ~exist(path_out.png,'dir')
%             mkdir(path_out.png);
%         end
%         print(hgraph,'-dpng','-r150','-zbuffer',[path_out.png,Rayname{ray_no},'.png']);
%         close(hgraph)
        %-----------------save cross-section------------------
        %-----------------------------------------------------
        if ~isempty(ray.Z3B{ray_no})
            x1          = ray.distcross3B{ray_no};
            z1          = ray.Z3B{ray_no};
            h1          = z1.*(-1)+water_level;    %Convert bed level to water depth
            Xid1        = X1(ray_no);
            Yid1        = Y1(ray_no);
            Xid2        = X2(ray_no);
            Yid2        = Y2(ray_no);
            filename    = [path_out.pro,Rayname{ray_no},'.pro'];
            [err_message,x1,z1,h1,x_dynbound] = writePRO(x1,h1,h_dynbound,Xid1,Yid1,Xid2,Yid2,filename,water_level);
            if ~isempty(err_message)
                fprintf(fid2,'%s\n',err_message);
            end
            PROdata(ray_no).X1 = Xid1;
            PROdata(ray_no).Y1 = Yid1;
            PROdata(ray_no).X2 = Xid2;
            PROdata(ray_no).Y2 = Yid2;
            PROdata(ray_no).x = x1;
            PROdata(ray_no).h = h1;
            PROdata(ray_no).z = z1;
            PROdata(ray_no).waterlevel = water_level;
            PROdata(ray_no).zmin = z_min;
            PROdata(ray_no).zmax = z_max;
            PROdata(ray_no).zdynbound = z_dynbound(ray_no);
            PROdata(ray_no).xdynbound = x_dynbound;
            PROdata(ray_no).xtrunctransp = x_dynbound;
            PROdata(ray_no).filename = filename;
            PROdata(ray_no).Rayname = Rayname{ray_no};        
        end
        
    end
    clear dx dy dist id2 idn idm id3 unique_id dist_offset
end
ray = orderfields(ray, {'X0', 'Y0', 'X1', 'Y1', 'Z1', 'distcross1', 'dist2sample1', 'X2', 'Y2', 'Z2', 'distcross2', 'dist2sample2', 'Z3', 'distcross3', 'Z3B', 'distcross3B'});