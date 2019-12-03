#!/bin/sh -f
#
# test_driver.sh:  driver script for the testing of CAM in Sequential CCSM
#
# usage on frankfurt, firefly, bluefire, jaguarpf/titan, lynx:
# ./test_driver.sh
#
# valid arguments: 
# -i    interactive usage
# -f    force batch submission (avoids user prompt)
# -h    displays this help message
#
# **pass environment variables by preceding above commands 
#   with 'env var1=setting var2=setting '
# **more details in the CAM testing user's guide, accessible 
#   from the CAM developers web page


#will attach timestamp onto end of script name to prevent overwriting
cur_time=`date '+%H:%M:%S'`

hostname=`hostname`
case $hostname in

    ##firefly
    ff* )
    submit_script="test_driver_bluefire_${cur_time}.sh"

    if [ -z "$CAM_ACCOUNT" ]; then
	export CAM_ACCOUNT=`grep -i "^${LOGNAME}:" /etc/project.ncar | cut -f 1 -d "," | cut -f 2 -d ":" `
	if [ -z "${CAM_ACCOUNT}" ]; then
	    echo "ERROR: unable to locate an account number to charge for this job under user: $LOGNAME"
	    exit 2
	fi
    fi

    if [ -z "$CAM_BATCHQ" ]; then
        export CAM_BATCHQ="premium"
    fi

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

#BSUB -a poe                    # use LSF poe elim
#BSUB -x                          # exclusive use of node (not_shared)
#BSUB -n 64                       # total tasks needed
#BSUB -R "span[ptile=64]"          # max number of tasks (MPI) per node
#BSUB -o test_dr.o%J              # output filename
#BSUB -e test_dr.o%J              # error filename
#BSUB -q $CAM_BATCHQ
#BSUB -W 5:58                     
#BSUB -P $CAM_ACCOUNT      

if [ -n "\$LSB_JOBID" ]; then   #batch job
    export JOBID=\${LSB_JOBID}
    initdir=\${LS_SUBCWD}
    interactive="NO"
else
    interactive="YES"
fi

##omp threads
export CAM_THREADS=8
export CAM_RESTART_THREADS=16

##mpi tasks
export CAM_TASKS=8
export CAM_RESTART_TASKS=4

export XLSMPOPTS="stack=256000000"
export OMP_DYNAMIC=false
export AIXTHREAD_SCOPE=S
export MALLOCMULTIHEAP=true
export MP_USE_BULK_XFER=yes
export MP_LABELIO=yes

export INC_NETCDF=/usr/local/include
export LIB_NETCDF=/usr/local/lib
export MAKE_CMD="gmake -j"
export CFG_STRING=""
export CCSM_MACH="bluefire"
export MACH_WORKSPACE="/ptmp"
export CPRNC_EXE=/fs/cgd/csm/tools/cprnc/cprnc
export ADDREALKIND_EXE=/fs/cgd/csm/tools/addrealkind/addrealkind
dataroot="/fis01/cgd/cseg/csm"
echo_arg=""
input_file="tests_pretag_bluefire"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;

    ##bluefire
    be* )
    submit_script="test_driver_bluefire_${cur_time}.sh"

    if [ -z "$CAM_ACCOUNT" ]; then
	export CAM_ACCOUNT=`grep -i "^${LOGNAME}:" /etc/project.ncar | cut -f 1 -d "," | cut -f 2 -d ":" `
	if [ -z "${CAM_ACCOUNT}" ]; then
	    echo "ERROR: unable to locate an account number to charge for this job under user: $LOGNAME"
	    exit 2
	fi
    fi

    if [ -z "$CAM_BATCHQ" ]; then
        export CAM_BATCHQ="lrg_regular"
    fi

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

#BSUB -a poe                    # use LSF poe elim
#BSUB -x                          # exclusive use of node (not_shared)
#BSUB -n 64                       # total tasks needed
#BSUB -R "span[ptile=64]"          # max number of tasks (MPI) per node
#BSUB -o test_dr.o%J              # output filename
#BSUB -e test_dr.o%J              # error filename
#BSUB -q $CAM_BATCHQ
#BSUB -W 5:58
#BSUB -P $CAM_ACCOUNT      
#BSUB -J test_dr

if [ -n "\$LSB_JOBID" ]; then   #batch job
    export JOBID=\${LSB_JOBID}
    initdir=\${LS_SUBCWD}
    interactive="NO"
else
    interactive="YES"
fi

##omp threads
export CAM_THREADS=8
export CAM_RESTART_THREADS=4

