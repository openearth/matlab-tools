function ok=ExtractSWANNestSpec(dr,outdir,runid,starttime,stoptime,varargin)

convc=0;
if nargin>3
    convc=1;
    hm=varargin{1};
    m1=varargin{2};
    m2=varargin{3};
end

lst=dir([dr runid '*.sp2']);

n=length(lst);

ok=zeros(hm.Models(m2).NrProfiles,1)+1;

for i=1:n
    
    disp(['Processing sp2 file ' num2str(i) ' of ' num2str(n)]);
    
    fname=lst(i).name;
    
    Spec=readSWANSpec([dr fname]);
    
    fname=strrep(fname,' ','');
    
    if convc
        if ~strcmpi(hm.Models(m1).CoordinateSystem,hm.Models(m2).CoordinateSystem) || ~strcmpi(hm.Models(m1).CoordinateSystemType,hm.Models(m2).CoordinateSystemType)
            % Convert coordinates
            [Spec.x,Spec.y]=ConvertCoordinates(Spec.x,Spec.y,'persistent','CS1.name',hm.Models(m1).CoordinateSystem,'CS1.type',hm.Models(m1).CoordinateSystemType,'CS2.name',hm.Models(m2).CoordinateSystem,'CS2.type',hm.Models(m2).CoordinateSystemType);
        end
    end
    
    it=1;
    
    if Spec.Time(it).Time>=starttime && Spec.Time(it).Time<=stoptime
        
        % Writing
        
        for jj=1:hm.Models(m2).NrProfiles
            
            if hm.Models(m2).Profile(jj).Run
                
                name=hm.Models(m2).Profile(jj).Name;
                
                fi2=fopen([outdir name filesep fname],'wt');
                
                fprintf(fi2,'%s\n','SWAN   1                                Swan standard spectral file, version');
                fprintf(fi2,'%s\n','$   Data produced by SWAN version 40.51AB             ');
                fprintf(fi2,'%s\n','$   Project:                 ;  run number:     ');
                fprintf(fi2,'%s\n','TIME                                    time-dependent data');
                fprintf(fi2,'%s\n','     1                                  time coding option');
                if convc
                    switch lower(hm.Models(m2).CoordinateSystemType)
                        case{'proj','projection','projected','cart','cartesian','xy'}
                            fprintf(fi2,'%s\n','LOCATIONS');
                        otherwise
                            fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
                    end
                else
                    fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
                end
                fprintf(fi2,'%i\n',1);
                fprintf(fi2,'%15.6f %15.6f\n',Spec.x(jj),Spec.y(jj));
                fprintf(fi2,'%s\n','AFREQ                                   absolute frequencies in Hz');
                fprintf(fi2,'%6i\n',Spec.NFreq);
                for j=1:Spec.NFreq
                    fprintf(fi2,'%15.4f\n',Spec.Freqs(j));
                end
                fprintf(fi2,'%s\n','NDIR                                   spectral nautical directions in degr');
                fprintf(fi2,'%i\n',Spec.NDir);
                for j=1:Spec.NDir
                    fprintf(fi2,'%15.4f\n',Spec.Dirs(j));
                end
                fprintf(fi2,'%s\n','QUANT');
                fprintf(fi2,'%s\n','     1                                  number of quantities in table');
                fprintf(fi2,'%s\n','EnDens                                  energy densities in J/m2/Hz/degr');
                fprintf(fi2,'%s\n','J/m2/Hz/degr                            unit');
                fprintf(fi2,'%s\n','   -0.9900E+02                          exception value');
                
                fprintf(fi2,'%s\n',datestr(Spec.Time(it).Time,'yyyymmdd.HHMMSS'));
                
                if Spec.Time(it).Points(jj).Factor>0
                    fprintf(fi2,'%s\n','FACTOR');
                    fprintf(fi2,'%18.8e\n',Spec.Time(it).Points(jj).Factor);
                    fmt=repmat([repmat('  %7i',1,Spec.NDir) '\n'],1,Spec.NFreq);
                    fprintf(fi2,fmt,Spec.Time(it).Points(jj).Energy');
                else
                    fprintf(fi2,'%s\n','NODATA');
                    ok(jj)=0;
                end
                
                fclose(fi2);
            else
                ok(jj)=0;
            end
        end
    end
end
