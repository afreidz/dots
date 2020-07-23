local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();
local config = require('helpers.config');

local h = config.topbar.h;
local w = config.topbar.w;
local r = config.global.r;
local m = config.global.m;
local o = config.global.o;
local f = config.colors.f;
local t = config.colors.t;
local b = config.colors.b;

function make_launcher(s)
  local container = wibox({ 
    width = w,
    height = h,
    type = "menu",
    screen = s,
    visible = false,
    bg = t,
  });

  local icon = wibox.widget.textbox(config.icons.arch);
  icon.font = config.fonts.im;
  icon.valign = "center";
  icon.align = "center";

  local button = wibox.container.background();
  button.bg = config.colors.x4;
  button.fg = config.colors.w;
  button.widget = icon;
  --button.shape = rounded();

  container:struts({ top = h + m });
  container.x = s.workarea.x + m;
  container.y = m;
  --container.shape = rounded();
  container:setup {
    layout = wibox.container.margin,
    forced_width = w,
    forced_height = h,
    button,
  };

  return container;
end

function make_power(s)
  local container = wibox({ 
    width = w,
    height = h,
    type = "menu",
    screen = s,
    visible = false,
    bg = t,
  });

  local icon = wibox.widget.textbox(config.icons.power);
  icon.font = config.fonts.im;
  icon.valign = "center";
  icon.align = "center";

  local button = wibox.container.background();
  button.bg = config.colors.x9;
  button.fg = config.colors.w;
  button.widget = icon;
  --button.shape = rounded();

  container:struts({ top = h + m });
  container.x = (s.workarea.width - (w+m)) + s.workarea.x;
  container.y = m;
  --container.shape = rounded();
  container:setup {
    layout = wibox.container.margin,
    forced_width = w,
    forced_height = h,
    button,
  };

  return container;
end

function make_date(s)
  local dw = 200;
  local date = wibox({
    type = "dock",
    width = dw,
    height = h,
    screen = s,
    visible = false,
    bg = t,
  });

  local clock = wibox.widget.textclock();
  clock.font = config.fonts.tlb;
  clock.refresh = 60;
  clock.format = config.icons.date..' %a, %b %-d   <span font="'..config.fonts.tll..'">'..config.icons.time..' %-I:%M %p</span>';

  date.x = ((s.workarea.width - (w+m+m)) + s.workarea.x) - dw;
  date.y = m;

  date:setup {
    layout = wibox.container.place,
    halign = "center",
    valign = "center",
    clock,
  };

  date:buttons(gears.table.join(awful.button({ }, 1, function()
    root.hub.x = (s.workarea.width - config.hub.w - m) + s.workarea.x;
    root.hub.visible = true;
    root.hub.enable_view_by_index(2);
  end)));

  return date;
end

