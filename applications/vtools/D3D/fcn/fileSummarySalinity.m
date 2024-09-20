% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Write table with salinity data at stations.
%
%INPUT:
%   -path_f_sal_cmp = file path
%   -station_s = station name; station_s{ksim,1}{ks,1} 
%   -z_mea_s_1 = elevation of each station; z_mea_s_1{ksim,1}{ks,1}
%   -sal_bias_s = bias at each station, elevation, and time limit ; sal_bias_s{ksim,1}{ks,1}{km,1}{klim,1}

function fileSummarySalinity(path_f_sal_cmp,station_s,z_mea_s_1,sal_bias_s,sal_std_s,sal_rmse_s,sal_corr_R_s,ksim,x_lims_v,fid_log)
        
lan='en';

ns=numel(sal_bias_s{ksim,1}); %number of stations
nlim=numel(sal_bias_s{ksim,1}{1,1}{1,1}); %number of time limits

save4mean=[];
% bias_all=[];
% std_all=[];
% rmse_all=[];
% corr_R_all=[];
        
ncol=nlim; %number of top blocks (excuding first for station name): period 1, ... period N
nsubcol=4; %number of subblocks in each block: sbias, std, rmse, rho
str_subcol={' bias [psu]',' std [psu]',' rmse [psu]',' rho [-]'};

lcol_1=50; %characters length of first column (stations)
lsubcol=15; %length of each subblock

lcol=lsubcol*nsubcol; 

%% WRITE

fid=fopen(path_f_sal_cmp,'w');

%% HEADER

    %% periods
str_period=cell(1,nlim);
for klim=1:nlim
    fprintf(fid,'Period %02d: %s - %s \r\n',klim,datestr(x_lims_v(klim,1)),datestr(x_lims_v(klim,2)));
    str_period{1,klim}=sprintf('                          period %02d',klim);
end

    %% line
scat='';

%first column
saux1=cat(2,repmat('-',1,lcol_1-1),'|'); 
scat=cat(2,scat,saux1);

%rest of the columns of subblock
saux1=cat(2,repmat('-',1,lsubcol-1),'|'); 
for kcol=1:ncol
    for ksubcol=1:nsubcol
        scat=cat(2,scat,saux1);
    end
end

%finish
scat=cat(2,scat,' \r\n');

fprintf(fid,scat);

    %% first line
scat='';

%first column
saux1=sprintf('%%-%ds|',lcol_1-1); 
scat=cat(2,scat,saux1);

%rest of the columns of top block
saux1=sprintf('%%-%ds|',lcol-1);
for kcol=1:ncol
scat=cat(2,scat,saux1);
end

%finish
scat=cat(2,scat,' \r\n');

%write
switch lan
    case 'en'
        fprintf(fid,scat,' station',str_period{:});
    case 'nl'
        error('repair')
end

    %% second line
scat='';

%first column
saux1=sprintf('%%-%ds|',lcol_1-1); 
scat=cat(2,scat,saux1);

%rest of the columns of subblock
saux1=sprintf('%%-%ds|',lsubcol-1);
str_total={};
for kcol=1:ncol
    for ksubcol=1:nsubcol
        scat=cat(2,scat,saux1);
    end
    str_total=cat(2,str_total,str_subcol);
end

%finish
scat=cat(2,scat,' \r\n');

%write
switch lan
    case 'en'
        fprintf(fid,scat,' ',str_total{:});
    case 'nl'
        error('repair')
end

%% numbers

    %% top line (stations)
scat='';

%first column
saux1=sprintf('%%-%ds|',lcol_1-1); 
scat=cat(2,scat,saux1);

%rest of the columns of subblocks
saux1=sprintf('%%-%ds|',lsubcol-1);
str_total={};
for kcol=1:ncol
    for ksubcol=1:nsubcol
        scat=cat(2,scat,saux1);
    end
    str_total=cat(2,str_total,repmat({' '},1,nsubcol));
end

%finish
scat=cat(2,scat,' \r\n');

%save
scat_top=scat;
str_total_top=str_total;

    %% numbers line
    
scat='';

%first column
num_length=6;
num_spaces=lcol_1-1-num_length-6;
str_spaces=repmat(' ',1,num_spaces);
saux1=sprintf('%sz = %%+06.2f m|',str_spaces);
scat=cat(2,scat,saux1);

%rest of the columns of subblocks
num_length=6; %length of the number
num_spaces=lsubcol-1-num_length;
str_spaces=repmat(' ',1,num_spaces);
saux1=sprintf('%s%%+06.2f|',str_spaces);
for kcol=1:ncol
    for ksubcol=1:nsubcol
        scat=cat(2,scat,saux1);
    end
end

