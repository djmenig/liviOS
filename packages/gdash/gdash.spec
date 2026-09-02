Name:           gdash
Version:        0~git20230624
Release:        1%{?dist}
Summary:        Boulder Dash clone, as close to the original as possible
License:        MIT
URL:            https://bitbucket.org/czirkoszoltan/gdash
# Git snapshot of the latest commit (2023-06-24, f980da7f4318)
Source0:        https://bitbucket.org/czirkoszoltan/gdash/get/f980da7f4318.tar.gz
BuildRequires:  gcc-c++
BuildRequires:  pkg-config
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  gettext-devel
BuildRequires:  glib2-devel
BuildRequires:  gtk3-devel
BuildRequires:  libSDL2-devel
BuildRequires:  SDL2_image-devel
BuildRequires:  SDL2_mixer-devel
BuildRequires:  Mesa-devel
BuildRequires:  glu-devel
BuildRequires:  libpng16-devel
BuildRequires:  desktop-file-utils
Requires:       glib2
Requires:       gtk3
Requires:       libSDL2-2_0-0
Requires:       SDL2_image
Requires:       SDL2_mixer
Requires:       Mesa-libGL1
Requires:       libpng16-16

%description
GDash is an open-source clone of the classic 1980s arcade game Boulder Dash.
It aims to be as close to the original as possible while adding modern
enhancements. Built with GTK+ 3 and SDL2 for both editor and game rendering.

%prep
# The bitbucket tarball extracts to czirkoszoltan-gdash-<hash>/
%autosetup -n czirkoszoltan-gdash-f980da7f4318 -p1

%build
autoreconf -fi
%configure
%make_build

%install
%make_install
desktop-file-validate %{buildroot}%{_datadir}/applications/gdash.desktop || true
%find_lang gdash

%files -f gdash.lang
%license COPYING COPYING.SDL COPYING.GTK COPYING.HQX
%doc README
%{_bindir}/gdash
%{_datadir}/gdash/
%{_datadir}/applications/gdash.desktop
%{_datadir}/pixmaps/gdash.png
