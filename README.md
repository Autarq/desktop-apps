# Desktop apps: Frontend

<p align="center"> 
  <a href="http://www.gnu.org/licenses/agpl-3.0.html"><img alt="License" src="https://img.shields.io/badge/License-AGPL%20v3.0-green?style=for-the-badge"></a>  
</p> 

This repo contains the frontend for [Desktop Editors](https://repo.mwaysolutions.com/blockscape/autarq/office/desktop-apps/DesktopEditors) which builds the program interface. [Desktop Editors](https://repo.mwaysolutions.com/blockscape/autarq/office/desktop-apps/DesktopEditors) is a free and open-source office suite that works offline on your Windows, Linux, and macOS computer. It offers maximum compatibility with Microsoft Office formats (DOCX, XLSX, PPTX) and allows you to connect to the cloud for real-time collaboration.

## **Why choose Desktop Editors? ✨**

* **✈️ Work offline, anytime:** Create and edit documents locally without needing an internet connection. Your work is always available on your machine.  
* **☁️ Connect to the cloud:** Integrate seamlessly with Seafile, ownCloud, Nextcloud and other platforms to co-author documents with your team in real time.  
* **📄 Unrivaled compatibility:** Enjoy flawless work with DOCX, XLSX, PPTX, and PDF files. We also support all other popular formats, including, ODT, ODS, ODP, CSV, etc.  
* **🛠️ All the tools you need:** Get a complete set of professional editing and formatting tools for creating stunning text documents, spreadsheets, and presentations.  
* **📝 More than just docs:** View, annotate, and convert PDF files. Create and fill out complex, interactive PDF forms. View and navigate diagrams right in the app.
* **🔒 Secure & private:** Protect your sensitive files with password encryption and digital signatures.  
* **🧩 Extendable with plugins:** Enhance your editing experience with a variety of built-in and third-party plugins like Doc2md, Draw.io, Highlight Code, and others.
* **🤖 AI integration:** Connect any AI model (local or cloud-based) for tasks like chatbot requests, translation, OCR, etc. Use AI agents to generate new files, list folder contents, preview file details without opening them in the editor, auto-fill forms with provided data, etc.

## **For developers: Building from source 👨‍💻**

This repository (`desktop-apps`) contains the frontend shell for the Desktop Editors. The core editing engine and conversion components are located in the main [DesktopEditors](https://repo.mwaysolutions.com/blockscape/autarq/office/desktop-apps/DesktopEditors) repository.

## Building the AUTARQ Office macOS apps

`desktop-apps` is not built as a standalone macOS product. The reproducible
AUTARQ macOS build is started from the `DesktopEditors` repository, which builds
the native payload, runs Xcode, exports the branded apps, signs them, and runs
the local verification checks.

### Requirements

* Apple Silicon Mac
* Xcode installed and selected with `xcode-select`
* Git and Python 3
* Qt 5, for example Homebrew `qt@5`
* At least 120 GiB free disk space

### Build with this repo as the app frontend

Clone both AUTARQ repositories next to each other:

```sh
mkdir -p ~/Dev/autarq-office-desktop
cd ~/Dev/autarq-office-desktop

git clone \
  --branch codex/macos-build-docs \
  ssh://git@repo.mwaysolutions.com:2022/blockscape/autarq/office/desktop-apps/DesktopEditors.git

git clone \
  --branch codex/macos-autarq-office-branding \
  ssh://git@repo.mwaysolutions.com:2022/blockscape/autarq/office/desktop-apps/desktop-apps.git
```

Initialize the `DesktopEditors` submodules:

```sh
cd ~/Dev/autarq-office-desktop/DesktopEditors
git submodule sync --recursive
git submodule update --init --recursive
```

Run the build from `DesktopEditors/build`, pointing it at this `desktop-apps`
checkout:

```sh
cd ~/Dev/autarq-office-desktop/DesktopEditors/build
./macos/build.sh --check
DESKTOP_APPS_DIR=~/Dev/autarq-office-desktop/desktop-apps \
  MIN_FREE_GIB=120 ./macos/build.sh arm64
```

The generated apps are written to:

```text
DesktopEditors/build/deploy/macos/arm64/AUTARQ Write.app
DesktopEditors/build/deploy/macos/arm64/AUTARQ Sheets.app
DesktopEditors/build/deploy/macos/arm64/AUTARQ Keynote.app
DesktopEditors/build/deploy/macos/arm64/AUTARQ PDF.app
```

The build installs the pinned ONLYOFFICE draw.io plugin into the supported
Write, Sheets and Keynote bundles. `macos/scripts/install-drawio-plugin.sh` can
also install the plugin into a prepared `sdkjs-plugins` directory, for example
when testing the Xcode payload manually.

The bundled AI agent is preconfigured from the `DesktopEditors` macOS exporter
with the AUTARQ OpenAI-compatible endpoint. Pass `AUTARQ_AI_API_KEY` only for a
private local build where embedding the key into the generated `.app` bundle is
acceptable; do not commit keys.

Without a Developer ID identity the apps are ad-hoc signed for local testing.
Release DMG signing and notarization require Developer ID and notarization
credentials.
