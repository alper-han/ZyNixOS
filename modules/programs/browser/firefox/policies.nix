{ lib, ... }:
let
  extensions = import ../extensions.nix { inherit lib; };
in
{
  AllowFileSelectionDialogs = true;
  AppAutoUpdate = false;
  AutofillAddressEnabled = false;
  AutofillCreditCardEnabled = false;
  #AutoLaunchProtocolsFromOrigins = { };
  BackgroundAppUpdate = false;
  BlockAboutAddons = false;
  BlockAboutConfig = false;
  BlockAboutProfiles = false;
  BlockAboutSupport = false;
  #Containers = { };
  DisableAppUpdate = true;
  DisableFirefoxAccounts = true;
  DisableFirefoxScreenshots = true;
  DisableFirefoxStudies = true;
  DisableFormHistory = true;
  DisableMasterPasswordCreation = true;
  DisablePocket = true;
  DisablePrivateBrowsing = false;
  DisableProfileImport = false;
  DisableProfileRefresh = false;
  DisableSafeMode = false;
  DisableTelemetry = true;
  DisableFeedbackCommands = true;
  DontCheckDefaultBrowser = true;
  DNSOverHTTPS = {
    # Let system/VPN DNS win; browser-level DoH can bypass Proton DNS/NetShield.
    Enabled = false;
  };
  EnableTrackingProtection = {
    Value = true;
    Locked = true;
    Cryptomining = true;
    Fingerprinting = true;
  };
  EncryptedMediaExtensions = {
    Enabled = true;
  };
  ExtensionUpdate = true;
  FirefoxHome = {
    Search = false;
    TopSites = false;
    SponsoredTopSites = false;
    Highlights = false;
    Pocket = false;
    SponsoredPocket = false;
    Snippets = false;
    Locked = false;
  };
  HardwareAcceleration = true;
  ManualAppUpdateOnly = true;
  NoDefaultBookmarks = false;
  OfferToSaveLogins = false;
  PasswordManagerEnabled = false;
  PictureInPicture = {
    Enabled = true;
  };
  PopupBlocking = {
    Allow = [ ];
    Default = true;
  };
  Preferences = {
    "browser.tabs.warnOnClose" = {
      Value = false;
    };
    "extensions.formautofill.addresses.enabled" = {
      Value = false;
      Status = "locked";
    };
    "extensions.formautofill.creditCards.enabled" = {
      Value = false;
      Status = "locked";
    };
    "dom.security.https_only_mode_pbm" = {
      Value = true;
      Status = "locked";
    };
    "dom.security.https_only_mode_error_page_user_suggestions" = {
      Value = true;
      Status = "locked";
    };
    "browser.firefox-view.feature-tour" = {
      Value = ''{"screen":"","complete":true}'';
      Status = "locked";
    };
    "identity.fxaccounts.enabled" = {
      Value = false;
      Status = "locked";
    };
    "browser.tabs.firefox-view-next" = {
      Value = false;
      Status = "locked";
    };
    "privacy.sanitize.sanitizeOnShutdown" = {
      Value = false;
      Status = "locked";
    };
    "privacy.clearOnShutdown.cache" = {
      Value = true;
      Status = "locked";
    };
    "privacy.clearOnShutdown.cookies" = {
      Value = false;
      Status = "locked";
    };
    "privacy.clearOnShutdown.offlineApps" = {
      Value = false;
      Status = "locked";
    };
    "browser.sessionstore.privacy_level" = {
      Value = 0;
      Status = "locked";
    };
    "floorp.browser.sidebar.enable" = {
      Value = false;
      Status = "locked";
    };
    "geo.enabled" = {
      Value = false;
      Status = "locked";
    };
    "media.navigator.enabled" = {
      Value = false;
      Status = "locked";
    };
    "dom.event.clipboardevents.enabled" = {
      Value = false;
      Status = "locked";
    };
    "dom.event.contextmenu.enabled" = {
      Value = false;
      Status = "locked";
    };
    "dom.battery.enabled" = {
      Value = false;
      Status = "locked";
    };
    "extensions.enabledScopes" = {
      Value = 15;
      Status = "locked";
    };
    "extensions.autoDisableScopes" = {
      Value = 0;
      Status = "locked";
    };
    "browser.newtabpage.activity-stream.floorp.newtab.imagecredit.hide" = {
      Value = true;
      Status = "locked";
    };
    "browser.newtabpage.activity-stream.floorp.newtab.releasenote.hide" = {
      Value = true;
      Status = "locked";
    };
    "browser.search.separatePrivateDefault" = {
      Value = true;
      Status = "locked";
    };
  };
  PromptForDownloadLocation = true;
  SearchSuggestEnabled = false;
  ShowHomeButton = false;
  StartDownloadsInTempDirectory = false;
  UserMessaging = {
    ExtensionRecommendations = false;
    SkipOnboarding = true;
  };
  ExtensionSettings = extensions.extensionSettings;
  "3rdparty".Extensions = extensions.extensionConfig;
}
