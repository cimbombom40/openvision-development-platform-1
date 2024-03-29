SUMMARY = "Dreamplex FHD skins"
MAINTAINER = "rossi2000"
inherit allarch

require conf/license/license-gplv2.inc

inherit gitpkgv

EPSM = "enigma2-plugin-skinpacks-dreamplex"
PV = "git${SRCPV}"
PKGV = "git${GITPKGV}"

PACKAGES = "${EPSM}-youplex-blue ${EPSM}-youplex-red ${EPSM}-youplex-green ${EPSM}-youplex-purple ${EPSM}-plex-experience"

SRC_URI = "git://github.com/OpenViX/DreamPlexSkins.git;protocol=git"

FILES_${EPSM}-youplex-blue = "${libdir}/enigma2/python/Plugins/Extensions/DreamPlex/skins/YouPlex-Blue"
FILES_${EPSM}-youplex-red = "${libdir}/enigma2/python/Plugins/Extensions/DreamPlex/skins/YouPlex-Red"
FILES_${EPSM}-youplex-green = "${libdir}/enigma2/python/Plugins/Extensions/DreamPlex/skins/YouPlex-Green"
FILES_${EPSM}-youplex-purple = "${libdir}/enigma2/python/Plugins/Extensions/DreamPlex/skins/YouPlex-Purple"
FILES_${EPSM}-plex-experience = "${libdir}/enigma2/python/Plugins/Extensions/DreamPlex/skins/Plex_Experience"

S = "${WORKDIR}/git"

do_compile_append() {
   python -O -m compileall ${S}
}

do_install() {
    install -d ${D}${libdir}/enigma2/python/Plugins/Extensions/DreamPlex/skins/
    cp -rp ${S}/* ${D}${libdir}/enigma2/python/Plugins/Extensions/DreamPlex/skins/
    chmod -R a+rX ${D}${libdir}/enigma2/python/Plugins/Extensions/DreamPlex/skins/
}

do_populate_sysroot[noexec] = "1"
do_package_qa[noexec] = "1"
