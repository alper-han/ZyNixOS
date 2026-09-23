{ ... }:
{
  home-manager.sharedModules = [
    (
      { lib, pkgs, ... }:
      let
        ompSettings = {
          setupVersion = 2;

          modelRoleStorage = "global";
          modelRoles.default = "openai-codex/gpt-5.6-luna";

          theme = {
            dark = "dark-github";
            light = "light";
          };
          symbolPreset = "nerd";
          colorBlindMode = false;
          composer = {
            shape = "band";
            tokenRate = true;
            recallClearedDrafts = true;
          };
          statusLine = {
            preset = "full";
            separator = "powerline-thin";
            contextLine = "embedded";
            sessionAccent = true;
            transparent = false;
            compactThinkingLevel = false;
            showHookStatus = true;
          };
          display = {
            shimmer = "classic";
            pinnedAgents = "full";
            smoothStreaming = true;
            hideToolActivity = false;
            showTokenUsage = true;
            showTurnTime = true;
            cacheMissMarker = true;
            collapseCompacted = true;
          };
          terminal = {
            showImages = true;
            showProgress = false;
          };
          images = {
            autoResize = true;
            blockImages = false;
            describeForTextModels = true;
            urls = {
              enabled = false;
              backends = [
                "provider-files"
                "tailscale"
                "cloudflared"
                "litterbox"
              ];
              bindHost = "127.0.0.1";
            };
          };
          tui = {
            maxInlineImageColumns = 100;
            maxInlineImageRows = 20;
            maxInlineImages = 8;
            resizeScrollback = "rebuild";
            textSizing = true;
            renderMermaid = true;
            reactions = true;
            codexResetFireworks = true;
            titleState = true;
            titleSpinner = "braille";
            hyperlinks = "always";
            mouse = false;
            tight = false;
            imeSafeCursor = false;
          };
          showHardwareCursor = true;

          defaultThinkingLevel = "auto";
          hideThinkingBlock = false;
          proseOnlyThinking = true;
          omitThinking = false;
          externalThinking = false;
          model = {
            loopGuard = {
              enabled = true;
              checkAssistantContent = true;
              toolCallReminder = true;
            };
            toolCallLoopGuard = {
              enabled = true;
              threshold = 5;
              exemptTools = [ "hub" ];
            };
          };
          providers = {
            tinyModelDevice = "default";
            tinyModelDtype = "default";
            anthropic.serverSideFallback = false;
            openai-codex = {
              codeMode = "auto";
            };
            webSearchTimeoutSeconds = 60;
            antigravityEndpoint = "auto";
            fetch = "auto";
            openaiWebsockets = "auto";
            cacheRetention = "auto";
            openrouterVariant = "default";
            streamFirstEventTimeoutSeconds = -1;
            streamIdleTimeoutSeconds = -1;
            fireworksTier = "standard";
          };
          tier = {
            openai = "none";
            anthropic = "none";
            google = "flex";
            subagent = "inherit";
          };
          inlineToolDescriptors = "auto";
          includeModelInPrompt = true;
          includeWorkspaceTree = false;
          skillful = true;
          personality = "pragmatic";

          retry = {
            enabled = true;
            maxRetries = 10;
            waitForUsageReset = true;
            modelFallback = true;
            usageAwareFallback = false;
            fallbackChains = { };
            fallbackRevertPolicy = "cooldown-expiry";
          };

          loop = {
            mode = "prompt";
            conditionTimeoutMs = 30000;
          };
          doubleEscapeAction = "rewind";
          treeFilterMode = "default";
          autocompleteMaxVisible = 10;
          emojiAutocomplete = true;
          paste.largeMenuThreshold = 100;
          tools = {
            approval = { };
            approvalMode = "yolo";
            artifactSpillThreshold = 50;
            artifactTailBytes = 20;
            artifactHeadBytes = 20;
            outputMaxColumns = 768;
            artifactTailLines = 500;
            intentTracing = true;
            abortOnFabricatedResult = true;
            speculativeExecution = {
              enabled = false;
              maxInFlight = 2;
            };
            maxTimeout = 0;
            xdev = true;
            xdevDocs = "builtins";
            xdevInlineDevices = [ ];
          };
          completion.notify = "on";
          error.notify = "on";
          ask = {
            timeout = 0;
            notify = "on";
            enabled = true;
          };
          recap = {
            enabled = true;
            idleSeconds = 240;
          };
          speech = {
            enabled = false;
            mode = "assistant";
            enhanced = false;
            voice = "af_heart";
          };
          stt = {
            enabled = false;
          };
          collab = {
            relayUrl = "wss://my.omp.sh";
            webUrl = "";
            displayName = "";
            autoStart = "off";
          };
          share = {
            serverUrl = "https://my.omp.sh/s";
            store = "blob";
            redactSecrets = true;
          };
          stream.serverUrl = "https://live.omp.sh";
          magicKeywords = {
            enabled = true;
            ultrathink = true;
            orchestrate = true;
            workflow = true;
          };
          startup = {
            quiet = false;
            showSplash = false;
            setupWizard = true;
            checkUpdate = true;
            changelogMode = "summary";
          };
          update.channel = "stable";
          marketplace.autoUpdate = "notify";
          autoResume = false;
          power.sleepPrevention = "idle";
          features.unexpectedStopDetection = "mechanical";
          git.enabled = true;

          contextPromotion.enabled = false;
          extendedContext = false;
          branchSummary.enabled = true;
          compaction = {
            enabled = true;
            experimentalContextManagement = true;
            midTurnEnabled = true;
            methodOrder = [
              "remote"
              "snapcompact"
              "handoff"
              "shake"
              "soft"
            ];
            thresholdPercent = -1;
            thresholdTokens = -1;
            handoffSaveToDisk = false;
            remoteStreamingV2Enabled = true;
            asyncEnabled = true;
            idleEnabled = false;
            idleThresholdTokens = 200000;
            idleTimeoutSeconds = 900;
            supersedeReads = true;
            dropUseless = true;
          };
          ttsr = {
            enabled = true;
            contextMode = "discard";
            interruptMode = "always";
            repeatMode = "once";
            repeatGap = 10;
            builtinRules = true;
          };
          snapcompact = {
            systemPrompt = "none";
            toolResults = false;
            shape = "auto";
          };

          memory.backend = "mnemopi";
          autolearn = {
            enabled = true;
            autoContinue = false;
          };
          mnemopi = {
            scoping = "per-project";
            embeddingVariant = "multilingual";
            autoRecall = true;
            autoRetain = true;
            polyphonicRecall = false;
            enhancedRecall = false;
            proactiveLinking = false;
            noEmbeddings = false;
            llmMode = "smol";
          };

          edit = {
            mode = "hashline";
            fuzzyMatch = true;
            fuzzyThreshold = 0.95;
            streamingAbort = false;
            recoverInlineEdits = true;
            blockAutoGenerated = true;
            enforceSeenLines = true;
            blackbox.enabled = false;
            autoRepair.enabled = true;
          };
          readLineNumbers = false;
          read = {
            defaultLimit = 300;
            renderMarkdown = false;
            toolResultPreview = false;
            summarize = {
              enabled = true;
              prose = false;
            };
          };
          lsp = {
            enabled = true;
            lazy = true;
            shared = true;
            formatOnWrite = true;
            diagnosticsOnWrite = true;
            diagnosticsOnEdit = true;
            diagnosticsDeduplicate = true;
          };
          astGrep.enabled = true;
          astEdit.enabled = true;
          debug.enabled = true;
          grep.enabled = true;

          bash = {
            enabled = true;
            allowCompoundCommands = false;
            autoBackground.enabled = true;
            direnv = "auto";
          };
          bashInterceptor.enabled = true;
          shellMinimizer = {
            enabled = true;
            sourceOutlineLevel = "default";
          };
          eval = {
            py = true;
            js = true;
            tools.enabled = true;
            workpool.freshAgents = false;
            autoBackground.enabled = false;
          };
          python = {
            kernelMode = "session";
            interpreter = "";
          };

          todo = {
            enabled = true;
            reminders = true;
            remindersMax = 3;
            eager = "preferred";
          };
          glob.enabled = true;
          launch.enabled = true;
          speechgen.enabled = false;
          generate_image.enabled = true;
          computer = {
            enabled = false;
            display = "all";
          };
          checkpoint.enabled = true;
          fetch.enabled = true;
          vault.enabled = false;
          github = {
            enabled = true;
            cache.enabled = true;
          };
          web_search.enabled = true;
          # Enables OMP's security_scan tool; this is not a sandbox.
          security.enabled = true;
          browser = {
            enabled = true;
            relay = false;
            headless = true;
            cmux = true;
            freezeOnTurnEnd = true;
            idleCloseSec = 1800;
          };
          images.questionTimeoutMs = 300000;

          plan = {
            enabled = true;
            defaultOnStartup = false;
            autosave = false;
          };
          goal = {
            enabled = true;
            statusInFooter = true;
            continuationModes = [ "interactive" ];
          };
          title.refreshOnReplan = true;
          task = {
            eager = "preferred";
            batch = true;
            enableEffort = true;
            maxConcurrency = 32;
            enableLsp = true;
            maxRecursionDepth = 2;
            maxRuntimeMs = 0;
            softRequestBudget = 200;
            softRequestBudgetNotice = true;
            maxEffort = "max";
            prewalk = false;
            isolation.enabled = true;
            isolation.apply = true;
            isolation.merge = "patch";
            isolation.commits = "generic";
          };
          isolation.backend = "auto";
          worktree.clone = true;
          worktree.cleanSource = false;
          task.showResolvedModelBadge = true;
          skills = {
            enabled = true;
            enableSkillCommands = true;
            enableCodexUser = false;
            enableClaudeUser = false;
            enableClaudeProject = true;
            enablePiUser = true;
            enablePiProject = true;
            enableAgentsUser = true;
            enableAgentsProject = true;
          };
          commands = {
            enableClaudeUser = false;
            enableClaudeProject = true;
            enableOpencodeUser = false;
            enableOpencodeProject = true;
          };

          providers.maxInFlightRequests = { };
          codexResets.autoRedeem = "no";
          exa.enabled = true;
          secrets.enabled = true;

        };
        configFile = (pkgs.formats.yaml { }).generate "omp-config.yml" ompSettings;
      in
      {

        home.packages = [ pkgs.omp ];

        # Override upstream replacement on every switch with a first-run-only seed.
        # Preserve user edits, secrets and provider overrides; do not force-write home.file.
        home.activation.ompConfig = lib.mkForce {
          before = [ ];
          after = [ "writeBoundary" ];
          data = ''
            run mkdir -p "$HOME/.omp/agent"
            if [ ! -f "$HOME/.omp/agent/config.yml" ]; then
              run install -m 600 ${configFile} "$HOME/.omp/agent/config.yml"
            fi
          '';
        };
      }
    )
  ];
}
