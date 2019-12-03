import xb_3dmoviemaker as xb3dmm

test = True

url = 'p:\\1204473-mississippi\\Models\\XBeach\\runs\\calibration\\run01_large2\\xboutput.nc'

MM = xb3dmm.XB_3DMovieMaker(url, layers=['zb','zs','sedero'])

MM.set_range(0,10000)

MM.set_baseroll(-90)
MM.set_distance(60000)
MM.set_layerdistance(5000)
MM.set_margins(29+5, 70+5, 3, 3)
MM.set_ratio(6)
MM.set_dir('mscip01')
MM.set_focalpoint((315000,3345000,0))

MM.build_figure()

# start storyboard

if not test:

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

else:

    MM.view(n=1, azimuth=-18, elevation=0, inc=0)
    MM.view(n=1, elevation=60, inc=0)
    MM.view(n=1, azimuth=210, elevation=30, inc=0)
    MM.zoom(n=1, zoom=4, inc=0)
    MM.zoom(n=1, zoom=0.25, inc=0)
    MM.view(n=1, azimuth=300, elevation=85, inc=0)
    MM.zoom(n=1, zoom=1.5, inc=0)
    MM.zoom(n=1, zoom=2./3, inc=0)
    MM.view(n=1, azimuth=110, elevation=60, inc=0)
    MM.view(n=1, azimuth=270, elevation=0, inc=0)
