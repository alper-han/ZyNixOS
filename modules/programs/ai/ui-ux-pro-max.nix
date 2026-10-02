{ ... }:
{
  home-manager.sharedModules = [
    (
      { pkgs, ... }:
      let
        upstreamSkills = [
          "banner-design"
          "brand"
          "design"
          "design-system"
          "slides"
          "ui-styling"
        ];
        # OMP discovers one directory level, so encode the upstream source in each skill name.
        mainSkill = "ui-ux-pro-max-nextlevelbuilder";
        installedSkills = [ mainSkill ] ++ map (name: "${mainSkill}-${name}") upstreamSkills;

        uiUxProMaxSkills = pkgs.stdenvNoCC.mkDerivation {
          pname = "ui-ux-pro-max-nextlevelbuilder-skills";
          version = "git-09170eec";
          src = pkgs.fetchFromGitHub {
            owner = "nextlevelbuilder";
            repo = "ui-ux-pro-max-skill";
            rev = "09170eec67eefd46a7ae85de61b40c194020f997";
            hash = "sha256-vKtkyxPGiuA5WGjHHr1wgl66XZxSFamjnIOLyxxSPJg=";
          };
          nativeBuildInputs = [ pkgs.python3 ];
          dontBuild = true;
          installPhase = ''
            runHook preInstall

            skillRoot="$out/share/agent-skills"
            mainSkillDir="$skillRoot/${mainSkill}"
            mkdir -p "$mainSkillDir"
            cp -R cli/assets/data "$mainSkillDir/data"
            cp -R cli/assets/scripts "$mainSkillDir/scripts"

            python3 - "$PWD" "$mainSkillDir" "${mainSkill}" <<'PY'
            import json
            import pathlib
            import sys

            source = pathlib.Path(sys.argv[1])
            destination = pathlib.Path(sys.argv[2])
            skill_name = sys.argv[3]

            config = json.loads(
                (source / "cli/assets/templates/platforms/universal.json").read_text(encoding="utf-8")
            )
            config["scriptPath"] = f"skills/{skill_name}/scripts/search.py"

            content = (source / "cli/assets/templates/base/skill-content.md").read_text(encoding="utf-8")
            frontmatter = ["---"]
            for key, value in config["frontmatter"].items():
                if any(character in value for character in (":", '"', "\n")):
                    value = value.replace('"', '\\"')
                    frontmatter.append(f'{key}: "{value}"')
                else:
                    frontmatter.append(f"{key}: {value}")
            frontmatter.extend(("---", ""))

            replacements = {
                "{{TITLE}}": config["title"],
                "{{DESCRIPTION}}": config["description"],
                "{{SCRIPT_PATH}}": f"~/{config['folderStructure']['root']}/{config['scriptPath']}",
                "{{SKILL_OR_WORKFLOW}}": config["skillOrWorkflow"],
                "{{QUICK_REFERENCE}}": "",
            }
            for placeholder, value in replacements.items():
                content = content.replace(placeholder, value)

            (destination / "SKILL.md").write_text(
                "\n".join(frontmatter) + content,
                encoding="utf-8",
            )
            PY

            for sourceSkill in cli/assets/skills/*; do
              [ -d "$sourceSkill" ] || continue
              skillName="${mainSkill}-$(basename "$sourceSkill")"
              mkdir -p "$skillRoot/$skillName"
              cp -R "$sourceSkill"/. "$skillRoot/$skillName/"
            done

            install -Dm644 LICENSE "$out/share/licenses/${mainSkill}/LICENSE"
            runHook postInstall
          '';
        };

        skillFiles = builtins.listToAttrs (
          map (name: {
            name = ".agents/skills/${name}";
            value.source = "${uiUxProMaxSkills}/share/agent-skills/${name}";
          }) installedSkills
        );
      in
      {
        home.packages = [ pkgs.python3 ];
        home.file = skillFiles;
      }
    )
  ];
}
