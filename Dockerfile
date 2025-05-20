FROM rocker/shiny:4.3

LABEL maintainer="Nicolas Wirth <mail.nicowirth@gmail.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	cmake \
	libcurl4-openssl-dev \
	libfontconfig1-dev \
	libxml2-dev \
	libx11-dev \
	git \
	texlive \
	pandoc \
	pandoc-citeproc \
	zlib1g-dev \
	gfortran \
	liblapack-dev \
	libblas-dev \
    sudo \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
	libharfbuzz-dev \
	libfreetype6-dev \
	libfribidi-dev  \
	gnupg \
	nano \
	libperl-dev \
	libpoppler-glib-dev

# Install TinyTeX
RUN wget -qO- "https://yihui.org/tinytex/install-unx.sh" | \
    sh -s - --admin --no-path

RUN ls -l /root/.TinyTeX/bin
RUN ln -s /root/bin/* /usr/local/bin
RUN /root/.TinyTeX/bin/*/tlmgr path add

RUN \
    wget -O - https://github.com/dawbarton/pdf2svg/archive/v0.2.3.tar.gz | tar xzv && \
    cd pdf2svg-0.2.3 && \
    ./configure && \
    make && \
    make install

# Install the ttf-mscorefonts-installer package
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ttf-mscorefonts-installer
# Accept the terms and conditions
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections

# Update font cache
RUN fc-cache -f

#RUN rm -rf /var/lib/apt/lists/*

# Install QurvE from CRAN for faster installation of dependencies
RUN R -e "install.packages('QurvE', repos='https://cran.rstudio.com/', Ncpus = 4, dependencies = T)"
# EXPERIMENTAL: Install QurvE from GitHub to install development version
RUN R -e "install.packages('remotes', repos='https://cran.rstudio.com/')"
RUN R -e "remotes::install_github('NicWir/QurvE', dependencies = FALSE)"


# Install missing fonts (Arial)
RUN apt-get remove -y ttf-mscorefonts-installer
RUN apt-get install -y ttf-mscorefonts-installer
RUN fc-cache -f

# copy the app to the image
RUN mkdir /root/qurve
COPY qurve /root/qurve

RUN echo "local(options(shiny.port = 3838, shiny.host = '0.0.0.0'))" > /usr/local/lib/R/etc/Rprofile.site

COPY Rprofile.site /usr/lib/R/etc/


RUN addgroup --system app \
    && adduser --system --ingroup app app

# WORKDIR /home/app

# COPY app .

# RUN chown app:app -R /home/qurve

# USER app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/qurve', port=3838, host='0.0.0.0')"]
