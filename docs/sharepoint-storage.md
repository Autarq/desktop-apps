# Microsoft SharePoint storage

AUTARQ Office intentionally exposes two cloud choices: AUTARQ Cloud (the
Nextcloud provider) and Microsoft SharePoint.

## Supported portal integration

The SharePoint provider can open a SharePoint portal in the desktop shell and
recognizes the editor page exposed by the ONLYOFFICE/Euro-Office SharePoint
connector. The connector and a reachable document server must be configured on
the SharePoint side before documents can be edited and saved from the portal.

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
