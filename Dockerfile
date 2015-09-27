FROM thewtex/jupyter-notebook-debian:effe6294c840
MAINTAINER Insight Software Consortium <community@itk.org>

USER root

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  cmake \
  git \
  libexpat1-dev \
  libhdf5-dev \
  libjpeg-dev \
  libpng12-dev \
  libpython3-dev \
  libtiff5-dev \
  python3 \
  python3-matplotlib \
  python3-numpy \
  python3-pip \
  ninja-build \
  wget \
  vim \
  zlib1g-dev

RUN pip3 install ipywidgets

WORKDIR /usr/src
RUN git clone git://itk.org/SimpleITK.git && \
  cd SimpleITK && \
  git checkout v0.9.0 && \
  cd .. && \
  mkdir SimpleITK-build && \
  cd SimpleITK-build && \
  cmake \
    -G Ninja \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr \
    -DSimpleITK_BUILD_DISTRIBUTE:BOOL=ON \
    -DSimpleITK_BUILD_STRIP:BOOL=ON \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_TESTING:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=OFF \
    -DITK_USE_SYSTEM_LIBRARIES:BOOL=ON \
    -DWRAP_CSHARP:BOOL=OFF \
    -DWRAP_LUA:BOOL=OFF \
    -DWRAP_PYTHON:BOOL=ON \
    -DWRAP_JAVA:BOOL=OFF \
    -DWRAP_TCL:BOOL=OFF \
    -DWRAP_R:BOOL=OFF \
    -DWRAP_RUBY:BOOL=OFF \
    -DPYTHON_EXECUTABLE:FILEPATH=/usr/bin/python3 \
    -DPYTHON_INCLUDE_DIR:PATH=/usr/include/python3.4 \
    -DPYTHON_LIBRARY:FILEPATH=/usr/lib/python3.4/config-3.4m-x86_64-linux-gnu/libpython3.4.so \
    ../SimpleITK/SuperBuild && \
  ninja && \
  cd SimpleITK-build && \
  cd Wrapping && \
  /usr/bin/python3 ./PythonPackage/setup.py install && \
  cd ../../.. && \
  rm -rf SimpleITK SimpleITK-build

USER jovyan
WORKDIR /home/jovyan/notebooks

RUN jupyter notebook --generate-config
RUN git clone https://github.com/damianavila/RISE.git && \
  cd RISE && \
  JUPYTER_CONFIG_DIR=/home/jovyan/.jupyter python3 setup.py install && \
  cd .. && \
  rm -rf RISE
