FROM python:3.6.5

RUN apt-get update

# upgrade pip
RUN pip install --upgrade pip

# install other python requirements
ADD requirements.txt /root/requirements.txt
RUN pip install -r /root/requirements.txt

ARG SVN_REPOS
ARG SVN_USERNAME
ARG SVN_PASSWORD

# initialize subversion (to create ~/.subversion directory and its content)
RUN svn --version

# allow passwords to be stored as plaintext
RUN echo "store-plaintext-passwords = yes" >> /root/.subversion/servers

# create SVN_REPOS environment variable
ENV SVN_REPOS $SVN_REPOS

# run svn info in order to store the credentials
RUN svn info --non-interactive "$SVN_REPOS" --username $SVN_USERNAME --password $SVN_PASSWORD

# Add geonetwork instance
ARG GN_URL
ARG GN_USERNAME
ARG GN_PASSWORD

# set geonetwork evironment variables
ENV GN_URL=$GN_URL \
	GN_USERNAME=$GN_USERNAME \
	GN_PASSWORD=$GN_PASSWORD

RUN mkdir /data
WORKDIR /data

ADD .publish2geonetwork.sh /data/publish2geonetwork.sh

ENTRYPOINT /data/publish2geonetwork.sh
