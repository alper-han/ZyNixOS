{ }:
let
  fileInfoCommand = "caelestia shell thunar fileinfo %f";
  exifCommand = "caelestia shell thunar exif %f";
  mediaInfoCommand = "caelestia shell thunar mediainfo %f";
  uiBackendName = "Caelestia";
  fileInfoId = "fileinfo-caelestia";
  exifInfoId = "exifinfo-caelestia";
  mediaInfoId = "mediainfo-caelestia";
in
{
  xml = ''
    <action>
      <icon>dialog-information</icon>
      <name>File Info</name>
      <unique-id>${fileInfoId}</unique-id>
      <command>${fileInfoCommand}</command>
      <description>Show file information with ${uiBackendName}</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <directories/>
      <other-files/>
    </action>

    <action>
      <icon>image-x-generic</icon>
      <name>EXIF Data</name>
      <unique-id>${exifInfoId}</unique-id>
      <command>${exifCommand}</command>
      <description>Show image metadata with ${uiBackendName}</description>
      <patterns>*.jpg;*.jpeg;*.png;*.gif;*.webp;*.heic;*.raw;*.cr2;*.nef;*.arw;*.tiff;*.bmp</patterns>
      <image-files/>
      <other-files/>
    </action>

    <action>
      <icon>video-x-generic</icon>
      <name>Media Info</name>
      <unique-id>${mediaInfoId}</unique-id>
      <command>${mediaInfoCommand}</command>
      <description>Show audio/video info with ${uiBackendName}</description>
      <patterns>*.mp4;*.mkv;*.avi;*.mov;*.webm;*.flv;*.wmv;*.m4v;*.mp3;*.flac;*.wav;*.ogg;*.m4a;*.aac;*.opus</patterns>
      <audio-files/>
      <video-files/>
      <other-files/>
    </action>
  '';

  packages =
    pkgs: with pkgs; [
      exiftool
      mediainfo
    ];
}
