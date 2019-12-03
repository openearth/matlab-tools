# -*- mode: python -*-
from PyInstaller import compat
compat.is_conda = True
from PyInstaller.utils.hooks import collect_data_files

block_cipher = None
a = Analysis(['blue2_import_results.py'],
             pathex=[],
             binaries=[],
             datas=collect_data_files('geopandas', subdir='datasets'),
             hiddenimports=[
              'fiona',
              'fiona.schema',
              'fiona._shim',
              'netCDF4',
              'cftime',
             ],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)

pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          [],
          exclude_binaries=True,
          name='blue2_import_results',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          console=True )

coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=False,
               upx=True,
               name='blue2_import_results')
