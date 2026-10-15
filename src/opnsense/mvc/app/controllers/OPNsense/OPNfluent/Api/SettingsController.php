<?php

/*
 * Copyright (c) 2026 OPNfluent contributors
 * SPDX-License-Identifier: BSD-2-Clause
 */

namespace OPNsense\OPNfluent\Api;

use OPNsense\Base\ApiMutableModelControllerBase;

class SettingsController extends ApiMutableModelControllerBase
{
    private const PUBLIC_SETTINGS = '/usr/local/opnsense/www/themes/opnfluent/build/branding.js';

    protected static $internalModelClass = '\OPNsense\OPNfluent\OPNfluent';
    protected static $internalModelName = 'general';

    /**
     * Publish cosmetic settings as a static file so the unauthenticated login
     * page can apply branding without exposing the management API.
     */
    protected function setActionHook()
    {
        $settings = $this->getModel()->getNodeContent();
        $payload = [];
        $publicKeys = [
            'colorMode', 'accentLight', 'accentDark', 'backgroundLight',
            'backgroundDark', 'surfaceLight', 'surfaceDark', 'surfaceOpacity',
            'blurRadius', 'cornerRadius', 'titlePrefix', 'logoPath',
            'faviconPath', 'hideFooter', 'customCss'
        ];
        foreach ($publicKeys as $key) {
            $payload[$key] = isset($settings[$key]) ? (string)$settings[$key] : '';
        }

        $encoded = json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        if ($encoded === false) {
            throw new \RuntimeException('Unable to encode public OPNfluent branding settings.');
        }
        $encoded = 'window.OPNfluentBranding=' . $encoded . ';';

        $temporary = self::PUBLIC_SETTINGS . '.' . bin2hex(random_bytes(8)) . '.tmp';
        if (file_put_contents($temporary, $encoded, LOCK_EX) === false ||
            !@chmod($temporary, 0644) || !@rename($temporary, self::PUBLIC_SETTINGS)) {
            @unlink($temporary);
            throw new \RuntimeException('Unable to publish OPNfluent branding settings.');
        }
    }
}