##mpi tasks
export CAM_TASKS=8
export CAM_RESTART_TASKS=16

export XLSMPOPTS="stack=256000000"
export OMP_DYNAMIC=false
export AIXTHREAD_SCOPE=S
export MALLOCMULTIHEAP=true
export MP_USE_BULK_XFER=yes
export MP_LABELIO=yes

. /contrib/Modules/3.2.6/init/ksh
module load netcdf/4.1.3_seq

export INC_NETCDF=\${NETCDF}/include
export LIB_NETCDF=\${NETCDF}/lib
export INC_PNETCDF=/contrib/parallel-netcdf-1.2.0-svn961/include
export LIB_PNETCDF=/contrib/parallel-netcdf-1.2.0-svn961/lib
export MAKE_CMD="gmake -j"
export CFG_STRING=""
export CCSM_MACH="bluefire"
export MACH_WORKSPACE="/ptmp"
export CPRNC_EXE=/fs/cgd/csm/tools/cprnc/cprnc
export ADDREALKIND_EXE=/fs/cgd/csm/tools/addrealkind/addrealkind
dataroot="/fs/cgd/csm"
echo_arg=""
input_file="tests_pretag_bluefire"
xlf -qVersion

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;

    ##frankfurt
    fr* | f0* )
    submit_script="test_driver_frankfurt_${cur_time}.sh"
    export PATH=/cluster/torque/bin:${PATH}

    if [ -z "$CAM_BATCHQ" ]; then
        export CAM_BATCHQ="long"
    fi

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

# Name of the queue (CHANGE THIS if needed)
#PBS -q $CAM_BATCHQ
# Number of nodes (CHANGE THIS if needed)
#PBS -l nodes=1:ppn=16
# output file base name
#PBS -N test_dr
# Put standard error and standard out in same file
#PBS -j oe
# Export all Environment variables
#PBS -V
# End of options

