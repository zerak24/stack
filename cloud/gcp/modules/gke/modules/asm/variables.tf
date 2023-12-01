/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "The project in which the resource belongs."
  type        = string
}

variable "cluster_name" {
  description = "The unique name to identify the cluster in ASM."
  type        = string
}

variable "cluster_location" {
  description = "The cluster location for this ASM installation."
  type        = string
}

variable "fleet_id" {
  description = "The fleet to use for this ASM installation."
  type        = string
  default     = ""
}

variable "channel" {
  description = "The channel to use for this ASM installation."
  type        = string
  validation {
    condition = anytrue([
      var.channel == "rapid",
      var.channel == "regular",
      var.channel == "stable",
      var.channel == "", // if unset, use GKE data source and use release cluster channel
    ])
    error_message = "Must be one of rapid, regular, or stable."
  }
  default = ""
}

variable "mesh_management" {
  default     = ""
  description = "ASM Management mode. For more information, see the [gke_hub_feature_membership resource documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/gke_hub_feature_membership#nested_mesh)"
  type        = string
  validation {
    condition = anytrue([
      var.mesh_management == null,
      var.mesh_management == "",
      var.mesh_management == "MANAGEMENT_AUTOMATIC",
      var.mesh_management == "MANAGEMENT_MANUAL",
    ])
    error_message = "Must be null, empty, or one of MANAGEMENT_AUTOMATIC or MANAGEMENT_MANUAL."
  }
}

variable "multicluster_mode" {
  description = "[Preview] Determines whether remote secrets should be autogenerated across fleet cluster."
  type        = string
  validation {
    condition = anytrue([
      var.multicluster_mode == "manual",
      var.multicluster_mode == "connected",
    ])
    error_message = "Must be one of manual or connected."
  }
  default = "manual"
}

variable "enable_cni" {
  description = "Determines whether to enable CNI for this ASM installation. Required to use Managed Data Plane (MDP)."
  type        = bool
  default     = false
}

variable "enable_vpc_sc" {
  description = "Determines whether to enable VPC-SC for this ASM installation. For more information read [VPC Service Controls for Managed Anthos Service Mesh](https://cloud.google.com/service-mesh/docs/managed/vpc-sc)"
  type        = bool
  default     = false
}

variable "enable_fleet_registration" {
  description = "Determines whether the module registers the cluster to the fleet."
  type        = bool
  default     = false
}

variable "enable_mesh_feature" {
  description = "Determines whether the module enables the mesh feature on the fleet."
  type        = bool
  default     = false
}

variable "internal_ip" {
  description = "Use internal ip for the cluster endpoint when running kubectl commands."
  type        = bool
  default     = false
}

variable "module_depends_on" {
  description = "List of modules or resources this module depends on.  If multiple, all items must be the same type."
  type        = list(any)
  default     = []
}

variable "create_system_namespace" {
  description = "Determines whether the module creates the istio-system namespace."
  type        = bool
  default     = true
}
