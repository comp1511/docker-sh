FROM bitnami/minideb:unstable   
ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_AU.UTF-8  
ENV LANGUAGE en_AU:en  
ENV LC_ALL en_AU.UTF-8  

RUN \
	rm  /etc/localtime &&\
	cp /usr/share/zoneinfo/Australia/Sydney  /etc/localtime &&\
	echo Australia/Sydney >/etc/timezone &&\
	apt-get remove --purge  -y tzdata &&\
	install_packages locales  &&\
    localedef -i en_AU -c -f UTF-8 -A /usr/share/locale/locale.alias en_AU.UTF-8 &&\
    install_packages \
         \
        clang ssh xz-utils curl python3 python3-requests python3-distutils gdb valgrind \
        vim nano rsync unzip bzip2 unzip &&\
    find /usr/lib/llvm* -name '*-i686.a' -exec rm \{\} \; &&\
    rm -f /usr/lib/llvm*/bin/*-*  /usr/lib/llvm*/bin/[d-z]*

RUN \
	course=cs1511 &&\
	session=18s1 &&\
	public_html_session_directory=/home/$course/public_html/$session &&\
    echo "PS1='Docker\$ '" >/etc/profile.d/$course.sh &&\
    echo 'export PATH="$PATH:/home/'$course'/bin":/home/'$course/public_html/$session/scripts:. >>/etc/profile.d/$course.sh &&\
    echo "export LC_COLLATE=POSIX" >>/etc/profile.d/$course.sh &&\
    echo '#!/bin/sh' >/usr/local/bin/1511 &&\
    echo 'PATH=/home/cs1511/bin:$PATH exec "$@"' >>/usr/local/bin/1511 &&\
    adduser --disabled-password --gecos '' --home  /home/$course $course &&\
    mkdir -p /home/$course/public_html/$session/scripts /web /home/$course/bin &&\
    ln -s  /home/$course/public_html /web/$course &&\
    ln -sf $public_html_session_directory/scripts/autotest /home/$course/bin/ &&\
    ln -sf $public_html_session_directory/scripts/dcc /home/$course/bin/ &&\
    ln -sf $public_html_session_directory/scripts/dcc /usr/local/bin/ &&\
    ln -sf $public_html_session_directory/scripts/give_remote /home/$course/bin/give &&\
    echo '#!/bin/sh' >/home/$course/bin/gcc &&\
    echo 'exec clang "$@"' >>/home/$course/bin/gcc &&\
    chmod -R 755 /web /home /usr/local/bin/1511 &&\
    chown -R $course.$course /web /home &&\
    date +'@%s.%N' >$public_html_session_directory/.docker_image_creation_time &&\
    date +'@%s.%N' >$public_html_session_directory/.last_autotest_file_update_time &&\
    curl -L -s http://cgi.cse.unsw.edu.au/~${course}/$session/cgi/autotest_files.cgi | \
    tar -C $public_html_session_directory --owner=$course -xJf - &&\
    chmod -R 755 /web /home &&\
    chown -R $course.$course /web /home &&\
    echo 61

ADD /entrypoint entrypoint
ENTRYPOINT ["/entrypoint"]
