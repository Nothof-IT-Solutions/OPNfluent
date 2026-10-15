<script type="text/javascript">
$(document).ready(function () {
    const defaults = {
        colorMode: 'auto',
        accentLight: '#0067c0',
        accentDark: '#60a5fa',
        backgroundLight: '#e9f0f7',
        backgroundDark: '#111820',
        surfaceLight: '#f8fbff',
        surfaceDark: '#1c242e',
        surfaceOpacity: '84',
        blurRadius: '22',
        cornerRadius: '10',
        titlePrefix: '',
        logoPath: '',
        faviconPath: '',
        hideFooter: '0',
        customCss: ''
    };

    function updatePreview(kind, path) {
        const preview = $('#' + kind + 'Preview');
        if (path) {
            preview.attr('src', path).removeClass('hidden');
        } else {
            preview.attr('src', '').addClass('hidden');
        }
    }

    function persistSettings(onComplete) {
        saveFormToEndpoint('/api/opnfluent/settings/set', 'frmSettings', function () {
            if (onComplete) {
                onComplete();
            }
        }, true);
    }

    function uploadAsset(kind) {
        const input = $('#' + kind + 'Upload').get(0);
        if (!input.files || input.files.length !== 1) {
            BootstrapDialog.alert('{{ lang._("Please select one image first.") }}');
            return;
        }

        const button = $('#' + kind + 'UploadAct');
        const formData = new FormData();
        formData.append('image', input.files[0]);
        button.prop('disabled', true);

        $.ajax({
            url: '/api/opnfluent/assets/upload/' + kind,
            method: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            dataType: 'json'
        }).done(function (data) {
            if (!data || data.status !== 'ok') {
                BootstrapDialog.alert(data && data.message ? data.message : '{{ lang._("Image upload failed.") }}');
                return;
            }

            const fieldName = kind === 'logo' ? 'logoPath' : 'faviconPath';
            $('[id="general.' + fieldName + '"]').val(data.path).trigger('change');
            updatePreview(kind, data.path);
            persistSettings(function () {
                BootstrapDialog.show({
                    type: BootstrapDialog.TYPE_SUCCESS,
                    title: '{{ lang._("Theme & Branding") }}',
                    message: '{{ lang._("Image uploaded and branding settings saved.") }}',
                    buttons: [{
                        label: '{{ lang._("Reload") }}',
                        action: function () { window.location.reload(); }
                    }]
                });
            });
        }).fail(function (xhr) {
            const message = xhr.responseJSON && xhr.responseJSON.errorMessage ?
                xhr.responseJSON.errorMessage : '{{ lang._("Image upload failed.") }}';
            BootstrapDialog.alert(message);
        }).always(function () {
            button.prop('disabled', false);
        });
    }

    mapDataToFormUI({'frmSettings': '/api/opnfluent/settings/get'}).done(function () {
        $('.selectpicker').selectpicker('refresh');
        updatePreview('logo', $('[id="general.logoPath"]').val());
        updatePreview('favicon', $('[id="general.faviconPath"]').val());
    });

    $('#saveAct').click(function () {
        persistSettings(function () {
            BootstrapDialog.show({
                type: BootstrapDialog.TYPE_SUCCESS,
                title: '{{ lang._("Theme & Branding") }}',
                message: '{{ lang._("Settings saved. Reload the page to apply branding everywhere.") }}',
                buttons: [{
                    label: '{{ lang._("Reload") }}',
                    action: function () { window.location.reload(); }
                }]
            });
        });
    });

    $('#resetAct').click(function () {
        Object.keys(defaults).forEach(function (key) {
            const field = $('[id="general.' + key + '"]');
            field.val(defaults[key]).trigger('change');
        });
        $('.selectpicker').selectpicker('refresh');
        updatePreview('logo', '');
        updatePreview('favicon', '');
    });

    $('#logoUploadAct').click(function () { uploadAsset('logo'); });
    $('#faviconUploadAct').click(function () { uploadAsset('favicon'); });
});
</script>

<ul class="nav nav-tabs" data-tabs="tabs">
  <li class="active"><a data-toggle="tab" href="#branding">{{ lang._('Theme & Branding') }}</a></li>
</ul>

<div class="tab-content content-box">
  <div id="branding" class="tab-pane fade in active">
    {{ partial('layout_partials/base_form', ['fields': settingsForm, 'id': 'frmSettings']) }}
  </div>
</div>

<section class="page-content-main">
  <div class="content-box">
    <div class="content-box-head container-fluid">
      <h3>{{ lang._('Image uploads') }}</h3>
    </div>
    <div class="content-box-main col-md-12">
      <div class="row" style="padding: 15px 0;">
        <div class="col-md-6">
          <label for="logoUpload">{{ lang._('Logo image') }}</label>
          <input id="logoUpload" type="file" class="form-control" accept="image/png,image/jpeg,image/webp"/>
          <p class="help-block">{{ lang._('PNG, JPEG or WebP; maximum 2 MiB and 4096 × 4096 pixels.') }}</p>
          <button class="btn btn-default" id="logoUploadAct" type="button">
            <i class="fa fa-upload"></i> {{ lang._('Upload logo') }}
          </button>
          <div style="margin-top: 15px; min-height: 48px;">
            <img id="logoPreview" class="hidden" alt="{{ lang._('Logo preview') }}" style="max-width: 280px; max-height: 96px;"/>
          </div>
        </div>
        <div class="col-md-6">
          <label for="faviconUpload">{{ lang._('Favicon image') }}</label>
          <input id="faviconUpload" type="file" class="form-control" accept="image/png,image/jpeg,image/webp,image/x-icon,image/vnd.microsoft.icon,.ico"/>
          <p class="help-block">{{ lang._('PNG, JPEG, WebP or ICO; maximum 512 KiB and 1024 × 1024 pixels.') }}</p>
          <button class="btn btn-default" id="faviconUploadAct" type="button">
            <i class="fa fa-upload"></i> {{ lang._('Upload favicon') }}
          </button>
          <div style="margin-top: 15px; min-height: 48px;">
            <img id="faviconPreview" class="hidden" alt="{{ lang._('Favicon preview') }}" style="max-width: 64px; max-height: 64px;"/>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="page-content-main">
  <div class="content-box">
    <div class="col-md-12">
      <br/>
      <button class="btn btn-primary" id="saveAct" type="button">
        <i class="fa fa-save"></i> {{ lang._('Save') }}
      </button>
      <button class="btn btn-default" id="resetAct" type="button">
        <i class="fa fa-undo"></i> {{ lang._('Restore defaults') }}
      </button>
      <br/><br/>
    </div>
  </div>
</section>
