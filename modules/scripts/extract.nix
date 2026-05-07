{ pkgs, ... }:
pkgs.writeShellScriptBin "ex" ''
  if [ -z "$1" ]; then
     # display usage if no parameters given
     echo "Usage: $(basename "$0") <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|exe|tar.bz2|tar.gz|tar.xz>"
     echo "       $(basename "$0") <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
     echo "       For password-protected files: EX_PASSWORD=yourpassword $(basename "$0") file.rar"
  else
     for n in "$@"
     do
       if [ -f "$n" ] ; then
           case "''${n%,}" in
             *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
             ${pkgs.gnutar}/bin/tar xvf "$n"       ;;
             *.lzma)      ${pkgs.xz}/bin/unlzma ./"$n"      ;;
             *.bz2)       ${pkgs.bzip2}/bin/bunzip2 ./"$n"     ;;
             *.cbr|*.rar)
                 if [ -n "$EX_PASSWORD" ]; then
                     ${pkgs.unrar}/bin/unrar x -ad -p"$EX_PASSWORD" ./"$n"
                 else
                     ${pkgs.unrar}/bin/unrar x -ad ./"$n"
                 fi ;;
             *.gz)        ${pkgs.gzip}/bin/gunzip ./"$n"      ;;
             *.cbz|*.epub|*.zip)
                 if [ -n "$EX_PASSWORD" ]; then
                     ${pkgs.unzip}/bin/unzip -P "$EX_PASSWORD" ./"$n"
                 else
                     ${pkgs.unzip}/bin/unzip ./"$n"
                 fi ;;
             *.z)         ${pkgs.gzip}/bin/uncompress ./"$n"  ;;
             *.7z|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                 if [ -n "$EX_PASSWORD" ]; then
                     ${pkgs.p7zip}/bin/7z x -p"$EX_PASSWORD" ./"$n"
                 else
                     ${pkgs.p7zip}/bin/7z x ./"$n"
                 fi ;;
             *.xz)        ${pkgs.xz}/bin/unxz ./"$n"        ;;
             *.exe)       ${pkgs.cabextract}/bin/cabextract ./"$n"  ;;
             *.cpio)      ${pkgs.cpio}/bin/cpio -id < ./"$n"  ;;
             *)
             echo "Unsupported format"
             return 1
             ;;
           esac
       else
           echo "'$n' - file does not exist"
           return 1
       fi
     done
  fi
''