if [ -n "\$PBS_JOBID" ]; then    #batch job
    export JOBID=\`echo \${PBS_JOBID} | cut -f1 -d'.'\`
    initdir=\${PBS_O_WORKDIR}
fi

if [ "\$PBS_ENVIRONMENT" = "PBS_BATCH" ]; then
    interactive="NO"
else
    interactive="YES"
fi

##omp threads
export CAM_THREADS=1
export CAM_RESTART_THREADS=2

##mpi tasks
export CAM_TASKS=8
export CAM_RESTART_TASKS=4

export PGI=/usr/local/pgi-pgcc-pghf-11.5
export LAHEY=/usr/local/lf6481
export INTEL=/usr/local/intel-cluster
export LD_LIBRARY_PATH=\${PGI}/linux86/lib:\${LAHEY}/lib64:/cluster/torque/lib:\${INTEL}/lib/intel64:\${LD_LIBRARY_PATH}
echo \${LD_LIBRARY_PATH}
export P4_GLOBMEMSIZE=500000000

/usr/local/bin/make_ib_hosts.sh
if [ "\$CAM_FC" = "INTEL" ]; then
    export INC_NETCDF=/usr/local/netcdf-intel-cluster/include
    export LIB_NETCDF=/usr/local/netcdf-intel-cluster/lib
    mvapich=/cluster/mvapich2-qlc-intel
    export INC_MPI=\${mvapich}/include
    export LIB_MPI=\${mvapich}/lib
    export LD_LIBRARY_PATH=\${LIB_MPI}:\${LD_LIBRARY_PATH}
    export PATH=\${INTEL}/fc/bin:\${mvapich}/bin:\${PATH}
    export CFG_STRING="-fc ifort "
    export MAKE_CMD="gmake -j"
    input_file="tests_posttag_frankfurt"
elif [ "\$CAM_FC" = "PGI" ]; then
    export INC_NETCDF=/usr/local/netcdf-4.1.3-pgi-hpf-cc-11.5-0/include
    export LIB_NETCDF=/usr/local/netcdf-4.1.3-pgi-hpf-cc-11.5-0/lib
    mpich=/usr/local/mpich-pgi
    export INC_MPI=\${mpich}/include
    export LIB_MPI=\${mpich}/lib
    export PATH=\${PGI}/linux86/bin:\${mpich}/bin:\${PATH}
    export MAKE_CMD="gmake -j "
    input_file="tests_pretag_frankfurt_pgi"
else
    export INC_NETCDF=/usr/local/netcdf-4.1.3-gcc-4.4.4-13-lf9581/include
    export LIB_NETCDF=/usr/local/netcdf-4.1.3-gcc-4.4.4-13-lf9581/lib
    mpich=/usr/local/mpich-gcc-lf64
    export INC_MPI=\${mpich}/include
    export LIB_MPI=\${mpich}/lib
    export PATH=\${LAHEY}/bin:\${mpich}/bin:\${PATH}
    export CFG_STRING="-fc lf95 "
    export MAKE_CMD="gmake -j "
    input_file="tests_pretag_frankfurt_lahey"
fi
export MACH_WORKSPACE="/scratch/cluster"
export CPRNC_EXE=/fs/cgd/csm/tools/cprnc_64/cprnc
export ADDREALKIND_EXE=/fs/cgd/csm/tools/addrealkind/addrealkind
dataroot="/fs/cgd/csm"
echo_arg="-e"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;


    ##jaguarpf/titan
    ja* | yo* )
    submit_script="test_driver_titanpf_${cur_time}.sh"

    if [ -z "$CAM_ACCOUNT" ]; then
	export CAM_ACCOUNT=`showproj -s jaguarpf | tail -1 `
	if [ -z "${CAM_ACCOUNT}" ]; then
	    echo "ERROR: unable to locate an account number to charge for this job under user: $LOGNAME"
	    exit 2
	fi
    fi

    if [ -z "$CAM_BATCHQ" ]; then
        export CAM_BATCHQ="batch"
    fi

    machine="titan"

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

# Name of the queue (CHANGE THIS if needed)
#PBS -q $CAM_BATCHQ
# Number of procs and walltime (CHANGE THIS if needed)
#PBS -l walltime=11:58:00,size=12
# output file base name
#PBS -N test_dr
# Put standard error and standard out in same file
#PBS -j oe
# Export all Environment variables
#PBS -V
#PBS -A $CAM_ACCOUNT
# End of options

if [ -n "\$PBS_JOBID" ]; then    #batch job
    export JOBID=\`echo \${PBS_JOBID} | cut -f1 -d'.'\`
    initdir=\${PBS_O_WORKDIR}
fi

if [ "\$PBS_ENVIRONMENT" = "PBS_BATCH" ]; then
    interactive="NO"
else
    interactive="YES"
fi

##omp threads
export CAM_THREADS=1
export CAM_RESTART_THREADS=2

##mpi tasks
export CAM_TASKS=8
export CAM_RESTART_TASKS=4

. /opt/modules/default/init/sh
module load netcdf
module switch pgi/10.9.0 pgi/11.8.0
module list

export INC_NETCDF=\${CRAY_NETCDF_DIR}/netcdf-pgi/include
export LIB_NETCDF=\${CRAY_NETCDF_DIR}/netcdf-pgi/lib

export MPICH_MAX_SHORT_MSG_SIZE=1024

export MAKE_CMD="gmake -j"
export CFG_STRING="-fc ftn "
export CCSM_MACH="$machine"
export MACH_WORKSPACE="/tmp/work"
export CPRNC_EXE=/tmp/proj/ccsm/tools/ccsm_cprnc/cprnc
export ADDREALKIND_EXE=/tmp/proj/ccsm/tools/addrealkind/addrealkind
dataroot="/tmp/proj/ccsm"
echo_arg="-e"
input_file="tests_posttag_titan"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;

    ##hopper
    ho* | ni* )
    submit_script="test_driver_hopper_${cur_time}.sh"

    if [ -z "$CAM_BATCHQ" ]; then
        export CAM_BATCHQ="regular"
    fi

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

# Name of the queue (CHANGE THIS if needed)
#PBS -q $CAM_BATCHQ
# Number of procs and walltime (CHANGE THIS if needed)
#PBS -l mppwidth=24,walltime=05:58:00
# output file base name
#PBS -N test_dr
# Put standard error and standard out in same file
#PBS -j oe
# Export all Environment variables
#PBS -V
# End of options

if [ -n "\$PBS_JOBID" ]; then    #batch job
    export JOBID=\`echo \${PBS_JOBID} | cut -f1 -d'.'\`
    initdir=\${PBS_O_WORKDIR}
fi

if [ "\$PBS_ENVIRONMENT" = "PBS_BATCH" ]; then
    interactive="NO"
else
    interactive="YES"
fi

##omp threads
export CAM_THREADS=1
export CAM_RESTART_THREADS=2

##mpi tasks
export CAM_TASKS=8
export CAM_RESTART_TASKS=4

. /opt/modules/default/init/sh
module unload PrgEnv-pathscale
module unload PrgEnv-intel
module unload PrgEnv-pgi
module load netcdf

if [ "\$CAM_FC" = "PATHSCALE" ]; then
    module load PrgEnv-pathscale
    export INC_NETCDF=\${CRAY_NETCDF_DIR}/pathscale/109/include
    export LIB_NETCDF=\${CRAY_NETCDF_DIR}/pathscale/109/lib
    export CFG_STRING="-fc ftn -cc cc -linker ftn -fc_type pathscale "
    export CCSM_MACH="hopper_pathscale"
    export USER_CC="cc"
elif [ "\$CAM_FC" = "INTEL" ]; then
    module load PrgEnv-intel
    export INC_NETCDF=\${CRAY_NETCDF_DIR}/intel/109/include
    export LIB_NETCDF=\${CRAY_NETCDF_DIR}/intel/109/lib
    export CFG_STRING="-fc ftn -cc cc -fc_type intel "
    export CCSM_MACH="hopper_intel"
else
    module load PrgEnv-pgi
    export INC_NETCDF=\${CRAY_NETCDF_DIR}/pgi/109/include
    export LIB_NETCDF=\${CRAY_NETCDF_DIR}/pgi/109/lib
    export CFG_STRING="-fc ftn -cc cc -fc_type pgi "
    export CCSM_MACH="hopper_pgi"
fi
module list

export MPICH_MAX_SHORT_MSG_SIZE=1024

export MAKE_CMD="gmake -j"
export MACH_WORKSPACE="/scratch/scratchdirs"
export CPRNC_EXE=/project/projectdirs/ccsm1/tools/cprnc/cprnc
export ADDREALKIND_EXE=/project/projectdir/ccsm1/tools/addrealkind/addrealkind
dataroot="/project/projectdirs/ccsm1"
echo_arg="-e"
input_file="tests_pretag_frankfurt_pgi"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;


    ##lynx
    ly* )
    submit_script="test_driver_lynx_${cur_time}.sh"

    if [ -z "$CAM_BATCHQ" ]; then
        export CAM_BATCHQ="regular"
    fi

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

# Name of the queue (CHANGE THIS if needed)
#PBS -q $CAM_BATCHQ
# Number of procs and walltime (CHANGE THIS if needed)
#PBS -l mppwidth=72,walltime=05:58:00
# output file base name
#PBS -N test_dr
# Put standard error and standard out in same file
#PBS -j oe
# Export all Environment variables
#PBS -V
# #PBS -A $CAM_ACCOUNT
#PBS -A UT-NTNL0121
# End of options

if [ -n "\$PBS_JOBID" ]; then    #batch job
    export JOBID=\`echo \${PBS_JOBID} | cut -f1 -d'.'\`
    initdir=\${PBS_O_WORKDIR}
fi

if [ "\$PBS_ENVIRONMENT" = "PBS_BATCH" ]; then
    interactive="NO"
else
    interactive="YES"
fi

##omp threads
export CAM_THREADS=4
export CAM_RESTART_THREADS=3

##mpi tasks
export CAM_TASKS=18
export CAM_RESTART_TASKS=24

. /opt/modules/default/init/sh
module unload PrgEnv-pathscale
module unload PrgEnv-intel
module unload PrgEnv-pgi
module unload pgi
module unload intel
module unload pathscale

module load netcdf

if [ "\$CAM_FC" = "PATHSCALE" ]; then
    module load PrgEnv-pathscale
    export INC_NETCDF=\${CRAY_NETCDF_DIR}/netcdf-pathscale/include
    export LIB_NETCDF=\${CRAY_NETCDF_DIR}/netcdf-pathscale/lib
    export CFG_STRING="-fc ftn -cc cc -linker ftn -fc_type pathscale "
    export CCSM_MACH="lynx_pathscale"
    export USER_CC="cc"
elif [ "\$CAM_FC" = "INTEL" ]; then
    module load PrgEnv-intel
    module switch intel intel/12.1.0
    export INC_NETCDF=\${CRAY_NETCDF_DIR}/netcdf-intel/include
    export LIB_NETCDF=\${CRAY_NETCDF_DIR}/netcdf-intel/lib
    export CFG_STRING="-fc ftn -cc cc -fc_type intel "
    export CCSM_MACH="lynx_intel"
else
    module load PrgEnv-pgi
    module switch pgi pgi/11.10.0
    export INC_NETCDF=\${CRAY_NETCDF_DIR}/netcdf-pgi/include
    export LIB_NETCDF=\${CRAY_NETCDF_DIR}/netcdf-pgi/lib
    export CFG_STRING="-fc ftn -cc cc -fc_type pgi "
    export CCSM_MACH="lynx_pgi"
fi
module list

export MPICH_MAX_SHORT_MSG_SIZE=1024

export MAKE_CMD="gmake -j"
export MACH_WORKSPACE="/ptmp"
export CPRNC_EXE=/glade/proj3/cseg/tools/cprnc.lynx/cprnc
export ADDREALKIND_EXE=/glade/proj3/cseg/tools/addrealkind/addrealkind
dataroot="/glade/proj3/cseg"
echo_arg="-e"
input_file="tests_posttag_titan"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;


    * ) echo "ERROR: machine $hostname not currently supported"; exit 1 ;;
esac

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat >> ./${submit_script} << EOF

##check if interactive job
if [ "\$interactive" = "YES" ]; then

    echo "test_driver.sh: interactive run - setting JOBID to \$\$"
    export JOBID=\$\$
    if [ \$0 = "test_driver.sh" ]; then
	initdir="."
    else
	initdir=\${0%/*}
    fi
fi

##establish script dir and cam_root
if [ -f \${initdir}/test_driver.sh ]; then
    export CAM_SCRIPTDIR=\`cd \${initdir}; pwd \`
    export CAM_ROOT=\`cd \${CAM_SCRIPTDIR}/../../../../.. ; pwd \`
else
    if [ -n "\${CAM_ROOT}" ] && [ -f \${CAM_ROOT}/models/atm/cam/test/system/test_driver.sh ]; then
	export CAM_SCRIPTDIR=\`cd \${CAM_ROOT}/models/atm/cam/test/system; pwd \`
    else
	echo "ERROR: unable to determine script directory "
	echo "       if initiating batch job from directory other than the one containing test_driver.sh, "
	echo "       you must set the environment variable CAM_ROOT to the full path of directory containing "
        echo "       <models>. "
	exit 3
    fi
fi

##output files
cam_log=\${initdir}/td.\${JOBID}.log
if [ -f \$cam_log ]; then
    rm \$cam_log
fi
cam_status=\${initdir}/td.\${JOBID}.status
if [ -f \$cam_status ]; then
    rm \$cam_status
fi

##setup test work directory
if [ -z "\$CAM_TESTDIR" ]; then
    export CAM_TESTDIR=\${MACH_WORKSPACE}/\$LOGNAME/test-driver.\${JOBID}
    if [ -d \$CAM_TESTDIR ]; then
        rm -rf \$CAM_TESTDIR
    fi
fi
if [ ! -d \$CAM_TESTDIR ]; then
    mkdir -p \$CAM_TESTDIR
    if [ \$? -ne 0 ]; then
	echo "ERROR: unable to create work directory \$CAM_TESTDIR"
	exit 4
    fi
fi

##set our own environment vars
export CSMDATA=\${dataroot}/inputdata
export MPI_TYPE_MAX=100000

##process other env vars possibly coming in
if [ -z "\$CAM_RETAIN_FILES" ]; then
    export CAM_RETAIN_FILES=FALSE
fi
if [ -n "\${CAM_INPUT_TESTS}" ]; then
    input_file=\$CAM_INPUT_TESTS
else
    input_file=\${CAM_SCRIPTDIR}/\${input_file}
fi
if [ ! -f \${input_file} ]; then
    echo "ERROR: unable to locate input file \${input_file}"
    exit 5
fi

if [ \$interactive = "YES" ]; then
    echo "reading tests from \${input_file}"
else
    echo "reading tests from \${input_file}" >> \${cam_log}
fi

num_tests=\`wc -w < \${input_file}\`
echo "STATUS OF CAM TESTING UNDER JOB \${JOBID};  scheduled to run \$num_tests tests from:" >> \${cam_status}
echo "\$input_file" >> \${cam_status}
echo "" >> \${cam_status}
if [ \$interactive = "NO" ]; then
    echo "see \${cam_log} for more detailed output" >> \${cam_status}
fi
echo "" >> \${cam_status}

test_list=""
while read input_line; do
    test_list="\${test_list}\${input_line} "
done < \${input_file}

##initialize flags, counter
skipped_tests="NO"
pending_tests="NO"
count=0

##loop through the tests of input file
for test_id in \${test_list}; do
    count=\`expr \$count + 1\`
    while [ \${#count} -lt 3 ]; do
        count="0\${count}"
    done

    master_line=\`grep \$test_id \${CAM_SCRIPTDIR}/input_tests_master\`
    status_out=""
    for arg in \${master_line}; do
        status_out="\${status_out}\${arg} "
    done

    test_cmd=\${status_out#* }

    status_out="\${count} \${status_out}"

    if [ \$interactive = "YES" ]; then
        echo ""
        echo "************************************************************"
        echo "\${status_out}"
        echo "************************************************************"
    else
        echo "" >> \${cam_log}
        echo "************************************************************"\
            >> \${cam_log}
        echo "\$status_out" >> \${cam_log}
        echo "************************************************************"\
            >> \${cam_log}
    fi

#    if [ \${#status_out} -gt 64 ]; then
#        status_out=\`echo "\${status_out}" | cut -c1-70\`
#    fi
    while [ \${#status_out} -lt 75 ]; do
        status_out="\${status_out}."
    done

    echo \$echo_arg "\$status_out\c" >> \${cam_status}

    if [ \$interactive = "YES" ]; then
        \${CAM_SCRIPTDIR}/\${test_cmd}
        rc=\$?
    else
        \${CAM_SCRIPTDIR}/\${test_cmd} >> \${cam_log} 2>&1
        rc=\$?
    fi
    if [ \$rc -eq 0 ]; then
        echo "PASS at \$(date)" >> \${cam_status}
    elif [ \$rc -eq 255 ]; then
        echo "SKIPPED* at \$(date)" >> \${cam_status}
        skipped_tests="YES"
    elif [ \$rc -eq 254 ]; then
        echo "PENDING** at \$(date)" >> \${cam_status}
        pending_tests="YES"
    else
        echo "FAIL! rc= \$rc at \$(date)" >> \${cam_status}
	if [ \$interactive = "YES" ]; then
	    if [ "\$CAM_SOFF" != "FALSE" ]; then
		echo "stopping on first failure"
		echo "stopping on first failure" >> \${cam_status}
		exit 6
	    fi
	else
	    if [ "\$CAM_SOFF" = "TRUE" ]; then
		echo "stopping on first failure" >> \${cam_status}
		echo "stopping on first failure" >> \${cam_log}
		exit 6
	    fi
	fi
    fi
done

echo "end of input" >> \${cam_status}
if [ \$interactive = "YES" ]; then
    echo "end of input"
else
    echo "end of input" >> \${cam_log}
fi

if [ \$skipped_tests = "YES" ]; then
    echo "*  please verify that any skipped tests are not required of your cam commit" >> \${cam_status}
fi
if [ \$pending_tests = "YES" ]; then
    echo "** tests that are pending must be checked manually for a successful completion" >> \${cam_status}
    if [ \$interactive = "NO" ]; then
	echo "   see the test's output in \${cam_log} " >> \${cam_status}
	echo "   for the location of test results" >> \${cam_status}
    fi
fi
exit 0

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^


chmod a+x $submit_script
arg1=${1##*-}
case $arg1 in
    [iI]* )
    ./${submit_script}
    exit 0
    ;;

    [fF]* )
    ;;

    "" )
    echo ""
    echo "**********************"
    echo "$submit_script has been created and will be submitted to the batch queue..."
    echo "(ret) to continue, (a) to abort"
    read ans
    case $ans in
	[aA]* ) 
	echo "aborting...type ./test_driver.sh -h for help message"
	exit 0
	;;
    esac
    ;;

    * )
    echo ""
    echo "**********************"
    echo "usage on frankfurt, firefly, bluefire, jaguarpf/titan, lynx: "
    echo "./test_driver.sh"
    echo ""
    echo "valid arguments: "
    echo "-i    interactive usage"
    echo "-f    force batch submission (avoids user prompt)"
    echo "-h    displays this help message"
    echo ""
    echo "**pass environment variables by preceding above commands "
    echo "  with 'env var1=setting var2=setting '"
    echo "**more details in the CAM testing user's guide, accessible "
    echo "  from the CAM developers web page"
    echo ""
    echo "**********************"
    exit 0
    ;;
esac

echo "submitting..."
case $hostname in
    ##firefly
    ff* )  bsub < ${submit_script};;

    ##bluefire
    be* )  bsub < ${submit_script};;

    ##frankfurt
    fr* | f0* )  qsub ${submit_script};;

    ##jaguarpf/titan
    ja* | yo* ) qsub ${submit_script};;

    ##hopper
    ho* | ni* ) qsub ${submit_script};;

    ##lynx
    ly* ) qsub ${submit_script};;

esac
exit 0
