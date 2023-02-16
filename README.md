# SBCL Goodies

This repository contains Github Actions workflows and build scripts
that build each SBCL release with a few extra "goodies" statically
linked into the SBCL runtime: OpenSSL and libfixposix. These two
libraries are often cited as a reason why distributing Common Lisp
binaries is difficult, so it's useful to have them built into the
core.

## Modifications

 - `src/runtime/sbcl` is statically linked to `libcrypto`, `libssl` and
   `libfixposix`
 - in the SBCL core, a new keyword was added to `*features*`:
   `:CL+SSL-FOREIGN-LIBS-ALREADY-LOADED`
 - `CL:LISP-IMPLEMENTATION-VERSION` returns a string containing the
   revision, e.g. `"2.3.1+r00"`
 - the subdirectory `third_party/include` contains the headers of
   libfixposix

## Build environment

Ubuntu 20.04 LTS.

### OpenSSL

The binaries are linked to the official OpenSSL from the Ubuntu
repositories (with security updates).

### LibFixPOSIX

The latest Github release.

## Releases

The release process publishes both a source and a binary distribution
tarball of SBCL. The naming scheme adds a two-digit revision that is
increased every time new releases of the "goodies" occur after SBCL
upstream makes a new release. When SBCL is released, the revision is
reset to "00".

Examples:
 - sbcl-2.3.1+r00-x86-64-linux-binary.tar.bz2
 - sbcl-2.3.1+r00-source.tar.bz2
