DESCRIPTION = "SAT>IP server"
MAINTAINER = "PLi team"
require conf/license/openvision-gplv2.inc

inherit gitpkgv

PV = "1+git${SRCPV}"
PKGV = "1+git${GITPKGV}"

SRC_URI = "git://github.com/eriksl/minisatip.git;protocol=git"
FILES_${PN} = "/usr/sbin/minisatip"
S = "${WORKDIR}/git"
BUILD = "${WORKDIR}/build"

inherit autotools

do_install() {
	install -m 755 -d ${D}/usr/sbin
	install -m 755 ${BUILD}/minisatip ${D}/usr/sbin
}
