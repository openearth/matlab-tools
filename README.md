# OpenEarth MATLAB-tools
OpenEarth is a free and open source initiative to deal with Data, Models and Tools in earth science & engineering projects.
This particular repository contains a collection of MATLAB functions contributed by numerous researchers for general reuse and collaboration.
These tools come without any implied quality or warranty.
If you think that something can be improved, please feel free to change the code.

# Important note on cloning this repository
Several functions depend on basic functionality implemented in the Delft3D-MATLAB interface toolbox.
Since that toolbox is subject to Deltares software quality control, it's maintained in a separate repository.
This repository is included in this repository as a submodule under applications/delft3d-matlab.
When cloning this repository, you will not automatically get the code of the Delft3D-MATLAB interface toolbox unless ... you do the following:
Select the `recursive` option in the cloning dialog, or when using the command line, type:
`git clone --recursive https://github.com/openearth/matlab-tools.git`.
If you forgot the recursive flag during the initial clone, you may execute the command
`git submodule update --init --recursive`
in the main folder of the matlab-tools checkout.

# Getting started
Clone this repository.
Start MATLAB.
Run the `oetsettings` script in the main folder to add all OpenEarth tools to the MATLAB search path.

# Related resources
- [OpenEarth website](https://www.openearth.nl/)
- [QUICKPLOT and Delft3D-MATLAB interface](https://github.com/Deltares/QUICKPLOT)
