DESCRIPTION = "Backup Suite"
LICENSE = "GPLv3"
MAINTAINER = "Open Vision Developers"
AUTHOR = "Pedro Newbie <pedro.newbie@gmail.com>"
LIC_FILES_CHKSUM = "file://LICENSE;md5=84dcc94da3adb52b53ae4fa38fe49e5d"

SRC_URI = "git://github.com/OpenVisionE2/BackupSuite.git;protocol=git;branch=upcoming"

# don't inherit allarch, it can't work with arch-dependent RDEPENDS
inherit gitpkgv distutils-openplugins gettext

RDEPENDS_${PN} = "\
	mtd-utils \
	mtd-utils-ubifs \
	${@bb.utils.contains("IMAGE_FSTYPES", "tar.bz2", "bzip2" , "", d)} \
	${@bb.utils.contains_any("IMAGE_FSTYPES", "jffs2 ubifs", "dreambox-buildimage mtd-utils-jffs2" , "", d)} \
	enigma2-plugin-systemplugins-mphelp \
	"

S = "${WORKDIR}/git"

PV = "26+git${SRCPV}"
PKGV = "26+git${GITPKGV}"

do_install_append() {
	find "${D}" -name '*.sh' -exec chmod a+x '{}' ';'
}

FILES_${PN}-src = "\
    ${libdir}/enigma2/python/*/*.py \
    ${libdir}/enigma2/python/*/*/*.py \
    ${libdir}/enigma2/python/*/*/*/*.py \
    ${libdir}/enigma2/python/*/*/*/*/*.py \
    ${libdir}/enigma2/python/*/*/*/*/*/*.py \
    ${libdir}/enigma2/python/*/*/*/*/*/*/*.py \
    ${libdir}/enigma2/python/*/*/*/*/*/*/*/*.py \
    ${libdir}/enigma2/python/*/*/*/*/*/*/*/*/*.py \
    ${libdir}/enigma2/python/*/*/*/*/*/*/*/*/*/*.py \
    ${libdir}/enigma2/python/*/*/*/*/*/*/*/*/*/*/*.py \
    "

python populate_packages_prepend() {
    enigma2_plugindir = bb.data.expand('${libdir}/enigma2/python/Plugins', d)
    do_split_packages(d, enigma2_plugindir, '^(\w+/\w+)/[a-zA-Z0-9_]+.*$', 'enigma2-plugin-%s', 'Enigma2 Plugin: %s', recursive=True, match_path=True, prepend=True)
    do_split_packages(d, enigma2_plugindir, '^(\w+/\w+)/.*\.py$', 'enigma2-plugin-%s-src', 'Enigma2 Plugin: %s', recursive=True, match_path=True, prepend=True)
}
