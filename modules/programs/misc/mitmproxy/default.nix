{
  config,
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../../../hosts/${host}/variables.nix) username;

  mitmweb = lib.getExe' pkgs.mitmproxy "mitmweb";
  webPassword = "mitmproxy-local";
  userHome = "/home/${username}";
  stateDir = "${userHome}/.mitmproxy";
  caPem = "${stateDir}/mitmproxy-ca.pem";
  certPem = "${stateDir}/mitmproxy-ca-cert.pem";
  bundlePem = "${stateDir}/ca-certificates-with-mitmproxy.crt";
  trustedCert = ./mitmproxy-ca-cert.pem;

  mitmproxyHomeInit = pkgs.writeShellScript "mitmproxy-home-init" ''
    set -eu
    umask 077

    if [ "$(${pkgs.coreutils}/bin/id -un)" != '${username}' ]; then
      echo "Run this command as ${username}." >&2
      exit 1
    fi

    state_dir='${stateDir}'
    ca_pem='${caPem}'
    cert_pem='${certPem}'
    bundle_pem='${bundlePem}'
    trusted_cert='${trustedCert}'
    generated_new_ca=0

    mkdir -p "$state_dir"
    chmod 700 "$state_dir"

    if [ ! -s "$ca_pem" ]; then
      tmp_key="$(mktemp "$state_dir/mitmproxy-ca-key.XXXXXX")"
      tmp_crt="$(mktemp "$state_dir/mitmproxy-ca-cert.XXXXXX")"

      trap 'rm -f "$tmp_key" "$tmp_crt"' EXIT

      ${pkgs.openssl}/bin/openssl req \
        -x509 \
        -newkey rsa:2048 \
        -sha256 \
        -nodes \
        -days 3650 \
        -subj "/CN=ZyNix mitmproxy CA/" \
        -addext "basicConstraints=critical,CA:TRUE" \
        -addext "keyUsage=critical,keyCertSign,cRLSign" \
        -addext "subjectKeyIdentifier=hash" \
        -keyout "$tmp_key" \
        -out "$tmp_crt"

      cat "$tmp_key" "$tmp_crt" > "$ca_pem"
      chmod 600 "$ca_pem"
      generated_new_ca=1

      trap - EXIT
      rm -f "$tmp_key" "$tmp_crt"
    fi

    ${pkgs.openssl}/bin/openssl x509 -in "$ca_pem" -out "$cert_pem"
    chmod 644 "$cert_pem"

    if ! ${pkgs.diffutils}/bin/cmp -s "$cert_pem" "$trusted_cert"; then
      if [ "$generated_new_ca" -eq 1 ]; then
        echo "A new mitmproxy CA was generated at $ca_pem, but NixOS still trusts a different CA." >&2
        echo "Copy $cert_pem to modules/programs/misc/mitmproxy/mitmproxy-ca-cert.pem and rebuild." >&2
      else
        echo "The local mitmproxy CA at $ca_pem does not match the CA trusted by NixOS." >&2
        echo "Restore the original CA or update modules/programs/misc/mitmproxy/mitmproxy-ca-cert.pem and rebuild." >&2
      fi
      exit 1
    fi

    cat '${config.security.pki.caBundle}' "$cert_pem" > "$bundle_pem"
    chmod 644 "$bundle_pem"
  '';

  mitmproxyStart = pkgs.writeShellScriptBin "mitmproxy-start" ''
    set -eu

    ${mitmproxyHomeInit}

    echo "Proxy:    http://127.0.0.1:8080"
    echo "Web UI:   http://127.0.0.1:8081"
    echo "Password: ${webPassword}"
    echo "CA file:  ${certPem}"
    echo "Use:      mitmproxy-run <command...> or set the app proxy manually."
    echo "Stop:     Ctrl+C"
    echo

    exec ${mitmweb} \
      --mode regular \
      --set confdir='${stateDir}' \
      --no-web-open-browser \
      --listen-host 127.0.0.1 \
      --listen-port 8080 \
      --web-host 127.0.0.1 \
      --web-port 8081 \
      --set web_password=${webPassword}
  '';

  mitmproxyStop = pkgs.writeShellScriptBin "mitmproxy-stop" ''
    set -eu

    ${pkgs.procps}/bin/pkill -INT -f '.mitmweb-wrapped .*--listen-port 8080' >/dev/null 2>&1 || true
    ${pkgs.procps}/bin/pkill -INT -f '/bin/mitmweb .*--listen-port 8080' >/dev/null 2>&1 || true
  '';

  mitmproxyStatus = pkgs.writeShellScriptBin "mitmproxy-status" ''
    set -eu

    ${pkgs.procps}/bin/pgrep -af 'mitmweb.*--listen-port 8080' || true
    ${pkgs.iproute2}/bin/ss -ltnp '( sport = :8080 or sport = :8081 )' || true
  '';

  mitmproxyRun = pkgs.writeShellScriptBin "mitmproxy-run" ''
    set -eu

    if [ "$#" -eq 0 ]; then
      echo "Usage: mitmproxy-run <command...>" >&2
      exit 1
    fi

    ${mitmproxyHomeInit}

    export HTTP_PROXY="http://127.0.0.1:8080"
    export HTTPS_PROXY="$HTTP_PROXY"
    export ALL_PROXY="$HTTP_PROXY"
    export NO_PROXY="127.0.0.1,localhost"

    export http_proxy="$HTTP_PROXY"
    export https_proxy="$HTTPS_PROXY"
    export all_proxy="$ALL_PROXY"
    export no_proxy="$NO_PROXY"

    export SSL_CERT_FILE='${bundlePem}'
    export CURL_CA_BUNDLE="$SSL_CERT_FILE"
    export GIT_SSL_CAINFO="$SSL_CERT_FILE"
    export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
    export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"
    export NIX_SSL_CERT_FILE="$SSL_CERT_FILE"

    exec "$@"
  '';
in
{
  security.pki.certificateFiles = lib.optional (builtins.elem pkgs.mitmproxy config.environment.systemPackages) trustedCert;

  environment.systemPackages = [
    pkgs.mitmproxy
    mitmproxyStart
    mitmproxyStop
    mitmproxyStatus
    mitmproxyRun
  ];
}
