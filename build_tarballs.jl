# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "normaliz"
version = v"3.7.4"

# Collection of sources required to build normaliz
sources = [
    "https://github.com/Normaliz/Normaliz/releases/download/v$version/normaliz-$version.tar.gz" =>
    "1b94ff9baa0ebbc682229e8cfad086245d67754958ae3ddb1cc0a563a16ceb89",

]

# Bash recipe for building across all platforms
script = raw"""
cd normaliz-3.7.4
# avoid libtool problems ....
rm /workspace/destdir/lib/libgmpxx.la
# add missing header
sed -i -e 's#^nobase_include_HEADERS = #nobase_include_HEADERS = libnormaliz/output.h #' source/Makefile.am source/Makefile.in
./configure --prefix=$prefix --host=$target --with-gmp=$prefix --disable-scip
make -j
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
# windows build would require MPIR instead of GMP for 'long long'
platforms = filter(x->!isa(x,Windows),supported_platforms())

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libnormaliz", :libnormaliz)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/GMP-v6.1.2-1/build_GMP.v6.1.2.jl",
    "https://github.com/benlorenz/boostBuilder/releases/download/v1.70.0/build_boost.v1.70.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
