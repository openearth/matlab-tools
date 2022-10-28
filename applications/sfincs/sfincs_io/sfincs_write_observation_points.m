function sfincs_write_observation_points(filename,points,varargin)

cstype='projected';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'cstype'}
                cstype=varargin{ii+1};
        end
    end
end

switch lower(cstype)
    case {'geographic','spherical','deg'}
        fmt='%12.5f %12.5f %s\n';
    otherwise
        fmt='%10.1f %10.1f %s\n';
end

fid=fopen(filename,'wt');
for ip=1:length(points)
    fprintf(fid,fmt,points(ip).x,points(ip).y,['"' points(ip).name '"']);
end
fclose(fid);
