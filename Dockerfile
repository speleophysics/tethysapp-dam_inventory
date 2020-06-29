# Use our Tethyscore base docker image as a parent image
FROM tethysplatform/tethys-core:master

###############################
# DEFAULT ENVIRONMENT VARIABLES
###############################

ARG TETHYS_HOME
ARG TETHYS_APPS_ROOT

#########
# SETUP #
#########


###########
# INSTALL #
###########
#RUN mkdir -p /usr/lib/tethys/apps/tethys_caves
#RUN mkdir -p ${TETHYS_PERSIST}
COPY --chown=www:www tethysapp ${TETHYS_APPS_ROOT}/dam_inventory/tethysapp
COPY --chown=www:www *.py ${TETHYS_APPS_ROOT}/dam_inventory/
#COPY *.sh ${TETHYS_APPS_ROOT}/dam_inventory/
COPY install.yml ${TETHYS_APPS_ROOT}/dam_inventory/


RUN /bin/bash -c ". ${CONDA_HOME}/bin/activate tethys \
  ; cd ${TETHYS_APPS_ROOT}/dam_inventory \
  ; python setup.py install"

#########
# CHOWN #
#########
RUN export NGINX_USER=$(grep 'user .*;' /etc/nginx/nginx.conf | awk '{print $2}' | awk -F';' '{print $1}') \
  ; find ${TETHYSAPP_DIR} ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {} \
  ; find ${WORKSPACE_ROOT} ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {} \
  ; find ${STATIC_ROOT} ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {} \
  ; find ${TETHYS_PERSIST}/keys ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {} \
  ; find ${TETHYS_HOME}/tethys ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {}


#########################
# CONFIGURE ENVIRONMENT #
#########################
EXPOSE 80


################
# COPY IN SALT #
################
ADD docker/salt/ /srv/salt/


#######
# RUN #
#######
CMD bash run.sh
