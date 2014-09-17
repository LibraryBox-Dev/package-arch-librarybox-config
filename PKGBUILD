# This is an example PKGBUILD file. Use this as a start to creating your own,
# and remove these comments. For more information, see 'man PKGBUILD'.
# NOTE: Please fill out the license field for your package! If it is unknown,
# then please put 'unknown'.

# Maintainer: Your Name <youremail@domain.com>
pkgname=librarybox-config
pkgver=0.0.1
pkgrel=1
epoch=
pkgdesc="Simple configuration menu for LibraryBox"
arch=('any')
url="http://librarybox.us"
license=('GPL')
groups=()
depends=('libnewt')
makedepends=()
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=(lbx_functions.sh
        librarybox-config
	cli_lbx.sh)
noextract=()
md5sums=() #generate with 'makepkg -g'


package() {
	mkdir -p $pkgdir/bin
	cp lbx_functions.sh $pkgdir/bin
	cp librarybox-config $pkgdir/bin
	cp cli_lbx.sh $pkgdir/bin
}
