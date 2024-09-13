{...}: {
  services.prometheus.exporters.node = {
    enable = true;
    port = 9200;
    openFirewall = true;

    user = "node-exporter";
    group = "node-exporter";

    enabledCollectors = ["systemd"];
  };
}
