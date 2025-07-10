terraform {
    required_providers {
        twc = {
            source = "tf.timeweb.cloud/timeweb-cloud/timeweb-cloud"
        }
    }
    required_version = ">= 1.12.2"
}


provider "twc" {
    token = var.twc_token
}

data "twc_configurator" "configurator" {
    location = "ru-1"
    disk_type = "nvme"
}

data "twc_os" "os" {
    name = "ubuntu"
    version = "22.04"
}
resource "twc_server" "server_prometheus" {
    name = "example_prometheus"
    os_id = data.twc_os.os.id

    configuration {
        configurator_id = data.twc_configurator.configurator.id
        disk = 1024 * 15
        cpu = 1
        ram = 1024
    }
}

resource "twc_server_ip" "prometheus_ipv4" {
    source_server_id = twc_server.server_prometheus.id
    type = "ipv4"
}


