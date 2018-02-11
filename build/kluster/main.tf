
"provider" "vsphere" {
         "allow_unverified_ssl" =  "${var.vsphere_unverified_ssl}",
         "password" =  "${var.vsphere_password}",
         "user" =  "${var.vsphere_domain}\\${var.vsphere_user}",
         "vsphere_server" =  "${var.vsphere_server}"
}

