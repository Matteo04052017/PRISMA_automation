FROM ubuntu:18.04

COPY idl88-linux.tar.gz /idl_install/idl88-linux.tar.gz

RUN cd /idl_install && tar -xzf idl88-linux.tar.gz

RUN apt-get update && apt-get install -y libxinerama1 libexpat1 libx11-dev libxt6 libxmu6

RUN cd /idl_install && chmod +x install.sh && ./install.sh -s < silent/idl_answer_file

RUN echo http://ia2-doc.oats.inaf.it:7070/fne/bin/capability > /usr/local/harris/license/o_licenseserverurl.txt

ENV PATH=/usr/local/harris/idl/bin/:$PATH

COPY astrometry_v1.30 /astrometry_v1.30


