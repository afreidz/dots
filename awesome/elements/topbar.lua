local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local beautiful = require('beautiful');
local config = require('helpers.config');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

root.elements = root.elements or {};

function make_launcher(s)
  local launcher = wibox({
    screen = s,
    type = 'menu',
    visible = false,
    width = config.topbar.w,
    height = config.topbar.h,
  });

  launcher:setup {
    layout = wibox.container.margin,
    forced_width = config.topbar.w,
    forced_height = config.topbar.h,
    {
      layout = wibox.container.background,
      bg = config.colors.x4,
      fg = config.colors.w,
      {
        layout = wibox.container.place,
        {
          widget = wibox.widget.textbox,
          text = config.icons.arch,
          font = config.fonts.im,
        }
      }
    }
  }

  launcher:struts({ top = config.topbar.h + config.global.m });
  launcher.x = s.workarea.x + config.global.m;
  launcher.y = config.global.m;
  launcher:buttons(gears.table.join(
    awful.button({}, 1, function() 
      awful.spawn(config.commands.rofi2);
    end)
  ));

  root.elements.launcher = root.elements.launcher or {};
  root.elements.launcher[s.index] = launcher;
end

function make_power(s)
  local power = wibox({
    screen = s,
    type = 'menu',
    visible = false,
    width = config.topbar.w,
    height = config.topbar.h,
  });

  power:setup {
    layout = wibox.container.margin,
    forced_width = config.topbar.w,
    forced_height = config.topbar.h,
    {
      layout = wibox.container.background,
      bg = config.colors.x9,
      fg = config.colors.w,
      {
        layout = wibox.container.place,
        {
          widget = wibox.widget.textbox,
          text = config.icons.power,
          font = config.fonts.im,
        }
      }
    }
  }

  power:struts({ top = config.topbar.h + config.global.m });
  power.x = (s.workarea.width - (config.topbar.w + config.global.m)) + s.workarea.x;
  power.y = config.global.m;
  power:buttons(gears.table.join(
    awful.button({}, 1, function() 
      if root.elements.powermenu.show then root.elements.powermenu.show() end
    end)
  ));

  root.elements.power = root.elements.power or {};
  root.elements.power[s.index] = power;
end

function make_date(s)
  local date = wibox({
    screen = s,
    type = "dock",
    visible = false,
    bg = config.colors.t,
    height = config.topbar.h,
    width = config.topbar.dw,
  });

  
  date:setup {
    layout = wibox.container.place,
    valign = "center",
    {
      widget = wibox.widget.textclock,
      font = config.fonts.tlb;
      refresh = 60,
      format = config.icons.date..' %a, %b %-d   <span font="'..config.fonts.tll..'">'..config.icons.time..' %-I:%M %p</span>';
    },
  };
  
  date.x = ((s.workarea.width - (config.topbar.w + (config.global.m*2))) + s.workarea.x) - config.topbar.dw;
  date.y = config.global.m;
  date:buttons(gears.table.join(awful.button({ }, 1, function()
    if not root.elements.hub then return end;
    root.elements.hub.enable_view_by_index(2, mouse.screen, "right");
  end)));

  root.elements.date = root.elements.date or {};
  root.elements.date[s.index] = date;
end

function make_icon(i)
  local icon = wibox.widget.textbox(i);
  icon.forced_width = config.topbar.w;
  icon.font = config.fonts.is;

  local container = wibox.widget {
    layout = wibox.container.background,
    bg = config.colors.t,
    fg = config.colors.w,
    icon
  };

  icon.update = function(t,c) icon.markup = '<span color="'..c..'">'..t..'</span>' end;

  return icon;
end

