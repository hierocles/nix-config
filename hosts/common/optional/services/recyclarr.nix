{
  config,
  pkgs,
  ...
}: let
  sonarr_url = "http://127.0.0.1:${builtins.toString config.modules.traefik.services.sonarr.port}";
  radarr_url = "http://127.0.0.1:${builtins.toString config.modules.traefik.services.radarr.port}";
in {
  environment.systemPackages = with pkgs; [
    recyclarr
  ];

  users.users.recyclarr = {
    isSystemUser = true;
    home = "/var/lib/recyclarr";
    createHome = true;
    group = "recyclarr";
  };
  users.groups.recyclarr = {};

  systemd.services.recyclarr = {
    description = "Recyclarr Service";
    after = ["network.target" "sonarr.service" "radarr.service"];
    wants = ["network.target" "sonarr.service" "radarr.service"];
    serviceConfig = {
      Type = "oneshot";
      User = "recyclarr";
      Group = "recyclarr";
      ExecStart = "${pkgs.recyclarr}/bin/recyclarr sync --config /etc/recyclarr/config.yaml";
      EnvironmentFile = [
        config.sops.secrets.sonarr-api-key.path
        config.sops.secrets.radarr-api-key.path
      ];
    };
  };

  systemd.timers.recyclarr = {
    wantedBy = ["timers.target"];
    partOf = ["recyclarr.service"];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  environment.etc."recyclarr/config.yaml" = {
    user = "recyclarr";
    group = "recyclarr";
    mode = "0400";
    text = ''
      sonarr:
        sonarr_main:
          base_url: ${sonarr_url}
          api_key: !env_var SONARR_API_KEY
          replace_existing_custom_formats: true
          delete_old_custom_formats: true
          media_naming:
            series: plex-imdb
            season: default
            episodes:
              rename: true
              standard: default
              daily: default
              anime: default
          include:
            - template: sonarr-quality-definition-series
            - template: sonarr-v4-quality-profile-web-1080p
            - template: sonarr-v4-quality-profile-web-2160p
            - template: sonarr-v4-custom-formats-web-1080p
            - template: sonarr-v4-custom-formats-web-2160p

      radarr:
        radarr_main:
          base_url: ${radarr_url}
          api_key: !env_var RADARR_API_KEY
          replace_existing_custom_formats: true
          delete_old_custom_formats: true
          media_naming:
            folder: plex-imdb
            movie:
              rename: true
              standard: plex-imdb
          include:
            - template: radarr-quality-definition-sqp-uhd
            - template: radarr-quality-profile-sqp-2
            - template: radarr-custom-formats-sqp-2
          custom_formats:
            # Movie Versions
            - trash_ids:
                - 0f12c086e289cf966fa5948eac571f44 # Hybrid
                - 570bc9ebecd92723d2d21500f4be314c # Remaster
                - eca37840c13c6ef2dd0262b141a5482f # 4K Remaster
                - e0c07d59beb37348e975a930d5e50319 # Criterion Collection
                - 9d27d9d2181838f76dee150882bdc58c # Masters of Cinema
                - db9b4c4b53d312a3ca5f1378f6440fc9 # Vinegar Syndrome
                - 957d0f44b592285f26449575e8b1167e # Special Edition
              assign_scores_to:
                - name: SQP-2
            # Misc
            - trash_ids:
                - 2899d84dc9372de3408e6d8cc18e9666 # x264
              assign_scores_to:
                - name: SQP-2

            # Unwanted
            - trash_ids:
                - 839bea857ed2c0a8e084f3cbdbd65ecb # x265 (no HDR/DV)
              assign_scores_to:
                - name: SQP-2
            - trash_ids:
                - dc98083864ea246d05a42df0d05f81cc # x265 (HD)
              assign_scores_to:
                - name: SQP-2
            # Optional
            - trash_ids:
                # Uncomment the next two lines if you have a setup that supports HDR10+
                - b17886cb4158d9fea189859409975758 # HDR10+ Boost
                - 55a5b50cb416dea5a50c4955896217ab # DV HDR10+ Boost

                # Comment out the next line if you and all of your users' setups are fully DV compatible
                - 923b6abef9b17f937fab56cfcf89e1f1 # DV (WEBDL)

                # Uncomment any of the following if you want them to be added to the quality profile
                - b6832f586342ef70d9c128d40c07b872 # Bad Dual Groups
                - 90cedc1fea7ea5d11298bebd3d1d3223 # EVO (no WEBDL)
                - ae9b7c9ebde1f3bd336a8cbd1ec4c5e5 # No-RlsGroup
                - 7357cf5161efbf8c4d5d0c30b4815ee2 # Obfuscated
                - 5c44f52a8714fdd79bb4d98e2673be1f # Retags
                - f537cf427b64c38c8e36298f657e4828 # Scene
                - f700d29429c023a5734505e77daeaea7 # DV (Disk)
              assign_scores_to:
                - name: SQP-2
            # Optional SDR
            # Only ever use ONE of the following custom formats:
            # SDR - block ALL SDR releases
            # SDR (no WEBDL) - block UHD/4k Remux and Bluray encode SDR releases, but allow SDR WEB
            - trash_ids:
                - 9c38ebb7384dada637be8899efa68e6f # SDR
                # - 25c12f78430a3a23413652cbd1d48d77 # SDR (no WEBDL)
              assign_scores_to:
                - name: SQP-2
    '';
  };
}
