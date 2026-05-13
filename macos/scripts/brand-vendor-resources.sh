#!/usr/bin/env bash
set -euo pipefail

vendor_dir="${1:?vendor resources directory is required}"
product_name="${2:-AUTARQ Office}"
export EO_PRODUCT_NAME="${product_name}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
desktop_apps_dir="$(cd "${script_dir}/../.." && pwd)"
loginpage_dir="${desktop_apps_dir}/common/loginpage"
branding_dir="${desktop_apps_dir}/macos/ONLYOFFICE/Resources/Branding"

if [[ ! -d "${vendor_dir}" ]]; then
  echo "brand-vendor-resources: vendor directory does not exist: ${vendor_dir}" >&2
  exit 1
fi

find "${vendor_dir}" -type f \
  \( -name '*.html' -o -name '*.htm' -o -name '*.js' -o -name '*.json' -o -name '*.svg' -o -name '*.md' -o -name '*.txt' -o -name '*.css' \) \
  -print0 | xargs -0 perl -0pi -CS -e '
    use utf8;
    use open qw(:std :encoding(UTF-8));
    my $product = $ENV{"EO_PRODUCT_NAME"} || "AUTARQ Office";
    my $product_url = "https://repo.mwaysolutions.com/blockscape/autarq/office/desktop-apps";
    my $legacy_dash = "Euro" . "-Office";
    my $legacy_space = "Euro " . "Office";
    my $legacy_slug = "euro" . "-office";
    my $legacy_mark = "euro" . "OfficeMark";

    s/ONLYOFFICE Documents/${product} Documents/g;
    s/ONLYOFFICE Desktop Editors/${product} Desktop Editors/g;
    s/ONLYOFFICE Desktop Editoren/${product} Desktop Editoren/g;
    s/ONLYOFFICE Cloud/${product}/g;

    s/ONLYOFFICE Document Editor/${product} Document Editor/g;
    s/ONLYOFFICE Spreadsheet Editor/${product} Spreadsheet Editor/g;
    s/ONLYOFFICE Presentation Editor/${product} Presentation Editor/g;
    s/ONLYOFFICE PDF Editor/${product} PDF Editor/g;

    s/ONLYOFFICE Dokumenteneditor/${product} Dokumenteneditor/g;
    s/ONLYOFFICE Tabellenkalkulation/${product} Tabellenkalkulation/g;
    s/ONLYOFFICE Tabellenkalkulationseditor/${product} Tabellenkalkulationseditor/g;
    s/ONLYOFFICE Präsentationseditor/${product} Präsentationseditor/g;
    s/ONLYOFFICE PDF-Editor/${product} PDF-Editor/g;
    s/ONLYOFFICE Docs/${product} Docs/g;
    s/ONLYOFFICE(?= Pr\S*sentationseditor)/${product}/g;
    s/ONLYOFFICE(?=-Editor-Oberfl)/${product}/g;

    s/ONLYOFFICE editors interface/${product} editors interface/g;
    s/ONLYOFFICE editor'\''s interface/${product} editor'\''s interface/g;
    s/ONLYOFFICE-Editor-Oberfläche/${product}-Editor-Oberfläche/g;
    s/von ONLYOFFICE/von ${product}/g;
    s/Editor-Oberfläche von ONLYOFFICE/Editor-Oberfläche von ${product}/g;

    s#https://github\.com/\Q$legacy_dash\E#${product_url}#g;
    s#github\.com/\Q$legacy_dash\E#repo.mwaysolutions.com/blockscape/autarq/office/desktop-apps#g;
    s#github\.com/\Q$legacy_slug\E#repo.mwaysolutions.com/blockscape/autarq/office/desktop-apps#g;
    s/\Q$legacy_dash\E/${product}/g;
    s/\Q$legacy_space\E/${product}/g;
    s/\Q$legacy_slug\E/autarq-office/g;
    s/\Q$legacy_mark\E/autarqOfficeMark/g;
  '

provider_assets_dir="${vendor_dir}/providers/onlyoffice/assets"
if [[ -d "${provider_assets_dir}" ]]; then
  for asset in buttonlogo.svg buttonlogo_dark.svg listicon.svg listicon_dark.svg; do
    if [[ -f "${loginpage_dir}/providers/onlyoffice/assets/${asset}" ]]; then
      cp -f "${loginpage_dir}/providers/onlyoffice/assets/${asset}" "${provider_assets_dir}/${asset}"
    fi
  done
fi

for logo in idx-logo-light.svg idx-logo-dark.svg; do
  if [[ -f "${vendor_dir}/login/res/img/${logo}" && -f "${loginpage_dir}/res/img/${logo}" ]]; then
    cp -f "${loginpage_dir}/res/img/${logo}" "${vendor_dir}/login/res/img/${logo}"
  fi
done

about_logo="${vendor_dir}/editors/web-apps/apps/common/main/resources/img/about/logo.svg"
if [[ -f "${about_logo}" && -f "${branding_dir}/autarq-about-logo.svg" ]]; then
  cp -f "${branding_dir}/autarq-about-logo.svg" "${about_logo}"
fi
