function [hm,m]=CheckForFinishedSimulations(hm)


%% Daemon

f=dir([hm.JobDir filesep 'finished.*']);
m=[];
n=length(f);
if n>0
    fname=[hm.JobDir f(1).name];
    mdl=f(1).name(25:end);
    m=findstrinstruct(hm.Models,'Name',mdl);
end

%% And now H4
if isempty(m)
    for i=1:hm.NrModels
        switch lower(hm.Models(i).Type)
            case{'xbeachcluster'}
                nprfperjob=hm.nrProfilesPerJob;
                njobs=ceil(hm.Models(i).NrProfiles/nprfperjob);
                allready=1;
                for j=1:njobs
                    fname=[hm.JobDir hm.Models(i).Name filesep 'finished' num2str(j) '.txt'];
                    if ~exist(fname,'file')
                        allready=0;
                    end
                end
                if allready
                    m=i;
                    break;
                end
            otherwise
                fname=[hm.JobDir hm.Models(i).Name filesep 'finished.txt'];
                if exist(fname,'file')
                    m=i;
                    break;
                end
        end
    end
end

if ~isempty(m)

    hm.Models(m).SimStart=0;
    hm.Models(m).SimStop=0;
    hm.Models(m).RunDuration=0;

    try

        switch hm.Models(m).Type
            case{'xbeachcluster'}
                startt=0;
                stopt=0;
                for j=1:njobs
                    fname=[hm.JobDir hm.Models(m).Name filesep 'finished' num2str(j) '.txt'];
                    fid=fopen(fname);
                    startstr = fgetl(fid);
                    stopstr = fgetl(fid);
                    fclose(fid);
                    delete(fname);
                    startt=max(datenum(startstr,'yyyymmdd HHMMSS'),startt);
                    stopt =max(datenum(stopstr,'yyyymmdd HHMMSS'),stopt);
                end

            otherwise
                fid=fopen(fname);
                startstr = fgetl(fid);
                stopstr = fgetl(fid);
                fclose(fid);
                delete(fname);

                startt=datenum(startstr,'yyyymmdd HHMMSS');
                stopt =datenum(stopstr,'yyyymmdd HHMMSS');
        end

        hm.Models(m).SimStart=startt;
        hm.Models(m).SimStop=stopt;
        hm.Models(m).RunDuration=(stopt-startt)*86400;

    end

end
