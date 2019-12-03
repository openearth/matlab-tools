To run EnKF (OpenDA) with Ourthe case:
1. Prepare OpenDA:
	- go to openda/fews/bin
	- run ". setup_openda.sh"
	- run ". settings_local.sh"
	- NOTE: if settings_local.sh doesn't work, first copy settings_local_linux.sh to settings_local_machinename.sh, for example settings_local_h4.sh. Then run settings_local.sh again.
2. Prepare other environment variables:
	- go to openstreams_2013/provisioning
	- run ". setpath.sh"
3. Run the Ourthe case:
	- go to openstreams_2013\cases\ourthe_case\Modules\OpenStreams\OurtheCase_hbv\
	- run ". run_enkf.sh"