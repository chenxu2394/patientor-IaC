resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "time_sleep" "wait_for_rg" {
  depends_on      = [azurerm_resource_group.rg]
  create_duration = "20s"
}

resource "azurerm_service_plan" "plan" {
  name                = "${var.app_name}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
  depends_on          = [time_sleep.wait_for_rg]
}

resource "time_sleep" "wait_for_plan" {
  depends_on      = [azurerm_service_plan.plan]
  create_duration = "45s"
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  depends_on = [time_sleep.wait_for_plan]

  https_only              = true
  client_affinity_enabled = false

  site_config {
    http2_enabled = true
    ftps_state    = "Disabled"
    always_on     = false

    application_stack {
      docker_image_name = var.image_reference
    }
  }

  app_settings = {
    WEBSITES_PORT                      = "3001"
    PORT                                = "3001"
    NODE_ENV                            = "production"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }

  tags = {
    app     = "patientor"
    env     = "prod"
    managed = "terraform"
  }
}