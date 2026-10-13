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
        faviconPath: ''
    };

    mapDataToFormUI({'frmSettings': '/api/opnfluent/settings/get'}).done(function () {
        $('.selectpicker').selectpicker('refresh');
    });

    $('#saveAct').click(function () {
        saveFormToEndpoint('/api/opnfluent/settings/set', 'frmSettings', function () {
            BootstrapDialog.show({
                type: BootstrapDialog.TYPE_SUCCESS,
                title: '{{ lang._("Theme & Branding") }}',
                message: '{{ lang._("Settings saved. Reload the page to apply branding everywhere.") }}',
                buttons: [{
                    label: '{{ lang._("Reload") }}',
                    action: function () { window.location.reload(); }
                }]
            });
        }, true);
    });

    $('#resetAct').click(function () {
        Object.keys(defaults).forEach(function (key) {
            const field = $('[id="general.' + key + '"]');
            field.val(defaults[key]).trigger('change');
        });
        $('.selectpicker').selectpicker('refresh');
    });
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
