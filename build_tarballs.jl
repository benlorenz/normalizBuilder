# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "normaliz"
version = v"3.7.2"

# Collection of sources required to build normaliz
sources = [
    "https://github.com/Normaliz/Normaliz/releases/download/v$version/normaliz-$version.tar.gz" =>
    "436a870a1ab9a5e0c2330f5900d904dc460938c17428db1c729318dbd9bf27aa",

]

# Bash recipe for building across all platforms
script = raw"""
cd normaliz-3.7.2
# avoid libtool problems ....
rm /workspace/destdir/lib/libgmpxx.la
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
