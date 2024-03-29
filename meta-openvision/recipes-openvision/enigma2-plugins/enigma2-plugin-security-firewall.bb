DESCRIPTION = "Firewall"

require conf/license/openvision-gplv2.inc

RDEPENDS_${PN} = "iptables kernel-module-ip-tables kernel-module-nf-conntrack kernel-module-ipt-reject kernel-module-xt-state kernel-module-iptable-filter"

SRC_URI = "file://firewall.sh file://firewall.users"

PV = "1.0"

S = "${WORKDIR}"

INITSCRIPT_NAME = "firewall"
INITSCRIPT_PARAMS = "defaults"

inherit update-rc.d

do_install() {
	install -d ${D}/etc/init.d
	install -m 0755 ${WORKDIR}/firewall.sh ${D}/etc/init.d/firewall
	install -d ${D}/etc
	install -m 0755 ${WORKDIR}/firewall.users ${D}/etc/firewall.users
}
