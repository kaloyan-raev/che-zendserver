FROM zend/php-zendserver

# install cUrl, download and execute the script that will install packages, including Java, onenssh, sudo, as well as create a user with UID 1000
RUN apt-get install curl -y && \
    curl https://gist.githubusercontent.com/eivantsov/6fba3d1b34a2672e34e0/raw/29a4520171c03db26f4e0e73ba0588fd15772d8a/che.sh | sh

# execute further instructions as a user and login to terminal as user
USER user

# set Java_HOME - required to start a workspace agent
ENV JAVA_HOME /opt/jre1.8.0_65

# start sshd and execute a non-terminating command
CMD sudo /usr/sbin/sshd -D && \
    tailf /dev/null
