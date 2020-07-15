local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local vars = require('helpers.vars');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();
local views = {};

function close_views()
  gears.table.map(function(v)
    v.view.visible = false;
    v.title.font = vars.hub.nf;
  end, views);
end

function enable_view_by_index(i)
  if views[i] then 
    close_views();
    views[i].view.visible = true;
    views[i].title.font = vars.hub.nfb;
  end
end 

function make_view(i, t, v, a)
  local button = wibox.container.background();
  button.forced_height = vars.global.m + vars.hub.i + vars.global.m;

  local icon = wibox.widget.textbox(i);
  icon.forced_height = vars.hub.i;
  icon.forced_width = vars.hub.i;
  icon.align = "center";
  icon.font = vars.hub.fi;

  local title = wibox.widget.textbox(t);
  if a == nil then title.font = vars.hub.nf else title.font = vars.hub.nfb end;

  local view = wibox.container.margin();
  view.margins = vars.global.m;
  if a == nil then view.visible = false else view.visible = true end;

  if(v == nil) then
    view:setup {
      layout = wibox.container.place,
      valign = "center",
      halign = "center",
      {
        layout = wibox.container.background,
        fg = vars.global.b,
        wibox.widget.textbox(t),
      }
    }
  else
    view = v;
  end

  button:connect_signal("mouse::enter", function() button.bg = vars.global.f2 end);
  button:connect_signal("mouse::leave", function() button.bg = vars.global.t end);
  button:buttons(gears.table.join(
    awful.button({ }, 1, function()
      close_views();
      view.visible = true;
      title.font = vars.hub.nfb;
    end)
  ));
  button:setup {
    layout = wibox.container.margin,
    margins = vars.global.m,
    {
      layout = wibox.layout.align.horizontal,
      icon,
      {
        layout = wibox.container.margin,
        left = vars.global.m,
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
    to = { vars.hub.nw, vars.hub.h },
    stops = { { 0, xrdb.color4 }, { 1, xrdb.color12 } }
  });

  local powerbg = gears.color({
    type = 'linear',
    from = { 0, 0 },
    to = { vars.hub.nw, vars.hub.i },
    stops = { { 0, xrdb.color5 }, { 1, xrdb.color13 } }
  });

  local nav = wibox.container.background();
  nav.bg = navbg;
  nav.forced_width = vars.hub.nw;

  local user = wibox.widget.textbox("");
  user.font = "Poppins SemiBold 12";
  awful.spawn.easy_async_with_shell('whoami', function(u) user.text = u end);

  local avatar = wibox.widget {
    layout = wibox.container.background,
    shape = gears.shape.circle,
    shape_clip = gears.shape.circle,
    forced_width = vars.hub.i,
    forced_height = vars.hub.i,
    {
      widget = wibox.widget.imagebox,
      image = vars.global.user,
      resize = true,
    }
  }

  local rule = wibox.container.background();
  rule.forced_height = 1;
  rule.bg = vars.global.f2;
  rule.widget = wibox.widget.base.empty_widget();

  table.insert(views, make_view("󰀠", "notifications"));
  table.insert(views, make_view("󰸘", "calendar"));
  table.insert(views, make_view("󰖟", "connections"));
  table.insert(views, make_view("󰄨", "system", require('views.system')()));
  table.insert(views, make_view("󰇄", "display"));
  table.insert(views, make_view("󰝚", "media"));
  table.insert(views, make_view("󰸌", "customization"));

  local header = wibox.container.margin();
  header.margins = vars.global.m;
  header.forced_height = vars.global.m + vars.hub.i + vars.global.m;
  header:setup {
    layout = wibox.layout.align.horizontal,
    avatar,
    {
      layout = wibox.container.margin,
      left = vars.global.m,
      user
    }
  };

  local nav_container = wibox.layout.fixed.vertical();
  nav_container.forced_width = vars.hub.nw;
  nav_container.forced_height = vars.hub.h;
  nav_container:add(header);
  nav_container:add(rule);
  gears.table.map(function(v) nav_container:add(v.link) end, views);

  local power = wibox.container.background();
  power.bg = powerbg;
  power.shape = rounded();
  power.forced_height = vars.hub.i;
  power:setup {
    layout = wibox.container.place,
    halign = "center",
    halign = "center",
    {
      widget = wibox.widget.textbox,
      text = '󰐥',
      font = vars.hub.fi,
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
        margins = vars.global.m,
        power,
      }
    }
  };

  return nav;
end

return function()
  local hub = wibox({
    type = 'toolbar',
    width = vars.hub.w,
    height = vars.hub.h,
    visible = false,
    ontop = true,
    bg = vars.global.f,
    screen = awful.screen.primary,
  });

  local nav = make_nav();
  local view_container = wibox.layout.stack();
  gears.table.map(function(v) view_container:add(v.view) end, views);
  
  hub.x = 100;
  hub.y = 50;
  hub.shape = rounded()
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
  
  hub.enable_view_by_index = enable_view_by_index;
  hub.close_views = close_views;
  hub.make_view = make_view;
  hub.views = views;

  return hub;
end

