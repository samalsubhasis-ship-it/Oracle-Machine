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

# 3. Create the Logical Compartment
resource "oci_identity_compartment" "mumbai_compartment" {
  compartment_id = var.parent_compartment_ocid
  name           = "mumbai-compartment"
  description    = "Compartment for Mumbai resources managed via GitHub Actions"
  enable_delete  = true
}

# 4. Create the Virtual Cloud Network (VCN)
resource "oci_core_vcn" "mumbai_vcn" {
  compartment_id = oci_identity_compartment.mumbai_compartment.id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "mumbai-vcn"
  dns_label      = "mumbaivcn"
}

# 5. Create an Internet Gateway for Outbound/Inbound Access
resource "oci_core_internet_gateway" "mumbai_ig" {
  compartment_id = oci_identity_compartment.mumbai_compartment.id
  vcn_id         = oci_core_vcn.mumbai_vcn.id
  display_name   = "mumbai-internet-gateway"
  enabled        = true
}

# 6. Create a Route Table to Route Traffic Through the Internet Gateway
resource "oci_core_route_table" "mumbai_rt" {
  compartment_id = oci_identity_compartment.mumbai_compartment.id
  vcn_id         = oci_core_vcn.mumbai_vcn.id
  display_name   = "mumbai-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mumbai_ig.id
  }
}

# 7. Create a Public Subnet inside the VCN
resource "oci_core_subnet" "mumbai_public_subnet" {
  compartment_id    = oci_identity_compartment.mumbai_compartment.id
  vcn_id            = oci_core_vcn.mumbai_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "mumbai-public-subnet"
  dns_label         = "publicsubnet"
  route_table_id    = oci_core_route_table.mumbai_rt.id
  prohibit_public_ip_on_vnic = false
}
