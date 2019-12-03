%BEDCOMPOSITION Bed composition class
%   BDC = bedcomposition
%   BDC.initialize
%   BDC.fractions(SEDTYP,D50,LOGSEDSIG,RHO)
%   DZ = BDC.deposit(MASS)
%   MASS = BDC.remove_thickness(DZ)
%   BDC.delete
%
%   BEDCOMPOSITION.version
%   BEDCOMPOSITION.unload
%
%   At most 100 bedcomposition object allowed at the same time
%
%   Properties can be set pre- or post-initialization.
%
%                                    SET   SET
%   PROPERTY NAME                    PRE   POST  GET
%   number_of_columns                 x     -     x
%   number_of_fractions               x     -     x
%   bed_layering_type                 x     -     x
%   number_of_layers                  -     -     x
%   thickness_of_transport_layer      -     x     x
%   number_of_lagrangian_layers       x     -     x
%   thickness_of_lagrangian_layers    x     x     x
%   number_of_eulerian_layers         x     -     x
%   thickness_of_eulerian_layers      x     x     x
%   base_layer_updating_type          x     -     x
%   diffusion_model_type              x     -     x
%   number_of_diffusion_values        x     -     x
%   diffusion_levels                  x     -     x
%   diffusion_coefficients            x     -     x
%   flufflayer_model_type             x     -     x
%   burial_coeff_1                    x     -     x
%   burial_coeff_2                    x     -     x
%   layer_thickness                   -     -     x
%   layer_mass                        -     -     x
%   porosity                          -     -     x
%   volume_fraction                   -     -     x
%   mass_fraction                     -     -     x
%-------------------------------------------------------------------------------
%  $Id: bedcomposition.m 9932 2014-01-06 08:28:09Z hoonhout $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/bedcomposition.m $
%-------------------------------------------------------------------------------

