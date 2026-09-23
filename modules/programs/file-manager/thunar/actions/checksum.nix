{ }:
let
  checksumCommand = algorithm: "caelestia shell thunar checksum %f ${algorithm}";
in
{
  xml = ''
    <action>
      <icon>dialog-password</icon>
      <name>SHA256</name>
      <submenu>Checksum</submenu>
      <unique-id>checksum-sha256</unique-id>
      <command>${checksumCommand "sha256"}</command>
      <description>Calculate SHA256 hash</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <other-files/>
    </action>

    <action>
      <icon>dialog-password</icon>
      <name>SHA512</name>
      <submenu>Checksum</submenu>
      <unique-id>checksum-sha512</unique-id>
      <command>${checksumCommand "sha512"}</command>
      <description>Calculate SHA512 hash</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <other-files/>
    </action>

    <action>
      <icon>dialog-password</icon>
      <name>BLAKE3</name>
      <submenu>Checksum</submenu>
      <unique-id>checksum-blake3</unique-id>
      <command>${checksumCommand "blake3"}</command>
      <description>Calculate BLAKE3 hash (fast)</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <other-files/>
    </action>

    <action>
      <icon>dialog-password</icon>
      <name>MD5</name>
      <submenu>Checksum</submenu>
      <unique-id>checksum-md5</unique-id>
      <command>${checksumCommand "md5"}</command>
      <description>Calculate MD5 hash (legacy)</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <other-files/>
    </action>

    <action>
      <icon>dialog-password</icon>
      <name>SHA1</name>
      <submenu>Checksum</submenu>
      <unique-id>checksum-sha1</unique-id>
      <command>${checksumCommand "sha1"}</command>
      <description>Calculate SHA1 hash (legacy)</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <other-files/>
    </action>

    <action>
      <icon>dialog-password</icon>
      <name>Calculate All</name>
      <submenu>Checksum</submenu>
      <unique-id>checksum-all</unique-id>
      <command>${checksumCommand "all"}</command>
      <description>Calculate all checksums</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
      <text-files/>
      <other-files/>
    </action>
  '';

  packages =
    pkgs: with pkgs; [
      b3sum
    ];

}
