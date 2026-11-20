{ ... }:
{
  home-manager.sharedModules = [
    (
      { pkgs, ... }:
      let
        collections = [
          {
            # Community-maintained; not an official Anthropic repository.
            prefix = "cybersecurity-mukul975";
            roots = [ "skills" ];
            src = pkgs.fetchFromGitHub {
              owner = "mukul975";
              repo = "Anthropic-Cybersecurity-Skills";
              rev = "54a798831d2266a3ca61ce68a7acb80b81160d57";
              hash = "sha256-6DgC3KZgbGqibMzS6akWn9ZaK5AjvCSVENwiknvBRV0=";
            };
          }
          {
            prefix = "cybersecurity-briiirussell";
            roots = [ "skills" ];
            src = pkgs.fetchFromGitHub {
              owner = "briiirussell";
              repo = "cybersecurity-skills";
              rev = "c9ade0349f8ecd5c9c68a82a05d2b6012c5fa1d7";
              hash = "sha256-wJjfc6/K7O4pybvWPzzPhGNOVBuBCwGyhv4gfMCymfQ=";
            };
          }
          {
            prefix = "secskills-trilwu";
            roots = [
              "secskills-core/skills"
              "secskills-defense/skills"
              "secskills-offense/skills"
            ];
            indexPaths = [ "secskills-core/ttp-index.json" ];
            src = pkgs.fetchFromGitHub {
              owner = "trilwu";
              repo = "secskills";
              rev = "ca53957bcd8e3b83b5d4d190bb3ad008a4f15c84";
              hash = "sha256-PANhTjY2iZ/haYyhLJwwewcj8DitboTfvGQEX9SRug4=";
            };
          }
        ];
        collectionManifest = pkgs.writeText "security-skill-collections.json" (builtins.toJSON collections);
        securitySkills = pkgs.stdenvNoCC.mkDerivation {
          pname = "security-agent-skills";
          version = "2026-10-03";
          nativeBuildInputs = [ pkgs.python3 ];
          dontUnpack = true;
          dontBuild = true;
          # Home Manager preserves these links outside the package directory.
          dontRewriteSymlinks = true;
          installPhase = ''
            runHook preInstall

            python3 - "${collectionManifest}" "$out" <<'PY'
            import json
            import pathlib
            import shutil
            import sys

            collections = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
            output = pathlib.Path(sys.argv[2])
            skill_root = output / "share/agent-skills"
            skill_root.mkdir(parents=True)

            for collection in collections:
                source = pathlib.Path(collection["src"])
                prefix = collection["prefix"]
                index_paths = collection.get("indexPaths", [])
                if index_paths:
                    # Adapt a complete tree so sibling references keep their layout.
                    source = output / "share/sources" / prefix
                    shutil.copytree(collection["src"], source)
                    for root_name in collection["roots"]:
                        for markdown in (source / root_name).rglob("*.md"):
                            original = markdown.read_text(encoding="utf-8")
                            adapted = original
                            for index_path in index_paths:
                                adapted = adapted.replace(index_path, str(source / index_path))
                            if adapted != original:
                                markdown.chmod(0o644)
                                markdown.write_text(adapted, encoding="utf-8")

                for root_name in collection["roots"]:
                    root = source / root_name
                    for skill_file in sorted(root.rglob("SKILL.md")):
                        skill_directory = skill_file.parent
                        # Flatten nested skills without losing their upstream location.
                        relative_name = "-".join(skill_directory.relative_to(source).parts)
                        destination = skill_root / f"{prefix}-{relative_name}"
                        # Keep the complete source tree reachable for sibling references,
                        # shared tools, and scripts, including the adapted index paths.
                        destination.symlink_to(skill_directory, target_is_directory=True)

                for license_name in ("LICENSE", "NOTICE"):
                    license_file = source / license_name
                    if license_file.is_file():
                        license_directory = output / "share/licenses" / prefix
                        license_directory.mkdir(parents=True, exist_ok=True)
                        (license_directory / license_name).symlink_to(license_file)
            PY

            runHook postInstall
          '';
        };
      in
      {
        # Merge these flat directory links with the existing UI skills. Keeping
        # directory symlinks intact preserves realpaths into the upstream trees.
        home.file.".agents/skills" = {
          source = "${securitySkills}/share/agent-skills";
          recursive = true;
        };
      }
    )
  ];
}
