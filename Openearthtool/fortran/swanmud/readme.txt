Swanmud is based on SWAN version 40.51A, see swan.tudelft.nl
The mud extension has been stored in separate modules as much as possible within our efforts.
For these separate mud modules a stand-alone (non-SWAN) test interface has beed made.
The mud extension has needs 3rd party code.
This means that all the code consists of three levels of code.

1a) SWAN code: OpenEarthTools\fortran\swanmud\Progrc\
1b) test code: OpenEarthTools\fortran\swanmud\Progrc\TEST_PORTAL\

Both codes above use the mud module:
2) mud  code: OpenEarthTools\fortran\swanmud\Progrc\files Delft\

The mud code uses the IMSL function dzanly
3) IMSL code: OpenEarthTools\fortran\swanmud\Progrc\files Delft\dzanly\

Current sitiuation:
1: [SWAN code] [test code]
2: [mud  code            ]
3: [IMSL code            ]

The plan is to remove as much mud-related code from swan as possible.
The plan is to extend the test interface such that it creates the SWANmud 
2d spectral file that is now produced (and swallowed) by SWANmud. This makes 
the SWANmud code lean, and allows for easier merginbg with newer SWAN versions.
Plus, it removes the need to compile SWANmud with non-free IMSL, such that the 
mud extension can become part of the main SWAN trunk.

Planned sitiuation:
1: [SWAN code (very lean)] <- SWANmud.s2d
2: [mud code wrapper     ] -> SWANmud.s2d (former test code)
3: [mud  code            ]
4: [IMSL code            ]
