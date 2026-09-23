{ peazip-action }:
let
  archivePatterns = builtins.concatStringsSep ";" [
    "*.zip"
    "*.ZIP"
    "*.7z"
    "*.7Z"
    "*.rar"
    "*.RAR"
    "*.tar"
    "*.TAR"
    "*.gz"
    "*.GZ"
    "*.tgz"
    "*.TGZ"
    "*.bz2"
    "*.BZ2"
    "*.tbz2"
    "*.TBZ2"
    "*.xz"
    "*.XZ"
    "*.txz"
    "*.TXZ"
    "*.zst"
    "*.ZST"
    "*.lz4"
    "*.LZ4"
    "*.z"
    "*.Z"
    "*.cab"
    "*.CAB"
    "*.arj"
    "*.ARJ"
    "*.lzh"
    "*.LZH"
    "*.iso"
    "*.ISO"
    "*.pea"
    "*.PEA"
    "*.ace"
    "*.ACE"
    "*.jar"
    "*.JAR"
    "*.war"
    "*.WAR"
    "*.apk"
    "*.APK"
    "*.deb"
    "*.DEB"
    "*.rpm"
    "*.RPM"
    "*.cpio"
    "*.CPIO"
    "*.wim"
    "*.WIM"
    "*.chm"
    "*.CHM"
    "*.msi"
    "*.MSI"
    "*.xpi"
    "*.XPI"
  ];
in
{
  xml = ''
    <action>
      <icon>package-x-generic</icon>
      <name>Add to Archive</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-add</unique-id>
      <command>${peazip-action}/bin/thunar-peazip -add2archive %F</command>
      <description>Create archive with PeaZip</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <directories/>
      <other-files/>
    </action>

    <action>
      <icon>package-x-generic</icon>
      <name>Add to ZIP</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-zip</unique-id>
      <command>${peazip-action}/bin/thunar-peazip -add2zip %F</command>
      <description>Create ZIP archive</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <directories/>
      <other-files/>
    </action>

    <action>
      <icon>package-x-generic</icon>
      <name>Add to 7Z</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-7z</unique-id>
      <command>${peazip-action}/bin/thunar-peazip -add27z %F</command>
      <description>Create 7Z archive</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <directories/>
      <other-files/>
    </action>

    <action>
      <icon>extract-archive</icon>
      <name>Extract Here</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-extract-here</unique-id>
      <command>${peazip-action}/bin/thunar-peazip -ext2here %F</command>
      <description>Extract to current folder</description>
      <patterns>${archivePatterns}</patterns>
      <other-files/>
    </action>

    <action>
      <icon>extract-archive</icon>
      <name>Extract to New Folder</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-extract-folder</unique-id>
      <command>${peazip-action}/bin/thunar-peazip -ext2folder %F</command>
      <description>Extract to new folder</description>
      <patterns>${archivePatterns}</patterns>
      <other-files/>
    </action>

    <action>
      <icon>extract-archive</icon>
      <name>Smart Extract</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-extract-smart</unique-id>
      <command>${peazip-action}/bin/thunar-peazip -ext2smart %F</command>
      <description>Smart extract (auto-detect structure)</description>
      <patterns>${archivePatterns}</patterns>
      <other-files/>
    </action>

    <action>
      <icon>archive-manager</icon>
      <name>Open with PeaZip</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-browse</unique-id>
      <command>${peazip-action}/bin/thunar-peazip -ext2browse %F</command>
      <description>Browse archive contents</description>
      <patterns>${archivePatterns}</patterns>
      <other-files/>
    </action>

    <action>
      <icon>dialog-information</icon>
      <name>Test Archive</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-test</unique-id>
      <command>${peazip-action}/bin/thunar-peazip -ext2test %F</command>
      <description>Test archive integrity</description>
      <patterns>${archivePatterns}</patterns>
      <other-files/>
    </action>

    <action>
      <icon>document-save-as</icon>
      <name>Convert Archive</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-convert</unique-id>
      <command>${peazip-action}/bin/thunar-peazip -add2convert %F</command>
      <description>Convert to another format</description>
      <patterns>${archivePatterns}</patterns>
      <other-files/>
    </action>
  '';

  packages =
    pkgs: with pkgs; [
      peazip
    ];
}
