
resource "k3d_cluster" "k3d" {
  name    = var.cluster_name
  servers = 1
  agents  = 2
  image   = var.cluster_image

  kube_api {
    host_ip   = "0.0.0.0"
    host_port = 6443
  }

  port {
    host_port      = 443
    container_port = 443
    node_filters   = ["loadbalancer"]
  }

  port {
    host_port      = 80
    container_port = 80
    node_filters   = ["loadbalancer"]
  }

  k3d {
    disable_load_balancer = false
    disable_image_volume  = false
  }

  k3s {
    extra_args {
      arg          = "--disable=traefik"
      node_filters = ["server:0"]
    }
  }

  kubeconfig {
    update_default_kubeconfig = true
    switch_current_context    = true
  }
}

resource "helm_release" "ingress" {
  depends_on = [k3d_cluster.k3d]
  name       = "nginx"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.6.1"
  values           = [file("values/ingress-nginx.yaml")]
}

data "external" "getip" {
  program = ["bash", "${path.module}/getip.sh"]
}


resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = "!#$%&*()-_=+[]{}<>:?@"
}

data "template_file" "helm_release" {
  for_each = { for i, j in var.helm_release : i => j if fileexists("${path.module}/values/${i}.yaml") }
  template = file("${path.module}/values/${each.key}.yaml")
  vars = {
    domain   = data.external.getip.result.sslip_io
    password = random_password.password.result
    app_name = each.key
  }
}

resource "helm_release" "charts" {
  for_each = var.helm_release
  name     = each.key

  repository       = each.value.repository
  chart            = each.value.chart
  namespace        = each.value.namespace
  version          = each.value.version
  create_namespace = true

  values  = fileexists("${path.module}/values/${each.key}.yaml") ? [data.template_file.helm_release[each.key].rendered] : [for i in each.value.values : file("values/${i}")]
  timeout = 600
}