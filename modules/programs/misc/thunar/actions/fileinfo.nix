# File Info Thunar Custom Actions (Rofi)
{
  xml = ''
    <!-- General Info (Rofi) -->
    <action>
      <icon>dialog-information</icon>
      <name>File Info</name>
      <unique-id>fileinfo-rofi</unique-id>
      <command>fileinfo-rofi %f</command>
      <description>Show file information with Rofi</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <directories/>
      <other-files/>
    </action>

    <!-- EXIF Data (Rofi) -->
    <action>
      <icon>image-x-generic</icon>
      <name>EXIF Data</name>
      <unique-id>exifinfo-rofi</unique-id>
      <command>exifinfo-rofi %f</command>
      <description>Show image metadata with Rofi</description>
      <patterns>*.jpg;*.jpeg;*.png;*.gif;*.webp;*.heic;*.raw;*.cr2;*.nef;*.arw;*.tiff;*.bmp</patterns>
      <image-files/>
      <other-files/>
    </action>

    <!-- Media Info (Rofi) -->
    <action>
      <icon>video-x-generic</icon>
      <name>Media Info</name>
      <unique-id>mediainfo-rofi</unique-id>
      <command>mediainfo-rofi %f</command>
      <description>Show audio/video info with Rofi</description>
      <patterns>*.mp4;*.mkv;*.avi;*.mov;*.webm;*.flv;*.wmv;*.m4v;*.mp3;*.flac;*.wav;*.ogg;*.m4a;*.aac;*.opus</patterns>
      <audio-files/>
      <video-files/>
      <other-files/>
    </action>
  '';

  packages = pkgs: with pkgs; [
    exiftool
    mediainfo
  ];

}
