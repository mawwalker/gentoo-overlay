# Copyright 2025 Your Name/Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit pax-utils xdg

DESCRIPTION="Kraken Desktop trading client"
HOMEPAGE="https://www.kraken.com/"

# The filename for the Debian package
_DEB_FILENAME="kraken-x86_64-debian-linux-gnu.deb"
SRC_URI="https://desktop-downloads.kraken.com/latest/${_DEB_FILENAME} -> ${P}.deb"

# The S variable points to the directory where sources are unpacked.
# Default src_unpack for .deb extracts control.tar.xz and data.tar.xz into ${WORKDIR}.
S="${WORKDIR}"

LICENSE="proprietary" # Verify with the actual license in usr/share/doc/kraken_desktop/copyright
SLOT="0"
KEYWORDS="-* amd64" # Binary package for amd64 architecture only

IUSE="" # No USE flags specified

# Standard restrictions for binary packages
RESTRICT="bindist mirror strip"

RDEPEND="" # As per request, no runtime dependencies listed here.
           # The binary may have its own bundled dependencies or expect a standard Linux environment.

# QA variables
QA_PREBUILT="*" # Mark all files as prebuilt
# The xdg.eclass handles .desktop files, but explicitly defining can be good for some QA checks.
QA_DESKTOP_FILE="usr/share/applications/kraken.desktop"

# src_unpack phase will use the default handler for .deb files.
# This extracts control.tar.xz and data.tar.xz into ${WORKDIR}.

src_install() {
    # Extract the contents of data.tar.xz directly into the target installation directory ${D}
    # This will create the necessary usr/bin, usr/share/applications, etc. structure in ${D}.
    tar -xpvf "${WORKDIR}/data.tar.xz" -C "${D}" --strip-components=0 || die "Failed to extract data.tar.xz"

    # Apply PaX markings to the executable for security hardening on PaX-enabled kernels.
    pax-mark m "${ED}/usr/bin/kraken_desktop"

    # The documentation is installed by tar to ${D}/usr/share/doc/kraken_desktop/
    # Rename it to ${PF} (Package-FullName, e.g., kraken-desktop-bin-1.0.0) for Gentoo standards.
    # Ensure the parent directory exists (though tar should have created it).
    mkdir -p "${D}/usr/share/doc" || die "Failed to create parent doc directory"
    mv "${D}/usr/share/doc/kraken_desktop" "${D}/usr/share/doc/${PF}" || die "Failed to move doc directory to ${PF}"

    # The xdg.eclass inherited will handle necessary updates for .desktop files and icons
    # during pkg_postinst and pkg_postrm phases (e.g., updating desktop and icon caches).
}
