local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local vars = require('helpers.vars');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

return function()
  local view = wibox.container.margin();
  view.left = vars.global.m;
  view.right = vars.global.m;

  local title = wibox.widget.textbox("Calendar");
  title.font = vars.fonts.tlb;
  title.forced_height = vars.hub.i + vars.global.m + vars.global.m;

  local cal_container = wibox.container.background();
  cal_container.bg = vars.global.f2;
  cal_container.shape = rounded();
  cal_container.forced_width = vars.hub.w - vars.hub.nw - (vars.global.m*4);
  cal_container.forced_height = vars.hub.w - vars.hub.nw - (vars.global.m*4);

  cal_container:setup {
    layout = wibox.container.margin,
    left = vars.global.m, right = 40,
    {
      date = os.date('*t'),
      font = vars.fonts.tml,
      widget = wibox.widget.calendar.month,
    }
  }

  view:setup {
    layout = wibox.container.background,
    fg = vars.global.b,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.container.place,
        title,
      },
      {
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        cal_container,
      }
    }
  }

  return view;
end