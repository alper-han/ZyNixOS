# PeaZip Thunar Custom Actions
{
  xml = ''
    <!-- Add to Archive -->
    <action>
      <icon>package-x-generic</icon>
      <name>Add to Archive</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-add</unique-id>
      <command>peazip -add2archive %F</command>
      <description>Create archive with PeaZip</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <directories/>
      <other-files/>
    </action>

    <!-- Add to ZIP -->
    <action>
      <icon>package-x-generic</icon>
      <name>Add to ZIP</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-zip</unique-id>
      <command>peazip -add2zip %F</command>
      <description>Create ZIP archive</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <directories/>
      <other-files/>
    </action>

    <!-- Add to 7Z -->
    <action>
      <icon>package-x-generic</icon>
      <name>Add to 7Z</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-7z</unique-id>
      <command>peazip -add27z %F</command>
      <description>Create 7Z archive</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <directories/>
      <other-files/>
    </action>

    <!-- Extract Here -->
    <action>
      <icon>extract-archive</icon>
      <name>Extract Here</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-extract-here</unique-id>
      <command>peazip -ext2here %F</command>
      <description>Extract to current folder</description>
      <patterns>*.zip;*.7z;*.rar;*.tar;*.gz;*.bz2;*.xz;*.iso;*.pea;*.zst;*.lz4</patterns>
      <other-files/>
    </action>

    <!-- Extract to New Folder -->
    <action>
      <icon>extract-archive</icon>
      <name>Extract to New Folder</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-extract-folder</unique-id>
      <command>peazip -ext2newfolder %F</command>
      <description>Extract to new folder</description>
      <patterns>*.zip;*.7z;*.rar;*.tar;*.gz;*.bz2;*.xz;*.iso;*.pea;*.zst;*.lz4</patterns>
      <other-files/>
    </action>

    <!-- Smart Extract -->
    <action>
      <icon>extract-archive</icon>
      <name>Smart Extract</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-extract-smart</unique-id>
      <command>peazip -ext2smart %F</command>
      <description>Smart extract (auto-detect structure)</description>
      <patterns>*.zip;*.7z;*.rar;*.tar;*.gz;*.bz2;*.xz;*.iso;*.pea;*.zst;*.lz4</patterns>
      <other-files/>
    </action>

    <!-- Open with PeaZip -->
    <action>
      <icon>archive-manager</icon>
      <name>Open with PeaZip</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-browse</unique-id>
      <command>peazip -ext2browse %F</command>
      <description>Browse archive contents</description>
      <patterns>*.zip;*.7z;*.rar;*.tar;*.gz;*.bz2;*.xz;*.iso;*.pea;*.zst;*.lz4</patterns>
      <other-files/>
    </action>

    <!-- Test Archive -->
    <action>
      <icon>dialog-information</icon>
      <name>Test Archive</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-test</unique-id>
      <command>peazip -ext2test %F</command>
      <description>Test archive integrity</description>
      <patterns>*.zip;*.7z;*.rar;*.tar;*.gz;*.bz2;*.xz;*.iso;*.pea;*.zst;*.lz4</patterns>
      <other-files/>
    </action>

    <!-- Convert Archive -->
    <action>
      <icon>document-save-as</icon>
      <name>Convert Archive</name>
      <submenu>PeaZip</submenu>
      <unique-id>peazip-convert</unique-id>
      <command>peazip -add2convert %F</command>
      <description>Convert to another format</description>
      <patterns>*.zip;*.7z;*.rar;*.tar;*.gz;*.bz2;*.xz;*.iso;*.pea;*.zst;*.lz4</patterns>
      <other-files/>
    </action>
  '';

  packages = pkgs: with pkgs; [
    peazip
  ];
}
