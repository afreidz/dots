local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local beautiful = require('beautiful');
local config = require('helpers.config');
local rounded = require('helpers.rounded');
local appname = require('helpers.nappname');
local xrdb = beautiful.xresources.get_current_theme();

function show_empty()
  local empty = wibox.container.place()
  empty.forced_width = config.hub.w - config.hub.nw - (config.global.m*4);
  empty.forced_height = config.hub.h - (config.global.m*3) - config.hub.i;
  empty.valign = "center";
  empty.halign = "center";
  empty.widget = wibox.widget.textbox('you have no notifications!')
  return empty;
end

return function()
  local view = wibox.container.margin();
  view.left = config.global.m;
  view.right = config.global.m;

  local title = wibox.widget.textbox("Notifications");
  title.font = config.fonts.tlb;
  title.forced_height = config.hub.i + config.global.m + config.global.m;

  local close = wibox.widget.textbox(config.icons.close);
  close.font = config.fonts.il;
  close.forced_height = config.hub.i;
  close:buttons(gears.table.join(
    awful.button({}, 1, function() if root.elements.hub then root.elements.hub.close() end end)
  ));

  local clear = wibox.widget.textbox(config.icons.clear);
  clear.font = config.fonts.il;
  clear.forced_height = config.hub.i;
  clear:buttons(gears.table.join(
    awful.button({}, 1, function() naughty.destroy_all_notifications() end)
  ));

  local notifications = naughty.list.notifications {
    base_layout = wibox.widget {
      layout = wibox.layout.fixed.vertical,
      spacing = config.global.m,
    },
    widget_template = {
      layout = wibox.container.background,
      bg = config.colors.f,
      shape = rounded(),
      {
        layout = wibox.container.margin,
        margins = config.global.m,
        {
          layout = wibox.layout.align.horizontal,
          {
            layout = wibox.container.margin,
            right = config.global.m,
            naughty.widget.icon,
          },
          {
            layout = wibox.layout.fixed.vertical,
            { layout = wibox.container.margin, bottom = config.global.m/2, naughty.widget.title },
            { layout = wibox.container.margin, bottom = config.global.m/2, naughty.widget.message },
            { layout = wibox.container.place, halign = 'right', appname },
          },
          nil
        }
      }
    }
  };

  view:setup {
    layout = wibox.container.background,
    fg = config.colors.xf,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.layout.align.horizontal,
        clear,
        {
          layout = wibox.container.place,
          title
        },
        close
      },
      {
        layout = wibox.layout.flex.horizontal,
        notifications,
      }
    }
  }

  return view;
end