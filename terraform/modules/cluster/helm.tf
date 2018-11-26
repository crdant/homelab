variable "tiller_service_account" {
  type = "string"
  default = "tiller"
}

data "template_file" "tiller_rbac" {
  template = "${file("${var.template_dir}/cluster/tiller.yml")}"
  vars {
    tiller_service_account = "${var.tiller_service_account}"
  }
}

resource "local_file" "tiller_rbac" {
  content  = "${data.template_file.tiller_rbac.rendered}"
  filename = "${var.work_dir}/cluster/${var.cluster}/tiller.yml"

  provisioner "local-exec" {
    command = <<COMMAND
kubectl config use-context ${var.cluster}
kubectl create -f ${self.filename}
COMMAND
  }
}

resource "null_resource" "tiller_install" {
  provisioner "local-exec" {
    command = <<COMMAND
helm init --service-account ${var.tiller_service_account}
COMMAND
  }

  provisioner "local-exec" {
    command = "sleep 20"
  }

  depends_on = [ "local_file.tiller_rbac" ]
}
