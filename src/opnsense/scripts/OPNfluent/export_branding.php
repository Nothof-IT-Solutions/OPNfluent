<?php

/*
 * Copyright (c) 2026 OPNfluent contributors
 * SPDX-License-Identifier: BSD-2-Clause
 */

require_once 'config.inc';

$defaults = [
    'colorMode' => 'auto',
    'accentLight' => '#0067c0',
    'accentDark' => '#60a5fa',
    'backgroundLight' => '#e9f0f7',
    'backgroundDark' => '#111820',
    'surfaceLight' => '#f8fbff',
    'surfaceDark' => '#1c242e',
    'surfaceOpacity' => '84',
    'blurRadius' => '22',
    'cornerRadius' => '10',
    'titlePrefix' => '',
    'logoPath' => '',
    'faviconPath' => '',
    'hideFooter' => '0',
    'customCss' => '',
];

$configured = $config['OPNsense']['OPNfluent']['general'] ?? [];
foreach ($defaults as $key => $fallback) {
    $defaults[$key] = isset($configured[$key]) && !is_array($configured[$key]) ? (string)$configured[$key] : $fallback;
}

$target = '/usr/local/opnsense/www/themes/opnfluent/build/branding.json';
$temporary = $target . '.' . bin2hex(random_bytes(8)) . '.tmp';
$encoded = json_encode($defaults, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);

if ($encoded === false || file_put_contents($temporary, $encoded, LOCK_EX) === false ||
    !chmod($temporary, 0644) || !rename($temporary, $target)) {
    @unlink($temporary);
    fwrite(STDERR, "Unable to publish OPNfluent branding settings.\n");
    exit(1);
}
