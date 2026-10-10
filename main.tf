# 1. OCI Provider Configuration
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = "oci_api_key.pem"
  region           = var.region
}

# 2. Input Variables (Fed securely from GitHub Actions)
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "region" {}
variable "parent_compartment_ocid" {}


# 5. Create an Internet Gateway for Outbound/Inbound Access
resource "oci_core_internet_gateway" "mumbai_ig" {
  compartment_id = var.parent_compartment_ocid
  vcn_id         = "ocid1.vcn.oc1.ap-mumbai-1.amaaaaaaktktwiyaqajiwkbg22zs5szl54eowxawkaxbnzh5t7cqbho6xhrq"
  display_name   = "mumbai-internet-gateway"
  enabled        = true
}

# 6. Create a Route Table to Route Traffic Through the Internet Gateway
resource "oci_core_route_table" "mumbai_rt" {
  compartment_id = var.parent_compartment_ocid
  vcn_id         = "ocid1.vcn.oc1.ap-mumbai-1.amaaaaaaktktwiyaqajiwkbg22zs5szl54eowxawkaxbnzh5t7cqbho6xhrq"
  display_name   = "mumbai-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mumbai_ig.id
  }
}

# 7. Create a Public Subnet inside the VCN
resource "oci_core_subnet" "mumbai_public_subnet" {
  compartment_id = var.parent_compartment_ocid
  vcn_id            = "ocid1.vcn.oc1.ap-mumbai-1.amaaaaaaktktwiyaqajiwkbg22zs5szl54eowxawkaxbnzh5t7cqbho6xhrq"
  cidr_block        = "10.0.1.0/24"
  display_name      = "mumbai-public-subnet"
  dns_label         = "publicsubnet"
  route_table_id    = oci_core_route_table.mumbai_rt.id
  prohibit_public_ip_on_vnic = false
}
