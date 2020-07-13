local gears = require('gears');

return function()
  return function(c,w,h) gears.shape.rounded_rect(c,w,h,r) end
end