function make_utility(s)
  local uw = 240;

  local utility = wibox({
    type = "utility",
    width = uw,
    height = h,
    screen = s,
    visible = false,
    bg = t,
  });

  function make_icon(i)
    local icon = wibox.widget.textbox(i);
    icon.forced_width = w;
    icon.forced_height = h;
    icon.align = "center";
    icon.valign = "center";
    icon.font = "MaterialDesignIconsDesktop 12";

    local container = wibox.container.background();
    container:setup {
      widget = icon,
    }
    return { icon = icon, container = container, widget = container };
  end

  local wifi = make_icon(config.icons.wifi);
  local bt = make_icon(config.icons.bt);
  local vol = make_icon(config.icons.vol_1);
  local pac = make_icon(config.icons.pac);
  local mem = make_icon(config.icons.mem);
  local lan = make_icon(config.icons.lan);
  local note = make_icon(config.icons.note);

  wifi.widget:buttons(gears.table.join(awful.button({}, 1, function() root.hub.enable_view_by_index(3) end)));
  bt.widget:buttons(gears.table.join(awful.button({}, 1, function() root.hub.enable_view_by_index(3) end)));
  vol.widget:buttons(gears.table.join(awful.button({}, 1, function() root.hub.enable_view_by_index(6) end)));
  pac.widget:buttons(gears.table.join(awful.button({}, 1, function() root.hub.enable_view_by_index(4) end)));
  mem.widget:buttons(gears.table.join(awful.button({}, 1, function() root.hub.enable_view_by_index(4) end)));
  lan.widget:buttons(gears.table.join(awful.button({}, 1, function() root.hub.enable_view_by_index(3) end)));
  note.widget:buttons(gears.table.join(awful.button({}, 1, function() root.hub.enable_view_by_index(1) end)));

  awful.widget.watch(config.commands.wifiup, 2, function(w,o,e,r,c)
    if c == 0 then wifi.icon.text = config.icons.wifi else wifi.icon.text = config.icons.wifix end;
  end);

  awful.widget.watch(config.commands.btup, 2, function(w,o,e,r,c)
    if c == 0 then bt.icon.text = config.icons.bt else bt.icon.text = config.icons.btx end;
  end);

  awful.widget.watch(config.commands.lanup, 2, function(w,o,e,r,c)
    if c == 0 then lan.icon.text = config.icons.lan else lan.icon.text = config.icons.lanx end;
  end);

  awful.widget.watch(config.commands.ismuted, 1, function(w,o,e,r,c)
    if c == 0 then vol.icon.text = config.icons.vol_mute else
      awful.spawn.easy_async_with_shell(config.commands.vol, function(o,e)
        if e then return end
        local v = tonumber(o);
        if v >= 75 then vol.icon.text = config.icons.vol_3 elseif v >= 50 then vol.icon.text = config.icons.vol_2 else vol.icon.text = config.icons.vol_1 end;
      end);
    end
  end);

  awful.widget.watch(config.commands.ramcmd, 5, function(w,o,e,r,c)
    local n = tonumber(o);
    if n >= 75 then mem.container.fg = config.colors.x9 elseif n >= 50 then mem.container.fg = config.colors.x11 else mem.container.fg = config.colors.x10 end;
  end);

  awful.widget.watch(config.commands.synccmd, 60);
  awful.widget.watch(config.commands.updatescmd, 10, function(w,o)
    local n = tonumber(o);
    if n > 0 then pac.container.fg = config.colors.x10 else pac.container.fg = config.colors.w end;
  end);

  awful.widget.watch('echo 1', 1, function(w,o)
    if #config.notifications.active > 0 then note.container.fg = config.colors.x10 else note.container.fg = config.colors.w end;
  end);

  local sep = wibox.widget.textbox("|");
  sep.forced_height = h;
  sep.forced_width = 20;
  sep.align = "center";
  sep.valign = "center";
  sep.font = "Monospace 14";
  sep.opacity = 0.2;

  local container = wibox.container.background();
  container.bg = f;
  container.shape = rounded();
  container:setup {
    layout = wibox.container.margin,
    left = m,
    right = m,
    {
      widget = wibox.layout.fixed.horizontal,
      wifi.widget,bt.widget,lan.widget,vol.widget,sep,pac.widget,mem.widget,note.widget,
    }
  };

  utility:struts({ top = h + m });
  utility.y = m;
  utility.x = ((s.workarea.width / 2) - (uw/2)) + s.workarea.x;
  utility:buttons(gears.table.join(awful.button({ }, 1, function()
    root.hub.x = ((s.workarea.width / 2) - (config.hub.w/2)) + s.workarea.x;
    root.hub.visible = true;
  end)));

  utility:setup {
    layout = wibox.container.margin,
    forced_height = h,
    container,
  };

  return utility;
end

function make_taglist(s)
  local container = wibox({
    type = "utility",
    width = w,
    height = h,
    screen = s,
    visible = false,
    bg = f,
    fg = b,
  });

  container:struts({ top = h + m });
  container.x = s.workarea.x + (w+m+m);
  container.y = m;

  local taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.selected,
    widget_template = {
      layout = wibox.container.margin,
      {
        id = "text_role",
        widget = wibox.widget.textbox,
        font = config.fonts.im,
      }
    }
  });

  container:setup {
    layout = wibox.container.place,
    valign = "center",
    halign = "center",
    taglist,
  }

  return container;
end


return function()
  awful.screen.connect_for_each_screen(function(screen)
    screen.date = make_date(screen);
    screen.power = make_power(screen);
    screen.tags = make_taglist(screen);
    screen.launch = make_launcher(screen);
    screen.utility = make_utility(screen);
  end);

  return {
    show = function()
      awful.screen.connect_for_each_screen(function(s)
        s.date.visible = true;
        s.power.visible = true;
        s.tags.visible = true;
        s.launch.visible = true;
        s.utility.visible = true;
      end)
    end
  }
end
