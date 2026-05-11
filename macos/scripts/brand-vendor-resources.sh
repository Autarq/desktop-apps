#!/usr/bin/env bash
set -euo pipefail

vendor_dir="${1:?vendor resources directory is required}"
product_name="${2:-AUTARQ Office}"
export EO_PRODUCT_NAME="${product_name}"

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
