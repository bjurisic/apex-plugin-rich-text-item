prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
-- Rich Text Editor - Item Plugin
-- APEX 24.2.0 | Application: 101 | Schema: PASTORAL
--
-- Redoslijed instalacije:
--   1. Pokrenuti pck_rich_text_item.sql  (kreira render proceduru)
--   2. Pokrenuti ovaj file               (registrira plugin u aplikaciji)
--
-- Napomena: visina (default 300px) i toolbar (default FULL) su hardkodirani
-- u render proceduri. Mogu se promijeniti direktno u pck_rich_text_item.sql.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>147097756376321804
,p_default_application_id=>101
,p_default_id_offset=>5682050545860076
,p_default_owner=>'PASTORAL'
);
end;
/

prompt PLUGIN - Rich Text Editor

begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(900001)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'COM.PASTORAL.RICH_TEXT_EDITOR'
,p_display_name=>'Rich Text Editor'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEM'
,p_render_function=>'RENDER_RICH_TEXT_ITEM'
,p_standard_attributes=>'VISIBLE:SESSION_STATE:READONLY:ESCAPE_OUTPUT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>unistr('Rich Text Editor item plugin koji koristi Quill.js. Omogu\0107uje formatiranje teksta, liste, linkove i vi\0161e.')
,p_version_identifier=>'1.0'
,p_about_url=>null
);
end;
/

prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
