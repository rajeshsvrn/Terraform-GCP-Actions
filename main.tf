module "bucket" {
source = "./modules/cloud-storage"
bucket_name = var.bucket_name
location   = var.location
#credentials = var.credentials
}

module "bucket1" {
source = "./modules/cloud-storage"
bucket_name = var.bucket_name1
location   = var.location
#credentials = var.credentials
}

module "bucket2" {
source = "./modules/cloud-storage"
bucket_name = var.bucket_name2
location   = var.location
#credentials = var.credentials
}

locals {
  project_id = "terraform-learn-382907"
  repo       = "rajeshsvrn/Terraform-GCP-Actions" 
}

resource "google_iam_workload_identity_pool" "github_pool2" {
  project                   = local.project_id
  workload_identity_pool_id = "github-pool2"
  display_name              = "GitHub pool2"
  description               = "Identity pool for GitHub deployments"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = local.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool2.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider2"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}


resource "google_service_account" "github_actions" {
  project      = local.project_id
  account_id   = "github-actions"
  display_name = "Service Account used for GitHub Actions"
}

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool2.name}/attribute.repository/${local.repo}"
}

output "workload_identity_provider" {
  value = "${google_iam_workload_identity_pool.github_pool2.name}/providers/${google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id}"
}

output "service_account" {
  value = google_service_account.github_actions.email
}