classdef bedcomposition < handle
    
    properties(SetAccess = private, Transient)
        ObjectHandle
    end
    
    properties
        number_of_columns = 0
        number_of_fractions = 0
        bed_layering_type = 1
        number_of_lagrangian_layers = 0
        number_of_eulerian_layers = 0
        thickness_of_transport_layer = 0;
        thickness_of_lagrangian_layers = 0;
        thickness_of_eulerian_layers = 0;
        base_layer_updating_type = 1;
        diffusion_model_type = 0;
        number_of_diffusion_values = 0;
        diffusion_levels
        diffusion_coefficients
        flufflayer_model_type = 0;    
        burial_coeff_1
        burial_coeff_2
    end
    
    properties(Dependent)
        number_of_layers
    end
    
    properties(Access = private, Transient)
        initialized = false
    end
    
    methods(Static)
        function [id,url,prec] = version
            blank = repmat(' ',1,1024);
            [id,url,prec] = bcmcall('version',blank,blank,0);
            id  = deblank(id);
            url = deblank(url);           
        end
        
        function unload
            bcmcall('unload')
        end
    end
    
    methods
        function this = bedcomposition
            this.ObjectHandle = bcmcall('new');
        end
        
        function delete(this)
            if bcmcall(this,'finalize')
                error('Unable to destroy object')
            end
            this.ObjectHandle = 0;
        end
        
        function bool = isinitialized(this)
            bool = this.initialized;
        end
        
        function set.number_of_columns(this,val)
            if this.isinitialized
                error('Property cannot be changed after initialization')
            elseif ~isPosInt(val)
                error('Number of columns must be positive integer')
            end
            val = double(val);
            this.number_of_columns = val;
            if bcmcall(this,'set_intpar','number_of_columns',val)
                error('Unable to set number of columns')
            end
        end
        
        function set.number_of_fractions(this,val)
            if this.isinitialized
                error('Property cannot be changed after initialization')
            elseif ~isPosInt(val)
                error('Number of fractions must be positive integer')
            end
            val = double(val);
            this.number_of_fractions = val;
            if bcmcall(this,'set_intpar','number_of_fractions',val)
                error('Unable to set number of sediment fractions')
            end
        end
        
        function set.bed_layering_type(this,val)
            if this.isinitialized
                error('Property cannot be changed after initialization')
            elseif ~isequal(val,1) && ~isequal(val,2)
                error('Bed layering type should be 1 or 2')
            end
            val = double(val);
            this.bed_layering_type = val;
            if bcmcall(this,'set_intpar','bed_layering_type',val)
                error('Unable to set bed layering type')
            end
        end
        
        function set.base_layer_updating_type(this,val)
            if this.isinitialized
                error('Property cannot be changed after initialization')
            elseif ~isequal(val,1) && ~isequal(val,2) && ~isequal(val,3) && ~isequal(val,4)
                error('Bed layering type should be 1, 2, 3 or 4')
            end
            val = double(val);
            this.base_layer_updating_type = val;
            if bcmcall(this,'set_intpar','base_layer_updating_type',val)
                error('Unable to set base layer updating type')
            end
        end
        
        function set.thickness_of_transport_layer(this,val)
            if ~this.isinitialized
                error('Property cannot be changed before initialization')
            elseif ~isPosRealArray(val)
                error('Thickness of transport layer must be positive')
            end
            this.thickness_of_transport_layer = val;
            if bcmcall(this,'set_realpar1d','thickness_of_transport_layer',val)
                error('Unable to set thickness of transport layer')
            end
        end
        
        function set.number_of_lagrangian_layers(this,val)
            if this.isinitialized
                error('Property cannot be changed after initialization')
            elseif ~isPosInt(val)
                error('Number of lagrangian layers must be zero or positive integer')
            end
            this.number_of_lagrangian_layers = val;
            if bcmcall(this,'set_intpar','number_of_lagrangian_layers',val)
                error('Unable to set number of lagrangian layers')
            end
        end
        
        function set.thickness_of_lagrangian_layers(this,val)
            if ~isPosReal(val)
                error('Thickness of lagrangian layers must be positive')
            end
            this.thickness_of_lagrangian_layers = val;
            if bcmcall(this,'set_realpar','thickness_of_lagrangian_layers',val)
                error('Unable to set thickness of lagrangian layers')
            end
        end
        
        function set.number_of_eulerian_layers(this,val)
            if this.isinitialized
                error('Property cannot be changed after initialization')
            elseif ~isPosInt(val)
                error('Number of eulerian layers must be zero or positive integer')
            end
            this.number_of_eulerian_layers = val;
            if bcmcall(this,'set_intpar','number_of_eulerian_layers',val)
                error('Unable to set number of eulerian layers')
            end
        end
        
        function set.thickness_of_eulerian_layers(this,val)
            if ~isPosReal(val)
                error('Thickness of eulerian layers must be positive')
            end
            this.thickness_of_eulerian_layers = val;
            if bcmcall(this,'set_realpar','thickness_of_eulerian_layers',val)
                error('Unable to set thickness of eulerian layers')
            end
        end
                
        function set.diffusion_model_type(this,val)
            if this.isinitialized
                error('Property cannot be changed after initialization')
            end
            if ~isequal(val,0) && ~isequal(val,1) && ~isequal(val,2)
                error('Diffusion model type should be 0, 1 or 2')
            end
            this.diffusion_model_type = val;
            if bcmcall(this,'set_intpar','diffusion_model_type',val)
                error('Unable to set diffusion model type')
            end
        end
        
        function set.number_of_diffusion_values(this,val)
            if this.isinitialized
                error('Property cannot be changed after initialization')
            end
            if ~mod(val,1)==0 || ~val>0 
                error('Number of diffusion values should be a positive integer')
            end
            this.number_of_diffusion_values = val;
            if bcmcall(this,'set_intpar','number_of_diffusion_values',val)
                error('Unable to set number of diffusion values')
            end
        end
        
        function set.diffusion_levels(this,val)
            if ~isnumeric(val) ...
                    || ~isequal(length(val),this.number_of_diffusion_values) ...
                    || any(val<0)
                error('diffusion_levels array should be a vector array of %i positive values', ...
                    this.number_of_diffusion_values)
            end
            this.diffusion_levels = val;
            if bcmcall(this,'set_realpar1d','diffusion_levels',val)
                error('Unable to set diffusion levels')
            end
        end       
        
        function set.diffusion_coefficients(this,val)
            if ~isnumeric(val) ...
                    || ~isequal(size(val), ...
                    [this.number_of_diffusion_values this.number_of_columns])
                error('diffusion coefficients array should be %i x %i numeric array', ...
                    this.number_of_diffusion_values,this.number_of_columns)
            end
            this.diffusion_coefficients = val;
            if bcmcall(this,'set_realpar2d','diffusion_coefficients',val,this.number_of_diffusion_values, this.number_of_columns)
                error('Unable to set diffusion coefficients')
            end
        end
        
        function set.flufflayer_model_type(this,val)
            if this.isinitialized
                error('Property cannot be changed after initialization')
            elseif ~isequal(val,0) && ~isequal(val,1) && ~isequal(val,2)
                error('Flufflayer model type should be 0, 1 or 2')
            end
            this.flufflayer_model_type = val;
            if bcmcall(this,'set_intpar','flufflayer_model_type',val)
                error('Unable to set flufflayer model type')
            end
        end
        
        function set.burial_coeff_1(this,val)
            if ~this.flufflayer_model_type==1
                error('First burial coefficient can only be used in flufflayer model type 1')
            end
            if ~isnumeric(val) ...
                    || ~isequal(size(val), ...
                    [this.number_of_fractions this.number_of_columns])
                error('First burial coefficient array should be %i x %i numeric array', ...
                    this.number_of_fractions,this.number_of_columns)
            end
            this.burial_coeff_1 = val;
            if bcmcall(this,'set_realpar','bfluff0',val)
                error('Unable to set first burial coefficient')
            end
        end
        
        function set.burial_coeff_2(this,val)
            if ~this.flufflayer_model_type==1
                error('Second burial coefficient can only be used in flufflayer model type 1')
            end
            if ~isnumeric(val) ...
                    || ~isequal(size(val), ...
                    [this.number_of_fractions this.number_of_columns])
                error('Second burial coefficient array should be %i x %i numeric array', ...
                    this.number_of_fractions,this.number_of_columns)
            end
            this.burial_coeff_2 = val;
            if bcmcall(this,'set_realpar','bfluff1',val)
                error('Unable to set second burial coefficient')
            end
        end
        
        function val = get.number_of_layers(this)
            if this.bed_layering_type==1
                val = 1;
            else
                val = 2 + this.number_of_eulerian_layers ...
                    + this.number_of_lagrangian_layers;
            end
        end
        
        function val = layer_thickness(this,layers,columns)
            if nargin==1
                layers = ':';
                columns = ':';
            end
            [istat,val] = get_field3d(this,'thickness',1,layers,columns);
            val = permute(val,[2 3 1]);
            if istat~=0
                error('Unable to obtain layer thickness values')
            end
        end
        
        function val = layer_mass(this,fractions,layers,columns)
            if nargin==1
                fractions = ':';
                layers = ':';
                columns = ':';
            end
            [istat,val] = get_field3d(this,'mass',fractions,layers,columns);
            if istat~=0
                error('Unable to obtain layer mass values')
            end
        end
                
        function val = fluff_mass(this,fractions,columns)
            if this.flufflayer_model_type==0
                error('no flufflayer is modeled')
            end
            if nargin==1
                fractions = ':';
                columns = ':';
            end
            [istat,val] = get_field3d(this,'massfluff',fractions,1,columns);
            val = permute(val,[1 3 2]);
            if istat~=0
                error('Unable to obtain flufflayer mass values')
            end
        end
        
        function val = porosity(this,layers,columns)
            if nargin==1
                layers = ':';
                columns = ':';
            end
            [istat,val] = get_field3d(this,'porosity',1,layers,columns);
            val = permute(val,[2 3 1]);
            if istat~=0
                error('Unable to obtain porosity values')
            end
        end
        
        function val = volume_fraction(this,fractions,layers,columns)
            if nargin==1
                fractions = ':';
                layers = ':';
                columns = ':';
            end
            [istat,val] = get_field3d(this,'volume_fractions',fractions,layers,columns);
            if istat~=0
                error('Unable to obtain volume fraction values')
            end
        end
        
        function val = mass_fraction(this,fractions,layers,columns)
            if nargin==1
                fractions = ':';
                layers = ':';
                columns = ':';
            end
            [istat,val] = get_field3d(this,'mass_fractions',fractions,layers,columns);
            if istat~=0
                error('Unable to obtain mass fraction values')
            end
        end
        
        function init_layer_thickness(this,val,layers,columns)
            if nargin==2
                layers = ':';
                columns = ':';
            end
            istat = set_field3d(this,val,'thickness',1,layers,columns);
            if istat~=0
                error('Unable to initialize layer thickness values')
            end
        end
        
        function init_layer_mass(this,val,fractions,layers,columns)
            if nargin==2
                fractions = ':';
                layers = ':';
                columns = ':';
            end
            istat = set_field3d(this,val,'mass',fractions,layers,columns);
            if istat~=0
                error('Unable to initialize layer mass values')
            end
        end
        
        function init_fluff_mass(this,val,fractions,columns)
            if this.flufflayer_model_type==0
                error('no flufflayer is modeled')
            end
            if nargin==2
                fractions = ':';
                columns = ':';
            end
            istat = set_field3d(this,val,'massfluff',fractions,1,columns);
            if istat~=0
                error('Unable to initialize flufflayer mass values')
            end
        end
                
        function init_porosity(this,val,layers,columns)
            if nargin==2
                layers = ':';
                columns = ':';
            end
            istat = set_field3d(this,val,'porosity',1,layers,columns);
            if istat~=0
                error('Unable to initialize porosity values')
            end
        end
              
        
        function disp(this)
            fprintf('  Bed composition object %i',this.ObjectHandle);
            if this.isinitialized
                fprintf(' (initialized)\n');
            else
                fprintf(' (not yet initialized)\n');
            end
            fprintf('    number_of_columns             : %i\n',this.number_of_columns);
            fprintf('    number_of_fractions           : %i\n',this.number_of_fractions);
            fprintf('    bed_layering_type             : %i\n',this.bed_layering_type);
            fprintf('    base_layer_updating_type      : %i\n',this.base_layer_updating_type);
            if this.bed_layering_type==2
                fprintf('    number_of_layers              : %i\n',this.number_of_layers);
                fprintf('    thickness_of_transport_layer  : %g\n',this.thickness_of_transport_layer);
                fprintf('    number_of_lagrangian_layers   : %i\n',this.number_of_lagrangian_layers);
                fprintf('    thickness_of_lagrangian_layers: %g\n',this.thickness_of_lagrangian_layers);
                fprintf('    number_of_eulerian_layers     : %i\n',this.number_of_eulerian_layers);
                fprintf('    thickness_of_eulerian_layers  : %g\n',this.thickness_of_eulerian_layers);
                fprintf('    diffusion_model_type          : %g\n',this.diffusion_model_type);
                if this.diffusion_model_type>0
                fprintf('    number_of_diffusion_values    : %g\n',this.number_of_diffusion_values);
                end
                fprintf('    flufflayer_model_type         : %g\n',this.flufflayer_model_type);
            end
        end
        
        function initialize(this)
            if this.number_of_columns == 0
                error('Number of columns should not equal 0 upon initialization')
            elseif this.number_of_fractions == 0
                error('Number of fractions should not equal 0 upon initialization')
            end
            if bcmcall(this,'initialize')
                error('Unable to initialize')
            end
            this.initialized = true;
        end
        function dz = deposit(this,mass,dt,rhosol,massfluff,morfac)
            if nargin<4
                dt     = 0.0;
                rhosol = zeros(1,this.number_of_fractions);
            end
            if nargin<5
                massfluff = 0.0*mass;
                morfac = 1.0;
            end
            if ~isnumeric(mass) ...
                    || ~isequal(size(mass), ...
                    [this.number_of_fractions this.number_of_columns])
                error('Mass array should be %i x %i numeric array', ...
                    this.number_of_fractions,this.number_of_columns)
            end
            if ~isnumeric(massfluff) ...
                    || ~isequal(size(massfluff), ...
                    [this.number_of_fractions this.number_of_columns])
                error('Massfluff array should be %i x %i numeric array', ...
                    this.number_of_fractions,this.number_of_columns)
            end
            if ~isnumeric(rhosol) ...
                    || ~isequal(size(rhosol), ...
                    [1 this.number_of_fractions])
                error('rhosol array should be 1 x %i numeric array', ...
                    this.number_of_fractions)
            end
            if ~isnumeric(dt) ...
                    || dt<0
                error('dt should be a positive numeric value')
            end
            if ~isnumeric(morfac) ...
                    || morfac<0
                error('morfac should be a positive numeric value')
            end
            dz = zeros(1,this.number_of_columns);
            [istat,~,~,~,~,~,~,dz] = bcmcall(this,'deposit_mass',mass,massfluff,rhosol,dt,morfac,dz, ...
                this.number_of_fractions,this.number_of_columns);
            if istat~=0
                error('Unable to deposit mass')
            end
        end
        
        function mass = remove_thickness(this,dz)
            if ~isnumeric(dz) ...
                    || ~isequal(length(dz),this.number_of_columns) ...
                    || any(dz<0)
                error('DZ array should be a vector array of %i positive values', ...
                    this.number_of_columns)
            end
            mass = zeros(this.number_of_fractions,this.number_of_columns);
            [istat,~,mass] = bcmcall(this,'remove_thickness',mass,dz, ...
                this.number_of_fractions,this.number_of_columns);
            if istat~=0
                error('Unable to remove sediment')
            end
        end
        
        function fractions(this,sedtyp,d50,logsigma,rho)
            if ~isnumeric(sedtyp) ...
                    || ~isequal(length(sedtyp),this.number_of_fractions) ...
                    || any(~ismember(sedtyp,[0 1 2]))
                error('Invalid sediment type array')
            end
            if ~isnumeric(d50) ...
                    || ~isequal(length(d50),this.number_of_fractions) ...
                    || any(d50<0)
                error('Invalid sediment diameter array')
            end
            if ~isnumeric(logsigma) ...
                    || ~isequal(length(logsigma),this.number_of_fractions) ...
                    || any(logsigma<0)
                error('Invalid sediment diameter sigma array')
            end
            if ~isnumeric(rho) ...
                    || ~isequal(length(rho),this.number_of_fractions) ...
                    || any(rho<0)
                error('Invalid sediment density array')
            end
            if bcmcall(this,'set_fraction_properties', ...
                    sedtyp,d50,logsigma,rho,this.number_of_fractions)
                error('Unable to set sediment fraction properties')
            end
        end
        
        
        function messages(this)
            if bcmcall(this,'messages')
                error('Unable to write messages')
            end
        end
        
    end
