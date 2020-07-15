local beautiful = require('beautiful');
local xrdb = beautiful.xresources.get_current_theme();

return {
  global = {
    f = xrdb.color7.."73",
    f2 = xrdb.color7.."80",
    t = "#00000000",
    b = "#000000",
    m = 10,
    r = 7,
    o = 0.35,
    user = '/home/afreidz/Pictures/andy-emoji-linicorn.png',
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
  },
  hub = {
    i = 40,
    w = 800,
    h = 600,
    nw = 260,
    fi = "MaterialDesignIconsDesktop 20",
    nf = "Poppins Light 12",
    nfb = "Poppins SemiBold 12",
    vhf = "Poppins SemiBold 12",
    vgsf = "Poppins Light 9",
    vgkf = "Poppins Semibold 10",
  }
};