FROM rocker/shiny:latest

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
	libfreetype-dev \
	libfribidi-dev  \
	libpoppler-glib-dev \
    && rm -rf /var/lib/apt/lists/*
	
RUN R -e "install.packages('remotes', repos='https://cran.rstudio.com/')"

RUN R -e "install.packages('QurvE', repos='https://cran.rstudio.com/', Ncpus = 4, dependencies = T)"

RUN \
    wget -O - https://github.com/dawbarton/pdf2svg/archive/v0.2.3.tar.gz | tar xzv && \
    cd pdf2svg-0.2.3 && \
    ./configure && \
    make && \
    make install

RUN sudo sudo apt-get install libperl5.34

#RUN R -e  "tinytex::uninstall_tinytex()"

RUN wget -qO- "https://yihui.org/tinytex/install-unx.sh" | \
    sh -s - --admin --no-path

#RUN R -e "tinytex::install_tinytex(force = TRUE)"
#RUN R -e "tinytex::tlmgr_update()"
#RUN R -e  "tinytex::reinstall_tinytex()"
#COPY /usr/local/bin/pdf2svg /usr/local/bin

RUN ln -s /root/bin/* /usr/local/bin
RUN /root/.TinyTeX/bin/*/tlmgr path add

# RUN sudo apt install -y --no-install-recommends ttf-mscirefints-installer 

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

CMD ["R", "-e", "shiny::runApp('/root/qurve')"]
