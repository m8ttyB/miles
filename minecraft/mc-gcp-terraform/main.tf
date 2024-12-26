# Requires a project to be provided upfront
# Create a project at https://cloud.google.com/
# Make note of the project ID
# You'll need to create a storage bucket to store the terraform state as well
terraform {
  backend "gcs" {
    prefix = "minecraft/state"
    bucket = "mc_java_bucket"
  }
}

# You need to fill these locals out with the project, region and zone
# Then to boot it up, run:-
#   gcloud auth application-default login
#   terraform init
#   terraform apply
locals {
  # The Google Cloud Project ID that will host and pay for your Minecraft server
  project = "mq-minecraft-java"
  region  = "us-west1"
  zone    = "us-west1-a"
  # Allow members of an external Google group to turn on the server
  # through the Cloud Console mobile app or https://console.cloud.google.com
  # Create a group at https://groups.google.com/forum/#!creategroup
  # and invite members by their email address.
  # enable_switch_access_group = 1
  # minecraft_switch_access_group = "groups.google.com/g/mq-minecraft-friends"
}


provider "google" {
  project = local.project
  region  = local.region
}

# Create service account to run service with no permissions
resource "google_service_account" "minecraft" {
  account_id   = "minecraft"
  display_name = "minecraft"
}

# Permenant Minecraft disk, stays around when VM is off
resource "google_compute_disk" "minecraft" {
  name  = "minecraft-disk"
  # type  = "pd-standard"
  type  = "pd-ssd"
  size = 35
  zone  = local.zone
  image = "cos-cloud/cos-stable"
}

# Permenant IP address, stays around when VM is off
resource "google_compute_address" "minecraft" {
  name   = "minecraft-ip"
  region = local.region
}

# VM to run Minecraft, we use preemptable which will shutdown within 24 hours
resource "google_compute_instance" "minecraft" {
  name         = "minecraft"
  machine_type = "n1-standard-1"
  zone         = local.zone
  tags         = ["minecraft"]

  # Run itzg/minecraft-server docker image on startup
  # The instructions of https://hub.docker.com/r/itzg/minecraft-server/ are applicable
  # For instance, Ssh into the instance and you can run
  #  docker logs mc
  #  docker exec -i mc rcon-cli
  # Once in rcon-cli you can "op <player_id>" to make someone an operator (admin)
  # Use 'sudo journalctl -u google-startup-scripts.service' to retrieve the startup script output
  metadata_startup_script = "[ \\\"$(docker ps -a -q -f name=mc)\\\" ] && docker rm -f mc && docker run -e EULA=TRUE -e MEMORY=3G -d -p 25565:25565 -v /var/minecraft:/data --name mc itzg/minecraft-server:latest || docker run -e EULA=TRUE -e MEMORY=3G -d -p 25565:25565 -v /var/minecraft:/data --name mc itzg/minecraft-server:latest"

  metadata = {
    enable-oslogin = "TRUE"
  }
      
  boot_disk {
    auto_delete = false # Keep disk after shutdown (game data)
    source      = google_compute_disk.minecraft.self_link
  }

  network_interface {
    network = google_compute_network.minecraft.name
    access_config {
      nat_ip = google_compute_address.minecraft.address
    }
  }

  service_account {
    email  = google_service_account.minecraft.email
    scopes = ["userinfo-email"]
  }

  scheduling {
    preemptible       = true # Closes within 24 hours (sometimes sooner)
    automatic_restart = false
  }
}

# Create a private network so the minecraft instance cannot access
# any other resources.
resource "google_compute_network" "minecraft" {
  name = "minecraft"
}

# Open the firewall for Minecraft traffic
resource "google_compute_firewall" "minecraft" {
  name    = "minecraft"
  network = google_compute_network.minecraft.name
  # Minecraft client port
  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }
  # ICMP (ping)
  allow {
    protocol = "icmp"
  }
  # SSH (for RCON-CLI access)
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft"]
}