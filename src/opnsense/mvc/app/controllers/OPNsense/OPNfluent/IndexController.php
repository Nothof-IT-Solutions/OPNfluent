<?php

/*
 * Copyright (c) 2026 OPNfluent contributors
 * SPDX-License-Identifier: BSD-2-Clause
 */

namespace OPNsense\OPNfluent;

use OPNsense\Base\IndexController as BaseIndexController;

class IndexController extends BaseIndexController
{
    public function indexAction()
    {
        $this->view->settingsForm = $this->getForm('settings');
        $this->view->pick('OPNsense/OPNfluent/index');
    }
}
