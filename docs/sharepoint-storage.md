# Microsoft SharePoint storage

AUTARQ Office intentionally exposes two cloud choices: AUTARQ Cloud (the
Nextcloud provider) and Microsoft SharePoint.

## Supported portal integration

The SharePoint provider opens Microsoft's tenant-independent SharePoint entry
page at `https://m365.cloud.microsoft/launch/sharepoint`. Microsoft handles the
work or school account login, MFA, and tenant discovery. The user is then sent
to the SharePoint start page and can access every site and document library
their Microsoft account is allowed to use. AUTARQ Office does not ask for a
tenant URL and does not embed or store Microsoft credentials.

The desktop shell recognizes the editor page exposed by the ONLYOFFICE/
Euro-Office SharePoint connector. The connector and a reachable document
server must be configured on the SharePoint side before documents can be
edited and saved with the integrated editor. Without that connector, the
SharePoint portal remains usable, but Microsoft controls whether a selected
file opens in a web app or is downloaded.

## SharePoint Online native storage

Direct SharePoint Online storage is a separate integration. It must not embed a
client secret in the desktop binary. The implementation requires:

1. A Microsoft Entra public-client app registration for AUTARQ Office.
2. Authorization Code with PKCE using a system browser and platform redirect
   URIs.
3. Delegated Microsoft Graph permissions for the user's files and sites.
4. A native file browser for SharePoint sites and document libraries.
5. Download, local edit, conflict detection, and upload/save-back through
   Microsoft Graph driveItem APIs.
6. Refresh-token storage in Keychain, Credential Manager, or Secret Service.

Until that component is complete, the SharePoint entry represents the portal
connector path. It must not be described as direct Graph-backed storage in
release notes.
