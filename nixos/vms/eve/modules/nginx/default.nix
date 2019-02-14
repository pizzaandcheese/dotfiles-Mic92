{ config, lib, ... }: 

let
  sanCertificate = domain: let
    wantedVhosts = lib.filterAttrs (_: attrs: (attrs.useACMEHost or null) == domain) 
      config.services.nginx.virtualHosts;
    serverAliases = lib.flatten (lib.mapAttrsToList (_: vhost: vhost.serverAliases) wantedVhosts);
  in {
    extraDomains = (
      lib.mapAttrs (name: _: null) wantedVhosts
    ) // (lib.foldl (domains: domain: domains // { ${domain} = null; }) {} serverAliases);
    postRun = "systemctl reload nginx.service";
    webroot = "/var/lib/acme/acme-challenge";
  };
in {
  imports = [
    ./blog.halfco.de.nix
    ./blog.nix
    ./devkid.net.nix
    ./dl.nix
    ./glowing-bear.nix
    ./halfco.de.nix
    ./homepage.nix
    ./ip.nix
    ./muc.nix
    #./threema.nix
  ];

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    appendHttpConfig = ''
      # TODO check later if this is required for ssl_stapling
      #ssl_trusted_certificate ${./isrgrootx1.pem.txt}
      add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
      add_header X-Frame-Options SAMEORIGIN;
      add_header X-Content-Type-Options nosniff;
    '';

    # owncloud etc
    clientMaxBodySize = "4G";

    resolver.addresses = ["172.23.75.6"];

    sslDhparam = config.security.dhparams.params.nginx.path;

    virtualHosts."_" = {
      locations."/stub_status".extraConfig = ''
        stub_status;
        # Security: Only allow access from the IP below.
        allow 127.0.0.1;
        # Deny anyone else
        deny all;
      '';
    };
  };

  security.dhparams = {
    enable = true;
    params.nginx = {};
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  #security.acme.production = false;
  security.acme.certs = {
    "thalheim.io" = sanCertificate "thalheim.io";
    "devkid.net" = sanCertificate "devkid.net";
    "halfco.de" = sanCertificate "halfco.de";
    "higgsboson.tk" = sanCertificate "higgsboson.tk";
  };

  environment.etc."netdata/python.d/web_log.conf".text = ''
    nginx_log3:
      name: 'nginx'
      path: '/var/spool/nginx/logs/access.log'
  '';

  users.users.netdata.extraGroups = [ "nginx" ];
}
