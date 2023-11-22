#!/bin/sh

# rpc_make.sh, a Linux build/install tool for rpCalc.
# rpCalc, a calculator using reverse polish notation.
# Copyright (c) 2023, Douglas W. Bell.
# Free software, GPL v2 or later.

depends_error () {
    echo
    echo "Error installing dependencies." 1>&2
    echo
    echo "Please install the following packages manually:"
    echo "    Clang"
    echo "    CMake"
    echo "    curl"
    echo "    git"
    echo "    GTK development headers"
    echo "    Ninja build"
    echo "    pkg-config"
    echo "    XZ development headers"
    echo
    exit 1
}

misc_error () {
    echo
    echo "${1:-"Unknown Error"}" 1>&2
    echo
    exit 1
}

if [ "$(getconf LONG_BIT)" != "64" ]; then
    misc_error "rpCalc only runs on a 64-bit OS"
fi

case "$1" in

    "depends")
        if [ "$(id -u)" != "0" ]; then
            misc_error "'depends' must be run as sudo or root"
        fi
        if [ -x "$(command -v apt-get)" ]; then
            echo "Detected 'apt-get' (Debian-based system)"
            echo
            apt-get -y install clang cmake curl git libgtk-3-dev ninja-build \
                pkgconf liblzma-dev || depends_error
        elif [ -x "$(command -v dnf)" ]; then
            echo "Detected 'dnf' (Fedora-based system)"
            echo
            dnf -y install clang cmake curl git gtk3-devel ninja-build \
                pkgconf xz-devel || depends_error
        elif [ -x "$(command -v pacman)" ]; then
            echo "Detected 'pacman' (Arch-based system)"
            echo
            pacman -S --needed --noconfirm clang cmake curl git gtk3 ninja \
                pkgconf xz || depends_error
        else
            echo "Could not find a supported package manager"
            depends_error
        fi
        ;;

    "build")
        if [ "$(id -u)" = "0" ]; then
            misc_error "'build' should not be run as sudo or root"
        fi
        echo "Downloading Flutter..."
        flutter_site="https://storage.googleapis.com"
        flutter_path="/flutter_infra_release/releases/stable/linux/"
        flutter_file="flutter_linux_3.16.0-stable.tar.xz"
        curl -O $flutter_site$flutter_path$flutter_file \
            || misc_error "Error:  Could not download Flutter"
        echo
        echo "Extracting Flutter..."
        tar -xf $flutter_file \
            || misc_error "Error:  Could not extract Flutter archive"
        echo "Extract done"
        echo
        export PATH="$PATH:`pwd`/flutter/bin"
        flutter build linux --release || misc_error "Error - build failed"
        echo
        echo "rpCalc build successful"
        ;;

    "install")
        if [ "$(id -u)" != "0" ]; then
            misc_error "'install' must be run as sudo or root"
        fi
        if [ ! -d "`pwd`/build/linux/x64/release/bundle" ]; then
            misc_error "'build' must be successfully run prior to 'install'"
        fi
        echo "Copying Files..."
        if [ ! -d "/opt" ]; then
            mkdir -m 755 /opt \
                || misc_error "Could not create '/opt/rpcalc' directory"
        fi
        mkdir -p -m 755 /opt/rpcalc \
            || misc_error "Could not create '/opt/rpcalc' directory"
        cp -pr `pwd`/build/linux/x64/release/bundle/* /opt/rpcalc/. \
            || misc_error "Could not copy files to '/opt/rpcalc' directory"
        cp -p `pwd`/rpcalc.desktop `pwd`/rpcalc_icon_64.png /opt/rpcalc/.
        echo "Copy done"
        echo
        echo "Creating symlinks..."
        ln -sf /opt/rpcalc/rpcalc /usr/local/bin/. \
            && ln -sf /opt/rpcalc/rpcalc.desktop \
            /usr/local/share/applications/. \
            || misc_error "Could not create symlinks"
        echo "Symlinks created"
        case ":$PATH:" in
            *:/usr/local/bin:*) ;;
            *) echo
               echo "Note that /usr/local/bin is not in your \$PATH variable."
               echo "Consider adding it or creating symlinks elsewhwere."
               echo
               ;;
        esac
        ;;

    "uninstall")
        if [ "$(id -u)" != "0" ]; then
            misc_error "'uninstall' must be run as sudo or root"
        fi
        rm -rf /opt/rpcalc && echo "Removed /opt/rpcalc/" \
            || echo "Failed to remove /opt/rpcalc/"
        rm /usr/local/bin/rpcalc \
            && echo "Removed /usr/local/bin/rpcalc (link)" \
            || echo "Failed to remove /usr/local/bin/rpcalc (link)"
        rm /usr/local/share/applications/rpcalc.desktop \
            && echo "Removed rpcalc.desktop (link)" \
            || echo "Failed to remove rpcalc.desktop (link)"
        ;;

    *)
        opt_list="'depends', 'build', 'install' or 'uninstall'"
        echo "Must have $opt_list as the first argument" 1>&2
        echo
        echo "Typical usage:"
        echo "    $ sudo ./rpc_make.sh depends"
        echo "    $ ./rpc_make.sh build"
        echo "    $ sudo ./rpc_make.sh install"
        echo
        exit 1
        ;;
esac

