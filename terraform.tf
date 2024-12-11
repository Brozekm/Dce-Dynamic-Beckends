terraform {
  required_providers {
    opennebula = {
      source = "OpenNebula/opennebula"
      version = "~> 1.2"
    }
  }
}

provider "opennebula" {
  endpoint      = "${var.opennebula_endpoint}"
  username      = "${var.opennebula_username}"
  password      = "${var.opennebula_password}"
}

#resource "opennebula_image" "os-image" {
#    name = "Ubuntu Minimal 24.04"
#    datastore_id = 101
#    persistent = false
#    path = "https://marketplace.opennebula.io//appliance/44077b30-f431-013c-b66a-7875a4a4f528/download/0"
#    permissions = "600"
#}

resource "opennebula_virtual_machine" "backends" {
  count = var.cluster_size
  name = "vmnode-${count.index + 1}"
  description = "Main node VM"
  cpu = 1
  vcpu = 1
  memory = 1024
  permissions = "600"
  group = "users"

  context = {
    NETWORK  = "YES"
    HOSTNAME = "$NAME"
    SSH_PUBLIC_KEY = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAZTwQn95haUFRe6z8hnEoERItMmck5SRotBfVOSaBK9knks0ijIEjyux4+/MhjY+dsfJx2v3x8FhnDQDuy2fl2nQFM3u4z0lBcWy+vuB7njuzUQutuwzSNSZsP08lu2//L5cIgr6jIY03rhXpkcnQoCk8wT2JNvW3nYiv1RG4GkjgfUQ== root@9a3a50d9fdc6"
  }
  
  os {
    arch = "x86_64"
    boot = "disk0"
  }

  disk {
    image_id = 686
    target   = "vda"
    size     = 10000 # 12GB
  }

  graphics {
    listen = "0.0.0.0"
    type   = "vnc"
  }

  nic {
    network_id = 3
  }

  connection {
    type = "ssh"
    user = "root"
    host = "${self.ip}"
    private_key = "${file("/var/iac-dev-container-data/id_ecdsa")}"
  }

}

resource "opennebula_virtual_machine" "lbs" {
  count = 1
  name = "vmnode-lb-1"
  description = "Main Load Balancer VM"
  cpu = 1
  vcpu = 1
  memory = 1024
  permissions = "600"
  group = "users"

  context = {
    NETWORK  = "YES"
    HOSTNAME = "$NAME"
    SSH_PUBLIC_KEY = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAZTwQn95haUFRe6z8hnEoERItMmck5SRotBfVOSaBK9knks0ijIEjyux4+/MhjY+dsfJx2v3x8FhnDQDuy2fl2nQFM3u4z0lBcWy+vuB7njuzUQutuwzSNSZsP08lu2//L5cIgr6jIY03rhXpkcnQoCk8wT2JNvW3nYiv1RG4GkjgfUQ== root@9a3a50d9fdc6"
  }
  
  os {
    arch = "x86_64"
    boot = "disk0"
  }

  disk {
    image_id = 686
    target   = "vda"
    size     = 10000 # 12GB
  }

  graphics {
    listen = "0.0.0.0"
    type   = "vnc"
  }

  nic {
    network_id = 3
  }

  connection {
    type = "ssh"
    user = "root"
    host = "${self.ip}"
    private_key = "${file("/var/iac-dev-container-data/id_ecdsa")}"
  }

}

resource "local_file" "hosts_cfg" {
  content = templatefile("inventory.tmpl",
    {
      be_ips = opennebula_virtual_machine.backends.*.ip,
      lb_ips = opennebula_virtual_machine.lbs.*.ip
    })
  filename = "./dynamic_inventories/inventory"
}
#----------Outputs----------

output "backend_ips"{
  description = "The IP addesses of the Backends"
  value = "${opennebula_virtual_machine.backends.*.ip}"
}

output "loadbalancer_ips"{
  description = "The IP addesses of the Load balancers"
  value = "${opennebula_virtual_machine.lbs.*.ip}"
}