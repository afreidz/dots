local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();
local screens = {}
local mon_size = {
  w = nil,
  h = nil,
};

function make_mon(wall, id)
  local monitor = wibox.widget {
    widget = wibox.widget.imagebox,
    shape = rounded(),
    clip_shape = rounded(),
    resize = false,
    forced_width = mon_size.w,
    forced_height = mon_size.h,
    fg = config.colors.w,
  } 
  monitor:set_image(gears.surface.load_uncached(gears.filesystem.get_configuration_dir()..wall));
  return wibox.widget {
    layout = wibox.layout.stack,
    forced_width = mon_size.w,
    forced_height = mon_size.h,
    monitor,
    {
      layout = wibox.container.place,
      valign = "center",
      {
        layout = wibox.container.background,
        fg = config.colors.w..'66',
        {
          widget = wibox.widget.textbox,
          font = config.fonts.t..' Bold 50',
          text = id,
        }
      }
    }
  };
end

return function()
  local view = wibox.container.margin();
  view.left = config.global.m;
  view.right = config.global.m;
  view.bottom = config.global.m;

  local title = wibox.widget.textbox("Display");
  title.font = config.fonts.tlb;
  title.forced_height = config.hub.i + config.global.m + config.global.m;

  local close = wibox.widget.textbox(config.icons.close);
  close.font = config.fonts.il;
  close.forced_height = config.hub.i;
  close:buttons(gears.table.join(
    awful.button({}, 1, function() if root.hub then root.hub.close() end end)
  ));

  local monitors = wibox.container.background();
  monitors.bg = config.colors.f;
  monitors.shape = rounded();

  local layout = wibox.layout.flex.horizontal();
  layout.spacing = config.global.m;

  local changewall = wibox.container.margin();
  changewall.top = config.global.m;
  changewall.bottom = config.global.m;
  changewall:buttons(gears.table.join(
    awful.button({}, 1, function()
      if root.hub then root.hub.close() end
      awful.spawn(config.commands.setwall);
    end)
  ));

  changewall:setup {
    layout = wibox.container.background,
    bg = config.colors.x12,
    fg = config.colors.w,
    shape = rounded(),
    {
      layout = wibox.container.place,
      valign = 'center',
      forced_height = config.hub.i,
      {
        widget = wibox.widget.textbox,
        text = "change wallpaper",
        font = config.fonts.tlb,
      }
    }
  }

  monitors:setup {
    layout = wibox.container.margin,
    margins = config.global.m,
    layout
  }
  
  view:setup {
    layout = wibox.container.background,
    fg = config.colors.b,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.layout.align.horizontal,
        nil,
        {
          layout = wibox.container.place,
          title
        },
        close
      },
      {
        layout = wibox.layout.fixed.vertical,
        monitors, changewall,
      },
      nil
    }
  }

  view.refresh = function()
    screens = {};
    layout:reset();
    awful.spawn.with_line_callback(config.commands.getwall, {
      stdout = function(o) table.insert(screens,o) end,
      output_done = function()
        mon_size.w = (((config.hub.w - config.hub.nw) - (config.global.m*4))/#screens)-((config.global.m/2)*(#screens-1));
        mon_size.h = mon_size.w * (screen.primary.geometry.height/screen.primary.geometry.width);
        monitors.forced_height = mon_size.h;
        for k,v in pairs(screens) do
          layout:insert(k,wibox.widget.base.empty_widget());
          awful.spawn.easy_async_with_shell(config.commands.resize..' '..v..' '..mon_size.w..' '..mon_size.h..' '..k, function(o)
            layout:set(k, make_mon('tmp/wall_'..k..'.jpg', k));
          end);
        end
      end
    });
  end

  return view;
end