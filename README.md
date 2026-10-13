# OPNfluent

OPNfluent is an OPNsense administration theme with Fluent-inspired controls and
layered Mica-style surfaces. It keeps the established OPNsense page structure,
so legacy pages and newer MVC views remain usable.

## Highlights

- Mica-style translucent navigation, panels, dialogs and flyouts
- Automatic light/dark mode via the browser/operating-system preference
- Accessible keyboard focus, status colors and high-contrast text
- Responsive layout and reduced-motion/reduced-transparency fallbacks
- Styling for Bootstrap tables, Bootgrid, Tabulator, dashboard widgets and forms
- Configuration page at **System > Settings > Theme & Branding**
- Configurable light/dark colors, Mica opacity, blur and corner radius
- Optional page-title prefix plus validated logo and favicon uploads
- No external web fonts, scripts, CDNs or runtime network requests

## Manual installation

For the theme only, copy the theme directory to the firewall (as `root`):

```sh
scp -r src/opnsense/www/themes/opnfluent root@FIREWALL:/tmp/
ssh root@FIREWALL
cp -R /tmp/opnfluent /usr/local/opnsense/www/themes/
```

Then select **System > Settings > Administration > Theme > opnfluent** and
save. Keep an existing admin session open until the new theme has been checked.

The **Theme & Branding** settings page is part of the packaged plugin and is
not installed by the theme-only copy command. To install it manually for
development, copy the complete contents of `src/opnsense/` over
`/usr/local/opnsense/`, then rebuild the OPNsense menu and ACL caches or reboot.
Production installations should use the generated `os-theme-opnfluent` package.

## Theme & Branding settings

After installing the complete plugin, open **System > Settings > Theme &
Branding**. Settings are validated and stored in the standard OPNsense
configuration tree under `OPNsense/OPNfluent`.

Logo and favicon images can be uploaded directly on the settings page. Uploads
accept PNG, JPEG and WebP images (plus ICO for favicons), validate their actual
image type, dimensions and size, and use content-hashed filenames to avoid
stale browser caches.

Alternatively, logo and favicon values may reference local web paths. Place
custom assets in the theme's `build/images` directory (ideally as part of your
package/deployment) and use paths such as:

```text
/ui/themes/opnfluent/build/images/company-logo.svg
/ui/themes/opnfluent/build/images/company-favicon.png
```

External URLs and data URLs are deliberately rejected. This preserves the
OPNsense content-security policy and prevents browsers from leaking firewall
access metadata to third parties.

To uninstall, first switch back to the `opnsense` theme, then remove:

```sh
rm -rf /usr/local/opnsense/www/themes/opnfluent
```

## Plugin packaging

The repository follows the official OPNsense plugins layout. Place `OPNfluent`
under `misc/theme-opnfluent` in an OPNsense plugins checkout and use the normal
plugin build process. The resulting package name is `os-theme-opnfluent`.

## Customisation

All visual tokens live at the top of:

`src/opnsense/www/themes/opnfluent/build/css/fluent-mica.css`

Change `--of-accent` and the related accent variables to apply a custom brand
colour. After editing, run `tools/build-theme.ps1` to refresh the compiled
`main.css` bundle.

## Compatibility and recovery

This release is based on the current official OPNsense 26.7 theme structure.
Because OPNsense pages and
plugins can introduce new markup, test the theme on a staging firewall after
major upgrades. If a custom page is unreadable, switch the configured theme
back to `opnsense` from another admin session.

## Licensing

OPNfluent-specific CSS and documentation use the BSD 2-Clause licence in the
repository root. Inherited Bootstrap, font and theme assets retain their own
licence notices inside the theme tree (including `LICENSE` and
`build/fonts/LICENSE.SourceSansPro.txt`).
