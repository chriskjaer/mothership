variable "digitalocean_token" {}
variable "cloudflare_token" {}
variable "cloudflare_email" {}
variable "cloudflare_ssh_fingerprint" {}
variable "cloudflare_domain" {}

variable "name" {
  default = "work"
}

variable "user" {
  default = "chris"
}

// Digital Ocean
// -------------
// Create the development droplet

provider "digitalocean" {
  token   = "${var.digitalocean_token}"
  version = "~> 1.0"
}

resource "digitalocean_tag" "work" {
  name = "work"
}

resource "digitalocean_droplet" "work" {
  image    = "ubuntu-18-04-x64"
  name     = "${var.name}"
  region   = "fra1"
  size     = "s-2vcpu-2gb"
  tags     = ["${digitalocean_tag.work.name}"]
  ssh_keys = ["${var.cloudflare_ssh_fingerprint}"]

  provisioner "file" {
    source      = "init.ubuntu.sh"
    destination = "/tmp/init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init.sh",
      "/tmp/init.sh ${var.user}",
    ]
  }
}

// Cloudflare
// ----------
// Create subdomain for work machine and map it to the droplets ip.
provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

resource "cloudflare_record" "work" {
  domain  = "${var.cloudflare_domain}"
  name    = "${var.name}"
  value   = "${digitalocean_droplet.work.ipv4_address}"
  type    = "A"
  proxied = false

  provisioner "local-exec" {
    // If we have ssh'ed in to this host earlier, it's probably added as a known.
    // But the host changes when we reprovision everything. This will remove any 
    // previous hosts created by this plan
    command = "sed -i'' -e '/${var.name}.${var.cloudflare_domain}/d' $HOME/.ssh/known_hosts"
  }
}
