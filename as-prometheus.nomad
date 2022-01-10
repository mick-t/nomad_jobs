job "prometheus" {
  datacenters = ["West"]

  group "prometheus" {
    count = 1

    network {
      port "prometheus_ui" {
        static = 9090
        to     = 9090
      }
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v2.25.0"

        args = [
          "--config.file=/etc/prometheus/config/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
        ]

        volumes = [
          "local/config:/etc/prometheus/config",
        ]
        ports = ["prometheus_ui"]
      } # end config

      template {
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/prometheus.yml"
        data = <<EOH
---
global:
  scrape_interval:     1s
  evaluation_interval: 1s

scrape_configs:
  - job_name: nomad
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
    static_configs:
    - targets: ['{{ env "attr.unique.network.ip-address" }}:4646']

  - job_name: consul
    metrics_path: /v1/agent/metrics
    params:
      format: ['prometheus']
    static_configs:
    - targets: ['{{ env "attr.unique.network.ip-address" }}:8500']
  - job_name: prometheus
    honor_timestamps: true
    scrape_interval: 1s
    scrape_timeout: 1s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['{{ env "attr.unique.network.ip-address" }}:9090']
EOH

      } # end template

      resources {
        cpu    = 100
        memory = 256
      } # end resources

      service {
        name = "prometheus"
        port = "prometheus_ui"
        check {
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      } # end service
    } # end task
  } # end group
} # end job
