#!/usr/bin/env python

#     * Commands
#           o about: Display Fabric version, warranty and license information
#           o help: Display Fabric usage help, or help for a given command.
#           o let: Set a Fabric variable.
#           o list: Display a list of commands with descriptions.
#           o shell: Start an interactive shell connection to the specified hosts.
#     * Operations
#           o abort: Simple way for users to have their commands abort the process.
#           o download: Download a file from the remote hosts.
#           o invoke: Invokes the supplied command only if it has not yet been run (with the
#           o load: Load up the given fabfile.
#           o local: Run a command locally.
#           o local_per_host: Run a command locally, for every defined host.
#           o prompt: Display a prompt to the user and store the input in the given variable.
#           o put: Upload files to the current hosts.
#           o require: Make sure that certain environment variables are available.
#           o rsync_project: Uploads the current project directory using rsync.
#           o run: Run a shell command on the current fab_hosts.
#           o sudo: Run a sudo (root privileged) command on the current hosts.
#           o upload_project: Uploads the current project directory to the connected hosts.
#     * Decorators
#           o depends: Calls `invoke` with the supplied arguments prior to executing the
#           o hosts: Tags function object with desired fab_hosts to run on.
#           o mode: Tags function object with desired fab_mode to run in.
#           o requires: Calls `require` with the supplied arguments prior to executing the
#           o roles: Tags function object with desired fab_hosts to run on.


# % TODO: implement a unix version mpi

# % Steps:
# % - Copy data to a place where the running machine can find it.  
# % - Create a run script. 
# % - Submit run script to cluster
# % - On finish move back results
# % - Set a finish file in the directory

# % use fabric -> split operations remote (h4/nodes)/local(pc)
# % tasks:
# %   local(create run.sh) -> start ww3/delft3d/xbeach <- this is done in the preprocess step
# %   put(jobs/model) -> copy to h4
# %   put(run.sh) -> copy to h4
# %   remote(submit run.sh) -> submit from h4 head node
# %   get(jobs/model) -> when do we do this? Put it in the run script? Listen
# %       to jobq? Better check the manual of the batch system....
# %   local(mv running finishied) -> This will tell OMSRunner the job is
# %       finished

# input:
# hm.Cycle
# hm.Models(m).Name
# hm.JobDir

config.fab_hosts = ['localhost'] #['h4.deltares.nl']

def copymodel():
    "copy the current directory to the remote server"
    upload_project()
def runmodel():
    """Run model"""
    run("cd ~/Downloads/model")
    run("./run.sh")
    run("cd -")
def getmodel():
    """download model"""
    download("~/Downloads/model")

