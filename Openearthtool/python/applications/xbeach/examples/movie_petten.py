import xb_3dmoviemaker as xb3dmm

url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/MICORE/public_html/egmond/scenarios/storm_112007/europe/petten/netcdf/pet.20071105_00z_ortho.xb.nc'
#url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/MICORE/public_html/egmond/scenarios/storm_112007/europe/petten/netcdf/pet.20071105_00z_reference.xb.nc'

MM = xb3dmm.XB_3DMovieMaker(url)

MM.set_range(825,10000)

MM.set_margins(0, 3, 3, 3)
MM.set_ratio(6)
MM.set_dir('hyperstorm_marcel2')
MM.set_focalpoint((8422,5206,0))

MM.build_figure()

# start storyboard
'''
# OLD

MM.view(n=1, azimuth=270, elevation=0, inc=0)
MM.view(n=60, elevation=60, inc=0)

MM.view(n=60, azimuth=210)
MM.zoom(n=60, zoom=4)
MM.watch(n=120)

MM.zoom(n=60, zoom=0.25)
MM.watch(n=120)

MM.view(n=30, azimuth=150, elevation=85)
MM.zoom(n=30, zoom=2)
MM.watch(n=180)
MM.zoom(n=30, zoom=0.5)
MM.view(n=30, azimuth=210, elevation=60)
MM.watch(n=420)

MM.view(n=60, azimuth=270, elevation=0, inc=0)
MM.watch(n=30, inc=0)
'''

# NEW

MM.view(n=1, azimuth=180, elevation=0, inc=0)
MM.view(n=30, elevation=60, inc=0)
MM.watch(n=30, inc=0)

MM.watch(n=30)
MM.view(n=30, azimuth=60, elevation=30)
MM.zoom(n=60, zoom=4)
MM.watch(n=120)

MM.zoom(n=60, zoom=0.25)
MM.watch(n=120)

MM.view(n=30, azimuth=60, elevation=85)
MM.zoom(n=30, zoom=1.5)
MM.watch(n=300)
MM.zoom(n=30, zoom=2./3)
MM.view(n=30, azimuth=120, elevation=60)
MM.watch(n=300)

MM.view(n=60, azimuth=180, elevation=0, inc=0)

'''
# TEST

MM.view(n=1, azimuth=180, elevation=0, inc=0)
MM.view(n=1, elevation=60, inc=0)
MM.view(n=1, azimuth=300, elevation=30, inc=0)
MM.zoom(n=1, zoom=4, inc=0)
MM.zoom(n=1, zoom=0.25, inc=0)
MM.view(n=1, azimuth=60, elevation=85, inc=0)
MM.zoom(n=1, zoom=1.5, inc=0)
MM.zoom(n=1, zoom=2./3, inc=0)
MM.view(n=1, azimuth=120, elevation=60, inc=0)
MM.view(n=1, azimuth=180, elevation=0, inc=0)
'''