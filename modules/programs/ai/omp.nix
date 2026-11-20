{ ... }:
{
  home-manager.sharedModules = [
    (
      { lib, pkgs, ... }:
      let
        ompSettings = {
          setupVersion = 3;

          # Claude first; GPT only for cross-vendor review/advisor and image generation.
          modelProviderOrder = [
            "anthropic"
            "openai-codex"
          ];
          modelRoleStorage = "global";
          modelRoles = {
            default = "anthropic/claude-opus-5-5";
            slow = "anthropic/claude-fable-5-2:high";
            plan = "anthropic/claude-fable-5-2:high";
            smol = "anthropic/claude-sonnet-5-5:medium";
            task = "anthropic/claude-sonnet-5-5:medium";
            vision = "anthropic/claude-sonnet-5-5:medium";
            commit = "anthropic/claude-haiku-5-5:low";
            tiny = "anthropic/claude-haiku-5-5:low";
            memory = "anthropic/claude-haiku-5-5:low";
            widget = "anthropic/claude-haiku-5-5:low";
            # Free native System One judge; Haiku is the fallback when it is unavailable.
            judge = "zen-free/jev-1.13-free";
            advisor = "openai-codex/gpt-6.1-sol:medium";
            image = "openai-codex/gpt-image-2";
          };
          advisor.enabled = false;
          # Off: one-way Opus→Sonnet handoff rewrites the whole cache; break-even ~30-37
          # requests after the first edit, median real task is 8. Use /prewalk manually for long jobs.
          prewalk.auto = "off";

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
          textVerbosity = "low";

          defaultThinkingLevel = "auto";
          temperature = -1;
          presencePenalty = -1;
          repetitionPenalty = -1;
          provider.appendOnlyContext = "auto";
          find.enabled = "auto";
          hideThinkingBlock = false;
          proseOnlyThinking = true;
          omitThinking = true;
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
            anthropic.serverSideFallback = true;
            # At the Claude session (5h) wall, continue at low priority on weekly quota
            # instead of falling back to another provider.
            anthropic.slowMode = "auto";
            autoThinkingMaxEffort = "xhigh";
            openai-codex = {
              codeMode = "auto";
              # Account has no Daybreak (cyber) access; opt out explicitly.
              daybreak = false;
            };
            webSearchTimeoutSeconds = 60;
            antigravityEndpoint = "auto";
            fetch = "auto";
            openaiWebsockets = "auto";
            cacheWarming = "idle";
            # 5m TTL: subagents get no cache warming, and the main agent's idle warmer
            # bridges short gaps; measured ~9.5% cheaper than the 1h default (2026-11-15).
            cacheRetention = "short";
            openrouterVariant = "default";
            streamFirstEventTimeoutSeconds = -1;
            streamIdleTimeoutSeconds = -1;
            fireworksTier = "standard";
          };
          tier = {
            openai = "none";
            anthropic = "none";
            google = "flex";
            # Keep /fast from fanning out to every subagent.
            subagent = "none";
          };
          inlineToolDescriptors = "auto";
          includeModelInPrompt = true;
          includeWorkspaceTree = false;
          skillful = false;
          personality = "pragmatic";

          retry = {
            enabled = true;
            maxRetries = 3;
            waitForUsageReset = false;
            modelFallback = true;
            usageAwareFallback = true;
            # Switch away only when quota is fully exhausted, so slowMode can engage at the wall.
            usageReservePct = 0;
            usageReservePolicy = "auto";
            fallbackChains = {
              "anthropic/claude-fable-5-2" = [
                "anthropic/claude-opus-5-5"
                "openai-codex/gpt-6.1-sol"
              ];
              "anthropic/claude-opus-5-5" = [
                "openai-codex/gpt-6.1-sol"
                "zen-free/glm-5.3-flash-free"
              ];
              "anthropic/claude-sonnet-5-5" = [
                "openai-codex/gpt-6.1-sol"
                "zen-free/glm-5.3-flash-free"
              ];
              "anthropic/claude-haiku-5-5" = [
                "openai-codex/gpt-6-luna"
                "zen-free/glm-5.3-flash-free"
              ];
              "openai-codex/*" = [
                "anthropic/claude-opus-5-5"
                "zen-free/glm-5.3-flash-free"
              ];
              "zen-free/glm-5.3-flash-free" = [ "zen-free/deepseek-v4.1-flash-free" ];
              judge = [ "anthropic/claude-haiku-5-5:low" ];
              "amd-account-1/*" = [ "amd-account-2/*" "amd-account-3/*" "amd-account-4/*" ];
              "amd-account-2/*" = [ "amd-account-3/*" "amd-account-4/*" "amd-account-1/*" ];
              "amd-account-3/*" = [ "amd-account-4/*" "amd-account-1/*" "amd-account-2/*" ];
              "amd-account-4/*" = [ "amd-account-1/*" "amd-account-2/*" "amd-account-3/*" ];
              # Gemini is being dropped: no image fallback beyond gpt-image-2.
              image = [ ];
            };
            rateLimitWalksChain = true;
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
            # Spill large outputs to recoverable artifacts instead of filling context.
            artifactSpillThreshold = 20;
            artifactTailBytes = 5;
            artifactHeadBytes = 5;
            outputMaxColumns = 768;
            artifactTailLines = 120;
            intentTracing = true;
            abortOnFabricatedResult = true;
            speculativeExecution = {
              enabled = false;
              maxInFlight = 2;
            };
            maxTimeout = 0;
            xdev = true;
            xdevDocs = "catalog";
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
            enabled = false;
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
            submitTrigger = "never";
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
            checkUpdate = false;
            changelogMode = "summary";
          };
          update.channel = "stable";
          marketplace.autoUpdate = "off";
          autoResume = false;
          power.sleepPrevention = "idle";
          features.unexpectedStopDetection = "smart";
          git.enabled = true;

          contextPromotion.enabled = false;
          extendedContext = false;
          branchSummary.enabled = false;
          compaction = {
            enabled = true;
            experimentalContextManagement = false;
            midTurnEnabled = true;
            methodOrder = [
              "remote"
              "handoff"
              "soft"
              "shake"
              "snapcompact"
            ];
            # Reserve-based default (~85%) for small windows; fixed triggers for the big ones.
            thresholdPercent = -1;
            # Exact keys only: a fixed trigger past a model's window opens its pricier
            # extended window (e.g. Haiku 5.5 above 100K), so never use "anthropic/*".
            modelThresholds = {
              "anthropic/claude-opus-5-5" = "f600000";
              "anthropic/claude-sonnet-5-5" = "f600000";
              "anthropic/claude-fable-5-2" = "f600000";
              "openai-codex/gpt-6.1-sol" = "f300000";
            };
            thresholdTokens = -1;
            handoffSaveToDisk = false;
            remoteStreamingV2Enabled = true;
            asyncEnabled = true;
            idleEnabled = false;
            idleThresholdTokens = 200000;
            idleTimeoutSeconds = 600;
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
            polyphonicRecall = true;
            enhancedRecall = true;
            proactiveLinking = true;
            noEmbeddings = false;
            llmMode = "smol";
          };

          edit = {
            mode = "hashline";
            fuzzyMatch = true;
            fuzzyThreshold = 0.95;
            streamingAbort = true;
            recoverInlineEdits = true;
            blockAutoGenerated = true;
            enforceSeenLines = true;
            blackbox.enabled = false;
            autoRepair.enabled = true;
          };
          readLineNumbers = false;
          read = {
            defaultLimit = 200;
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
            requestTimeout = 20;
          };
          astGrep.enabled = true;
          astEdit.enabled = true;
          debug.enabled = true;
          grep.enabled = true;

          bash = {
            enabled = true;
            allowCompoundCommands = true;
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
            eager = "default";
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
          title = {
            generator = "tiny";
            refreshOnReplan = false;
          };
          task = {
            eager = "default";
            batch = true;
            completionProbe = false;
            enableEffort = true;
            maxConcurrency = 8;
            enableLsp = true;
            maxRecursionDepth = 1;
            maxRuntimeMs = 0;
            softRequestBudget = 120;
            # Long implementation assignments keep their own larger request budget.
            agentSoftRequestBudget.task = 300;
            agentModelOverrides = {
              scout = "anthropic/claude-sonnet-5-5:low";
              sonic = "anthropic/claude-haiku-5-5:low";
              task = "anthropic/claude-sonnet-5-5:medium";
              reviewer = "openai-codex/gpt-6.1-sol:medium";
              security-reviewer = "openai-codex/gpt-6.1-sol:high";
            };
            softRequestBudgetNotice = true;
            maxEffort = "high";
            prewalk = false;
            isolation.enabled = true;
            isolation.apply = true;
            isolation.merge = "patch";
            isolation.commits = "generic";
          };
          isolation.backend = "auto";
          worktree.clone = true;
          worktree.onStart = "ask";
          worktree.onExit = "ask";
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
            # The large ~/.agents collection stays installed, but is opt-in for OMP.
            enableAgentsUser = false;
            enableAgentsProject = true;
            customDirectories = [
              "/home/zynix/.omp/agent/skills"
            ];
          };
          commands = {
            enableClaudeUser = false;
            enableClaudeProject = true;
            enableOpencodeUser = false;
            enableOpencodeProject = true;
          };

          providers.maxInFlightRequests = {
            "openai-codex" = 4;
            "google-antigravity" = 2;
          };
          codexResets = {
            autoRedeem5h = "no";
            autoRedeemWeekly = "no";
          };
          claudeResets = {
            autoRedeem5h = "no";
            autoRedeemWeekly = "no";
          };
          exa.enabled = true;
          secrets.enabled = true;
          dev = {
            autoqa = true;
            autoqaConsent = "granted";
          };

        };
        configFile = (pkgs.formats.yaml { }).generate "omp-config.yml" ompSettings;
      in
      {

        home.packages = [ pkgs.omp ];

        # Seed mutable user files once; later rebuilds preserve edits and credentials.
        # Superpowers maintains its own versioned extension path in a separate activation.
        home.activation.ompConfig = lib.mkForce {
          before = [ ];
          after = [ "writeBoundary" ];
          data = ''
            run mkdir -p "$HOME/.omp/agent"
            run mkdir -p "$HOME/.omp/agent/extensions/zen-free"
            run mkdir -p "$HOME/.omp/agent/skills"
            if [ -d "$HOME/.agents/skills/reverse-engineer-anything" ]; then
              run ln -sfn "$HOME/.agents/skills/reverse-engineer-anything" "$HOME/.omp/agent/skills/reverse-engineer-anything"
            fi
            if [ ! -f "$HOME/.omp/agent/config.yml" ]; then
              run install -m 600 ${configFile} "$HOME/.omp/agent/config.yml"
            fi
            if [ ! -f "$HOME/.omp/agent/models.yml" ]; then
              run install -m 600 ${./omp/models.yml} "$HOME/.omp/agent/models.yml"
            fi
            for name in index.ts transport.ts index.test.ts transport.test.ts; do
              if [ ! -e "$HOME/.omp/agent/extensions/zen-free/$name" ]; then
                run install -m 600 ${./omp/zen-free}/"$name" "$HOME/.omp/agent/extensions/zen-free/$name"
              fi
            done
            # The extension resolves its own imports through this link when run under
            # `bun test`; OMP's own loader resolves the host modules itself. Repoint it on
            # every rebuild so it never pins a garbage-collected store path.
            run ln -sfn ${pkgs.omp}/lib/omp/node_modules "$HOME/.omp/agent/extensions/zen-free/node_modules"
          '';
        };
      }
    )
  ];
}
