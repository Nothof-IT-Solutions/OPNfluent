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
- Login-page branding, optional footer hiding and custom CSS
- No external web fonts, scripts, CDNs or runtime network requests

## Installation from an OPNsense repository

OPNfluent is packaged as a single plugin named `os-theme-opnfluent`. The
package contains both the complete theme and the **Theme & Branding** settings,
including the logo and favicon upload APIs. No separate branding plugin is
required.

Install the custom repository by executing the following command in the OPNsense shell:
```sh
fetch -o /usr/local/etc/pkg/repos/opnfluent.conf https://nothof-it-solutions.github.io/OPNfluent/opnfluent.conf
```

After that, the custom repository is configured on the firewall:

1. Refresh **System > Firmware > Status**.
2. Open **System > Firmware > Plugins**.
3. Install **os-theme-opnfluent**.
4. Select `opnfluent` under **System > Settings > Administration > Theme**.
5. Configure branding under **System > Settings > Theme & Branding**.

The OPNsense package hooks automatically refresh the MVC model, ACL and menu
caches during installation and removal.

## Theme & Branding settings

After installing the plugin, open **System > Settings > Theme &
Branding**. Settings are validated and stored in the standard OPNsense
configuration tree under `OPNsense/OPNfluent`.

The selected logo, favicon, title, appearance and accent colors also apply to
the unauthenticated login page. A generated, read-only JavaScript file exposes only
these cosmetic values; the management API remains protected by authentication.
The footer can be hidden globally, and optional custom CSS is appended after
the theme stylesheet.

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

## Building the plugin package

The repository follows the official OPNsense plugin layout. On an OPNsense or
FreeBSD build host, place this project under `misc/theme-opnfluent` in an
OPNsense `plugins` checkout, then run:

```sh
./tools/build-plugin.sh
```

The official plugin framework stages all files, generates the package manifest
and install/deinstall hooks, and produces
`work/pkg/os-theme-opnfluent-x.x.x.pkg`.

Installing that file directly with `pkg add` is suitable for testing, but the
OPNsense firmware page will label it **orphaned** until the same package is
listed in the catalogue of an enabled repository. 

For a signed repository, feed the package into the repository's existing
signing and publication pipeline instead, so its current trust configuration
is preserved. Once the refreshed catalogue is published, the package appears
in the OPNsense firmware plugin list.

## Compatibility and recovery

This release is based on the current official OPNsense 26.7 theme structure.
Because OPNsense pages and
plugins can introduce new markup, test the theme on a staging firewall after
major upgrades. If a custom page is unreadable, switch the configured theme
back to `opnsense` from another admin session.
This plugin is in an early state and was created for a personal project, so there is no warranty everything's working.

## Licensing

OPNfluent-specific CSS and documentation use the BSD 2-Clause licence in the
repository root. Inherited Bootstrap, font and theme assets retain their own
licence notices inside the theme tree (including `LICENSE` and
`build/fonts/LICENSE.SourceSansPro.txt`).

## Disclaimer and Limitation of Liability

**OPNfluent is an independent, experimental, community-developed project and is not affiliated with, endorsed by, or officially supported by the OPNsense project or Deciso B.V.**

This software is provided free of charge, on an **"AS IS" and "AS AVAILABLE"** basis, without any warranties or guarantees of any kind, to the extent permitted by applicable law.

### Functionality and Compatibility

No guarantee is made regarding the functionality, stability, reliability, availability, compatibility, or continued maintenance of this software.

The plugin may contain defects, cause unexpected behavior, interfere with the OPNsense administration interface, or become incompatible with future OPNsense releases.

### Security

No representation or warranty is made that the software is free from vulnerabilities, security defects, maliciously exploitable behavior, or other risks.

Parts of this project have been developed with the assistance of AI-based coding tools. AI-generated contributions may contain errors, vulnerabilities, or other defects.

**The software has not been independently security-audited.**

### Use at Your Own Risk

Installation and use of OPNfluent are entirely at the user's own risk.

Users are strongly encouraged to test the plugin in a non-production environment and create appropriate configuration backups before installation or updates.

The software is not recommended for security-critical or production environments without appropriate independent validation and testing.

### Limitation of Liability

To the maximum extent permitted by applicable law, the project maintainer and contributors disclaim liability for damages arising from the installation, use, malfunction, incompatibility, or unavailability of this software, including but not limited to:

- Loss of data or configuration
- System instability or service interruptions
- Security breaches or unauthorized access
- Network outages or operational disruptions
- Financial losses or other consequential damages

Nothing in this disclaimer excludes or limits liability where such exclusion or limitation is prohibited by applicable law.

The software remains subject to the terms and conditions of the BSD 2-Clause License included in this repository.
