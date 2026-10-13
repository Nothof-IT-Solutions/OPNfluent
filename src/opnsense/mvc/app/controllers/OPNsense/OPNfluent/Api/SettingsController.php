<?php

/*
 * Copyright (c) 2026 OPNfluent contributors
 * SPDX-License-Identifier: BSD-2-Clause
 */

namespace OPNsense\OPNfluent\Api;

use OPNsense\Base\ApiMutableModelControllerBase;

class SettingsController extends ApiMutableModelControllerBase
{
    protected static $internalModelClass = '\OPNsense\OPNfluent\OPNfluent';
    protected static $internalModelName = 'general';
}
