/* OPNfluent runtime branding */
(function () {
    'use strict';

    var originalTitle = document.title;
    var media = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;
    var settings = null;

    function settingValue(name, fallback) {
        var value = settings && settings[name];

        /* OptionField values can be returned as a scalar or as a selected-value
           structure depending on the OPNsense framework version. */
        if (value && typeof value === 'object') {
            if (Object.prototype.hasOwnProperty.call(value, 'selected')) {
                value = value.selected;
            } else if (Object.prototype.hasOwnProperty.call(value, 'value')) {
                value = value.value;
            } else {
                Object.keys(value).some(function (key) {
                    if (value[key] && Number(value[key].selected) === 1) {
                        value = key;
                        return true;
                    }
                    return false;
                });
            }
        }
        if (Array.isArray(value)) {
            value = value.length ? value[0] : fallback;
        }

        return value === undefined || value === null ? fallback : String(value).trim();
    }

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

        var configuredMode = settingValue('colorMode', 'auto').toLowerCase();
        var mode = ['auto', 'light', 'dark'].indexOf(configuredMode) >= 0 ? configuredMode : 'auto';
        var dark = mode === 'dark' || (mode === 'auto' && media && media.matches);
        var accent = validHex(settingValue(dark ? 'accentDark' : 'accentLight', ''), dark ? '#60a5fa' : '#0067c0');
        var background = validHex(settingValue(dark ? 'backgroundDark' : 'backgroundLight', ''), dark ? '#111820' : '#e9f0f7');
        var surface = validHex(settingValue(dark ? 'surfaceDark' : 'surfaceLight', ''), dark ? '#1c242e' : '#f8fbff');
        var opacity = clamp(settingValue('surfaceOpacity', '84'), 60, 100, 84) / 100;
        var blur = clamp(settingValue('blurRadius', '22'), 0, 40, 22);
        var radius = clamp(settingValue('cornerRadius', '10'), 0, 24, 10);
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

        var titlePrefix = settingValue('titlePrefix', '');
        document.title = titlePrefix ? titlePrefix + ' | ' + originalTitle : originalTitle;

        var logo = localPath(settingValue('logoPath', ''));
        if (logo) {
            document.querySelectorAll('.navbar-brand img, .brand img, img.logo, img[src*="default-logo"]').forEach(function (image) {
                image.src = logo;
            });
        }

        var favicon = localPath(settingValue('faviconPath', ''));
        if (favicon) {
            document.querySelectorAll('link[rel~="icon"]').forEach(function (link) {
                link.href = favicon;
            });
        }

        root.setAttribute(
            'data-opnfluent-hide-footer',
            ['1', 'true', 'yes', 'on'].indexOf(settingValue('hideFooter', '0').toLowerCase()) >= 0 ? 'true' : 'false'
        );

        var customCss = settingValue('customCss', '');
        var customStyle = document.getElementById('opnfluent-custom-css');
        if (!customStyle) {
            customStyle = document.createElement('style');
            customStyle.id = 'opnfluent-custom-css';
            document.head.appendChild(customStyle);
        }
        customStyle.textContent = customCss;
    }

    function loadSettings() {
        fetch('/ui/themes/opnfluent/build/branding.json', {
            credentials: 'same-origin',
            headers: {'Accept': 'application/json'},
            cache: 'no-store'
        }).then(function (response) {
            if (!response.ok) {
                throw new Error('settings unavailable');
            }
            return response.json();
        }).then(function (data) {
            settings = data && data.general ? data.general : data;
            applyBranding();
        }).catch(function () {
            /* Keep the safe compiled defaults if public branding is unavailable. */
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
