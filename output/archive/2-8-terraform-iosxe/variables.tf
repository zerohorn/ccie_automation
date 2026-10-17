variable "username" {
    description = "Username for target device"
    sensitive = true
    type = string
}

variable "password" {
    description = "UPassword for target device"
    sensitive = true
    type = string
}

variable "host" {
    description = "IP Address or FQDN for target device"
    type = string
}

variable "vlans" {
    description = "List of VLANs to add to device"
    type = map(object({
        id = number
        name = string
        shutdown = bool
    }
    ))
}