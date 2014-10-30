FROM phusion/baseimage

RUN apt-get update
RUN apt-get -y install software-properties-common
RUN apt-get update
RUN add-apt-repository -y ppa:builds/sphinxsearch-rel22
RUN apt-get update
RUN apt-get -y install sphinxsearch
RUN mkdir -p /etc/my_init.d
ADD indexandsearch.sh /etc/my_init.d/indexandsearch.sh
RUN chmod a+x /etc/my_init.d/indexandsearch.sh
ADD searchd.sh /
ADD sample.tsv /
RUN chmod a+x searchd.sh
ADD gosphinx.conf /etc/sphinxsearch/gosphinx.conf
