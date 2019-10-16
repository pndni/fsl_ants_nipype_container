FROM centos:7.6.1810

RUN yum install -y epel-release
RUN yum install -y wget file bc tar gzip libquadmath which bzip2 libgomp tcsh perl less vim zlib zlib-devel hostname git
RUN yum groupinstall -y "Development Tools"
RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0-Linux-x86_64.sh
RUN mkdir -p /opt/cmake
RUN /bin/bash cmake-3.14.0-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN rm cmake-3.14.0-Linux-x86_64.sh

RUN wget --output-document=/root/fslinstaller.py https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py 
RUN python /root/fslinstaller.py -p -V 6.0.1 -d /opt/fsl
RUN rm /root/fslinstaller.py

ENV FSLDIR=/opt/fsl
ENV FSLOUTPUTTYPE="NIFTI_GZ"
ENV FSLMULTIFILEQUIT="TRUE"
ENV FSLTCLSH=/opt/fsl/bin/fsltclsh
ENV FSLWISH=/opt/fsl/bin/fslwish
ENV FSLLOCKDIR=""
ENV FSLMACHINELIST=""
ENV FSLREMOTECALL=""
ENV FSLGECUDAQ="cuda.q"
ENV PATH=/opt/fsl/bin:$PATH

# ANTs
# it doesn't look like the libraries are needed. no RPATH or
# RUNPATH used. as determined by running
# for i in `ls`; do if [ $(file $i | awk '{print $2}') == "ELF" ]; then objdump -x $i | awk -v FS='\n' -v RS='\n\n' '$1 == "Dynamic Section:" {print}' | grep -i path ; fi; done;
# in /scif/apps/ants/bin
# and the documentation doesn't say to alter LD_LIBRARY_PATH
RUN tmpdir=$(mktemp -d) && \
    pushd $tmpdir && \
    git clone --branch v2.3.1 https://github.com/ANTsX/ANTs.git ANTs_src && \
    mkdir ANTs_build && \
    pushd ANTs_build && \
    /opt/cmake/bin/cmake ../ANTs_src && \
    make -j 2 && \
    popd && \
    mkdir -p /opt/ants/bin && \
    cp ANTs_src/Scripts/* /opt/ants/bin/ && \
    cp ANTs_build/bin/* /opt/ants/bin/ && \
    popd && \
    rm -rf $tmpdir
ENV PATH=/opt/ants/bin:$PATH
ENV ANTSPATH=/opt/ants/bin

RUN yum install -y python36 python36-pip python36-devel
RUN pip3.6 install --upgrade pip
RUN pip3.6 install bids-validator==1.2.3 pybids==0.8.0 git+https://github.com/stilley2/nipype.git@1.2.3-mod

LABEL Maintainer="Steven Tilley"
ARG ver=dev
ARG builddate=""
ARG revision=""

LABEL org.opencontainers.image.title=fsl_ants_nipype_container \
      org.opencontainers.image.source=https://github.com/pndni/fsl_ants_nipype_container \
      org.opencontainers.image.url=https://github.com/pndni/fsl_ants_nipype_container \
      org.opencontainers.image.revision=$ver \
      org.opencontainers.image.created=$builddate \
      org.opencontainers.image.version=$revision \
      org.label-schema.build-date="" \
      org.label-schema.license="" \
      org.label-schema.name="" \
      org.label-schema.schema-version="" \
      org.label-schema.vendor=""
