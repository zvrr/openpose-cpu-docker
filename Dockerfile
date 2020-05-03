FROM ubuntu:19.10

LABEL maintainer="xeptore@gmail.com"
LABEL description="CPU-only version of OpenPose. Not slimmed for production."
LABEL version="1.0"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install software-properties-common -y && \
    add-apt-repository ppa:git-core/ppa

RUN apt-get update -y && \
    apt-get install apt-utils -y && \
    apt-get upgrade -y

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

RUN apt-get install aptitude -y && \
    aptitude install --with-recommends wget lsb-core cmake -y && \
    aptitude install --with-recommends libopencv-dev -y

RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git

WORKDIR openpose

WORKDIR scripts/ubuntu

RUN sed -i 's/\<sudo -H\>//g' install_deps.sh; \
   sed -i 's/\<sudo\>//g' install_deps.sh; \
   sed -i 's/\<easy_install pip\>//g' install_deps.sh; \
   sync; sleep 1; bash install_deps.sh

WORKDIR /openpose/build

RUN cmake -DGPU_MODE:String=CPU_ONLY \
          -DDOWNLOAD_BODY_MPI_MODEL:Bool=ON \
          -DDOWNLOAD_BODY_COCO_MODEL:Bool=ON \
          -DDOWNLOAD_FACE_MODEL:Bool=ON \
          -DDOWNLOAD_HAND_MODEL:Bool=ON \
          -DUSE_MKL:Bool=OFF \
          ..

RUN make -j $(nproc)

WORKDIR /openpose

ENTRYPOINT ["build/examples/openpose/openpose.bin"]

CMD ["--help"]

