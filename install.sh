#!/bin/bash
set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/gyatfiles}"

echo "=== Dotfiles Setup Script ==="
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed"
fi

echo ""
echo "=== Installing Brew Formulae ==="

FORMULAE=(
    abseil
    aom
    aribb24
    arm-none-eabi-binutils
    arm-none-eabi-gcc@8
    assimp
    autoconf
    avr-binutils
    avr-gcc@8
    avrdude
    awscli
    bat
    bazel
    boost
    bootloadhid
    borders
    brotli
    c-ares
    ca-certificates
    cairo
    carthage
    certifi
    cffi
    cjson
    clang-format
    confuse
    coreutils
    coursier
    cryptography
    dav1d
    dbus
    dfu-programmer
    dfu-util
    diff-so-fancy
    double-conversion
    expat
    fd
    ffmpeg
    firefoxpwa
    flac
    fnm
    fontconfig
    freetype
    frei0r
    fribidi
    fswatch
    fzf
    gettext
    gh
    ghostscript
    giflib
    gifsicle
    git
    git-delta
    glib
    gmp
    gnu-typist
    gnupg
    gnutls
    go
    graphite2
    gum
    gzip
    harfbuzz
    hid_bootloader_cli
    hidapi
    highway
    httpie
    hunspell
    icu4c@76
    icu4c@77
    imagemagick
    imath
    isl
    jasper
    jbig2dec
    jpeg-turbo
    jpeg-xl
    jq
    k9s
    krb5
    kubectx
    kubernetes-cli
    lame
    lazygit
    lazysql
    leptonica
    libarchive
    libass
    libassuan
    libb2
    libbluray
    libde265
    libdeflate
    libevent
    libftdi
    libgcrypt
    libgit2
    libgpg-error
    libheif
    libidn
    libidn2
    libimagequant
    libksba
    liblqr
    libmicrohttpd
    libmng
    libmpc
    libnghttp2
    libogg
    libomp
    libpng
    libraqm
    libraw
    librist
    libsamplerate
    libsndfile
    libsodium
    libsoxr
    libssh
    libssh2
    libtasn1
    libtiff
    libtool
    libunibreak
    libunistring
    libusb
    libusb-compat
    libuv
    libvidstab
    libvmaf
    libvorbis
    libvpx
    libx11
    libxau
    libxcb
    libxdmcp
    libxext
    libxml2
    libxrender
    libyaml
    little-cms2
    lpeg
    lua
    luajit
    luarocks
    luv
    lz4
    lzo
    m4
    make
    mbedtls
    md4c
    mdloader
    memcached
    mpdecimal
    mpfr
    mpg123
    mysql@5.7
    ncurses
    neovim
    nettle
    node
    npth
    oniguruma
    opencore-amr
    openexr
    openjdk
    openjdk@11
    openjdk@21
    openjpeg
    openssl@1.1
    openssl@3
    opus
    p11-kit
    pango
    parallel
    pcre
    pcre2
    pillow
    pinentry
    pipx
    pixman
    pkgconf
    postgresql@14
    powerlevel10k
    pre-commit
    protobuf
    pure
    pycparser
    pyenv
    pyright
    python-packaging
    python@3.12
    python@3.13
    qmk
    qpdf
    qt
    rav1e
    rbenv
    readline
    ripgrep
    rm-improved
    rover
    rubberband
    ruby-build
    rustup
    rustup-init
    scooter
    sdl2
    sesh
    shared-mime-info
    snappy
    speex
    spotify_player
    sqlite
    srt
    stow
    svt-av1
    swiftlint
    teensy_loader_cli
    tesseract
    the_silver_searcher
    thefuck
    theora
    thrift
    tmux
    tree-sitter
    unbound
    unibilium
    utf8proc
    webp
    wtfutil
    x264
    x265
    xcbeautify
    xcode-build-server
    xcodegen
    xcodes
    xorgproto
    xvid
    xz
    zeromq
    zimg
    zoxide
    zsh-async
    zsh-autosuggestions
    zsh-syntax-highlighting
    zstd
)

for formula in "${FORMULAE[@]}"; do
    if brew list "$formula" &>/dev/null; then
        echo "Already installed: $formula"
    else
        echo "Installing: $formula"
        brew install "$formula" || echo "Failed to install $formula, continuing..."
    fi
done

echo ""
echo "=== Installing Brew Casks ==="

CASKS=(
    aerospace
    alt-tab
    anaconda
    ghostty
    graphiql
    monitorcontrol
    qmk-toolbox
    wezterm
    xquartz
    ytmdesktop-youtube-music
)

for cask in "${CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        echo "Already installed: $cask"
    else
        echo "Installing: $cask"
        brew install --cask "$cask" || echo "Failed to install $cask, continuing..."
    fi
done

echo ""
echo "=== Setting up Rust ==="

# Initialize rustup if installed via brew
if command -v rustup-init &> /dev/null; then
    if ! command -v cargo &> /dev/null; then
        echo "Initializing Rust toolchain..."
        rustup-init -y
        source "$HOME/.cargo/env"
    else
        echo "Rust already initialized"
    fi
fi

echo ""
echo "=== Installing Cargo Packages ==="

CARGO_PACKAGES=(
    create-tauri-app
    lsd
)

for pkg in "${CARGO_PACKAGES[@]}"; do
    if cargo install --list | grep -q "^$pkg "; then
        echo "Already installed: $pkg"
    else
        echo "Installing: $pkg"
        cargo install "$pkg" || echo "Failed to install $pkg, continuing..."
    fi
done

echo ""
echo "=== Stowing Dotfiles ==="

# Directories to stow (these should match your dotfiles repo structure)
STOW_DIRS=(
    aerospace
    borders
    ghostty
    ideavim
    karabiner
    lsd
    nvim
    starship
    tmux
    wezterm
    wtf
    zsh
)

if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Error: Dotfiles directory not found at $DOTFILES_DIR"
    echo "Please clone your dotfiles repo first:"
    echo "  git clone <your-dotfiles-repo> $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

for dir in "${STOW_DIRS[@]}"; do
    if [[ ! -d "$DOTFILES_DIR/$dir" ]]; then
        echo "Skipping $dir (directory not found in dotfiles)"
        continue
    fi

    # Check if already stowed by looking for symlinks
    # stow --no will do a dry run and report conflicts
    if stow -n "$dir" 2>&1 | grep -q "existing target"; then
        echo "Already stowed or conflict: $dir (run 'stow --adopt $dir' to adopt existing files)"
    else
        echo "Stowing: $dir"
        stow "$dir" || echo "Failed to stow $dir, continuing..."
    fi
done

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Restart your terminal to apply all changes."
