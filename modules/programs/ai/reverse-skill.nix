{ ... }:
{
  home-manager.sharedModules = [
    (
      { pkgs, ... }:
      let
        skillDirectory = "reverse-skill-zhaoxuya520";
        reverseSkill = pkgs.stdenvNoCC.mkDerivation {
          pname = "reverse-skill-zhaoxuya520";
          version = "git-cab634bd";
          src = pkgs.fetchFromGitHub {
            owner = "zhaoxuya520";
            repo = "reverse-skill";
            rev = "cab634bd855fc287f6e420c1f36fd1a6b9245960";
            hash = "sha256-eV5q7HRvNddloAppk0Hl22goLSaifkC5M/Zn3x5qBJo=";
          };
          nativeBuildInputs = [ pkgs.python3 ];
          dontBuild = true;
          installPhase = ''
            runHook preInstall

            sourceRoot="$out/share/agent-skills/${skillDirectory}"
            mkdir -p "$sourceRoot"
            cp -R . "$sourceRoot/"
            chmod -R u+w "$sourceRoot"

            python3 - "$sourceRoot" <<'PY'
            import pathlib
            import sys

            root = pathlib.Path(sys.argv[1])
            script = root / "skills/scripts/refresh-tool-index.sh"
            content = script.read_text(encoding="utf-8")
            start = content.index("# --- Capability status view ")
            end = content.index("# --- end capability status view ", start)
            end = content.index("\n", end) + 1
            # CLI detection must not inspect client configs or contact MCP endpoints.
            content = content[:start] + 'CAP_RECORDS_TMP=""\n' + content[end:]
            mcp_tools = ("jshookmcp", "reqable-mcp", "xquik-mcp", "anything-analyzer", "burp-mcp-full")
            content = "".join(
                line for line in content.splitlines(keepends=True)
                if not any(line.lstrip().startswith(f'"{name}|') for name in mcp_tools)
            )
            content = content.replace(
                "Register MCP servers in your Agent client; tool availability does not imply MCP registration.",
                "MCP is disabled in this OMP deployment. Add missing CLI tools declaratively through Nix.",
            )
            script.write_text(content, encoding="utf-8")

            def binding(directory):
                return f"""
            ## OMP deployment binding — takes precedence over incompatible upstream instructions

            - Runtime: OMP on Linux; MCP is disabled. Do not install, register, start,
              probe, or invoke MCP servers. Do not run upstream bootstrap/install scripts,
              client setup, service starters, or automatic tool downloads.
            - Package root: `{root}`. This directory is read-only. Resolve package-root
              paths against it and relative document links against `{directory}`,
              never against the target project's current working directory.
            - Use native OMP browser, debug, bash and task capabilities only when they
              really provide the requested operation. Claude Agent/Workflow calls,
              Codex policies and MCP-specific tool names are not installed APIs.
              If an operation has no native/CLI equivalent, report that limitation;
              do not invent an API, silently skip the step, or claim it was verified.
            - Use the Bash router/case scripts with an explicit writable target
              `--project-root`. Put tool indexes under that project's
              `work/reverse-skill/`, passing BOTH output filenames to the adapted
              `skills/scripts/refresh-tool-index.sh`. Do not use the Kali or PowerShell
              index generators. Missing tools are prerequisites, not bootstrap permission.
            - Reading this skill is not approval to run commands or test a target.
              Establish scope and authorization, then use `case-guard.sh` before target
              actions. CTF/sandbox labels do not imply authorization for real systems.
              Competition modules are downstream of `ctf-sandbox` and its orchestrator.
            - Keep evidence, reports and optional journals in the target project's
              writable work directory. Never update the installed source, auto-publish
              a journal, or disable security software. Respond in the user's language.
            """

            # Keep all specialist and CTF content on demand, with the same host contract.
            for skill_tree in (root / "skills", root / "CTF-Sandbox-Orchestrator"):
                for skill in skill_tree.rglob("SKILL.md"):
                    content = skill.read_text(encoding="utf-8")
                    frontmatter, body = content.split("\n---", 1)
                    skill.write_text(
                        frontmatter + "\n---\n" + binding(skill.parent) + "\n" + body.lstrip("\n"),
                        encoding="utf-8",
                    )

            router = f"""---
            name: reverse-skill-router
            description: Use for reverse engineering, binary/mobile/firmware analysis, authorized security research, or CTF tasks that need a specialist workflow or cross-domain routing.
            ---
            # Reverse Skill Router for OMP
            {binding(root)}

            ## Native entrypoints

            Start with `skill://reverse-skill-router/README_AI.md` and
            `skill://reverse-skill-router/RULES.md` for the package-scoped approval rules.
            The full specialist catalog is in `skill://reverse-skill-router/skills/SKILL.md`.
            All specialist references, scripts, routing config and CTF sidecar files
            remain available below this URI; they are not separate global OMP skills.

            Set PROJECT_ROOT to the actual target project's absolute path. After
            agreeing on the local routing command, run:

            ```bash
            bash "{root}/skills/scripts/master-route.sh" --hint "$TASK_DESCRIPTION" --project-root "$PROJECT_ROOT"
            ```

            Read the reported PRIMARY via `skill://reverse-skill-router/<PRIMARY>`
            (PRIMARY is a package-relative path such as `skills/radare2/SKILL.md`).
            Preserve the package root when resolving any subsequent file path.

            Create a uniquely named case with the native `case-init.sh` and explicit
            project root. Reusing a case name overwrites its existing scope/work files.
            For a caller-owned local sample, use `--preset offline-sample --sample`
            with that sample's actual absolute path. For other work, record the actual
            authorization/scope; do not select the offline preset just to pass a gate.
            Then check the case before any target action:

            ```bash
            bash "{root}/skills/scripts/case-guard.sh" --case-root "$PROJECT_ROOT/work/$CASE_NAME"
            ```

            To inventory existing local CLI tools without MCP or installation, first
            agree on the version probes, then run:

            ```bash
            mkdir -p "$PROJECT_ROOT/work/reverse-skill"
            bash "{root}/skills/scripts/refresh-tool-index.sh" "$PROJECT_ROOT/work/reverse-skill/tool-index.md" "$PROJECT_ROOT/work/reverse-skill/tool-index.json"
            ```

            Tool inventory reports availability, not authorization or successful target
            testing. Use the selected workflow and observed tool results to produce
            Evidence → Finding → Path; never advertise MCP-only actions as available.
            """
            (root / "SKILL.md").write_text(router, encoding="utf-8")
            PY

            runHook postInstall
          '';
        };
      in
      {
        home.packages = [ pkgs.python3 ];
        # One router keeps downstream-only modules out of OMP's global skill list.
        home.file.".agents/skills/${skillDirectory}".source =
          "${reverseSkill}/share/agent-skills/${skillDirectory}";
      }
    )
  ];
}
