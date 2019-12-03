all: \
	rlr_annual.zip \
	rlr_monthly.zip \
	id1-DENHDR.nc \
	etmgeg_235.nc \
	slp.mnmean.real.nc \
	dsea250.1grid.ICE5Gv1.3_VM2_L90_2012.nc \
	psmsl.json \
	stations.l.rdata \
	uwnd.10m.mon.mean.nc \
	vwnd.10m.mon.mean.nc \
	wspd.10m.mon.mean.nc \
	dt_upd_global_merged_msla_h_merged.nc




# PSMSL, mean sealevel
rlr_annual.zip:
	wget -c http://www.psmsl.org/data/obtaining/rlr.annual.data/rlr_annual.zip
rlr_monthly.zip:
	wget -c http://www.psmsl.org/data/obtaining/rlr.monthly.data/rlr_monthly.zip


# High frequency example
id1-DENHDR.nc:
	wget -c http://opendap.deltares.nl/thredds/fileServer/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-DENHDR.nc
etmgeg_235.nc:
	wget -c http://opendap.deltares.nl/thredds/fileServer/opendap/knmi/etmgeg/etmgeg_235.nc


# Inverse barometer correction
slp.mnmean.real.nc:
	wget -c ftp://ftp.cdc.noaa.gov/Datasets.other/hadslp2/slp.mnmean.real.nc

# Same as rad*-1
dsea250.1grid.ICE5Gv1.3_VM2_L90_2012.nc:
	wget -c http://www.atmosp.physics.utoronto.ca/~peltier/datasets/GRID/dsea250.1grid.ICE5Gv1.3_VM2_L90_2012.nc



# See also: http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.derived.surfaceflux.html

vwnd.10m.mon.mean.nc:
	wget -c ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.derived/surface_gauss/vwnd.10m.mon.mean.nc
uwnd.10m.mon.mean.nc:
	wget -c ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.derived/surface_gauss/uwnd.10m.mon.mean.nc
wspd.10m.mon.mean.nc:
	wget -c ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.derived/surface_gauss/wspd.10m.mon.mean.nc

# Satelite measurements of sealevel
dt_upd_global_merged_msla_h_merged.nc:
	wget -c -nd --recursive --accept '*.nc*' ftp://ftp.aviso.oceanobs.com/pub/oceano/AVISO/SSH/climatology/global/monthly_mean_dt_upd
	gunzip -f *.nc.gz
	for f in $(find . -name 'dt_upd_*.nc' -exec basename {} \;);do ncecat -v Grid_0001 $f record_$f; done
	python update_records.py
	ulimit -n 2000
	ncrcat record_*.nc dt_upd_global_merged_msla_h_merged.nc
	rm record_*.nc
# ulimit needed because many files can be open
# TODO: merge

# Processing
psmslsources := psmsl.R
prepare.py: prepare.ipynb 
	ipython nbconvert --to=python prepare.ipynb
records_annual.csv overview.csv: prepare.py uwnd.10m.mon.mean.nc vwnd.10m.mon.mean.nc
	python prepare.py
stations.l.rdata psmsl.json: records_annual.csv overview.csv rlr_annual.zip dsea250.1grid.ICE5Gv1.3_VM2_L90_2012.nc $(psmslsources)
	R CMD BATCH psmsl.R
waterbasesources := waterbase.R
waterbase.json: id1-DENHDR.nc $(waterbasesources)
	R CMD BATCH waterbase.R
