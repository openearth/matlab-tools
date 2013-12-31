	function [longname, cf_name, deltares_name] = resolve_wns(code,varargin)
%resolve_wns   convert donar code to english long_name, CF standard name, ...
%
%  [longname,cf_name,...] = donar.resolve_wns(code)
%
% resolves DONAR longname "wnsoms" + CF standard name from DONAR datamodel "wnsnum"
% published as web service here (we use csv format as it is smaller and extendable compared to RDF xml):
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=en&action=value&type=wns&order=code
% manually extended with CF compliant standared_names. Loading the cache the 1st
% time is slow, but the internal DB is persistent, so any 2nd time is faster.
%
% To be applied to field WNS from donar.read_header().
%
%See also: resolve_ehd, CF standard_names: http://cf-pcmdi.llnl.gov/documents/cf-standard-names/
% https://data.overheid.nl/data/dataset/rws-donar-metis-service-rijkswaterstaat
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=en

%% source (mind lang=nl or lang=en)
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=nl&action=value&type=wns
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=nl&action=value&type=wns&order=code&format=xml
% http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=nl&action=value&type=wns&order=code&format=txt

% TO DO: add BODC SeaDataNet P01
% TO DO: vectorize

%%

if isnumeric(code)
   code = num2str(code);
end

%% load cache

persistent WNS  % cache this as it takes too long to load many times
if isempty(WNS)
   disp('Loading persistent cache of DONAR variable names ...')
   WNS = csv2struct([fileparts(mfilename('fullpath')),filesep,'wns_en.csv'],'delimiter',';');
end

%%

index = find(strcmpi(WNS.wnsnum,code));
if isempty(index)
    disp(['DONAR wns code not in database cache: ',code])
    disp(['http://live.waterbase.nl/metis/cgi-bin/mivd.pl?lang=en&action=value&type=wns&order=code'])
    error('.')
else
    longname      = WNS.wnsoms{index};
    
    if isfield(WNS,'standard_name')
    cf_name       = WNS.standard_name{index}; % often still empty
    else
    cf_name       = '';
    disp([code,' not mapped to CF standard_name yet.'])
    end
    if isempty(cf_name)
        disp([code,' not mapped to CF standard_name yet.'])
    end     
    
    if isfield(WNS,'deltares_name')
    deltares_name = WNS.deltares_name{index}; % not always present
    else
    deltares_name = '';
    disp([code,' not mapped to Deltares netCDF name yet.'])
    end
    if isempty(deltares_name)
        disp([code,' not mapped to Deltares netCDF name yet.'])
    end    
    
end
