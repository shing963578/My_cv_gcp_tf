provider "google" {
  project = "mc-fqsi"
  region  = "us-central1" 
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-cv-network"
  auto_create_subnetworks = true
}

resource "google_compute_instance" "vm_instance" {
  name         = "my-cv-instance"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link

    access_config {
    }
  }

  metadata = {
    ssh-keys = "your-ssh-public-key"
    startup-script = <<-EOF
        #!/bin/bash
        sudo apt-get update
        sudo apt-get install nginx -y
        sudo apt install unzip
        sudo systemctl start nginx
        sudo systemctl enable nginx
        sudo apt-get install wget -y
        wget https://github.com/shing963578/CV/raw/main/My_cv.zip
        sudo unzip -o My_cv.zip
        sudo systemctl restart nginx
    EOF
  }

  tags = ["http-server", "https-server"]
}

resource "google_compute_address" "vm_public_ip" {
  name = "my-cv-vm-ip"
  address_type = "EXTERNAL"
}


resource "google_compute_firewall" "firewall_http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall_https" {
  name    = "allow-https"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}