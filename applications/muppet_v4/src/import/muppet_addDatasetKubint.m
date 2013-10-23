function varargout=muppet_addDatasetKubint(varargin)

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

dataset.fid=fid;

sz=fid.Field(1).Size;

par=[];
par=muppet_setDefaultParameterProperties(par);
par.name='Area';
par.size=[0 0 0 0 0];
dataset.parameters(1).parameter=par;

par=[];
par=muppet_setDefaultParameterProperties(par);
par.name='Volume';
par.size=[0 0 0 0 0];
dataset.parameters(2).parameter=par;

par=[];
par=muppet_setDefaultParameterProperties(par);
par.name='Average';
par.size=[0 0 0 0 0];
dataset.parameters(3).parameter=par;

dataset.tekaltype='kubint';

%%
function dataset=import(dataset)

fid=dataset.fid;

switch lower(dataset.parameter)
    case{'area'}
        dataset.z=fid.Field.Data(:,2);
    case{'volume'}
        dataset.z=fid.Field.Data(:,3);
    case{'average'}
        dataset.z=fid.Field.Data(:,4);
end

dataset.x=[1e9 -1e9];
dataset.y=[1e9 -1e9];

tekpol=tekal('read',dataset.polygonfile);
for ipol=1:length(tekpol.Field)
    dataset.polygon(ipol).name=tekpol.Field(ipol).Name;
    dataset.polygon(ipol).x=tekpol.Field(ipol).Data(:,1);
    dataset.polygon(ipol).y=tekpol.Field(ipol).Data(:,2);
    dataset.x(1)=min(min(dataset.polygon(ipol).x),dataset.x(1));
    dataset.x(2)=max(max(dataset.polygon(ipol).x),dataset.x(2));
    dataset.y(1)=min(min(dataset.polygon(ipol).y),dataset.y(1));
    dataset.y(2)=max(max(dataset.polygon(ipol).y),dataset.y(2));
end

dataset.type='kubint';
