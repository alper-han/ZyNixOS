{
  home-manager.sharedModules = [
    {
      programs.starship = {
        enable = true;
        settings = {
          # Show session identity over SSH; retain Starship's privileged-user warning.
          add_newline = false;
          scan_timeout = 100;
          format = "$os$container($username$hostname )$sudo$directory$git_branch$git_state$direnv$nix_shell$docker_context$nodejs$bun$deno$lua$rust$golang$dotnet$java$kotlin$swift$dart$elixir$haskell$scala$ruby$php$zig$c$cpp$cmake$python$git_status$cmd_duration$jobs$memory_usage$status$character";
          right_format = "$time";

          # Explicit OS badges keep local and remote identities readable.
          os = {
            disabled = false;
            format = "[$symbol]($style)";
            style = "#8AADF4";
            symbols = {
              AIX = "AIX ";
              Alpaquita = "Alpaquita Linux ";
              AlmaLinux = " ";
              Alpine = " ";
              ALTLinux = "ALT Linux ";
              Amazon = "Amazon Linux ";
              Android = " ";
              AOSC = " ";
              Arch = " ";
              Artix = " ";
              Bluefin = "Bluefin ";
              CachyOS = " ";
              CentOS = " ";
              Debian = " ";
              Elementary = " ";
              DragonFly = "DragonFly BSD ";
              Emscripten = "Emscripten ";
              EndeavourOS = " ";
              Fedora = " ";
              FreeBSD = " ";
              Garuda = " ";
              Gentoo = " ";
              HardenedBSD = "HardenedBSD ";
              Illumos = " ";
              Ios = "iOS ";
              InstantOS = "InstantOS ";
              Kali = " ";
              Linux = " ";
              Mabox = "Mabox ";
              Macos = " ";
              Manjaro = " ";
              Mariner = "Azure Linux ";
              MidnightBSD = "MidnightBSD ";
              Mint = " ";
              NetBSD = "NetBSD ";
              NixOS = " ";
              Nobara = " ";
              OpenBSD = " ";
              OpenCloudOS = "OpenCloudOS ";
              openEuler = "openEuler ";
              openSUSE = " ";
              OracleLinux = "Oracle Linux ";
              PikaOS = "PikaOS ";
              Pop = " ";
              Raspbian = " ";
              Redhat = " ";
              RedHatEnterprise = " ";
              RockyLinux = " ";
              Redox = "Redox ";
              Solus = " ";
              SUSE = "SUSE ";
              Ubuntu = " ";
              Ultramarine = "Ultramarine ";
              Unknown = "Unknown ";
              Uos = "UnionTech OS ";
              Void = " ";
              Windows = " ";
              Zorin = " ";
            };
          };

          username = {
            show_always = false;
            style_user = "#A6DA95";
            style_root = "#ED8796";
            format = "[$user]($style)";
          };

          hostname = {
            ssh_only = true;
            style = "#F4DBD6";
            format = "[@$hostname]($style)";
          };

          shell = {
            disabled = false;
            format = "[$indicator]($style) ";
            style = "#A5ADCB";
            bash_indicator = "bash";
            zsh_indicator = "zsh";
            fish_indicator = "fish";
            powershell_indicator = "pwsh";
            nu_indicator = "nu";
            unknown_indicator = "";
          };

          # Shield: cached sudo credentials, not persistent root access.
          sudo = {
            disabled = false;
            symbol = " ";
            format = "[$symbol]($style)";
            style = "#EED49F";
          };

          directory = {
            truncate_to_repo = false;
            read_only = " ro";
            style = "#57C7FF";
          };

          character = {
            success_symbol = "[❯](#FF6AC1)";
            error_symbol = "[❯](#FF5C57)";
            vimcmd_symbol = "[❮](bright-green)";
          };

          git_branch = {
            format = "[ $branch]($style) ";
            style = "#A5ADCB";
          };

          git_status = {
            format = "$staged$modified$deleted$untracked$renamed$conflicted$stashed$ahead_behind";
            staged = "[ \${count}](#A6DA95) ";
            modified = "[ \${count}](#EED49F) ";
            deleted = "[ \${count}](#ED8796) ";
            untracked = "[ \${count}](#EED49F) ";
            renamed = "[ \${count}](#57C7FF) ";
            conflicted = "[ \${count}](#ED8796) ";
            stashed = "[ \${count}](#A5ADCB) ";
            ahead = "[ \${count}](#A6DA95) ";
            behind = "[ \${count}](#EED49F) ";
            diverged = "[ \${ahead_count}](#A6DA95) [ \${behind_count}](#EED49F) ";
          };

          git_state = {
            format = ''\([$state( $progress_current/$progress_total)]($style)\) '';
            style = "#EED49F";
          };

          direnv = {
            disabled = false;
            symbol = "direnv ";
            format = "[$symbol$loaded/$allowed]($style) ";
            style = "#EED49F";
          };

          nix_shell = {
            symbol = " ";
            format = ''[$symbol$state( \($name\))]($style) '';
            style = "#8AADF4";
          };

          docker_context = {
            symbol = " ";
            only_with_files = true;
            style = "blue";
          };

          container = {
            disabled = false;
            symbol = " ";
            format = "[$symbol$name]($style) ";
            style = "#C6A0F6";
          };

          nodejs.symbol = " ";
          bun.symbol = " ";
          deno.symbol = " ";
          lua = {
            disabled = false;
            symbol = " ";
            format = "[$symbol$version]($style) ";
            style = "#8AADF4";
          };
          rust.symbol = " ";
          golang.symbol = " ";
          dotnet.symbol = " ";
          java.symbol = " ";
          kotlin.symbol = " ";
          swift.symbol = " ";
          dart.symbol = " ";
          elixir.symbol = " ";
          haskell.symbol = " ";
          scala.symbol = " ";
          ruby.symbol = " ";
          php.symbol = " ";
          zig.symbol = " ";
          c.symbol = " ";
          cpp = {
            disabled = false;
            symbol = " ";
          };
          # Detect C/C++ build trees without local sources.
          cmake.symbol = " ";

          python = {
            format = ''[$symbol($version )(\($virtualenv\))]($style) '';
            style = "#A5ADCB";
            symbol = " ";
          };

          memory_usage = {
            disabled = false;
            threshold = 80;
            symbol = "󰍛";
            format = "[$symbol$ram_pct]($style) ";
            style = "#F5A97F";
          };

          cmd_duration = {
            min_time = 1000;
            format = "[ $duration]($style) ";
            style = "#EED49F";
          };

          time = {
            disabled = false;
            time_format = "%R";
            format = "[$time]($style)";
            style = "#A5ADCB";
          };

          jobs = {
            symbol = "jobs:";
            symbol_threshold = 1;
            number_threshold = 1;
            format = "[$symbol$number]($style) ";
            style = "#8AADF4";
          };

          status = {
            disabled = false;
            symbol = "";
            format = "[$symbol$status]($style) ";
            style = "#ED8796";
            pipestatus = false;
          };
        };
      };
    }
  ];
}
