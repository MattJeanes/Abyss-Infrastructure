resource "helm_release" "helloworld" {
  name      = "hello-world"
  chart     = "../kubernetes/hello-world"
  namespace = "default"
  version   = "1.0.1"
  atomic    = true

  set {
    name  = "host"
    value = var.hello_world_host
  }

  provisioner "local-exec" {
    command     = "./WaitKubeCertificate.ps1 -Name 'hello-world-tls'"
    interpreter = ["pwsh", "-Command"]
    working_dir = "../scripts"
  }

  depends_on = [
    null_resource.aks_login
  ]
}
