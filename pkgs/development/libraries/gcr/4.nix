{
  stdenv,
  lib,
  fetchurl,
  pkg-config,
  meson,
  ninja,
  gettext,
  gnupg,
  p11-kit,
  glib,
  libgcrypt,
  libtasn1,
  gtk4,
  pango,
  libsecret,
  openssh,
  systemd,
  gobject-introspection,
  wrapGAppsHook4,
  vala,
  gi-docgen,
  gnome,
  python3,
  shared-mime-info,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gcr";
  version = "4.4.0.1";

  outputs = [
    "out"
    "bin"
    "dev"
    "devdoc"
  ];

  src = fetchurl {
    url = "mirror://gnome/sources/gcr/${lib.versions.majorMinor finalAttrs.version}/gcr-${finalAttrs.version}.tar.xz";
    hash = "sha256-DDw0Hkn59PJTKkiEUJgEGQoMJmPmEgNguymMXRdKgJg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gettext
    gobject-introspection
    gi-docgen
    wrapGAppsHook4
    vala
    gi-docgen
    shared-mime-info
  ];

  buildInputs =
    [
      libgcrypt
      libtasn1
      pango
      libsecret
      openssh
      gtk4
    ]
    ++ lib.optionals systemdSupport [
      systemd
    ];

  propagatedBuildInputs = [
    glib
    p11-kit
  ];

  nativeCheckInputs = [
    python3
  ];

  mesonFlags = [
    # We are still using ssh-agent from gnome-keyring.
    # https://github.com/NixOS/nixpkgs/issues/140824
    "-Dssh_agent=false"
    "-Dgpg_path=${lib.getBin gnupg}/bin/gpg"
    (lib.mesonEnable "systemd" systemdSupport)
  ];

  doCheck = false; # fails 21 out of 603 tests, needs dbus daemon

  PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  postPatch = ''
    patchShebangs gcr/fixtures/
  '';

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gcr_4";
      packageName = "gcr";
      versionPolicy = "ninety-micro-unstable";
    };
  };

  meta = with lib; {
    platforms = platforms.unix;
    teams = [ teams.gnome ];
    description = "GNOME crypto services (daemon and tools)";
    mainProgram = "gcr-viewer-gtk4";
    homepage = "https://gitlab.gnome.org/GNOME/gcr";
    license = licenses.lgpl2Plus;

    longDescription = ''
      GCR is a library for displaying certificates, and crypto UI, accessing
      key stores. It also provides the viewer for crypto files on the GNOME
      desktop.

      GCK is a library for accessing PKCS#11 modules like smart cards, in a
      (G)object oriented way.
    '';
  };
})