end

function bool = isPosInt(val)
bool = isnumeric(val) && ...
    isequal(size(val),[1 1]) && ...
    val>=0 && ...
    isequal(val,round(val));
end

function bool = isPosReal(val)
bool = isnumeric(val) && ...
    isequal(size(val),[1 1]) && ...
    val>=0;
end

function bool = isPosRealArray(val)
bool = isnumeric(val) && ...
    isvector(val) && ...
    all(val>=0);
end

function bool = isIntInRange(val,minval,maxval)
bool = isnumeric(val) && ...
    all(val>=minval & val<=maxval) && ...
    all(val==round(val));
end

function [istat,fld] = get_field3d(this,var,fractions,layers,columns)
if isequal(fractions,':')
    fractions = 1:this.number_of_fractions;
elseif ~isIntInRange(fractions,1,this.number_of_fractions)
    error('Fraction index should be integer between 1 and %i',this.number_of_fractions)
end
if isequal(layers,':')
    layers = 1:this.number_of_layers;
elseif ~isIntInRange(layers,1,this.number_of_layers)
    error('Layer index should be integer between 1 and %i',this.number_of_layers)
end
if isequal(columns,':')
    columns = 1:this.number_of_columns;
elseif ~isIntInRange(columns,1,this.number_of_columns)
    error('Column index should be integer between 1 and %i',this.number_of_columns)
