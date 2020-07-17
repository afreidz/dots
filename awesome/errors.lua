local naughty = require('naughty')

return function()
  naughty.connect_signal("request::display_error", function(m,s)
    naughty.notification {
      urgency = 'critical',
      title = "ERROR"..(s and " during startup" or ''),
      message = m
    }
  end);
end