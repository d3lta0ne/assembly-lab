packer {
    required_version = ">= 1.11.2"
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
    windows-update = {
      version = ">= 0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}

variable "box" {
  type    = string
  default = ""
}

variable "iso_checksum" {
  type    = string
  default = ""
}

variable "iso_url" {
  type    = string
  default = ""
}

source "virtualbox-iso" "debug-lab" {
  boot_command            = ["<esc><wait>", "install <wait>", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ", "locale=en_US ", "keymap=us ", "hostname=kali ", "domain='' ", "<enter>"]
  cpus                    = "2"
  guest_additions_mode    = "disable"
  guest_os_type           = "Debian_64"
  http_directory          = "http"
  iso_checksum            = "sha256:${var.iso_checksum}"
  iso_url                 = "${var.iso_url}"
  memory                  = "2048"
  shutdown_command        = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password            = "vagrant"
  ssh_timeout             = "60m"
  ssh_username            = "vagrant"
  vboxmanage              = [["modifyvm", "{{ .Name }}", "--clipboard-mode", "bidirectional"], ["modifyvm", "{{ .Name }}", "--draganddrop", "bidirectional"], ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"]]
  virtualbox_version_file = ""
}

build {
  sources = ["source.qemu.autogenerated_1", "source.virtualbox-iso.autogenerated_2", "source.vmware-iso.autogenerated_3"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S bash -euxo pipefail '{{ .Path }}'"
    scripts         = ["scripts/vagrant.sh", "scripts/minimize.sh"]
  }

  post-processor "vagrant" {
    vagrantfile_template = "Vagrantfile"
  }
}