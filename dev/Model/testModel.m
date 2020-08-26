%function TestConversion

clear;clc;close all

iLayer = 1;
type = 'delft3d';

%% telemac



switch type
    case 'telemac'
        strFile = 'Z:\projects\11401\Telemac\Deme002\results3D.slf';
        
        [dataset,sctData,varNames] = Telemac.readTelemacHeader(strFile);
        Dataset.showDataset(dataset);
        figure('pos',[100 100 1200 800]);
        
        
        % loop over number of time steps
        for i = 1:10
            sctOptions.start = i;
            dataset = Telemac.readTelemacData(dataset,sctData,varNames,sctOptions);
            quiver(dataset.X.data,dataset.Y.data,dataset.VelX.data(:,iLayer),dataset.VelY.data(:,iLayer));axis equal;
            pause(0.1)
        end;
        
        Dataset.showDataset(dataset);
        
        return;
        
    case 'delft3d'
        %% delft3d
        
        %Alex test
        strFile  = 'Z:\projects\12119\delft3d\test\newRDPmodel2\trim-RDP.dat';
        
        %Kai file (2D, HD)
        %         strFile  = 'Z:\projects\17000_mz\HD\t13\trim-t13.dat';
        
        %Kai file (2D, SED)
        %         strFile  = 'Z:\projects\17000_mz\HD\t13_02\trim-t13_02.dat';
        
        %Kai file (3D,SED)
        %         strFile  = 'Z:\projects\17000_mz\HD\nf_06_refine_sed_3D\trim-near_field_01.dat';
        
        sctOptions = struct;
        Delft3D.showDelft(strFile);
        
        %         sctOptions.varNames = {'VelX', 'VelY', 'TauX', 'TauY', 'WatLev'};
        
        
        
        [dataset,sctStruct] = Delft3D.readDelftHeader(strFile, sctOptions);
        Dataset.showDataset(dataset);
        disp('**********************************************************')
        disp('*                                                        *')
        disp('*                                                        *')
        disp('*                                                        *')
        disp('**********************************************************')
        Dataset.showDataset(sctStruct);
        
        afac = 1000;
        figure('pos',[100 100 1200 800]);
        for i = 1:10
            %             figure;
            sctOptions.start = i;
            dataset = Delft3D.readDelftData(dataset,sctStruct,sctOptions);
            quiver(dataset.X.data(1:3:end,1:3:end),dataset.Y.data(1:3:end,1:3:end),afac.*dataset.VelX.data(1:3:end,1:3:end,iLayer),afac.*dataset.VelY.data(1:3:end,1:3:end,iLayer),0);axis equal;
            title(datestr(dataset.Time.data(i)))
            
            %              temp = find(dataset.X.data(:) > 0);
            %              xmin =  min(dataset.X.data(temp));
            %              xmax = max(dataset.X.data(:));
            %
            %              temp = find(dataset.Y.data(:) > 0);
            %              ymin = min(dataset.Y.data(temp));
            %              ymax = max(dataset.Y.data(:));
            %
            %              xlim([xmin xmax]);
            %              ylim([ymin ymax]);
            
            
            %              xlim([654000 662000]);ylim([980000 999000])
            %             pause()
        end
        
        % trih file
        %Alex test
        strFile  = 'Z:\projects\OFS\MonteVideo\04_runs\000_testruns\20150330105527_run_11889_T\Montevideo_Ocean_GFS\trih-big.dat';
        
        % trih file
        %KAI test (2D, HD)
        %         strFile  = 'Z:\projects\17000_mz\HD\t13\trih-t13.dat';
        
        %KAI test (2D, SED)
        %         strFile  = 'Z:\projects\17000_mz\HD\t13_02\trih-t13_02.dat';
        
        %Kai file (3D,SED)
        %         strFile  = 'Z:\projects\17000_mz\HD\nf_06_refine_sed_3D\trih-near_field_01.dat';
        
        %Delft3D.showDelft(strFile);
        
        %         datasetH2 = Delft3D.readDelftHis(strFile);
        
        %add options to include the data in the hist header
        [datasetH,sctStructH] = Delft3D.readDelftHeader(strFile);
        newDataset2 = Delft3D.readDelftHisData(datasetH,sctStructH);
        Dataset.showDataset(newDataset2);
        
        return;
        
    case 'coherens'
        
        %% cogherens / netcdf
        filename = 'K:\EXCHANGE\BJL\COHERENS\COHERENS_MorphAccerlation\TESTCases_ClosedTidalBasin\3daySim_SL_VanRijn.tsout2N';
        filename2 = 'c:\test\test.nc';
        dataset = Delft3D.readCoherens(filename)
        
end
%
% Delft3D.WriteNetCDF(dataset,filename2)
%
% dataset2 = Delft3D.readIMDC(filename2)