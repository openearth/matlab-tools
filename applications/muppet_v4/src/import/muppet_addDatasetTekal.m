function varargout=muppet_addDatasetTekal(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'read'}
                % Read file data
                dataset=varargin{ii+1};
                parameter=[];
                if length(varargin)==3
                    parameter=varargin{ii+1};
                end
                dataset=read(dataset,parameter);
                varargout{1}=dataset;                
            case{'import'}
                % Import data
                dataset=varargin{ii+1};
                dataset=import(dataset);
                varargout{1}=dataset;
            case{'gettimes'}
                varargout{1}=[];
        end
    end
end

%%
function dataset=read(dataset,varargin)

try
    fid=tekal('open',dataset.filename);
catch
    disp([dataset.filename ' does not appear to be a valid tekal file!']);    
end

columnlabels=fid.Field(1).ColLabels;

switch lower(columnlabels{1})
    case{'date'}
        tp='timeseries';
end

switch tp
    case{'timeseries'}
        nrows=size(fid.Field(1).Data,1);
        ncols=size(fid.Field(1).Data,2);
        npar=ncols-2;
        nblocks=length(fid.Field);
        dates=fid.Field(1).Data(:,1);
        times=fid.Field(1).Data(:,2);
        years=floor(dates/10000);
        months=floor((dates-years*10000)/100);
        days=dates-years*10000-months*100;
        hours=floor(times/10000);
        minutes=floor((times-hours*10000)/100);
        seconds=times-hours*10000-minutes*100;
        times=datenum(years,months,days,hours,minutes,seconds);
        for ipar=1:npar
            par=[];
            par=muppet_setDefaultParameterDimensions(par);
            par.timesbyblock=1;
            par.block=1;
            par.parametername=columnlabels{ipar+2};
            par.size=[nrows 1 0 0 0];
            par.times=times;
            par.columnlabels=columnlabels;
            par.tekaltype=tp;
            par.nrparameters=npar;
            par.nrstations=nblocks;
            for iblock=1:nblocks
                par.stations{iblock}=fid.Field(iblock).Name;
            end
            par.quantity='scalar';
            if npar>1
                par.nrquantities=3;
                par.quantities={'scalar','vector2d','vector3d'};
            end            
            dataset.parameters(ipar).parameter=par;            
        end
end

%%
function dataset=import(dataset)

fid=tekal('open',dataset.filename);

switch dataset.tekaltype
    case{'timeseries'}
        iblock=strmatch(lower(dataset.station),lower(dataset.stations),'exact');
        dataset.x=dataset.times;
        if isfield(dataset,'ucomponent')
            icolu=strmatch(lower(dataset.ucomponent),lower(dataset.columnlabels),'exact');
            icolv=strmatch(lower(dataset.vcomponent),lower(dataset.columnlabels),'exact');
            dataset.u=fid.Field(iblock).Data(:,icolu);
            dataset.u(dataset.u==999.999)=NaN;
            dataset.u(dataset.u==-999)=NaN;
            dataset.v=fid.Field(iblock).Data(:,icolv);
            dataset.v(dataset.u==999.999)=NaN;
            dataset.v(dataset.u==-999)=NaN;
            dataset.type='timeseriesvector2d';
            dataset.parametername=[];
        else
            icol=strmatch(lower(dataset.parametername),lower(dataset.columnlabels),'exact');
            dataset.y=fid.Field(iblock).Data(:,icol);
            dataset.y(dataset.y==999.999)=NaN;
            dataset.y(dataset.y==-999)=NaN;
            dataset.type='timeseriesscalar';
        end
        dataset.tc='c';
end
