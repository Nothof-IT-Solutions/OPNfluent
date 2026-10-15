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

## Installation from an OPNsense repository

OPNfluent is packaged as a single plugin named `os-theme-opnfluent`. The
package contains both the complete theme and the **Theme & Branding** settings,
including the logo and favicon upload APIs. No separate branding plugin is
required.

After the package has been published to the custom repository already
configured on the firewall:

1. Refresh **System > Firmware > Status**.
2. Open **System > Firmware > Plugins**.
3. Install **os-theme-opnfluent**.
4. Select `opnfluent` under **System > Settings > Administration > Theme**.
5. Configure branding under **System > Settings > Theme & Branding**.

The OPNsense package hooks automatically refresh the MVC model, ACL and menu
caches during installation and removal.

## Manual installation for development

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

## Building the plugin package

The repository follows the official OPNsense plugin layout. On an OPNsense or
FreeBSD build host, place this project under `misc/theme-opnfluent` in an
OPNsense `plugins` checkout, then run:

```sh
./tools/build-plugin.sh
```

The official plugin framework stages all files, generates the package manifest
and install/deinstall hooks, and produces
`work/pkg/os-theme-opnfluent-1.4.2.pkg`.

Installing that file directly with `pkg add` is suitable for testing, but the
OPNsense firmware page will label it **orphaned** until the same package is
listed in the catalogue of an enabled repository. Publish it and regenerate
the repository metadata before using the firmware page for normal installs and
updates.

To copy that package into an existing unsigned custom package repository and
regenerate its catalogue:

```sh
./tools/update-plugin-repository.sh \
  work/pkg/os-theme-opnfluent-1.4.2.pkg /path/to/repository
```

For a signed repository, feed the package into the repository's existing
signing and publication pipeline instead, so its current trust configuration
is preserved. Once the refreshed catalogue is published, the package appears
in the OPNsense firmware plugin list.

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
