variable "digitalocean_token" {}
variable "cloudflare_token" {}
variable "cloudflare_email" {}
variable "cloudflare_ssh_fingerprint" {}
variable "cloudflare_domain" {}

variable "name" {
  default = "x"
}

// Digital Ocean
// -------------
// Create the development droplet

provider "digitalocean" {
  token   = "${var.digitalocean_token}"
  version = "~> 1.0"
}

resource "digitalocean_tag" "x" {
  name = "x"
}

resource "digitalocean_droplet" "x" {
  image    = "ubuntu-18-04-x64"
  name     = "${var.name}"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  tags     = ["${digitalocean_tag.x.name}"]
  ssh_keys = ["${var.cloudflare_ssh_fingerprint}"]
}

// Cloudflare
// ----------
// Create subdomain for dev machine and map it to the droplets ip.

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

resource "cloudflare_record" "x" {
  domain  = "${var.cloudflare_domain}"
  name    = "${var.name}"
  value   = "${digitalocean_droplet.x.ipv4_address}"
  type    = "A"
  proxied = false
}