end
fld=zeros(length(fractions),length(layers),length(columns));
[istat,~,fld] = bcmcall(this,'get_layer',fld,var, ...
    fractions,layers,columns,length(fractions),length(layers),length(columns));
fld=reshape(fld,[length(fractions),length(layers),length(columns)]);
end

function [istat] = set_field3d(this,val,var,fractions,layers,columns)
if isequal(fractions,':')
    fractions = 1:this.number_of_fractions;
elseif ~isIntInRange(fractions,1,this.number_of_fractions)
    error('Fraction index should be integer between 1 and %i',this.number_of_fractions)
end
if isequal(layers,':')
    layers = 1:this.number_of_layers;
elseif ~isIntInRange(layers,1,this.number_of_layers)
    error('Layer index should be integer between 1 and %i',this.number_of_layers)
end
if isequal(columns,':')
    columns = 1:this.number_of_columns;
elseif ~isIntInRange(columns,1,this.number_of_columns)
    error('Column index should be integer between 1 and %i',this.number_of_columns)
end
[istat,~,~] = bcmcall(this,'set_layer',val,var, ...
    fractions,layers,columns,length(fractions),length(layers),length(columns));
end

function varargout = bcmcall(varargin)
%BCMCALL Call Deltares Delft3D bedcomposition module

