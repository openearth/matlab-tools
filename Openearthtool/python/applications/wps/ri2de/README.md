# PyWPS 4 example installation

This is an example application using PyWPS dummy processes.
If this file layout is kept, the complete folder
can be deployed with Ansible.

For deployment you should:
- Add your wps processes in the processes folder
- Edit `requirements.txt` with the required packages
- Edit `wsgi.py` to import the processes you want to deploy
- Edit `pywps.cfg` with your details

*adapted from https://github.com/geopython/pywps-flask*
