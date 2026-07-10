# AUTARQ Office: Desktop frontend

<p align="center"> 
  <a href="http://www.gnu.org/licenses/agpl-3.0.html"><img alt="License" src="https://img.shields.io/badge/License-AGPL%20v3.0-green?style=for-the-badge"></a>  
</p> 

This repository contains the frontend shell for [AUTARQ Office](https://github.com/Autarq/DesktopEditors). AUTARQ Office is a free and open-source office suite that works offline on Windows, Linux, and macOS. It offers compatibility with Microsoft Office formats (DOCX, XLSX, PPTX) and can connect to supported collaboration platforms.

## **Why choose Desktop Editors? ✨**

* **✈️ Work offline, anytime:** Create and edit documents locally without needing an internet connection. Your work is always available on your machine.  
* **☁️ Connect to the cloud:** Integrate seamlessly with Seafile, ownCloud, Nextcloud and other platforms to co-author documents with your team in real time.  
* **📄 Unrivaled compatibility:** Enjoy flawless work with DOCX, XLSX, PPTX, and PDF files. We also support all other popular formats, including, ODT, ODS, ODP, CSV, etc.  
* **🛠️ All the tools you need:** Get a complete set of professional editing and formatting tools for creating stunning text documents, spreadsheets, and presentations.  
* **📝 More than just docs:** View, annotate, and convert PDF files. Create and fill out complex, interactive PDF forms. View and navigate diagrams right in the app.
* **🔒 Secure & private:** Protect your sensitive files with password encryption and digital signatures.  
* **🧩 Extendable with plugins:** Enhance your editing experience with a variety of built-in and third-party plugins like Doc2md, Draw.io, Highlight Code, and others.

## **For developers: Building from source 👨‍💻**

This repository (`desktop-apps`) contains the frontend shell for the Desktop Editors. The core editing engine and conversion components are located in the main [DesktopEditors](https://github.com/Autarq/DesktopEditors) repository.

## Building AUTARQ Office for macOS

`desktop-apps` is not built as a standalone macOS product. The reproducible
macOS build is started from the `DesktopEditors` repository. It builds the
native payload, runs Xcode, exports the branded suite, signs it, and runs the
local verification checks.

### Requirements

* Apple Silicon Mac
* Xcode installed and selected with `xcode-select`
* Git and Python 3
* The Qt version reported by `build/macos/build.sh --check`
* At least 120 GiB free disk space

### Build the suite

Clone the AUTARQ integration branch and initialize its pinned submodules:

```sh
mkdir -p ~/Dev/autarq-office-desktop
cd ~/Dev/autarq-office-desktop

git clone \
  --branch autarq-office \
  https://github.com/Autarq/DesktopEditors.git
cd DesktopEditors
git submodule sync --recursive
git submodule update --init --recursive
```

Run the build from `DesktopEditors/build`:

```sh
cd ~/Dev/autarq-office-desktop/DesktopEditors/build
./macos/build.sh --check
MIN_FREE_GIB=120 ./macos/build.sh arm64
```

The generated app is written to:

```text
DesktopEditors/build/deploy/macos/arm64/AUTARQ Office.app
```

For frontend development, a separate checkout can be selected explicitly with
`DESKTOP_APPS_DIR=/absolute/path/to/desktop-apps`. Release builds should use the
submodule commit pinned by `DesktopEditors`.

Without a Developer ID identity the apps are ad-hoc signed for local testing.
Release DMG signing and notarization require Developer ID and notarization
credentials.
