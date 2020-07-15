local gears = require('gears');
local vars = require('helpers.vars');

return function()
  return function(c,w,h) gears.shape.rounded_rect(c,w,h,vars.global.r) end
end