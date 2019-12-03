import xb_3dmoviemaker as xb3dmm

url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/MICORE/public_html/egmond/scenarios/storm_112007/europe/egmond/netcdf/egm.20071105_00z_hardlayers.xb.nc'

MM = xb3dmm.XB_3DMovieMaker(url)

#MM.set_range(600,603)

MM.set_margins(0, 35, 5, 5)
MM.set_ratio(6)
MM.set_dir('egmond')
MM.set_focalpoint((4273,2500,0))
MM.set_distance(25000)
MM.set_warpscale(25)

MM.build_figure()

# start storyboard
MM.view(n=1, azimuth=180, elevation=0, inc=0)
MM.view(n=30, elevation=60, inc=0)
MM.watch(n=30, inc=0)

MM.watch(n=80)
MM.view(n=60, azimuth=60, elevation=30)
MM.watch(n=180)
MM.zoom(n=60, zoom=2)
MM.watch(n=180)

MM.zoom(n=60, zoom=0.5)
MM.watch(n=120)

MM.view(n=30, azimuth=60, elevation=85)
MM.zoom(n=30, zoom=1.25)
MM.watch(n=200)
MM.zoom(n=30, zoom=1./1.25)
MM.view(n=30, azimuth=120, elevation=60)
MM.watch(n=80)

MM.view(n=60, azimuth=180, elevation=0, inc=0)