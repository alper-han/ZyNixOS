{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "thunar-backend-helper";
  runtimeInputs = with pkgs; [
    b3sum
    coreutils
    exiftool
    file
    gnused
    jq
    mediainfo
    wl-clipboard
    xdg-utils
  ];
  text = ''
    set -o pipefail

    usage() {
      printf '%s\n' 'Usage: thunar-backend-helper <fileinfo|checksum|exif|mediainfo|copy> ...'
    }

    one_line() {
      printf '%s' "$1" | tr '\t\n' '  ' | sed 's/[[:space:]]\+/ /g; s/^[[:space:]]*//; s/[[:space:]]*$//'
    }

    emit_error() {
      local command="$1"
      local code="$2"
      local message="$3"
      jq -cn \
        --arg command "$command" \
        --arg code "$code" \
        --arg message "$message" \
        '{ok:false, command:$command, error:{code:$code, message:$message}}'
    }

    require_existing_path() {
      local command="$1"
      local target="$2"
      if [[ -z "$target" || ! -e "$target" ]]; then
        emit_error "$command" invalid-path 'No valid path selected'
        return 1
      fi
    }

    require_regular_file() {
      local command="$1"
      local target="$2"
      if [[ -z "$target" || ! -f "$target" ]]; then
        emit_error "$command" invalid-file 'No valid file selected'
        return 1
      fi
    }

    hash_file() {
      local algorithm="$1"
      local target="$2"
      case "$algorithm" in
        sha256) sha256sum "$target" | cut -d' ' -f1 ;;
        sha512) sha512sum "$target" | cut -d' ' -f1 ;;
        blake3|b3) b3sum "$target" | cut -d' ' -f1 ;;
        md5) md5sum "$target" | cut -d' ' -f1 ;;
        sha1) sha1sum "$target" | cut -d' ' -f1 ;;
        *) return 2 ;;
      esac
    }

    exif_field() {
      local tag="$1"
      local target="$2"
      local value
      value=$(exiftool -s3 "$tag" "$target" 2>/dev/null || true)
      if [[ -n "$value" ]]; then
        one_line "$value"
      else
        printf '%s' 'N/A'
      fi
    }

    media_field() {
      local format="$1"
      local target="$2"
      local value
      value=$(mediainfo --Inform="$format" "$target" 2>/dev/null || true)
      if [[ -n "$value" ]]; then
        one_line "$value"
      fi
    }

    or_na() {
      if [[ -n "$1" ]]; then
        printf '%s' "$1"
      else
        printf '%s' 'N/A'
      fi
    }

    command="''${1-}"
    shift || true

    case "$command" in
      fileinfo)
        target="''${1-}"
        require_existing_path fileinfo "$target" || exit 1

        basename_value=$(basename "$target")
        realpath_value=$(realpath "$target")
        file_type=$(file -b "$target")
        mime_type=$(xdg-mime query filetype "$target" 2>/dev/null || true)
        [[ -n "$mime_type" ]] || mime_type='unknown'
        size_bytes=$(stat --printf='%s' "$target")
        size_human=$(numfmt --to=iec-i --suffix=B "$size_bytes" 2>/dev/null || printf '%s bytes' "$size_bytes")
        permissions=$(stat --printf='%A' "$target")
        owner=$(stat --printf='%U:%G' "$target")
        modified_time=$(stat --printf='%y' "$target" | cut -d'.' -f1)
        accessed_time=$(stat --printf='%x' "$target" | cut -d'.' -f1)
        inode=$(stat --printf='%i' "$target")

        jq -cn \
          --arg command fileinfo \
          --arg path "$target" \
          --arg basename "$basename_value" \
          --arg realpath "$realpath_value" \
          --arg file_type "$file_type" \
          --arg mime_type "$mime_type" \
          --arg size_bytes "$size_bytes" \
          --arg size_human "$size_human" \
          --arg permissions "$permissions" \
          --arg owner "$owner" \
          --arg modified_time "$modified_time" \
          --arg accessed_time "$accessed_time" \
          --arg inode "$inode" \
          '{ok:true, command:$command, path:$path, fields:{basename:$basename, realpath:$realpath, file_type:$file_type, mime_type:$mime_type, size_bytes:($size_bytes|tonumber), size_human:$size_human, permissions:$permissions, owner:$owner, modified_time:$modified_time, accessed_time:$accessed_time, inode:$inode}}'
        ;;

      checksum)
        target="''${1-}"
        algorithm="''${2-}"
        require_regular_file checksum "$target" || exit 1
        if [[ -z "$algorithm" ]]; then
          emit_error checksum missing-algorithm 'Missing checksum algorithm'
          exit 1
        fi

        case "$algorithm" in
          sha256|sha512|blake3|b3|md5|sha1)
            canonical="$algorithm"
            [[ "$canonical" == b3 ]] && canonical=blake3
            checksum=$(hash_file "$algorithm" "$target") || {
              emit_error checksum command-failed "Checksum command failed for algorithm: $algorithm"
              exit 1
            }
            jq -cn \
              --arg command checksum \
              --arg path "$target" \
              --arg algorithm "$canonical" \
              --arg checksum "$checksum" \
              '{ok:true, command:$command, path:$path, algorithm:$algorithm, checksums:{($algorithm):$checksum}}'
            ;;
          all)
            sha256=$(hash_file sha256 "$target") || exit 1
            sha512=$(hash_file sha512 "$target") || exit 1
            blake3=$(hash_file blake3 "$target") || exit 1
            md5=$(hash_file md5 "$target") || exit 1
            sha1=$(hash_file sha1 "$target") || exit 1
            jq -cn \
              --arg command checksum \
              --arg path "$target" \
              --arg sha256 "$sha256" \
              --arg sha512 "$sha512" \
              --arg blake3 "$blake3" \
              --arg md5 "$md5" \
              --arg sha1 "$sha1" \
              '{ok:true, command:$command, path:$path, algorithm:"all", checksums:{sha256:$sha256, sha512:$sha512, blake3:$blake3, md5:$md5, sha1:$sha1}}'
            ;;
          *)
            emit_error checksum unsupported-algorithm "Unsupported checksum algorithm: $algorithm"
            exit 2
            ;;
        esac
        ;;

      exif)
        target="''${1-}"
        require_regular_file exif "$target" || exit 1
        basename_value=$(basename "$target")
        model=$(exif_field -Model "$target")
        lens_model=$(exif_field -LensModel "$target")
        date_time_original=$(exif_field -DateTimeOriginal "$target")
        image_size=$(exif_field -ImageSize "$target")
        iso=$(exif_field -ISO "$target")
        aperture=$(exif_field -Aperture "$target")
        shutter_speed=$(exif_field -ShutterSpeed "$target")
        focal_length=$(exif_field -FocalLength "$target")
        gps_position=$(exif_field -GPSPosition "$target")
        software=$(exif_field -Software "$target")
        color_space=$(exif_field -ColorSpace "$target")
        file_size=$(exif_field -FileSize "$target")
        jq -cn \
          --arg command exif \
          --arg path "$target" \
          --arg basename "$basename_value" \
          --arg model "$model" \
          --arg lens_model "$lens_model" \
          --arg date_time_original "$date_time_original" \
          --arg image_size "$image_size" \
          --arg iso "$iso" \
          --arg aperture "$aperture" \
          --arg shutter_speed "$shutter_speed" \
          --arg focal_length "$focal_length" \
          --arg gps_position "$gps_position" \
          --arg software "$software" \
          --arg color_space "$color_space" \
          --arg file_size "$file_size" \
          '{ok:true, command:$command, path:$path, fields:{basename:$basename, Model:$model, LensModel:$lens_model, DateTimeOriginal:$date_time_original, ImageSize:$image_size, ISO:$iso, Aperture:$aperture, ShutterSpeed:$shutter_speed, FocalLength:$focal_length, GPSPosition:$gps_position, Software:$software, ColorSpace:$color_space, FileSize:$file_size}}'
        ;;

      mediainfo)
        target="''${1-}"
        require_regular_file mediainfo "$target" || exit 1
        if ! mediainfo "$target" >/dev/null 2>&1; then
          emit_error mediainfo command-failed 'Could not read media information'
          exit 1
        fi
        format=$(or_na "$(media_field 'General;%Format%' "$target")")
        duration=$(or_na "$(media_field 'General;%Duration/String3%' "$target")")
        file_size=$(or_na "$(media_field 'General;%FileSize/String%' "$target")")
        overall_bitrate=$(or_na "$(media_field 'General;%OverallBitRate/String%' "$target")")
        video_format=$(or_na "$(media_field 'Video;%Format%' "$target")")
        video_width=$(media_field 'Video;%Width%' "$target")
        video_height=$(media_field 'Video;%Height%' "$target")
        if [[ -n "$video_width" && -n "$video_height" ]]; then
          video_resolution="''${video_width}x''${video_height}"
        else
          video_resolution='N/A'
        fi
        video_frame_rate=$(media_field 'Video;%FrameRate%' "$target")
        if [[ -n "$video_frame_rate" ]]; then
          video_fps="$video_frame_rate fps"
        else
          video_fps='N/A'
        fi
        video_bitrate=$(or_na "$(media_field 'Video;%BitRate/String%' "$target")")
        audio_format=$(or_na "$(media_field 'Audio;%Format%' "$target")")
        audio_channels_raw=$(media_field 'Audio;%Channel(s)%' "$target")
        if [[ -n "$audio_channels_raw" ]]; then
          audio_channels="$audio_channels_raw ch"
        else
          audio_channels='N/A'
        fi
        audio_sample_rate=$(or_na "$(media_field 'Audio;%SamplingRate/String%' "$target")")
        audio_bitrate=$(or_na "$(media_field 'Audio;%BitRate/String%' "$target")")
        basename_value=$(basename "$target")
        jq -cn \
          --arg command mediainfo \
          --arg path "$target" \
          --arg basename "$basename_value" \
          --arg format "$format" \
          --arg duration "$duration" \
          --arg file_size "$file_size" \
          --arg overall_bitrate "$overall_bitrate" \
          --arg video_format "$video_format" \
          --arg video_resolution "$video_resolution" \
          --arg video_frame_rate "$video_fps" \
          --arg video_bitrate "$video_bitrate" \
          --arg audio_format "$audio_format" \
          --arg audio_channels "$audio_channels" \
          --arg audio_sample_rate "$audio_sample_rate" \
          --arg audio_bitrate "$audio_bitrate" \
          '{ok:true, command:$command, path:$path, fields:{basename:$basename, general:{Format:$format, Duration:$duration, FileSize:$file_size, OverallBitRate:$overall_bitrate}, video:{Format:$video_format, Resolution:$video_resolution, FrameRate:$video_frame_rate, BitRate:$video_bitrate}, audio:{Format:$audio_format, Channels:$audio_channels, SamplingRate:$audio_sample_rate, BitRate:$audio_bitrate}}}'
        ;;

      copy)
        if [[ "$#" -gt 0 ]]; then
          copy_text="$*"
        else
          copy_text=$(cat)
        fi
        if printf '%s' "$copy_text" | wl-copy --type text/plain; then
          jq -cn --arg command copy '{ok:true, command:$command, copied:true}'
        else
          emit_error copy clipboard-failed 'Failed to copy to clipboard'
          exit 1
        fi
        ;;

      ""|-h|--help|help)
        usage
        exit 0
        ;;

      *)
        emit_error unknown unsupported-command "Unsupported helper command: $command"
        exit 2
        ;;
    esac
  '';
}
