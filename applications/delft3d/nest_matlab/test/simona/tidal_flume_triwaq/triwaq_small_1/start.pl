#!/usr/bin/env perl
#
# $URL: https://repos.deltares.nl/repos/simona/bo_omgeving/releases/simona2012/examples/triwaq-examples/csm8/start.pl $
# $Revision: 3803 $, $Date: 2010-11-19 15:38:29 +0100 (Fri, 19 Nov 2010) $
#
# ------------------------------------------------------------------------------
#
# DESCRIPTION
#
# This script runs the CSM8 model (with wind forcing) with TRIWAQ.
#
# ------------------------------------------------------------------------------
#
# VERSION HISTORY
#
# Version  1.0  01-08-2007  c75832: initial version (JG, VORtech)
# Version  1.1  07-08-2008  c81949: error detection added
#
# ------------------------------------------------------------------------------
#
# Set environment variable SIMONADIR for indicating the Simona version that
# should be used and print this to the screen.
# $ENV{SIMONADIR}='/full/path/to/simona/directory';
print "SIMONADIR = $ENV{SIMONADIR}\n\n";

# Expand environment variable PATH with executables in Simona directory.
my $platform = $^O;
$platform = "win32" if ($platform eq "MSWin32");
if ($platform eq "linux" or $platform eq "linux64" or $platform eq "hpux")
{
   $ENV{PATH}="$ENV{SIMONADIR}/bin:$ENV{PATH}";
}
elsif ($platform eq "win32")
{
   $ENV{PATH}="$ENV{SIMONADIR}" . '\bin;' . "$ENV{PATH}";
}
else
{
   die "Platform '$platform' has not been implemented";
}

# Command for running Waqwnd.
my $run_waqwnd = 'waqwnd.pl -coordsystem USER       -inpfmt svwp         '.
                 '          -timzon GMT             -wnd2strfile -       '.
                 '          -runid wind             -stress_SVWP N       '.
                 '          -exp csm8               -KNMI svwp.csm8      '.
                 '          -date_ref "31 DEC 1999" -mmw 101             '.
                 '          -nmw 87                 -angle 0             '.
                 '          -grid S                 -gridmode n          '.
                 '          -stress_SVWP n          -overwrite y         '.
                 '          -windidfile windid.csm8 -back no             '.
                 '          -bufsize 10             -convert2stress N    ';

# Command for running Waqpre.
my $run_waqpre = 'waqpre.pl -runid small           -input siminp.small   '.
                 '          -isddh no               -bufsize 10          '.
                 '          -back no                                     ';

# Command for running Waqpro.
my $run_waqpro = 'waqpro.pl -runid small            -isddh no            '.
                 '          -bufsize 50             -back no             '.
                 '          -npart 1                                     ';

# Run commands. Comment out the lines with commands that should not be
# executed.
die "Wind SDS-file 'SDS-wind' already exists" if (-f "SDS-wind");

# if system() is ok, returns 0 and the "die" is not executed.
#system("$run_waqwnd") && die ("*** ERROR in example triwaq/csm8, waqwnd");
system("$run_waqpre") && die ("*** ERROR in example triwaq/csm8, waqpre");
system("$run_waqpro") && die ("*** ERROR in example triwaq/csm8, waqpro");

exit 0;
