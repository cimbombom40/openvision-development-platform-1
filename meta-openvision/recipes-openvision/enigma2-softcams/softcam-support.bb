SUMMARY = "Start, stop and select softcams."
MAINTAINER = "PLi team"

require conf/license/openvision-gplv2.inc

inherit allarch

PACKAGES = "${PN}"

PV = "2"

INITSCRIPT_NAME = "softcam"
INITSCRIPT_PARAMS = "defaults 50"
inherit update-rc.d

FILES_${PN} = "/etc"

do_install() {
	install -d ${D}/etc/init.d
	install -m 755 ${S}/softcam.None ${D}/etc/init.d/softcam.None
}

do_compile_append() {
	echo "# Placeholder for no cam" > ${S}/softcam.None
}

pkg_postinst_${PN} () {
	if [ ! -e "$D/etc/init.d/softcam" ]
	then
		ln -s softcam.None $D/etc/init.d/softcam
	fi
}
