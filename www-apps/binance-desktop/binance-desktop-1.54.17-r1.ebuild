# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm xdg-utils

DESCRIPTION="Binance Desktop Application"
HOMEPAGE="https://binance.com"
SRC_URI="https://github.com/binance/desktop/releases/download/v${PV}/binance-${PV}-x86_64-linux.rpm -> ${P}-x86_64-linux.rpm"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

# 虽然 RPM 包自带依赖，但在这里声明一些核心依赖是好习惯
# 例如：RDEPEND="x11-libs/gtk+:3 media-libs/alsa-lib dev-libs/nss"
# 这里暂时留空，遵循你的原始文件
DEPEND=""
RDEPEND="${DEPEND}"

RESTRICT="mirror strip"

S="${WORKDIR}"

src_prepare() {
	default
	xdg_environment_reset
}

src_unpack() {
	rpm_unpack ${P}-x86_64-linux.rpm
}

src_install() {
	# 复制应用文件
	cp -r "${S}/opt" "${D}/opt" || die "Install /opt failed!"
	cp -r "${S}/usr" "${D}/usr" || die "Install /usr failed!"

	# 定义 desktop 文件的路径
	local desktop_file="${D}/usr/share/applications/binance.desktop"

	# 检查文件是否存在
	if [[ ! -f "${desktop_file}" ]]; then
		die "Desktop file not found: ${desktop_file}"
	fi

	# 使用 sed 修改 .desktop 文件中的启动命令，添加 --no-sandbox 参数
	# s|^Exec=.*|...| 会替换以 "Exec=" 开头的整行，更稳妥
	sed -i 's|^Exec=.*|Exec=/opt/Binance/binance --no-sandbox %U|' "${desktop_file}" || die "Failed to patch .desktop file"

	# 创建符号链接，方便从命令行启动
	dosym /opt/Binance/binance /usr/bin/binance
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
