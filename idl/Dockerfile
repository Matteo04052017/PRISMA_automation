FROM ubuntu:18.04

COPY idl88-linux.tar.gz /idl_install/idl88-linux.tar.gz

RUN cd /idl_install && tar -xzf idl88-linux.tar.gz

RUN apt-get update && apt-get install -y libxinerama1 libexpat1 libx11-dev libxt6 libxmu6

RUN cd /idl_install && chmod +x install.sh && ./install.sh -s < silent/idl_answer_file

RUN echo http://ia2-doc.oats.inaf.it:7070/fne/bin/capability > /usr/local/harris/license/o_licenseserverurl.txt

COPY astrometry_v1.30 /astrometry

RUN ln -s /astrometry/code/PRISMA /usr/local/harris/idl/lib/PRISMA

COPY third_part.tar.gz /idl_install/third_part.tar.gz
RUN cd /idl_install && tar -xzf third_part.tar.gz 
RUN ln -s /idl_install/third_part /usr/local/harris/idl/lib/third_part

ENV PATH=/usr/local/harris/idl/bin/:$PATH

CMD ["sleep","infinity"]

# idl -e "calibration, CAMERACODE, '20210501', process_image=1, process_day=1, process_month=0, config_file='/astrometry/settings/configuration.ini'" * una volta al giorno
# idl -e "calibration, CAMERACODE, '202105', process_image=1, process_day=1, process_month=0, config_file='/astrometry/settings/configuration.ini'" * processa tutti i giorni del mese
# idl -e "calibration, CAMERACODE, '202105', process_image=0, process_day=0, process_month=1, config_file='/astrometry/settings/configuration.ini'" * una volta al lmese
# - process_day=0 solo se devi riprocessare il mese senza le astrometrie giornaliere
# - process_month=1 solo una volta al mese con process_day=0
# giorno è dalle 12 alle 12, giorni giuliani

# idl -e "event, '20210602T220831_UT', config_file='/astrometry/settings/configuration.ini'"

