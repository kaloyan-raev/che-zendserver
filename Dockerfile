FROM php-zendserver

ENV JAVA_VERSION=8u65 \
    JAVA_VERSION_PREFIX=1.8.0_65
ENV JAVA_HOME /opt/jre$JAVA_VERSION_PREFIX
ENV PATH $JAVA_HOME/bin:/usr/local/zend/bin:$PATH
RUN apt-get update && \
    apt-get -y install \
    openssh-server \
    sudo \
    procps \
    wget \
    unzip \
    mc \
    ca-certificates \
    curl \
    software-properties-common \
    python-software-properties && \
    mkdir /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user && \
    echo "secret\nsecret" | passwd user && \
    add-apt-repository ppa:git-core/ppa && \
    apt-get update && \
    sudo apt-get install git subversion -y && \
    apt-get clean && \
    wget \
   --no-cookies \
   --no-check-certificate \
   --header "Cookie: oraclelicense=accept-securebackup-cookie" \
   -qO- \
   "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-b17/jre-$JAVA_VERSION-linux-x64.tar.gz" | tar -zx -C /opt/ && \
    apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* && \
    echo "#! /bin/bash\n set -e\n sudo /usr/sbin/sshd -D &\n exec \"\$@\"" > /home/user/entrypoint.sh && chmod a+x /home/user/entrypoint.sh && \
    sudo ln -s /usr/local/zs-init/composer.phar /usr/local/bin/composer && \
    sudo sqlite3 /usr/local/zend/var/db/zsd.db "UPDATE ZSD_DIRECTIVES SET DISK_VALUE=0 WHERE NAME='zend_gui.studioAutoDetection'" && \
    sudo sqlite3 /usr/local/zend/var/db/zsd.db "UPDATE ZSD_DIRECTIVES SET DISK_VALUE=0 WHERE NAME='zend_gui.studioAutoDetectionEnabled'" && \
    sudo sqlite3 /usr/local/zend/var/db/zsd.db "UPDATE ZSD_DIRECTIVES SET DISK_VALUE=0 WHERE NAME='zend_gui.studioBreakOnFirstLine'" && \
    sudo sqlite3 /usr/local/zend/var/db/zsd.db "UPDATE ZSD_DIRECTIVES SET DISK_VALUE='127.0.0.1' WHERE NAME='zend_gui.studioHost'" && \
    sudo sed -i 's/zend_gui\.studioAutoDetection =.*/zend_gui\.studioAutoDetection = 0/g' /usr/local/zend/gui/config/zs_ui.ini && \
    sudo sed -i 's/zend_gui\.studioAutoDetectionEnabled =.*/zend_gui\.studioAutoDetectionEnabled = 0/g' /usr/local/zend/gui/config/zs_ui.ini && \
    sudo sed -i 's/zend_gui\.studioBreakOnFirstLine =.*/zend_gui\.studioBreakOnFirstLine = 0/g' /usr/local/zend/gui/config/zs_ui.ini && \
    sudo sed -i 's/zend_gui\.studioHost =.*/zend_gui\.studioHost = 127.0.0.1/g' /usr/local/zend/gui/config/zs_ui.ini && \
    sudo wget -qO /usr/local/zs-init/src/Config.php https://dl.dropboxusercontent.com/u/74228612/Config.php

# Bash completion
RUN apt-get update && \
    apt-get -y install bash-completion && \
    echo "\nif [ -f /etc/bash_completion ]; then\n  . /etc/bash_completion\nfi" >> /etc/profile && \
    composer global require bamarni/symfony-console-autocomplete && \
    ~/.composer/vendor/bamarni/symfony-console-autocomplete/symfony-autocomplete --shell bash composer > /etc/bash_completion.d/composer

# Install NodeJS to improve startup time when the JSON language server is enabled
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs

ENV LANG en_GB.UTF-8
ENV LANG en_US.UTF-8
RUN echo "export JAVA_HOME=/opt/jre$JAVA_VERSION_PREFIX\nexport PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH" >> /home/user/.bashrc && \
    sudo locale-gen en_US.UTF-8
USER user
EXPOSE 22 4403
WORKDIR /projects
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD sudo /usr/local/bin/run && tail -f /dev/null
