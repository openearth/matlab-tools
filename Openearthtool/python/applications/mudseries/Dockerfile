FROM continuumio/miniconda
MAINTAINER maarten.pronk@deltares.nl

# install requirements
RUN conda install -y \
    numpy \
    opencv \
    bokeh \
    matplotlib \
    scipy \
    jupyter
RUN pip install exifread

# Setup application
COPY mudseries.py /
ENTRYPOINT ["jupyter", "notebook", "--no-browser", "--ip=*", "--port=8888", "--allow-root"]
EXPOSE 8888
