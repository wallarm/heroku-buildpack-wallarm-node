#!/bin/sh

PKGLIST=/result/packages-${STACK}.lst
PKGLIST_NEW=${PKGLIST}.new

TMPDEST=/tmp/app

case $STACK in
	cedar-14)
		DIST=trusty
		;;
        heroku-16)
		DIST=xenial
		;;
        heroku-18)
		DIST=bionic
		;;
	*)
		echo "Unknown stack $STACK"
		exit 1
		;;
esac

apt-key adv --keyserver keys.gnupg.net --recv-keys 72B865FD
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
echo "deb http://repo.wallarm.com/ubuntu/wallarm-node $DIST/" >/etc/apt/sources.list.d/wallarm.list
echo "deb http://repo.wallarm.com/ubuntu/wallarm-node-heroku $DIST/" >>/etc/apt/sources.list.d/wallarm.list
echo "deb http://nginx.org/packages/ubuntu $DIST nginx" >>/etc/apt/sources.list.d/nginx.list
apt-get -q update
apt-get -q install -dy --force-yes --no-install-recommends wallarm-node libpython2.7 nginx-module-wallarm-heroku
rm -f /var/cache/apt/archives/binutils*.deb || true
ls /var/cache/apt/archives/*.deb | xargs -L1 basename | sort > ${PKGLIST_NEW}
if [ -f $PKGLIST ] && diff $PKGLIST $PKGLIST_NEW; then
	rm -f $PKGLIST_NEW
	exit
fi
mv $PKGLIST_NEW $PKGLIST
for PKG in /var/cache/apt/archives/*.deb; do dpkg -x $PKG $TMPDEST; done
mkdir -p /app/wallarm
mv $TMPDEST/etc /app/wallarm/
mv $TMPDEST/usr/* /app/wallarm/

. /build-nginx.sh

cp -r /app/wallarm/lib/x86_64-linux-gnu/* /app/wallarm/lib
cp /usr/lib/x86_64-linux-gnu/libpython2.7* /app/wallarm/lib
rm -rf /app/wallarm/lib/x86_64-linux-gnu
tar -C /app -czf /result/wallarm-${STACK}.tgz wallarm
