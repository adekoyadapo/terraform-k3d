terraform {
  required_providers {
    k3d = {
      source  = "pvotal-tech/k3d"
      version = "0.0.7"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    client_certificate     = k3d_cluster.k3d.credentials.0.client_certificate
    host                   = k3d_cluster.k3d.credentials.0.host
    client_key             = k3d_cluster.k3d.credentials.0.client_key
    cluster_ca_certificate = k3d_cluster.k3d.credentials.0.cluster_ca_certificate
  }
}

provider "kubectl" {
  client_certificate     = k3d_cluster.k3d.credentials.0.client_certificate
  host                   = k3d_cluster.k3d.credentials.0.host
  client_key             = k3d_cluster.k3d.credentials.0.client_key
  cluster_ca_certificate = k3d_cluster.k3d.credentials.0.cluster_ca_certificate
}

provider "kubernetes" {
  client_certificate     = k3d_cluster.k3d.credentials.0.client_certificate
  host                   = k3d_cluster.k3d.credentials.0.host
  client_key             = k3d_cluster.k3d.credentials.0.client_key
  cluster_ca_certificate = k3d_cluster.k3d.credentials.0.cluster_ca_certificate
}