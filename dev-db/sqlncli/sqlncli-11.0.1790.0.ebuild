# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=3

inherit eutils rpm

DESCRIPTION="Microsoft(c) SQL Server(c) ODBC Driver 1.0 for Linux"
HOMEPAGE="http://www.microsoft.com/downloads/"
SRC_URI="http://download.microsoft.com/download/6/A/B/6AB27E13-46AE-4CE9-AFFD-406367CADC1D/Linux6/sqlncli-11.0.1790.0.tar.gz"

LICENSE="GPLv2"

RESTRICT="mirror"

SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}
	dev-libs/openssl
	sys-fs/e2fsprogs
	sys-libs/glibc
	virtual/krb5
	=dev-db/unixODBC-2.3.1[unicode]
	"

src_prepare() {
	sed -i \
		-e 's/uname -p/uname -m/g' \
		-e 's/req_libs=( glibc e2fsprogs krb5-libs openssl )/req_libs=(  )/' \
		-e 's/req_dm_ver="2.3.0";/req_dm_ver="2.3.1";/' \
		-e "s,sup_dir=\"/opt/microsoft/\$driver_short_name/\$driver_version\";,sup_dir=\"${D}opt/microsoft/\$driver_short_name/\$driver_version\";," \
		-e "s,lib_dir=\"/opt/microsoft/\$driver_short_name/lib64\",lib_dir=\"${D}opt/microsoft/\$driver_short_name/lib64\"," \
		-e "s,bin_dir=\"/opt/microsoft/\$driver_short_name/bin\",bin_dir=\"${D}opt/microsoft/\$driver_short_name/bin\"," \
		-e "s,sup_dir=\"/opt/microsoft/\$driver_short_name/\$driver_version\",sup_dir=\"${D}opt/microsoft/\$driver_short_name/\$driver_version\"," \
		-e "s,bin_sym_dir=\"/usr/bin\";,bin_sym_dir=\"${D}usr/bin\";," \
		-e 's/odbcinst -i -d -f/echo odbcinst -i -d -f/' \
		install.sh
}

src_install() {
	mkdir -p "${D}usr/bin"
	
	# run the verify step
	./install.sh verify
	
	# run the install step
	./install.sh install --accept-license --force
	
	# remove image path from driver
	sed -i -e "s,${D},/," "${D}opt/microsoft/sqlncli/11.0.1790.0/sqlncli.ini"
	
	# create necessary library symb links for backwards compatibility
	mkdir -p "${D}usr/lib64"
	ln -s libcrypto.so "${D}usr/lib64/libcrypto.so.10"
	ln -s libssl.so "${D}usr/lib64/libssl.so.10"
	ln -s libodbc.so "${D}usr/lib64/libodbc.so.1"
	ln -s libodbcinst.so "${D}usr/lib64/libodbcinst.so.1"
}

pkg_postinst() {
	odbcinst -i -d -f /opt/microsoft/sqlncli/11.0.1790.0/sqlncli.ini
}

pkg_prerm() {
	odbcinst -u -d -n "SQL Server Native Client 11.0"
}
