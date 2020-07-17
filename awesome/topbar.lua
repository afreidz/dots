local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();
local vars = require('helpers.vars');

local h = vars.topbar.h;
local w = vars.topbar.w;
local r = vars.global.r;
local m = vars.global.m;
local o = vars.global.o;
local f = vars.global.f;
local t = vars.global.t;
local b = vars.global.b;

function make_launcher(s)
  local container = wibox({ 
    width = w,
    height = h,
    type = "menu",
    screen = s,
    ontop = true,
    visible = true,
    bg = t,
  });

  local icon = wibox.widget.textbox(vars.icons.arch);
  icon.font = vars.fonts.im;
  icon.valign = "center";
  icon.align = "center";

  local button = wibox.container.background();
  button.bg = xrdb.color4;
  button.fg = xrdb.foreground;
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
    ontop = true,
    visible = true,
    bg = t,
  });

  local icon = wibox.widget.textbox(vars.icons.power);
  icon.font = vars.fonts.im;
  icon.valign = "center";
  icon.align = "center";

  local button = wibox.container.background();
  button.bg = xrdb.color9;
  button.fg = xrdb.foreground;
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
  local dw = 190;
  local date = wibox({
    type = "dock",
    width = dw,
    height = h,
    screen = s,
    ontop = true,
    visible = true,
    bg = t,
  });

  local clock = wibox.widget.textclock();
  clock.font = vars.fonts.tlb;
  clock.refresh = 60;
  clock.format = vars.icons.date..' %a, %b %-d   <span font="'..vars.fonts.tll..'">'..vars.icons.time..' %-I:%M %p</span>';

  date.x = ((s.workarea.width - (w+m+m)) + s.workarea.x) - dw;
  date.y = m;

  date:setup {
    layout = wibox.container.place,
    halign = "center",
    valign = "center",
    clock,
  };

  date:buttons(gears.table.join(awful.button({ }, 1, function()
    s.hub.x = (s.workarea.width - vars.hub.w - m) + s.workarea.x;
    s.hub.visible = true;
    s.hub.enable_view_by_index(2);
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
    ontop = true,
    visible = true,
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

  local wifi = make_icon(vars.icons.wifi);
  local bt = make_icon(vars.icons.bt);
  local vol = make_icon(vars.icons.vol_1);
  local pac = make_icon(vars.icons.pac);
  local mem = make_icon(vars.icons.mem);
  local lan = make_icon(vars.icons.lan);
  local note = make_icon(vars.icons.note);

  wifi.widget:buttons(gears.table.join(awful.button({}, 1, function() s.hub.enable_view_by_index(3) end)));
  bt.widget:buttons(gears.table.join(awful.button({}, 1, function() s.hub.enable_view_by_index(3) end)));
  vol.widget:buttons(gears.table.join(awful.button({}, 1, function() s.hub.enable_view_by_index(6) end)));
  pac.widget:buttons(gears.table.join(awful.button({}, 1, function() s.hub.enable_view_by_index(4) end)));
  mem.widget:buttons(gears.table.join(awful.button({}, 1, function() s.hub.enable_view_by_index(4) end)));
  lan.widget:buttons(gears.table.join(awful.button({}, 1, function() s.hub.enable_view_by_index(3) end)));
  note.widget:buttons(gears.table.join(awful.button({}, 1, function() s.hub.enable_view_by_index(1) end)));

  awful.widget.watch(vars.commands.wifiup, 2, function(w,o,e,r,c)
    if c == 0 then wifi.icon.text = vars.icons.wifi else wifi.icon.text = vars.icons.wifix end;
  end);

  awful.widget.watch(vars.commands.btup, 2, function(w,o,e,r,c)
    if c == 0 then bt.icon.text = vars.icons.bt else bt.icon.text = vars.icons.btx end;
  end);

  awful.widget.watch(vars.commands.lanup, 2, function(w,o,e,r,c)
    if c == 0 then lan.icon.text = vars.icons.lan else lan.icon.text = vars.icons.lanx end;
  end);

  awful.widget.watch(vars.commands.ismuted, 1, function(w,o,e,r,c)
    if c == 0 then vol.icon.text = vars.icons.vol_mute else
      awful.spawn.easy_async_with_shell(vars.commands.vol, function(o)
        local v = tonumber(o);
        if v >= 75 then vol.icon.text = vars.icons.vol_3 elseif v >= 50 then vol.icon.text = vars.icons.vol_2 else vol.icon.text = vars.icons.vol_1 end;
      end);
    end
  end);

  awful.widget.watch(vars.commands.ramcmd, 5, function(w,o,e,r,c)
    local n = tonumber(o);
    if n >= 75 then mem.container.fg = xrdb.color9 elseif n >= 50 then mem.container.fg = xrdb.color11 else mem.container.fg = xrdb.color10 end;
  end);

  awful.widget.watch(vars.commands.synccmd, 60);
  awful.widget.watch(vars.commands.updatescmd, 10, function(w,o)
    local n = tonumber(o);
    if n > 0 then pac.container.fg = xrdb.color10 else pac.container.fg = xrdb.foreground end;
  end);

  awful.widget.watch('echo 1', 1, function(w,o)
    if #vars.notifications.active > 0 then note.container.fg = xrdb.color10 else note.container.fg = xrdb.foreground end;
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
    s.hub.x = ((s.workarea.width / 2) - (vars.hub.w/2)) + s.workarea.x;
    s.hub.visible = true;
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
    ontop = true,
    visible = true,
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
        font = vars.fonts.im,
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

awful.screen.connect_for_each_screen(function(screen)
  screen.date = make_date(screen);
  screen.power = make_power(screen);
  screen.tags = make_taglist(screen);
  screen.launch = make_launcher(screen);
  screen.utility = make_utility(screen);
end);
