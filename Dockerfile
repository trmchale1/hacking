FROM kalilinux/kali-rolling
WORKDIR /os

RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" | tee /etc/apt/sources.list


RUN apt-get update 
RUN apt-get -y upgrade
RUN apt-get -y dist-upgrade
RUN apt-get -y autoremove
RUN apt-get -y clean

# what libs / tools should we add?
#RUN apt-get install kali-tools-top10

COPY . /os
