# General Thunar Custom Actions
{ copy-path, open-terminal-here }:
{
  xml = ''
    <!-- Open Terminal Here -->
    <action>
      <icon>utilities-terminal</icon>
      <name>Open Terminal Here</name>
      <unique-id>open-terminal-here</unique-id>
      <command>${open-terminal-here}/bin/thunar-open-terminal-here %f</command>
      <description>Open terminal in this directory</description>
      <patterns>*</patterns>
      <startup-notify/>
      <directories/>
    </action>

    <!-- Copy Path -->
    <action>
      <icon>edit-copy</icon>
      <name>Copy Path</name>
      <unique-id>copy-path</unique-id>
      <command>${copy-path}/bin/thunar-copy-path %F</command>
      <description>Copy file/folder path to clipboard</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <directories/>
      <other-files/>
    </action>
  '';
}
