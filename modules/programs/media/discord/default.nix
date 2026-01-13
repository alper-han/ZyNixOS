{ pkgs, lib, ... }:
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      let
        discordSettings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          cloud = {
            authenticated = false;
            settingsSync = false;
            settingsSyncVersion = 1761094743293;
            url = "https://api.vencord.dev/";
          };
          disableMinSize = false;
          eagerPatches = false;
          enableReactDevtools = false;
          enabledThemes = [ "theme.css" ];
          frameless = false;
          notifications = {
            logLimit = 50;
            position = "bottom-right";
            timeout = 5000;
            useNative = "not-focused";
          };
          notifyAboutUpdates = true;
          plugins = {
            AccountPanelServerProfile.enabled = false;
            AlwaysAnimate.enabled = false;
            AlwaysExpandRoles.enabled = false;
            AlwaysTrust.enabled = false;
            AnonymiseFileNames = {
              anonymiseByDefault = true;
              consistent = "image";
              enabled = true;
              method = 0;
              randomisedLength = 7;
            };
            AppleMusicRichPresence.enabled = false;
            AutoDNDWhilePlaying.enabled = false;
            BANger.enabled = false;
            BadgeAPI.enabled = true;
            BetterFolders.enabled = false;
            BetterGifAltText.enabled = true;
            BetterGifPicker.enabled = false;
            BetterNotesBox.enabled = false;
            BetterRoleContext.enabled = false;
            BetterRoleDot.enabled = false;
            BetterSessions = {
              backgroundCheck = false;
              enabled = true;
            };
            BetterSettings = {
              disableFade = true;
              eagerLoad = true;
              enabled = true;
              organizeMenu = true;
            };
            BetterUploadButton.enabled = false;
            BiggerStreamPreview.enabled = true;
            BlurNSFW.enabled = false;
            CallTimer = {
              enabled = true;
              format = "stopwatch";
            };
            ChatInputButtonAPI.enabled = true;
            ClearURLs.enabled = true;
            ClientTheme.enabled = false;
            ColorSighted.enabled = false;
            CommandsAPI.enabled = true;
            ConsoleJanitor.enabled = false;
            ConsoleShortcuts.enabled = false;
            CopyEmojiMarkdown.enabled = false;
            CopyFileContents.enabled = true;
            CopyStickerLinks.enabled = false;
            CopyUserURLs.enabled = false;
            CrashHandler.enabled = true;
            CtrlEnterSend.enabled = false;
            CustomIdle.enabled = false;
            CustomRPC = {
              enabled = false;
              timestampMode = 0;
              type = 0;
            };
            Dearrow.enabled = false;
            Decor.enabled = false;
            DisableCallIdle.enabled = false;
            DisableDeepLinks.enabled = true;
            DontRoundMyTimestamps.enabled = false;
            DynamicImageModalAPI.enabled = false;
            Experiments = {
              enabled = false;
              toolbarDevMenu = false;
            };
            ExpressionCloner.enabled = false;
            F8Break.enabled = false;
            FakeNitro = {
              disableEmbedPermissionCheck = false;
              emojiSize = 48;
              enableEmojiBypass = true;
              enableStickerBypass = true;
              enableStreamQualityBypass = true;
              enabled = true;
              hyperLinkText = "{{NAME}}";
              stickerSize = 160;
              transformCompoundSentence = false;
              transformEmojis = true;
              transformStickers = true;
              useHyperLinks = true;
            };
            FakeProfileThemes.enabled = false;
            FavoriteEmojiFirst.enabled = false;
            FavoriteGifSearch.enabled = false;
            FixCodeblockGap.enabled = false;
            FixImagesQuality.enabled = true;
            FixSpotifyEmbeds.enabled = false;
            FixYoutubeEmbeds.enabled = true;
            ForceOwnerCrown.enabled = false;
            FriendInvites.enabled = false;
            FriendsSince.enabled = false;
            FullSearchContext.enabled = false;
            FullUserInChatbox.enabled = false;
            GameActivityToggle.enabled = false;
            GifPaste.enabled = false;
            GreetStickerPicker.enabled = false;
            HideMedia.enabled = false;
            IgnoreActivities.enabled = false;
            ImageFilename = {
              enabled = true;
              showFullUrl = true;
            };
            ImageLink.enabled = false;
            ImageZoom.enabled = false;
            ImplicitRelationships.enabled = false;
            InvisibleChat = {
              enabled = false;
              savedPasswords = "password, Password";
            };
            IrcColors.enabled = false;
            KeepCurrentChannel.enabled = false;
            LastFMRichPresence.enabled = false;
            LoadingQuotes.enabled = false;
            MemberCount = {
              enabled = true;
              memberList = true;
              toolTip = true;
              voiceActivity = true;
            };
            MemberListDecoratorsAPI.enabled = true;
            MentionAvatars.enabled = false;
            MessageAccessoriesAPI.enabled = true;
            MessageClickActions.enabled = false;
            MessageDecorationsAPI.enabled = true;
            MessageEventsAPI.enabled = true;
            MessageLatency.enabled = false;
            MessageLinkEmbeds.enabled = false;
            MessageLogger = {
              collapseDeleted = true;
              deleteStyle = "text";
              enabled = true;
              ignoreBots = true;
              ignoreChannels = "";
              ignoreGuilds = "";
              ignoreSelf = true;
              ignoreUsers = "";
              inlineEdits = true;
              logDeletes = true;
              logEdits = true;
            };
            MessagePopoverAPI.enabled = true;
            MessageTags.enabled = false;
            MessageUpdaterAPI.enabled = true;
            MoreCommands.enabled = false;
            MoreKaomoji.enabled = false;
            MoreUserTags.enabled = false;
            Moyai.enabled = false;
            MutualGroupDMs.enabled = false;
            NSFWGateBypass.enabled = true;
            NewGuildSettings.enabled = false;
            NoBlockedMessages.enabled = false;
            NoDevtoolsWarning.enabled = false;
            NoF1.enabled = true;
            NoMaskedUrlPaste.enabled = false;
            NoMosaic.enabled = false;
            NoOnboardingDelay.enabled = false;
            NoPendingCount.enabled = false;
            NoProfileThemes.enabled = false;
            NoRPC.enabled = false;
            NoReplyMention.enabled = false;
            NoScreensharePreview.enabled = false;
            NoServerEmojis.enabled = false;
            NoSystemBadge.enabled = false;
            NoTrack = {
              disableAnalytics = true;
              enabled = true;
            };
            NoTypingAnimation.enabled = false;
            NoUnblockToJump.enabled = false;
            NormalizeMessageLinks.enabled = false;
            NotificationVolume.enabled = false;
            OnePingPerDM = {
              allowEveryone = false;
              allowMentions = false;
              channelToAffect = "both_dms";
              enabled = true;
            };
            OpenInApp.enabled = false;
            OverrideForumDefaults.enabled = false;
            PartyMode.enabled = false;
            PauseInvitesForever.enabled = false;
            PermissionFreeWill.enabled = false;
            PermissionsViewer.enabled = false;
            PictureInPicture.enabled = false;
            PinDMs.enabled = false;
            PlainFolderIcon.enabled = false;
            PlatformIndicators.enabled = false;
            PreviewMessage.enabled = false;
            QuickMention.enabled = false;
            QuickReply.enabled = false;
            ReactErrorDecoder.enabled = false;
            ReadAllNotificationsButton.enabled = false;
            RelationshipNotifier.enabled = false;
            ReplaceGoogleSearch = {
              customEngineName = "Startpage";
              customEngineURL = "https://www.startpage.com/sp/search?prfe=c602752472dd4a3d8286a7ce441403da08e5c4656092384ed3091a946a5a4a4c99962d0935b509f2866ff1fdeaa3c33a007d4d26e89149869f2f7d0bdfdb1b51aa7ae7f5f17ff4a233ff313d&query=";
              enabled = false;
            };
            ReplyTimestamp.enabled = false;
            RevealAllSpoilers.enabled = false;
            ReverseImageSearch.enabled = true;
            ReviewDB.enabled = false;
            RoleColorEverywhere.enabled = false;
            SecretRingToneEnabler.enabled = false;
            SendTimestamps.enabled = false;
            ServerInfo.enabled = true;
            ServerListAPI.enabled = false;
            ServerListIndicators.enabled = false;
            Settings = {
              enabled = true;
              settingsLocation = "aboveNitro";
            };
            ShikiCodeblocks.enabled = false;
            ShowAllMessageButtons.enabled = false;
            ShowConnections.enabled = false;
            ShowHiddenChannels = {
              defaultAllowedUsersAndRolesDropdownState = true;
              enabled = true;
              hideUnreads = true;
              showMode = 1;
            };
            ShowHiddenThings = {
              enabled = true;
              showInvitesPaused = true;
              showModView = true;
              showTimeouts = true;
            };
            ShowMeYourName.enabled = false;
            ShowTimeoutDuration.enabled = false;
            SilentMessageToggle.enabled = false;
            SilentTyping = {
              contextMenu = true;
              enabled = true;
              isEnabled = true;
              showIcon = true;
            };
            SortFriendRequests.enabled = false;
            SpotifyControls.enabled = false;
            SpotifyCrack.enabled = false;
            SpotifyShareCommands.enabled = false;
            StartupTimings.enabled = false;
            StickerPaste.enabled = false;
            StreamerModeOnStream.enabled = false;
            Summaries.enabled = false;
            SuperReactionTweaks.enabled = false;
            SupportHelper.enabled = true;
            TextReplace.enabled = false;
            ThemeAttributes.enabled = false;
            Translate = {
              autoTranslate = false;
              deeplApiKey = "";
              enabled = false;
              receivedInput = "en";
              receivedOutput = "tr";
              sentInput = "en";
              sentOutput = "tr";
              service = "google";
              showAutoTranslateTooltip = true;
              showChatBarButton = true;
            };
            TypingIndicator = {
              enabled = true;
              includeCurrentChannel = true;
              includeMutedChannels = false;
              indicatorMode = 3;
            };
            TypingTweaks = {
              alternativeFormatting = true;
              enabled = true;
              showAvatars = true;
              showRoleColors = true;
            };
            USRBG.enabled = false;
            Unindent.enabled = false;
            UnlockedAvatarZoom.enabled = false;
            UnsuppressEmbeds.enabled = false;
            UserMessagesPronouns.enabled = false;
            UserSettingsAPI.enabled = true;
            UserVoiceShow = {
              enabled = true;
              showInMemberList = true;
              showInMessages = true;
              showInUserProfileModal = true;
            };
            ValidReply.enabled = true;
            ValidUser.enabled = true;
            VcNarrator.enabled = false;
            VencordToolbox.enabled = false;
            ViewIcons.enabled = false;
            ViewRaw.enabled = false;
            VoiceChatDoubleClick.enabled = true;
            VoiceDownload.enabled = false;
            VoiceMessages.enabled = false;
            VolumeBooster = {
              enabled = true;
              multiplier = 3;
            };
            WebContextMenus.enabled = true;
            WebKeybinds.enabled = true;
            WebScreenShareFixes = {
              enabled = true;
              experimentalAV1Support = true;
            };
            WhoReacted.enabled = true;
            XSOverlay.enabled = false;
            YoutubeAdblock.enabled = true;
            iLoveSpam.enabled = false;
            oneko.enabled = false;
            petpet.enabled = false;
            "WebRichPresence (arRPC)".enabled = false;
          };
          themeLinks = [ ];
          transparent = false;
          useQuickCss = false;
          winCtrlQ = false;
          winNativeTitleBar = false;
        };
      in
      {
        home.packages = with pkgs; [
          # discord
          vesktop
          curl
        ];

        home.activation.setupDiscord = lib.mkAfter ''
          export PATH=${pkgs.curl}/bin:$PATH

          for APP in Vencord vesktop; do
            # Theme
            THEME_DIR="$HOME/.config/$APP/themes"
            THEME_FILE="$THEME_DIR/theme.css"
            if ! [ -f "$THEME_FILE" ]; then
              echo "$APP theme not found. Downloading..."
              mkdir -p "$THEME_DIR"
              curl -sSfL "https://raw.githubusercontent.com/alper-han/discord-css/refs/heads/main/theme.css" -o "$THEME_FILE"
            fi

            # Settings
            SETTING_DIR="$HOME/.config/$APP/settings"
            SETTING_FILE="$SETTING_DIR/settings.json"
            if ! [ -f "$SETTING_FILE" ]; then
              echo "$APP settings.json not found. Creating initial settings..."
              mkdir -p "$SETTING_DIR"
              echo '${builtins.toJSON discordSettings}' > "$SETTING_FILE"
            fi
          done
        '';

      }
    )
  ];
}
