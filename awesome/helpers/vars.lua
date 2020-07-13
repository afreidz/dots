local beautiful = require('beautiful');
local xrdb = beautiful.xresources.get_current_theme();

return {
  global = {
    f = xrdb.color7.."59",
    f2 = xrdb.color7.."80",
    t = "#00000000",
    b = "#000000",
    m = 10,
    r = 7,
    o = 0.35,
  },
  topbar = {
    h = 30,
    w = 30,
  },
  tagswitcher= {
    h = 120,
  },
  volume = {
    muted = false,
    v = 0,
  }
};