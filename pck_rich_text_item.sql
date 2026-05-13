--------------------------------------------------------------------------------
-- Rich Text Editor - APEX Item Plugin Render Procedure
-- Koristi Quill.js 1.3.7
-- Owner: Bjurisic | APEX 24.2.0
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE render_rich_text_item(
    p_item   IN            apex_plugin.t_item,
    p_plugin IN            apex_plugin.t_plugin,
    p_param  IN            apex_plugin.t_item_render_param,
    p_result IN OUT NOCOPY apex_plugin.t_item_render_result
) AS
    l_item_id   VARCHAR2(100) := apex_escape.html_attribute(p_item.name);
    l_value     VARCHAR2(32767) := p_param.value;
    l_height    PLS_INTEGER  := 300;   -- promijeni po potrebi
    l_toolbar   VARCHAR2(10) := 'FULL'; -- 'FULL' ili 'BASIC'
    l_readonly  BOOLEAN := p_param.is_readonly OR p_param.is_printer_friendly;

    l_toolbar_cfg VARCHAR2(4000);
BEGIN
    -- Toolbar konfiguracija ovisno o atributu
    IF l_toolbar = 'BASIC' THEN
        l_toolbar_cfg :=
            '["bold","italic","underline"],'
         || '[{"list":"ordered"},{"list":"bullet"}],'
         || '["clean"]';
    ELSE
        l_toolbar_cfg :=
            '[{"header":[1,2,3,false]}],'
         || '["bold","italic","underline","strike"],'
         || '[{"color":[]},{"background":[]}],'
         || '[{"list":"ordered"},{"list":"bullet"}],'
         || '[{"indent":"-1"},{"indent":"+1"}],'
         || '[{"align":[]}],'
         || '["link","blockquote","code-block"],'
         || '["clean"]';
    END IF;

    -- Quill CSS
    apex_css.add_file(
        p_name      => 'quill.snow',
        p_directory => 'https://cdn.quilljs.com/1.3.7/',
        p_key       => 'quill-snow-css'
    );

    -- Inline stilovi za integraciju s APEX temom
    apex_css.add(
        p_css => '
.rte-wrapper { border: 1px solid #ccc; border-radius: 4px; background: #fff; }
.rte-wrapper .ql-toolbar { border-top: none; border-left: none; border-right: none; border-bottom: 1px solid #e0e0e0; }
.rte-wrapper .ql-container { border: none; font-size: 14px; }
.rte-wrapper.is-readonly .ql-toolbar { display: none; }
.rte-wrapper.is-readonly .ql-container { border-top: 1px solid #e0e0e0; }
',
        p_key => 'rte-apex-style'
    );

    -- Quill JS (direktno u <head>, browser cache spriječava dupli load)
    htp.p('<script src="https://cdn.quilljs.com/1.3.7/quill.min.js"></script>');

    -- Wrapper div
    htp.p('<div class="rte-wrapper'
        || CASE WHEN l_readonly THEN ' is-readonly' ELSE '' END
        || '" id="' || l_item_id || '_wrapper">');

    -- Hidden input — stvarni APEX item koji nosi vrijednost
    htp.p('<input type="hidden"'
        || ' id="' || l_item_id || '"'
        || ' name="' || l_item_id || '"'
        || ' value="' || apex_escape.html_attribute(l_value) || '"'
        || '>');

    -- Editor container
    htp.p('<div id="' || l_item_id || '_editor"'
        || ' style="height:' || l_height || 'px;">'
        || '</div>');

    htp.p('</div>');

    -- Inicijalizacija Quill editora
    apex_javascript.add_onload_code(
        p_code =>
            '(function() {' ||
            '  var itemId   = ' || apex_javascript.add_value(l_item_id) || ';' ||
            '  var editorId = itemId + "_editor";' ||
            '  var hidden   = document.getElementById(itemId);' ||
            '  var quill = new Quill("#" + editorId, {' ||
            '    theme: "snow",' ||
            '    readOnly: ' || CASE WHEN l_readonly THEN 'true' ELSE 'false' END || ',' ||
            '    modules: { toolbar: [' || l_toolbar_cfg || '] }' ||
            '  });' ||
            -- Postavi početnu vrijednost
            '  var initVal = hidden.value;' ||
            '  if (initVal) {' ||
            '    quill.clipboard.dangerouslyPasteHTML(initVal);' ||
            '  }' ||
            -- Sinkronizacija na svaku promjenu
            '  quill.on("text-change", function() {' ||
            '    var content = quill.root.innerHTML;' ||
            '    hidden.value = (content === "<p><br></p>") ? "" : content;' ||
            '    apex.event.trigger("#" + itemId, "change");' ||
            '  });' ||
            -- APEX item API integracija
            '  apex.item.create(itemId, {' ||
            '    getValue: function() {' ||
            '      var c = quill.root.innerHTML;' ||
            '      return (c === "<p><br></p>") ? "" : c;' ||
            '    },' ||
            '    setValue: function(v) {' ||
            '      quill.clipboard.dangerouslyPasteHTML(v || "");' ||
            '      hidden.value = v || "";' ||
            '    },' ||
            '    disable: function() { quill.disable(); },' ||
            '    enable:  function() { quill.enable(); },' ||
            '    isChanged: function() { return true; }' ||
            '  });' ||
            '})();'
    );

    p_result.is_navigable := FALSE;

END render_rich_text_item;
/

SHOW ERRORS PROCEDURE render_rich_text_item;
