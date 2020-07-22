local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local vars = require('helpers.vars');
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
    fg = xrdb.foreground,
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
        fg = xrdb.foreground..'66',
        {
          widget = wibox.widget.textbox,
          font = vars.fonts.t..' Bold 50',
          text = id,
        }
      }
    }
  };
end

return function()
  local view = wibox.container.margin();
  view.left = vars.global.m;
  view.right = vars.global.m;
  view.bottom = vars.global.m;

  local title = wibox.widget.textbox("Display");
  title.font = vars.fonts.tlb;
  title.forced_height = vars.hub.i + vars.global.m + vars.global.m;

  local monitors = wibox.container.background();
  monitors.bg = vars.global.f2;
  monitors.shape = rounded();

  local layout = wibox.layout.flex.horizontal();
  layout.spacing = vars.global.m;

  local changewall = wibox.container.margin();
  changewall.top = vars.global.m;
  changewall.bottom = vars.global.m;
  changewall:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn(vars.commands.setwall) end)
  ));

  changewall:setup {
    layout = wibox.container.background,
    bg = xrdb.color12,
    fg = xrdb.foreground,
    shape = rounded(),
    {
      layout = wibox.container.place,
      valign = 'center',
      forced_height = vars.hub.i,
      {
        widget = wibox.widget.textbox,
        text = "change wallpaper",
        font = vars.fonts.tlb,
      }
    }
  }

  monitors:setup {
    layout = wibox.container.margin,
    margins = vars.global.m,
    layout
  }
  
  view:setup {
    layout = wibox.container.background,
    fg = vars.global.b,
    {
      layout = wibox.layout.align.vertical,
      { layout = wibox.container.place, title },
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
    awful.spawn.with_line_callback(vars.commands.getwall, {
      stdout = function(o) table.insert(screens,o) end,
      output_done = function()
        mon_size.w = (((vars.hub.w - vars.hub.nw) - (vars.global.m*4))/#screens)-((vars.global.m/2)*(#screens-1));
        mon_size.h = mon_size.w * (screen.primary.geometry.height/screen.primary.geometry.width);
        monitors.forced_height = mon_size.h;
        for k,v in pairs(screens) do
          layout:insert(k,wibox.widget.base.empty_widget());
          awful.spawn.easy_async_with_shell(vars.commands.resize..' '..v..' '..mon_size.w..' '..mon_size.h..' '..k, function(o)
            layout:set(k, make_mon('tmp/wall_'..k..'.jpg', k));
          end);
        end
      end
    });
  end

  return view;
end