%finish
scat=cat(2,scat,' \r\n');

%save
scat_num=scat;

    %% write

for ks=1:ns
    fprintf(fid,scat_top,station_s{ksim,1}{ks,1},str_total_top{:});
    nm=numel(z_mea_s_1{ksim,1}{ks,1});
    for km=1:nm
%         num2lim=NaN(ncol,nlim);
        num2lim=NaN(nsubcol,nlim);
        for klim=1:nlim
            num2lim(:,klim)=[sal_bias_s{ksim,1}{ks,1}{km,1}{klim,1};sal_std_s{ksim,1}{ks,1}{km,1}{klim,1};sal_rmse_s{ksim,1}{ks,1}{km,1}{klim,1};sal_corr_R_s{ksim,1}{ks,1}{km,1}{klim,1}];
        end
        num2lim=reshape(num2lim,1,[]);
%         num2print=cat(2,z_mea_s_1{ksim,1}{ks,1}{km,1}{klim,1},num2lim);
        num2print=cat(2,z_mea_s_1{ksim,1}{ks,1}{km,1},num2lim);
        save4mean=cat(1,save4mean,num2lim);
        fprintf(fid,scat_num,num2print);
    end
end %ks

%% total
    %% first line
scat='';

%first column
saux1=cat(2,repmat('-',1,lcol_1-1),'|'); 
scat=cat(2,scat,saux1);

%rest of the columns of subblock
saux1=cat(2,repmat('-',1,lsubcol-1),'|'); 
for kcol=1:ncol
    for ksubcol=1:nsubcol
        scat=cat(2,scat,saux1);
    end
end

%finish
scat=cat(2,scat,' \r\n');

fprintf(fid,scat);

    %% number line

scat='';

%first column
saux1=sprintf('%%-%ds|',lcol_1-1); 
scat=cat(2,scat,saux1);

%rest of the columns of subblocks
num_length=6; %length of the number
num_spaces=lsubcol-1-num_length;
str_spaces=repmat(' ',1,num_spaces);
saux1=sprintf('%s%%+06.2f|',str_spaces);
for kcol=1:ncol
    for ksubcol=1:nsubcol
        scat=cat(2,scat,saux1);
    end
end

%finish
scat=cat(2,scat,' \r\n');

%write
fprintf(fid,scat,'       TOTAL',nanmean(save4mean));

%% CLOSE
fclose(fid);

%% OUT
messageOut(fid_log,sprintf('File saved %s',path_f_sal_cmp));

end %function

%%
%%
%%

% spaces_1=repmat(' ',1,15);
% fid=fopen(path_f_sal_cmp,'w');
% % fprintf(fid,'%-46s |%-15s|%-15s|%-15s|%-15s| \r\n','    ',' bias [psu]',' std [psu]',' rmse [psu]',' rho [-]');
% fprintf(fid,'%-46s |%-15s|%-15s|%-15s|%-15s| \r\n','    ',' bias [psu]',' std [psu]',' rmse [psu]',' rho [-]');
% for ks=1:ns
%     fprintf(fid,'%-46s |%-15s|%-15s|%-15s|%-15s| \r\n',station_s{ksim,1}{ks,1},spaces_1,spaces_1,spaces_1,spaces_1);
%     nm=numel(z_mea_s_1{ksim,1}{ks,1});
%     for km=1:nm
%         fprintf(fid,'                                  z = %+06.2f m |    %+06.2f     |    %+06.2f     |    %+06.2f     |    %+06.2f     | \r\n',z_mea_s_1{ksim,1}{ks,1}{km,1},sal_bias_s{ksim,1}{ks,1}{km,1},sal_bias_s{ksim,1}{ks,1}{km,1},sal_rmse_s{ksim,1}{ks,1}{km,1},sal_corr_R_s{ksim,1}{ks,1}{km,1});
%         bias_all  =cat(1,bias_all  ,sal_bias_s  {ksim,1}{ks,1}{km,1});
%         std_all   =cat(1,std_all   ,sal_std_s   {ksim,1}{ks,1}{km,1});
%         rmse_all  =cat(1,rmse_all  ,sal_rmse_s  {ksim,1}{ks,1}{km,1});
%         corr_R_all=cat(1,corr_R_all,sal_corr_R_s{ksim,1}{ks,1}{km,1});
%     end
% end %ks
% fprintf(fid,'-----------------------------------------------|---------------|---------------|---------------|---------------| \r\n');
% fprintf(fid,'                                        TOTAL  |    %+06.2f     |    %+06.2f     |    %+06.2f     |    %+06.2f     | \r\n',nanmean(bias_all),nanmean(std_all),nanmean(rmse_all),nanmean(corr_R_all));
% fclose(fid);
% 
% end %function