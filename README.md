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
- No external web fonts, scripts, CDNs or runtime network requests

## Manual installation

Copy the theme directory to the firewall (as `root`):

```sh
scp -r src/opnsense/www/themes/opnfluent root@FIREWALL:/tmp/
ssh root@FIREWALL
cp -R /tmp/opnfluent /usr/local/opnsense/www/themes/
```

Then select **System > Settings > Administration > Theme > opnfluent** and
save. Keep an existing admin session open until the new theme has been checked.

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

This first release is structured against the current official OPNsense theme
layout and uses the Tukan compatibility layer. Because OPNsense pages and
plugins can introduce new markup, test the theme on a staging firewall after
major upgrades. If a custom page is unreadable, switch the configured theme
back to `opnsense` from another admin session.

## Licensing

OPNfluent-specific CSS and documentation use the BSD 2-Clause licence in the
repository root. Inherited Bootstrap, font and theme assets retain their own
licence notices inside the theme tree (including `LICENSE` and
`build/fonts/LICENSE.SourceSansPro.txt`).
