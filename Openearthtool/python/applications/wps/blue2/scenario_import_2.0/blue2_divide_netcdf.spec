# -*- mode: python -*-
from PyInstaller import compat
compat.is_conda = True
from PyInstaller.utils.hooks import collect_data_files
import rasterio
import inspect
from os.path import dirname, basename
import glob

rasteriopath = dirname(inspect.getfile(rasterio))
print(rasteriopath)
rasteriofiles = glob.glob(rasteriopath + "/*.py")
print(rasteriofiles)
rasteriomodules = ["rasterio." + basename(f).replace(".py", "") for f in rasteriofiles]
print(rasteriomodules)


block_cipher = None
a = Analysis(['blue2_divide_netcdf.py'],
             pathex=[],
             binaries=[],
             datas=collect_data_files('geopandas', subdir='datasets'),
             hiddenimports=[
              'fiona',
              'fiona.schema',
              'fiona._shim',
              'netCDF4',
              'cftime',
              'rasterio._shim',
             ] + rasteriomodules,
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          exclude_binaries=True,
          name='blue2_divide_netcdf',
          debug=False,
          strip=False,
          upx=True,
          console=True )
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=False,
               upx=True,
               name='blue2_divide_netcdf')
