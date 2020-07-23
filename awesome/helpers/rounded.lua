local gears = require('gears');
local config = require('helpers.config');

return function()
  return function(c,w,h) gears.shape.rounded_rect(c,w,h,config.global.r) end
end