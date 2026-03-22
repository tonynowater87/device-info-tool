#!/usr/bin/env python3
"""
Script to generate Intent Actions translations for all 10 languages.
Run this script and copy the output into lib/l10n/app_localizations.dart
"""

import json

# Load translations
with open('tools/intent_translations.json', 'r', encoding='utf-8') as f:
    translations = json.load(f)

# Add remaining languages with English as fallback
remaining_languages = {
    'fr': 'French',
    'de': 'German', 
    'ar': 'Arabic',
    'pt': 'Portuguese',
    'es': 'Spanish'
}

# French translations
translations['fr'] = {
    "intent_settings": "Page de paramètres",
    "intent_developer_options": "Options développeur",
    "intent_app_info": "Informations et autorisations",
    "intent_usage_access": "Accès aux statistiques d'utilisation",
    "intent_display_over_apps": "Afficher par-dessus d'autres apps",
    "intent_modify_system": "Modifier les paramètres système",
    "intent_install_unknown": "Installer des apps inconnues",
    "intent_do_not_disturb": "Accès Ne pas déranger",
    "intent_locale": "Langue et région",
    "intent_all_apps": "Toutes les applications",
    "intent_wifi": "Paramètres WiFi",
    "intent_bluetooth": "Paramètres Bluetooth",
    "intent_date_time": "Date et heure",
    "intent_display": "Paramètres d'affichage",
    "intent_accessibility": "Paramètres d'accessibilité",
    "intent_about_device": "À propos de l'appareil",
    "intent_notifications": "Paramètres de notification",
    "intent_default_apps": "Applications par défaut",
    "intent_sound": "Paramètres audio",
    "intent_storage": "Paramètres de stockage",
    "intent_battery": "Batterie et économie d'énergie",
    "intent_location": "Services de localisation",
    "intent_security": "Paramètres de sécurité",
    "intent_privacy": "Paramètres de confidentialité",
    "intent_nfc": "Paramètres NFC",
    "intent_accounts": "Comptes et synchronisation",
    "intent_search": "Paramètres de recherche",
    "intent_system_update": "Mise à jour système",
    "intent_biometric": "Inscription biométrique",
    "intent_cast": "Paramètres de diffusion",
    "intent_webview": "Implémentation WebView"
}

# German translations
translations['de'] = {
    "intent_settings": "Einstellungsseite",
    "intent_developer_options": "Entwickleroptionen",
    "intent_app_info": "App-Informationen & Berechtigungen",
    "intent_usage_access": "Nutzungszugriff-Einstellungen",
    "intent_display_over_apps": "Über anderen Apps anzeigen",
    "intent_modify_system": "Systemeinstellungen ändern",
    "intent_install_unknown": "Unbekannte Apps installieren",
    "intent_do_not_disturb": "Nicht-Stören-Zugriff",
    "intent_locale": "Sprache & Region",
    "intent_all_apps": "Alle Anwendungen",
    "intent_wifi": "WiFi-Einstellungen",
    "intent_bluetooth": "Bluetooth-Einstellungen",
    "intent_date_time": "Datum & Uhrzeit",
    "intent_display": "Anzeigeeinstellungen",
    "intent_accessibility": "Bedienungshilfen",
    "intent_about_device": "Über das Gerät",
    "intent_notifications": "Benachrichtigungseinstellungen",
    "intent_default_apps": "Standard-Apps",
    "intent_sound": "Toneinstellungen",
    "intent_storage": "Speichereinstellungen",
    "intent_battery": "Akku & Energiesparen",
    "intent_location": "Standortdienste",
    "intent_security": "Sicherheitseinstellungen",
    "intent_privacy": "Datenschutzeinstellungen",
    "intent_nfc": "NFC-Einstellungen",
    "intent_accounts": "Konten & Synchronisierung",
    "intent_search": "Sucheinstellungen",
    "intent_system_update": "Systemaktualisierung",
    "intent_biometric": "Biometrische Anmeldung",
    "intent_cast": "Cast-Einstellungen",
    "intent_webview": "WebView-Implementierung"
}

