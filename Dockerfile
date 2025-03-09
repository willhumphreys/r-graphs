FROM amazonlinux
MAINTAINER WillHumphreys

RUN yum install -y aws-cli lzop

RUN yum -y install libcurl-devel gcc-gfortran python

RUN amazon-linux-extras install R4

#RUN alternatives --set gcc /usr/bin/gcc64

#RUN yum -y install libcurl libcurl-devel
#RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
#RUN Rscript -e "install.packages('yhatr')"
#RUN Rscript -e "install.packages('ggplot2')"
#RUN Rscript -e "install.packages('plyr')"
#RUN Rscript -e "install.packages('reshape2')"


RUN Rscript -e "install.packages('tidyverse', repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages('data.table', type = 'source',repos = 'http://Rdatatable.github.io/data.table')"
RUN Rscript -e "install.packages(c('reshape', 'plyr', 'ggthemes', 'scales', 'viridis', 'RColorBrewer'), repos='http://cran.us.r-project.org')"

#Rscript -e "install.packages(c('ggplot2'), repos='http://cran.us.r-project.org', dependencies=TRUE)"


COPY runStopsRScript.sh /usr/local/bin/runStopsRScript.sh
COPY src/stops.r stops.r
COPY src/years.r years.r
COPY src/bestTraders.r bestTraders.r

RUN ["chmod", "+x", "/usr/local/bin/runStopsRScript.sh"]

#ENTRYPOINT [runStopsRScript.sh]
ENTRYPOINT ["/usr/local/bin/runStopsRScript.sh"]