function make_utilities(s)
  local uw = config.global.m-4;
  for _,v in pairs(config.topbar.utilities) do if v then uw = uw + config.topbar.w end end
  if config.topbar.utilities.mem or config.topbar.utilities.pac or config.topbar.utilities.bat or config.topbar.utilities.note then uw = uw + 20 end
  
  local utilities = wibox({
    screen = s,
    width = uw,
    visible = false,
    type = "utility",
    bg = config.colors.f,
    height = config.topbar.h,
  });

  local layout = wibox.layout.fixed.horizontal();

  if config.topbar.utilities.wifi then
    root.elements.wifi_icons = root.elements.wifi_icons or {};
    root.elements.wifi_icons[s.index] = make_icon(config.icons.wifi);
    layout:add(root.elements.wifi_icons[s.index]);
  end

  if config.topbar.utilities.bt then
    root.elements.bt_icons = root.elements.bt_icons or {};
    root.elements.bt_icons[s.index] = make_icon(config.icons.bt);
    layout:add(root.elements.bt_icons[s.index]);
  end

  if config.topbar.utilities.lan then
    root.elements.lan_icons = root.elements.lan_icons or {};
    root.elements.lan_icons[s.index] = make_icon(config.icons.lan);
    layout:add(root.elements.lan_icons[s.index]);
  end

  if config.topbar.utilities.vol then
    root.elements.vol_icons = root.elements.vol_icons or {};
    root.elements.vol_icons[s.index] = make_icon(config.icons.vol_3);
    layout:add(root.elements.vol_icons[s.index]);
  end

  if config.topbar.utilities.mem or config.topbar.utilities.pac or config.topbar.utilities.bat or config.topbar.utilities.note then
    local sep = wibox.widget.textbox('|');
    sep.opacity = 0.2;
    sep.forced_width = 20;
    sep.font = config.fonts.m..' 14';
    sep.forced_height = config.topbar.h;
    layout:add(sep);;
  end

  if config.topbar.utilities.mem then
    root.elements.mem_icons = root.elements.mem_icons or {};
    root.elements.mem_icons[s.index] = make_icon(config.icons.mem);
    layout:add(root.elements.mem_icons[s.index]);
  end

  if config.topbar.utilities.pac then
    root.elements.pac_icons = root.elements.pac_icons or {};
    root.elements.pac_icons[s.index] = make_icon(config.icons.pac);
    layout:add(root.elements.pac_icons[s.index]);
  end
  
  if config.topbar.utilities.note then
    root.elements.note_icons = root.elements.note_icons or {};
    root.elements.note_icons[s.index] = make_icon(config.icons.note);
    layout:add(root.elements.note_icons[s.index]);
  end

  if config.topbar.utilities.bat then
    root.elements.bat_icons = root.elements.bat_icons or {};
    root.elements.bat_icons[s.index] = make_icon(config.icons.bat);
    layout:add(root.elements.bat_icons[s.index]);
  end
  
  utilities:struts({ top = config.topbar.h + config.global.m });
  utilities.y = config.global.m;
  utilities.x = ((s.workarea.width / 2) - (uw/2)) + s.workarea.x;

  utilities:setup {
    layout = wibox.container.margin,
    right = config.global.m,
    left = config.global.m,
    layout
  }

  root.elements.utilities = root.elements.utilities or {};
  root.elements.utilities[s.index] = utilities;
end


function make_taglist(s)
  local taglist = wibox({
    screen = s,
    visible = false,
    type = "utility",
    bg = config.colors.f,
    fg = config.colors.xf,
    width = config.topbar.w,
    height = config.topbar.h,
  });

  taglist:struts({ top = config.topbar.h + config.global.m });
  taglist.x = s.workarea.x + (config.topbar.w + (config.global.m*2));
  taglist.y = config.global.m;

  local tags = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.selected,
    widget_template = {
      layout = wibox.container.margin,
      {
        id = "text_role",
        widget = wibox.widget.textbox,
        font = config.fonts.tmb,
      }
    }
  });

  taglist:setup {
    layout = wibox.container.place,
    valign = "center",
    tags
  }

  root.elements.taglist = root.elements.taglist or {};
  root.elements.taglist[s.index] = taglist;
end


return function()
  awful.screen.connect_for_each_screen(function(screen)
    if not root.elements.utilities or not root.elements.utilities[screen.index] then make_utilities(screen) end;
    if not root.elements.launcher or not root.elements.launcher[screen.index] then make_launcher(screen) end;
    if not root.elements.taglist or not root.elements.taglist[screen.index] then make_taglist(screen) end;
    if not root.elements.power or not root.elements.power[screen.index] then make_power(screen) end;
    if not root.elements.date or not root.elements.date[screen.index] then make_date(screen) end;
  end);

  for _, i in pairs(gears.table.join(root.elements.wifi_icons, root.elements.bt_icons, root.elements.lan_icons)) do
    i:buttons(gears.table.join(awful.button({ }, 1, function()
      if not root.elements.hub then return end;
      root.elements.hub.enable_view_by_index(3, mouse.screen);
    end)));
  end

  for _, i in pairs(root.elements.vol_icons) do
    i:buttons(gears.table.join(awful.button({ }, 1, function()
      if not root.elements.hub then return end;
      root.elements.hub.enable_view_by_index(6, mouse.screen);
    end)));
  end

  for _, i in pairs(gears.table.join(root.elements.pac_icons, root.elements.mem_icons, root.elements.bat_icons)) do
    i:buttons(gears.table.join(awful.button({ }, 1, function()
      if not root.elements.hub then return end;
      root.elements.hub.enable_view_by_index(4, mouse.screen);
    end)));
  end

  for _, i in pairs(root.elements.note_icons) do
    i:buttons(gears.table.join(awful.button({ }, 1, function()
      if not root.elements.hub then return end;
      root.elements.hub.enable_view_by_index(1, mouse.screen);
    end)));
  end

  root.elements.topbar = {
    show = function()
      for i in pairs(root.elements.utilities) do root.elements.utilities[i].visible = true end;
      for i in pairs(root.elements.launcher) do root.elements.launcher[i].visible = true end;
      for i in pairs(root.elements.taglist) do root.elements.taglist[i].visible = true end;
      for i in pairs(root.elements.power) do root.elements.power[i].visible = true end;
      for i in pairs(root.elements.date) do root.elements.date[i].visible = true end;
    end,
    hide = function()
      for i in pairs(root.elements.utilities) do root.elements.utilities[i].visible = false end;
      for i in pairs(root.elements.launcher) do root.elements.launcher[i].visible = false end;
      for i in pairs(root.elements.taglist) do root.elements.taglist[i].visible = false end;
      for i in pairs(root.elements.power) do root.elements.power[i].visible = false end;
      for i in pairs(root.elements.date) do root.elements.date[i].visible = false end;
    end
  }
end
