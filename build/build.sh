#!/bin/sh

PKGLIST=/result/packages-${STACK}.lst
PKGLIST_NEW=${PKGLIST}.new

case $STACK in
	cedar-14)
		DIST=trusty
		;;
        heroku-16)
		DIST=xenial
		;;
	*)
		echo "Unknown stack $STACK"
		exit 1
		;;
esac

apt-key adv --keyserver keys.gnupg.net --recv-keys 72B865FD
echo "deb http://repo.wallarm.com/ubuntu/wallarm-node $DIST/" >/etc/apt/sources.list.d/wallarm.list
echo "deb http://repo.wallarm.com/ubuntu/wallarm-node-heroku $DIST/" >>/etc/apt/sources.list.d/wallarm.list
apt-get -q update
apt-get -q install -dy --force-yes --no-install-recommends nginx wallarm-node nginx-module-wallarm
rm -f /var/cache/apt/archives/binutils*.deb
ls /var/cache/apt/archives/*.deb | xargs -L1 basename | sort > ${PKGLIST_NEW}
if [ -f $PKGLIST ] && diff $PKGLIST $PKGLIST_NEW; then
	rm -f $PKGLIST_NEW
	exit
fi
mv $PKGLIST_NEW $PKGLIST
for PKG in /var/cache/apt/archives/*.deb; do dpkg -x $PKG /tmp/app; done
mkdir -p /app/wallarm
mv /tmp/app/etc /app/wallarm/
mv /tmp/app/usr/* /app/wallarm/
cp -r /app/wallarm/lib/x86_64-linux-gnu/* /app/wallarm/lib
rm -rf /app/wallarm/lib/x86_64-linux-gnu
tar -C /app -czf /result/wallarm-${STACK}.tgz wallarm
