# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Desktop client for the Kraken cryptocurrency exchange"
HOMEPAGE="https://kraken.com/features/desktop"

# The license is likely proprietary. User should verify.
# If a license file is included in the zip, add it to dodoc.
LICENSE="Proprietary"
SLOT="0"
KEYWORDS="~amd64" # Binary is for x86_64

# This ebuild expects the downloaded zip file to be named based on ${P}.zip in DISTDIR.
# Example: for kraken-desktop-0.0.1.ebuild, Portage will try to save the download
# as kraken-desktop-0.0.1.zip in your distfiles directory.
# If upstream "latest" content changes, you'll need to:
# 1. Update this ebuild's version (e.g., kraken-desktop-0.0.2.ebuild or kraken-desktop-YYYYMMDD.ebuild).
# 2. Run 'ebuild /path/to/new/kraken-desktop-version.ebuild manifest'
SRC_URI="https://desktop-downloads.kraken.com/latest/kraken-x86_64-unknown-linux-gnu.zip -> ${P}.zip"

# Assumes the zip file extracts its contents (kraken.desktop, kraken_desktop, README)
# directly into ${WORKDIR} without an intermediate top-level directory.
S="${WORKDIR}"

# RDEPEND: xdg-utils provides update-desktop-database, crucial for .desktop file
# and kraken:// URL scheme integration as mentioned in the application's README.
# The noVNC example provided by the user also includes RDEPENDs.
RDEPEND=""

src_install() {
    # Install the main executable to /usr/bin
    # dobin is a standard eutils function that handles permissions and installation path.
    dobin "${S}/kraken_desktop"

    # Install the .desktop file to /usr/share/applications
    # Manual installation similar to how noVNC ebuild handles its files.
    insinto /usr/share/applications
    doins "${S}/kraken.desktop"

    # Install the README file to /usr/share/doc/${PF}/
    # dodoc is a standard eutils function.
    dodoc "${S}/README"
}

pkg_postinst() {
    # Update desktop database for the .desktop file and MIME type associations (for kraken://)
    # This is needed for the 'kraken://' URL scheme mentioned in the README to work correctly.
    # The command 'update-desktop-database' comes from xdg-utils.
    update-desktop-database -q
}
