del nesthd*.exe
n:\Applications\Matlab\MATLAB2012b\bin\matlab    -nosplash -nodesktop -wait -r nesthd_compile
ren nesthd.exe nesthd_w32.exe
n:\Applications\Matlab\MATLAB2012b_64\bin\matlab -nosplash -nodesktop -wait -r nesthd_compile
ren nesthd.exe nesthd_w64.exe
