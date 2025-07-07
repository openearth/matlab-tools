%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Convert a set of kml-files to xy-files, changing the coordinate system.
%
%E.G.:
%
% kml2xy(fpath_kml,'epsg_convert',3116,'save_type','separate');
% kml2xy(fpath_kml_2,'epsg_convert',3116,'save_type','together');

function kml2xy(fpath_kml,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'save_type','separate');
addOptional(parin,'epsg_convert',28992);
addOptional(parin,'overwrite',true);

parse(parin,varargin{:});

save_type=parin.Results.save_type;
epsg_convert=parin.Results.epsg_convert;
overwrite=parin.Results.overwrite;

%% CALC

nf=numel(fpath_kml);
switch save_type
    case 'separate'
        for kf=1:nf
            fpath_kml_1=fpath_kml{kf};
            mat=read_1_kml(fpath_kml_1,epsg_convert,overwrite);
            fpath_xyz_c_e=strrep(fpath_kml_1,'.kml',sprintf('_%d.xy',epsg_convert));
            write_2DMatrix(fpath_xyz_c_e,mat,'check_existing',~overwrite);
        end
    case 'together'
        mat_all=[];
        for kf=1:nf
            fpath_kml_1=fpath_kml{kf};
            mat=read_1_kml(fpath_kml_1,epsg_convert,overwrite);
            mat_all=cat(1,mat_all,[NaN,NaN],mat);
        end
        mat_all(1,:)=[]; %remove first [NaN,NaN]
        mat=mat_all;
        fpath_kml_1=fpath_kml{1};
        fpath_xyz_c_e=strrep(fpath_kml_1,'.kml',sprintf('_all_%d.xy',epsg_convert));
        write_2DMatrix(fpath_xyz_c_e,mat,'check_existing',~overwrite);
    otherwise
        error('Unknown type for saving file: %s',save_type)
end

end %function

%%
%% FUNCTION
%%

function mat=read_1_kml(fpath_kml_1,epsg_convert,overwrite)

%call `convert_filetype`
fpath_xyz=strrep(fpath_kml_1,'.kml','.xyz');
EHY_convert(fpath_kml_1,'xyz','outputFile',fpath_xyz,'overwrite',overwrite);
fpath_xyz_c=strrep(fpath_xyz,'.xyz',sprintf('_%d.xyz',epsg_convert));
EHY_convert(fpath_xyz,'xyz','fromEPSG',4326,'toEPSG',epsg_convert,'outputFile',fpath_xyz_c,'overwrite',overwrite);
mat=readmatrix(fpath_xyz_c,'FileType','text');
mat(:,3)=[]; %remove third line of zeros

end %function