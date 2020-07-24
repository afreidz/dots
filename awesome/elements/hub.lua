local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();
local views = {};

function close_views()
  gears.table.map(function(v)
    v.view.visible = false;
    v.title.font = config.fonts.tll;
  end, views);
end

function enable_view_by_index(i)
  if views[i] then 
    close_views();
    views[i].view.visible = true;
    views[i].title.font = config.fonts.tlb;
    if views[i].view.refresh then views[i].view.refresh() end
  end
end 

function make_view(i, t, v, a)
  local button = wibox.container.background();
  button.forced_height = config.global.m + config.hub.i + config.global.m;

  local icon = wibox.widget.textbox(i);
  icon.forced_height = config.hub.i;
  icon.forced_width = config.hub.i;
  icon.align = "center";
  icon.font = config.fonts.il;

  local title = wibox.widget.textbox(t);
  if a == nil then title.font = config.fonts.tll else title.font = config.fonts.tllb end;

  local view = wibox.container.margin();
  view.margins = config.global.m;
  if a == nil then view.visible = false else view.visible = true end;

  if(v == nil) then
    view:setup {
      layout = wibox.container.place,
      valign = "center",
      halign = "center",
      {
        layout = wibox.container.background,
        fg = config.colors.b,
        wibox.widget.textbox(t),
      }
    }
  else
    view = v;
  end

  button:connect_signal("mouse::enter", function() button.bg = config.colors.f end);
  button:connect_signal("mouse::leave", function() button.bg = config.colors.t end);
  button:buttons(gears.table.join(
    awful.button({ }, 1, function()
      close_views();
      view.visible = true;
      title.font = config.fonts.tlb;
      if view.refresh then view.refresh() end;
    end)
  ));
  button:setup {
    layout = wibox.container.margin,
    margins = config.global.m,
    {
      layout = wibox.layout.align.horizontal,
      icon,
      {
        layout = wibox.container.margin,
        left = config.global.m,
        title
      },
    }
  }

  return { link = button, view = view, title = title };
end

function make_nav()
  local navbg = gears.color({
    type = 'linear',
    from = { 0, 0 },
    to = { config.hub.nw, config.hub.h },
    stops = { { 0, config.colors.x4 }, { 1, config.colors.x12 } }
  });

  local nav = wibox.container.background();
  nav.bg = navbg;
  nav.forced_width = config.hub.nw;

  local user = wibox.widget.textbox("");
  user.font = config.fonts.tlb;
  awful.spawn.easy_async_with_shell('whoami', function(u) user.text = u:gsub("^%s*(.-)%s*$", "%1") end);

  local avatar = wibox.widget {
    layout = wibox.container.background,
    shape = gears.shape.circle,
    shape_clip = gears.shape.circle,
    forced_width = config.hub.i,
    forced_height = config.hub.i,
    {
      widget = wibox.widget.imagebox,
      image = config.global.user,
      resize = true,
    }
  }

  local rule = wibox.container.background();
  rule.forced_height = 1;
  rule.bg = config.colors.f;
  rule.widget = wibox.widget.base.empty_widget();

  table.insert(views, make_view(config.icons.note, "notifications", require('views.notifications')()));
  table.insert(views, make_view(config.icons.date, "calendar", require('views.calendar')()));
  table.insert(views, make_view(config.icons.web, "connections", require('views.connections')()));
  table.insert(views, make_view(config.icons.system, "system", require('views.system')()));
  table.insert(views, make_view(config.icons.display, "display", require('views.display')()));
  table.insert(views, make_view(config.icons.media, "media", require('views.media')()));

  local header = wibox.container.margin();
  header.margins = config.global.m;
  header.forced_height = config.global.m + config.hub.i + config.global.m;
  header:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.container.margin,
      right = config.global.m,
      avatar,
    },
    user
  };

  local nav_container = wibox.layout.fixed.vertical();
  nav_container.forced_width = config.hub.nw;
  nav_container.forced_height = config.hub.h;
  nav_container:add(header);
  nav_container:add(rule);
  gears.table.map(function(v) nav_container:add(v.link) end, views);

  local power = wibox.container.background();
  power.bg = config.colors.x1;
  power.shape = rounded();
  power.forced_height = config.hub.i;
  power:setup {
    layout = wibox.container.place,
    halign = "center",
    halign = "center",
    {
      widget = wibox.widget.textbox,
      text = '󰐥',
      font = config.fonts.il,
    }
  };

  nav:setup {
    layout = wibox.container.place,
    {
      layout = wibox.layout.align.vertical,
      wibox.widget.base.empty_widget(),
      nav_container,
      {
        layout = wibox.container.margin,
        margins = config.global.m,
        power,
      }
    }
  };

  return nav;
end

return function()
  local hub = wibox({
    type = 'toolbar',
    width = config.hub.w,
    height = config.hub.h,
    visible = false,
    ontop = true,
    bg = config.colors.f,
    screen = awful.screen.primary,
  });

  local nav = make_nav();
  local view_container = wibox.layout.stack();
  gears.table.map(function(v) view_container:add(v.view) end, views);
  
  hub.x = 100;
  hub.y = 50;
  --hub.shape = rounded()
  hub:buttons(gears.table.join(
    awful.button({ }, 3, function() hub.visible = false end)
  ));
  
  hub:setup {
    layout = wibox.layout.flex.vertical,
    {
      layout = wibox.layout.align.horizontal,
      nav,
      view_container,
    }
  };
  
  hub.close = function() hub.visible = false end;
  hub.enable_view_by_index = enable_view_by_index;
  hub.close_views = close_views;
  hub.make_view = make_view;
  hub.views = views;

  close_views();
  root.hub = hub;

  return hub;
end