arguments = varargin;
lib = LibName;
if ischar(arguments{1})
    cmd = upper(arguments{1});
    if isequal(cmd,'UNLOAD')
        unloadlibrary(lib)
        return
    end
elseif nargin>=2 && ischar(arguments{2})
    cmd = upper(arguments{2});
    arguments{2} = arguments{1};
    if isa(arguments{2},'bedcomposition')
        arguments{2} = arguments{2}.ObjectHandle;
    end
else
    error('Can''t determine DBC command to call')
end
arguments{1} = [LibPrefix cmd];
if isunix
    arguments{1} = lower(arguments{1});
end
if ~libisloaded(lib)
    LoadLibrary(lib)
end
charargs = cellfun(@ischar,arguments);
charargs(1)=false;
if any(charargs)
    lengths = num2cell(cellfun(@length,arguments(charargs)));
    arguments = [arguments lengths];
    arguments(charargs) = upper(arguments(charargs));
end
if nargout>0
    varargout = cell(1,nargout);
    %fprintf('Calling: %s\nFunction: %s\n',lib,arguments{1});
    [varargout{:}] = calllib(lib,arguments{:});
else
    calllib(lib,arguments{:});
end
end

function LoadLibrary(lib)
if libisloaded(lib)
    return
end
if ismac
    dll = [lib '.dylib'];
elseif isunix
    dll = [lib '.so'];
else
    dll = [lib '.dll'];
end
loadlibrary(dll,LibH)
end

function nm=LibName
if isunix
    nm='libbedcomposition_module';
else
    nm='bedcomposition_module';
end
end

function nm=LibH
if ismac
    nm='bedcomposition_interface.macosx.h';
elseif isunix
    nm='bedcomposition_interface.macosx.h';
else
    nm='bedcomposition_interface.h';
end
end

function nm=LibPrefix
nm='DBC_';
end
