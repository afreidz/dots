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
    layout = wibox.widget.background,
    fg = config.colors.w,
    icon
  };

  container.update = function(t) icon.text = t end;

  return container;
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

  if config.topbar.utilities.bat then
    root.elements.bat_icons = root.elements.bat_icons or {};
    root.elements.bat_icons[s.index] = make_icon(config.icons.bat);
    layout:add(root.elements.bat_icons[s.index]);
  end

  if config.topbar.utilities.note then
    root.elements.note_icons = root.elements.note_icons or {};
    root.elements.note_icons[s.index] = make_icon(config.icons.note);
    layout:add(root.elements.note_icons[s.index]);
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


-- function make_utility(s)
--   local uw = 240;

--   local utility = wibox({
--     type = "utility",
--     width = uw,
--     height = h,
--     screen = s,
--     visible = false,
--     bg = t,
--   });

--   function make_icon(i)
--     local icon = wibox.widget.textbox(i);
--     icon.forced_width = w;
--     icon.forced_height = h;
--     icon.align = "center";
--     icon.valign = "center";
--     icon.font = "MaterialDesignIconsDesktop 12";

--     local container = wibox.container.background();
--     container:setup {
--       widget = icon,
--     }
--     return { icon = icon, container = container, widget = container };
--   end

--   local wifi = make_icon(config.icons.wifi);
--   local vol = make_icon(config.icons.bt);
--   local vol = make_icon(config.icons.vol_1);
--   local pac = make_icon(config.icons.pac);
--   local mem = make_icon(config.icons.mem);
--   local lan = make_icon(config.icons.lan);
--   local note = make_icon(config.icons.note);

--   wifi.widget:buttons(gears.table.join(awful.button({}, 1, function() root.elements.hub.enable_view_by_index(3) end)));
--   bt.widget:buttons(gears.table.join(awful.button({}, 1, function() root.elements.hub.enable_view_by_index(3) end)));
--   vol.widget:buttons(gears.table.join(awful.button({}, 1, function() root.elements.hub.enable_view_by_index(6) end)));
--   pac.widget:buttons(gears.table.join(awful.button({}, 1, function() root.elements.hub.enable_view_by_index(4) end)));
--   mem.widget:buttons(gears.table.join(awful.button({}, 1, function() root.elements.hub.enable_view_by_index(4) end)));
--   lan.widget:buttons(gears.table.join(awful.button({}, 1, function() root.elements.hub.enable_view_by_index(3) end)));
--   note.widget:buttons(gears.table.join(awful.button({}, 1, function() root.elements.hub.enable_view_by_index(1) end)));

--   awful.widget.watch(config.commands.wifiup, 2, function(w,o,e,r,c)
--     if c == 0 then wifi.icon.text = config.icons.wifi else wifi.icon.text = config.icons.wifix end;
--   end);

--   awful.widget.watch(config.commands.btup, 2, function(w,o,e,r,c)
--     if c == 0 then bt.icon.text = config.icons.bt else bt.icon.text = config.icons.btx end;
--   end);

--   awful.widget.watch(config.commands.lanup, 2, function(w,o,e,r,c)
--     if c == 0 then lan.icon.text = config.icons.lan else lan.icon.text = config.icons.lanx end;
--   end);

--   awful.widget.watch(config.commands.ismuted, 1, function(w,o,e,r,c)
--     if c == 0 then vol.icon.text = config.icons.vol_mute else
--       awful.spawn.easy_async_with_shell(config.commands.vol, function(o,e)
--         if e ~= '' then return end
--         local v = tonumber(o);
--         if v >= 75 then vol.icon.text = config.icons.vol_3 elseif v >= 50 then vol.icon.text = config.icons.vol_2 else vol.icon.text = config.icons.vol_1 end;
--       end);
--     end
--   end);

--   awful.widget.watch(config.commands.ramcmd, 5, function(w,o,e,r,c)
--     local n = tonumber(o);
--     if n >= 75 then mem.container.fg = config.colors.x9 elseif n >= 50 then mem.container.fg = config.colors.x11 else mem.container.fg = config.colors.x10 end;
--   end);

--   awful.widget.watch(config.commands.synccmd, 60);
--   awful.widget.watch(config.commands.updatescmd, 10, function(w,o)
--     local n = tonumber(o);
--     if n > 0 then pac.container.fg = config.colors.x10 else pac.container.fg = config.colors.w end;
--   end);

--   awful.widget.watch('echo 1', 1, function(w,o)
--     if #config.notifications.active > 0 then note.container.fg = config.colors.x10 else note.container.fg = config.colors.w end;
--   end);

--   local sep = wibox.widget.textbox("|");
--   sep.forced_height = h;
--   sep.forced_width = 20;
--   sep.align = "center";
--   sep.valign = "center";
--   sep.font = "Monospace 14";
--   sep.opacity = 0.2;

--   local container = wibox.container.background();
--   container.bg = f;
--   container.shape = rounded();
--   container:setup {
--     layout = wibox.container.margin,
--     left = m,
--     right = m,
--     {
--       widget = wibox.layout.fixed.horizontal,
--       wifi.widget,bt.widget,lan.widget,vol.widget,sep,pac.widget,mem.widget,note.widget,
--     }
--   };

--   utility:struts({ top = h + m });
--   utility.y = m;
--   utility.x = ((s.workarea.width / 2) - (uw/2)) + s.workarea.x;
--   utility:buttons(gears.table.join(awful.button({ }, 1, function()
--     root.elements.hub.x = ((s.workarea.width / 2) - (config.hub.w/2)) + s.workarea.x;
--     root.elements.hub.visible = true;
--   end)));

--   utility:setup {
--     layout = wibox.container.margin,
--     forced_height = h,
--     container,
--   };

--   return utility;
-- end

function make_taglist(s)
  local taglist = wibox({
    screen = s,
    visible = false,
    type = "utility",
    bg = config.colors.f,
    fg = config.colors.b,
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
        font = config.fonts.im,
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
