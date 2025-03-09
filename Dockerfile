FROM amazonlinux:2

LABEL maintainer="WillHumphreys"

# Install amazon-linux-extras and other required packages
RUN yum install -y amazon-linux-extras aws-cli lzop
RUN yum -y install libcurl-devel gcc-gfortran python

# Install R using amazon-linux-extras
RUN amazon-linux-extras install R4 -y

# Copy R scripts first so we can analyze them
COPY src/stops.r stops.r
COPY src/years.r years.r
COPY src/bestTraders.r bestTraders.r

# Install automagic and detect required packages
RUN Rscript -e "install.packages('automagic', repos='http://cran.us.r-project.org')" && \
    Rscript -e "library(automagic); \
                scripts <- c('stops.r', 'years.r', 'bestTraders.r'); \
                deps <- unique(unlist(lapply(scripts, function(x) automagic::get_dependent_packages(x)))); \
                cat('Required packages:', paste(deps, collapse=', '), '\n'); \
                install.packages(deps, repos='http://cran.us.r-project.org')"

# Install additional specific packages that might not be detected
RUN Rscript -e "install.packages('data.table', type = 'source', repos = 'http://Rdatatable.github.io/data.table')"
RUN Rscript -e "install.packages(c('ggthemes', 'scales', 'viridis', 'RColorBrewer', 'plyr', 'Matrix', 'reshape'), repos='http://cran.us.r-project.org')"

# Copy shell script
COPY runStopsRScript.sh /usr/local/bin/runStopsRScript.sh

# Make shell script executable
RUN chmod +x /usr/local/bin/runStopsRScript.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/runStopsRScript.sh"]