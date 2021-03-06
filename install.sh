#!/bin/sh
# install.sh
# installation script for slackmatic-startkit
# (the only bourne script you will ever see in slackmatic)
#
# note: distfiles included with startkit distribution
#
# wcm, 2007.04.17 - 2007.04.18
# sukkopera, 2014-2016
# ===
umask 022

uid=`id -u`
if test ! $uid = 0 ; then
    echo 'sorry, root permission is required to install the startkit'
    exit 1
fi

# Detect arch
arch=`arch`
case "$arch" in
	arm*)
		arch=arm
		;;
esac

echo 'begin installation of slackmatic ...'

pkg=`ls rc_static-*$arch* 2> /dev/null`
conffile=`(cd slackmatic && ls files/slackmat-$arch.conf 2> /dev/null)`
if test -z "$pkg" -o -z "$conffile"; then
    echo 'error: unsupported architecture:' $arch
    cd ..
    exit 1
fi

echo 'installing rc_static (for /bin/rc, required by slackmatic) ...'
## this package is included in start kit:
/sbin/upgradepkg --install-new --reinstall $pkg

echo 'building slackmatic package ...'
## build slackmatic with itself:
cd slackmatic
cp $conffile files/slackmat.conf
/bin/rc ./files/slackmat-build \
    --root-build \
    --source-archive ../distfiles \
     --config-file ./files/slackmat.conf
if test ! $? = 0 ; then
    echo 'failure building slackmatic'
    cd ..
    exit 1
fi

echo 'installing slackmatic ...'
pkg=`head -1 package`
/sbin/upgradepkg --install-new --reinstall $pkg
rm -Rf work
cd ..


echo 'building fakeroot ...'
cd fakeroot
## now slackmat-build s/b present:
slackmat-build --root-build --source-archive ../distfiles
if test ! $? = 0 ; then
    echo 'error: slackmat-build failed for fakeroot'
    cd ..
    exit 1
fi

echo 'installing fakeroot (required by slackmat-build) ...'
pkg=`head -1 package`
/sbin/upgradepkg --install-new --reinstall $pkg
rm -Rf work
cd ..

echo 'building httpup ...'
cd httpup
slackmat-build --root-build --source-archive ../distfiles
if test ! $? = 0 ; then
    echo 'error: slackmat-build failed for httpup'
    cd ..
    exit 1
fi

echo 'installing httpup (required by slackmat-sync) ...'
pkg=`head -1 package`
/sbin/upgradepkg --install-new --reinstall $pkg
rm -Rf work
cd ..


echo 'slackmatic installation complete!'


### EOF
