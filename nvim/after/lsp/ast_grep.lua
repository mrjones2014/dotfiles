-- disable hover provider to avoid erroneous "No information available" notifications
return {
  on_init = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
