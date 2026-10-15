<?php

/*
 * Copyright (c) 2026 OPNfluent contributors
 * SPDX-License-Identifier: BSD-2-Clause
 */

namespace OPNsense\OPNfluent\Api;

use OPNsense\Base\ApiControllerBase;

class AssetsController extends ApiControllerBase
{
    private const ASSET_DIRECTORY = '/usr/local/opnsense/www/themes/opnfluent/build/images/custom';
    private const WEB_DIRECTORY = '/ui/themes/opnfluent/build/images/custom';
    private const ALLOWED_TYPES = [
        'image/png' => 'png',
        'image/jpeg' => 'jpg',
        'image/webp' => 'webp',
        'image/x-icon' => 'ico',
        'image/vnd.microsoft.icon' => 'ico',
    ];

    /**
     * Store a validated branding image and return its public same-origin path.
     *
     * @param string $kind logo or favicon
     * @return array status and stored path or a user-facing error
     */
    public function uploadAction($kind = null)
    {
        try {
            return $this->storeUpload($kind);
        } catch (\Throwable $error) {
            syslog(LOG_ERR, sprintf('OPNfluent branding upload failed: %s', $error->getMessage()));
            return $this->failure(gettext('The image could not be processed. Check the system log for details.'));
        }
    }

    private function storeUpload($kind)
    {
        if (!$this->request->isPost()) {
            return $this->failure(gettext('Only POST requests are accepted.'));
        }

        $this->throwReadOnly();

        if (!in_array($kind, ['logo', 'favicon'], true)) {
            return $this->failure(gettext('Unknown branding asset type.'));
        }

        $files = $this->request->getUploadedFiles(false);
        if (count($files) !== 1) {
            return $this->failure(gettext('Select exactly one image to upload.'));
        }

        $file = array_values($files)[0];
        if ($file->getError() !== UPLOAD_ERR_OK) {
            return $this->failure(gettext('The image upload did not complete successfully.'));
        }

        $maxBytes = $kind === 'favicon' ? 524288 : 2097152;
        if ($file->getSize() < 1 || $file->getSize() > $maxBytes) {
            return $this->failure(sprintf(
                gettext('The %s image must not exceed %s.'),
                $kind,
                $kind === 'favicon' ? '512 KiB' : '2 MiB'
            ));
        }

        $temporaryUpload = $file->getTempName();
        $imageInfo = @getimagesize($temporaryUpload);
        if ($imageInfo === false || empty($imageInfo['mime'])) {
            return $this->failure(gettext('The uploaded file is not a valid image.'));
        }

        $mimeType = strtolower($imageInfo['mime']);
        if (!isset(self::ALLOWED_TYPES[$mimeType])) {
            return $this->failure(gettext('Only PNG, JPEG, WebP and ICO images are supported.'));
        }
        if ($kind === 'logo' && self::ALLOWED_TYPES[$mimeType] === 'ico') {
            return $this->failure(gettext('ICO files are only supported for favicons.'));
        }

        $maxDimension = $kind === 'favicon' ? 1024 : 4096;
        if ($imageInfo[0] < 1 || $imageInfo[1] < 1 || $imageInfo[0] > $maxDimension || $imageInfo[1] > $maxDimension) {
            return $this->failure(sprintf(
                gettext('Image dimensions must not exceed %1$d × %1$d pixels.'),
                $maxDimension
            ));
        }

        if (!is_dir(self::ASSET_DIRECTORY) && !@mkdir(self::ASSET_DIRECTORY, 0755, true)) {
            return $this->failure(gettext('The branding image directory could not be created.'));
        }
        if (!is_writable(self::ASSET_DIRECTORY)) {
            return $this->failure(gettext('The branding image directory is not writable.'));
        }

        $extension = self::ALLOWED_TYPES[$mimeType];
        $digest = substr(hash_file('sha256', $temporaryUpload), 0, 16);
        $filename = sprintf('%s-%s.%s', $kind, $digest, $extension);
        $target = self::ASSET_DIRECTORY . '/' . $filename;

        if (!file_exists($target)) {
            $staging = self::ASSET_DIRECTORY . '/.' . bin2hex(random_bytes(12)) . '.upload';
            if (!$file->moveTo($staging)) {
                return $this->failure(gettext('The uploaded image could not be stored.'));
            }
            @chmod($staging, 0644);
            if (!@rename($staging, $target)) {
                @unlink($staging);
                return $this->failure(gettext('The uploaded image could not be activated.'));
            }
        }

        foreach (glob(self::ASSET_DIRECTORY . '/' . $kind . '-*') ?: [] as $oldAsset) {
            if ($oldAsset !== $target && is_file($oldAsset)) {
                @unlink($oldAsset);
            }
        }

        return [
            'status' => 'ok',
            'path' => self::WEB_DIRECTORY . '/' . $filename,
            'width' => $imageInfo[0],
            'height' => $imageInfo[1],
            'mime' => $mimeType,
        ];
    }

    private function failure($message)
    {
        return ['status' => 'failed', 'message' => $message];
    }
}