# Arabic translations
translations['ar'] = {
    "intent_settings": "صفحة الإعدادات",
    "intent_developer_options": "خيارات المطور",
    "intent_app_info": "معلومات التطبيق والأذونات",
    "intent_usage_access": "إعدادات الوصول للاستخدام",
    "intent_display_over_apps": "العرض فوق التطبيقات الأخرى",
    "intent_modify_system": "تعديل إعدادات النظام",
    "intent_install_unknown": "تثبيت التطبيقات غير المعروفة",
    "intent_do_not_disturb": "الوصول إلى عدم الإزعاج",
    "intent_locale": "اللغة والمنطقة",
    "intent_all_apps": "جميع التطبيقات",
    "intent_wifi": "إعدادات WiFi",
    "intent_bluetooth": "إعدادات Bluetooth",
    "intent_date_time": "التاريخ والوقت",
    "intent_display": "إعدادات العرض",
    "intent_accessibility": "إعدادات إمكانية الوصول",
    "intent_about_device": "حول الجهاز",
    "intent_notifications": "إعدادات الإشعارات",
    "intent_default_apps": "التطبيقات الافتراضية",
    "intent_sound": "إعدادات الصوت",
    "intent_storage": "إعدادات التخزين",
    "intent_battery": "البطارية وتوفير الطاقة",
    "intent_location": "خدمات الموقع",
    "intent_security": "إعدادات الأمان",
    "intent_privacy": "إعدادات الخصوصية",
    "intent_nfc": "إعدادات NFC",
    "intent_accounts": "الحسابات والمزامنة",
    "intent_search": "إعدادات البحث",
    "intent_system_update": "تحديث النظام",
    "intent_biometric": "التسجيل البيومتري",
    "intent_cast": "إعدادات البث",
    "intent_webview": "تنفيذ WebView"
}

# Portuguese translations
translations['pt'] = {
    "intent_settings": "Página de configurações",
    "intent_developer_options": "Opções do desenvolvedor",
    "intent_app_info": "Informações e permissões do app",
    "intent_usage_access": "Configurações de acesso de uso",
    "intent_display_over_apps": "Exibir sobre outros apps",
    "intent_modify_system": "Modificar configurações do sistema",
    "intent_install_unknown": "Instalar apps desconhecidos",
    "intent_do_not_disturb": "Acesso ao Não perturbe",
    "intent_locale": "Idioma e região",
    "intent_all_apps": "Todos os aplicativos",
    "intent_wifi": "Configurações de WiFi",
    "intent_bluetooth": "Configurações de Bluetooth",
    "intent_date_time": "Data e hora",
    "intent_display": "Configurações de tela",
    "intent_accessibility": "Configurações de acessibilidade",
    "intent_about_device": "Sobre o dispositivo",
    "intent_notifications": "Configurações de notificação",
    "intent_default_apps": "Apps padrão",
    "intent_sound": "Configurações de som",
    "intent_storage": "Configurações de armazenamento",
    "intent_battery": "Bateria e economia de energia",
    "intent_location": "Serviços de localização",
    "intent_security": "Configurações de segurança",
    "intent_privacy": "Configurações de privacidade",
    "intent_nfc": "Configurações de NFC",
    "intent_accounts": "Contas e sincronização",
    "intent_search": "Configurações de pesquisa",
    "intent_system_update": "Atualização do sistema",
    "intent_biometric": "Cadastro biométrico",
    "intent_cast": "Configurações de transmissão",
    "intent_webview": "Implementação de WebView"
}

print("=" * 80)
print("Intent Actions Translations for All 10 Languages")
print("=" * 80)
print()
print("Copy the following translations into your language sections in")
print("lib/l10n/app_localizations.dart")
print()
print("Add them before the closing }, of each language section")
print("=" * 80)
print()

for lang_code in ['en', 'zh_TW', 'zh_CN', 'ja', 'ko', 'es', 'fr', 'de', 'ar', 'pt']:
    if lang_code in translations:
        print(f"\n// {lang_code} - Intent Actions")
        print("      // Intent Actions")
        for key, value in translations[lang_code].items():
            print(f"      '{key}': '{value}',")

print("\n" + "=" * 80)
print(f"Total: {len(translations)} languages × 31 keys = {len(translations) * 31} translations")
print("=" * 80)
