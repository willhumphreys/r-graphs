FROM rocker/r-ver:4.4.0

LABEL maintainer="WillHumphreys"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    awscli \
    lzop \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Configure renv to use a local cache directory for faster rebuilds
ENV RENV_PATHS_CACHE=/renv_cache

# Create a volume for the renv cache
VOLUME /renv_cache

# Copy renv files first
COPY renv.lock .Rprofile ./
COPY renv/activate.R renv/activate.R

# Install renv
RUN Rscript -e "install.packages('renv', repos='https://cloud.r-project.org/')"

# Copy the src directory
COPY src/ src/

# Restore packages using renv
RUN Rscript -e "renv::restore(confirm=FALSE)"

# Copy shell script
COPY runStopsRScript.sh /usr/local/bin/runStopsRScript.sh

# Make shell script executable
RUN chmod +x /usr/local/bin/runStopsRScript.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/runStopsRScript.sh"]