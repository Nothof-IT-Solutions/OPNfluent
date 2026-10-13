/* OPNfluent runtime branding */
(function () {
    'use strict';

    /* MVC normally falls back to the stock theme script. Load it explicitly
       because the OPNfluent runtime script occupies the theme override slot. */
    var stockTheme = document.createElement('script');
    stockTheme.src = '/ui/themes/opnsense/build/js/theme.js';
    stockTheme.async = false;
    document.head.appendChild(stockTheme);

    var originalTitle = document.title;
    var media = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;
    var settings = null;

    function validHex(value, fallback) {
        return /^#[0-9a-f]{6}$/i.test(value || '') ? value : fallback;
    }

    function rgba(hex, opacity) {
        var clean = hex.substring(1);
        return 'rgba(' + parseInt(clean.substring(0, 2), 16) + ',' +
            parseInt(clean.substring(2, 4), 16) + ',' +
            parseInt(clean.substring(4, 6), 16) + ',' + opacity + ')';
    }

    function clamp(value, min, max, fallback) {
        var number = parseInt(value, 10);
        return isNaN(number) ? fallback : Math.min(max, Math.max(min, number));
    }

    function localPath(value) {
        return typeof value === 'string' && /^\/[0-9a-z._~!$&'()*+,;=:@%\/-]+$/i.test(value) ? value : '';
    }

    function applyBranding() {
        if (!settings) {
            return;
        }

        var mode = ['auto', 'light', 'dark'].indexOf(settings.colorMode) >= 0 ? settings.colorMode : 'auto';
        var dark = mode === 'dark' || (mode === 'auto' && media && media.matches);
        var accent = validHex(dark ? settings.accentDark : settings.accentLight, dark ? '#60a5fa' : '#0067c0');
        var background = validHex(dark ? settings.backgroundDark : settings.backgroundLight, dark ? '#111820' : '#e9f0f7');
        var surface = validHex(dark ? settings.surfaceDark : settings.surfaceLight, dark ? '#1c242e' : '#f8fbff');
        var opacity = clamp(settings.surfaceOpacity, 60, 100, 84) / 100;
        var blur = clamp(settings.blurRadius, 0, 40, 22);
        var radius = clamp(settings.cornerRadius, 0, 24, 10);
        var root = document.documentElement;

        root.setAttribute('data-opnfluent-mode', dark ? 'dark' : 'light');
        root.style.setProperty('--of-accent', accent);
        root.style.setProperty('--of-accent-hover', accent);
        root.style.setProperty('--of-accent-soft', rgba(accent, dark ? 0.16 : 0.12));
        root.style.setProperty('--of-accent-border', rgba(accent, dark ? 0.38 : 0.32));
        root.style.setProperty('--of-bg', background);
        root.style.setProperty('--of-mica-solid', surface);
        root.style.setProperty('--of-mica', rgba(surface, opacity));
        root.style.setProperty('--of-layer', rgba(surface, Math.max(0.60, opacity - 0.06)));
        root.style.setProperty('--of-layer-hover', rgba(surface, Math.min(1, opacity + 0.10)));
        root.style.setProperty('--of-flyout', rgba(surface, Math.min(1, opacity + 0.10)));
        root.style.setProperty('--of-blur', blur ? 'blur(' + blur + 'px) saturate(135%)' : 'none');
        root.style.setProperty('--of-radius', radius + 'px');
        root.style.setProperty('--of-radius-sm', Math.max(0, radius - 4) + 'px');

        document.title = settings.titlePrefix ? settings.titlePrefix + ' | ' + originalTitle : originalTitle;

        var logo = localPath(settings.logoPath);
        if (logo) {
            document.querySelectorAll('.navbar-brand img, .brand img, img.logo, img[src*="default-logo"]').forEach(function (image) {
                image.src = logo;
            });
        }

        var favicon = localPath(settings.faviconPath);
        if (favicon) {
            document.querySelectorAll('link[rel~="icon"]').forEach(function (link) {
                link.href = favicon;
            });
        }
    }

    function loadSettings() {
        fetch('/api/opnfluent/settings/get', {
            credentials: 'same-origin',
            headers: {'Accept': 'application/json'}
        }).then(function (response) {
            if (!response.ok) {
                throw new Error('settings unavailable');
            }
            return response.json();
        }).then(function (data) {
            settings = data && data.general ? data.general : null;
            applyBranding();
        }).catch(function () {
            /* Login pages and restricted users keep the safe compiled defaults. */
        });
    }

    if (media) {
        if (media.addEventListener) {
            media.addEventListener('change', applyBranding);
        } else if (media.addListener) {
            media.addListener(applyBranding);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', loadSettings);
    } else {
        loadSettings();
    }
}());
