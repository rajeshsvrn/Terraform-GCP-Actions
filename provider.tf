terraform {
required_providers {
google = {
source = "hashicorp/google"
version = "4.61.0"
 }
 }

}


provider "google" {
# Configuration options
project = var.project_id
region = var.region
zone = "us-central1-a"
credentials = jsondecode(var.CREDENTIALS)


}