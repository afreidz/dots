local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local beautiful = require('beautiful');
local xrdb = beautiful.xresources.get_current_theme();
local vars = require('helpers.vars');

local h = vars.topbar.h;
local w = vars.topbar.w;
local r = vars.global.r;
local m = vars.global.m;
local o = vars.global.o;
local v = vars.volume.v;
local f = vars.global.f;
local t = vars.global.t;
local b = vars.global.b;
local muted = vars.volume.muted;

local wifi_widgets = {};
local pac_widgets = {};
local mem_widgets = {};
local vol_widgets = {};

function rounded()
  return function(c,w,h) gears.shape.rounded_rect(c,w,h,r) end
end

function frost()
  local container = wibox.container.background();
  container.bg = f;
  container.shape = rounded();
  return container;
end

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

  local icon = wibox.widget.textbox("󰣇");
  icon.font = "MaterialDesignIconsDesktop 14";
  icon.valign = "center";
  icon.align = "center";

  local button = wibox.container.background();
  button.bg = xrdb.color4;
  button.fg = xrdb.foreground;
  button.widget = icon;
  button.shape = rounded();

  container:struts({ top = h + m });
  container.x = s.workarea.x + m;
  container.y = m;
  container.shape = rounded();
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

  local icon = wibox.widget.textbox("󰐥");
  icon.font = "MaterialDesignIconsDesktop 14";
  icon.valign = "center";
  icon.align = "center";

  local button = wibox.container.background();
  button.bg = xrdb.color9;
  button.fg = xrdb.foreground;
  button.widget = icon;
  button.shape = rounded();

  container:struts({ top = h + m });
  container.x = (s.workarea.width - (w+m)) + s.workarea.x;
  container.y = m;
  container.shape = rounded();
  container:setup {
    layout = wibox.container.margin,
    forced_width = w,
    forced_height = h,
    button,
  };

  return container;
end

function make_date(s)
  local dw = 130;
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
  clock.font = "Poppins SemiBold 9";
  clock.refresh = 60;
  clock.format = '%a, %b %-d   <span font="Poppins Medium 9">%-I:%M %p</span>';

  date.x = ((s.workarea.width - (w+m+m)) + s.workarea.x) - dw;
  date.y = m;

  date:setup {
    layout = wibox.container.place,
    halign = "center",
    valign = "center",
    clock,
  };

  return date;
end

function make_utility(s)
  local uw = 190;

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
    return { text = icon, container = container, widget = container };
  end

  local wifi = make_icon("󰖩");
  local bt = make_icon("󰂯");
  local vol = make_icon("󰕾");
  local pac = make_icon("󰏗");
  local mem = make_icon("󰍛");
  --local bat = make_icon("󰁽");

  table.insert(wifi_widgets, { icon = wifi.text });
  table.insert(pac_widgets, { icon = pac.widget });
  table.insert(mem_widgets, { icon = mem.widget });
  table.insert(vol_widgets, { icon = vol.text });

  local sep = wibox.widget.textbox("|");
  sep.forced_height = h;
  sep.forced_width = 20;
  sep.align = "center";
  sep.valign = "center";
  sep.font = "Poppins 14";
  sep.opacity = 0.2;

  local container = frost();
  container:setup {
    layout = wibox.container.margin,
    left = m,
    right = m,
    {
      widget = wibox.layout.fixed.horizontal,
      wifi.widget,bt.widget,vol.widget,sep,pac.widget,mem.widget,
    }
  };

  utility:struts({ top = h + m });
  utility.y = m;
  utility.x = ((s.workarea.width / 2) - (uw/2)) + s.workarea.x;
  utility:buttons(gears.table.join(
    awful.button({ }, 1, function() s.hub.visible = not s.hub.visible end)
  ));

  utility:setup {
    layout = wibox.container.margin,
    forced_height = h,
    container,
  };

  return utility;
end

function increase_volume(vol)
  if(muted) then return end;
  v=v+2;
  local cmd = 'pamixer -i 2';
  awful.spawn.with_shell(cmd);
  vol:set_value(v);
end

function decrease_volume(vol)
  if(muted) then return end;
  v=v-2;
  local cmd = 'pamixer -d 2';
  awful.spawn.with_shell(cmd);
  vol:set_value(v);
end

function launch_volume_app(hub)
  hub.visible = false;
  return awful.spawn("pavucontrol");
end

function launch_stat_app(hub)
  hub.visible = false;
  return awful.spawn("gnome-system-monitor");
end

function launch_wifi_app(hub)
  hub.visible = false;
  return awful.spawn("nm-connection-editor");
end

function make_progress_bar(title,initial)
  local bw = 60;
  local bh = 150;
  local bb = '#00000033';

  local title = wibox.widget.textbox(title);
  title.font = "Poppins SemiBold 9";
  title.valign = "center";
  title.align = "center";
  title.forced_height = h;

  local progress = wibox.widget.progressbar();
  progress.max_value = 100;
  progress.background_color = bb;
  progress.color = xrdb.foreground;
  progress.value = initial;
  progress.shape = rounded();

  local bar = wibox.widget {
    layout = wibox.container.rotate,
    direction = "east",
    forced_width = bw,
    forced_height = bh,
    progress,
  }

  return { bar = bar, title = title, p = progress };
end

function watch_wifi(widgets)
  local wi = '󰖪';
  local wt = 'wifi off';
  local cmd = 'bash -c "nmcli dev wifi list | awk \'/\\*/{if (NR!=1) {print $3}}\'"';
  awful.widget.watch(cmd, 3, function(w,o)
    if(o ~= '') then wi = '󰖩' else wi = '󰖪' end;
    if(o ~= '') then wt = o else wt = 'wifi off' end;
    for k,w in pairs(widgets) do
      if(w.icon) then w.icon.text = wi end;
      if(w.title) then w.title.text = wt end;
    end
  end);
end

function watch_mem(widgets)
  local i = '󰍛';
  local r = '#F90239';
  local y = '#FDC400';
  local g = '#7DF26F';
  local c = g;
  local cmd = 'bash -c "free | grep Mem | awk \'{print $3/$2 * 100.0}\'"';

  awful.widget.watch(cmd, 2, function(w,o)
    if(tonumber(o) < 50 ) then
      c = g;
    elseif (tonumber(o) < 75) then 
      c = y;
    else
      c = r;
    end
    for k,w in pairs(widgets) do
      if(w.p) then w.p:set_value(tonumber(o)); w.p.color = c; end;
      if(w.icon) then w.icon.fg = c end;
    end
  end);
end

function watch_pac(widgets)
  local pc = xrdb.foreground;
  local pt = 'no updates';
  local sync_cmd = 'bash -c "yay -Syy"';
  local cmd = 'bash -c "yay -Sup | wc -l"';
  awful.widget.watch(sync_cmd, 60);
  awful.widget.watch(cmd, 10, function(w,o)
    if(o ~= '') then pc = '#7DF26F' else pc = xrdb.foreground end;
    if(o ~= '') then pt = (o:gsub("^%s*(.-)%s*$", "%1")..' updates') else pt = 'no updates' end;
    for k,w in pairs(widgets) do
      if(w.title) then w.title.text = pt end;
      if(w.icon) then w.icon.fg = pc end;
    end
  end);
end

function watch_vol(widgets)
  local v1 = '󰕿';
  local v2 = '󰖀';
  local v3 = '󰕾';
  local vm = '󰝟';
  local i = v3;
  local is_muted_cmd = 'bash -c "pamixer --get-mute"';
  local vol_cmd = 'bash -c "pamixer --get-volume"';

  awful.widget.watch(is_muted_cmd, 1, function(w,o)
    if(tostring(o):gsub("^%s*(.-)%s*$", "%1") == 'true') then muted = true else muted = false end;
  end);

  awful.widget.watch(vol_cmd, 2, function(w,o)
    if(muted) then
      for k,w in pairs(widgets) do
        if(w.p) then w.p:set_value(0) end;
        if(w.icon) then w.icon.text = vm end;
        if(w.title) then w.title.text = "Mute" end;
      end
    else
      for k,w in pairs(widgets) do
        v = tonumber(o);
        if(w.p) then w.p:set_value(v) end;
        if(w.icon) then
          if(v < 50) then 
            i = v1;
          elseif(v < 75) then
            i = v2;
          else
            i = v3;
          end
          w.icon.text = i; 
        end
        if(w.title) then w.title.text = "Volume" end;
      end  
    end
  end);
end

function make_connection(i,title)
  local cw = 90;
  local ch = 90;
  local ih = 40;
  local bg = xrdb.color4;
  local fg = xrdb.foreground;

  local button = wibox.container.background();
  button.bg = bg;
  button.fg = fg
  button.shape = rounded();
  button.forced_width = cw;
  button.forced_height = ch;

  local container = wibox.container.margin();
  container.margins = m;

  local icon = wibox.widget.textbox(i);
  icon.font = "MaterialDesignIconsDesktop 33";
  icon.valign = "center";
  icon.align = "center";
  icon.forced_height = ih;

  local title = wibox.widget.textbox(title);
  title.font = "Poppins SemiBold 8";
  title.valign = "center";
  title.align = "center";

  local layout = wibox.layout.fixed.vertical();
  layout.spacing = m;
  layout:add(icon);
  layout:add(title);

  button.widget = container;
  container.widget = layout;

  return { widget = button, icon = icon, title = title };
end

function make_hub(s)
  local hw = 410;
  local hh = 310;
  local bb = '#00000033';
  local wi = '󰖪';


  local hub = wibox({
    type = "toolbar",
    width = hw,
    height = hh,
    screen = s,
    ontop = true,
    visible = false,
    bg = t,
    fg = b,
  });

  local vol = make_progress_bar('Volume', 0);
  vol.bar:buttons(gears.table.join(
    awful.button({ }, 1, function() launch_volume_app(hub) end),
    awful.button({ }, 4, function() increase_volume(vol.p) end),
    awful.button({ }, 5, function() decrease_volume(vol.p) end)
  ));

  local mem = make_progress_bar('Memory', 30);
  mem.bar:buttons(gears.table.join(
    awful.button({ }, 1, function() launch_stat_app(hub) end)
  ));

  local wifi = make_connection(wi, 'wifi off');
  local pac = make_connection('󰏗', 'no updates');

  table.insert(mem_widgets, mem);
  table.insert(vol_widgets, vol);
  table.insert(wifi_widgets, wifi);
  table.insert(pac_widgets, { title = pac.title });

  wifi.widget:buttons(gears.table.join(
    awful.button({ }, 1, function() launch_wifi_app(hub) end)
  ));

  awful.widget.watch(vol_cmd, 1, function(w,o)
    v = tonumber(o);
    vol.p:set_value(v);
  end);


  local container = frost();
  container:setup {
    layout = wibox.layout.fixed.vertical,
    {
      layout = wibox.container.place,
      halign = "center",
      {
        layout = wibox.layout.fixed.horizontal,
        {
          layout = wibox.container.margin,
          margins = m,
          {
            layout = wibox.layout.align.vertical,
            vol.title, vol.bar,
          }
        },
        {
          layout = wibox.container.margin,
          margins = m,
          {
            layout = wibox.layout.align.vertical,
            mem.title, mem.bar,
          }
        }
      },
    },
    {
      layout = wibox.container.margin,
      left = m, right = m, top = m,
      {
        layout = wibox.layout.fixed.horizontal,
        spacing = m,
        wifi.widget, pac.widget,
      }
    }
  };

  hub.y = (h+m+(m/2));
  hub.x = ((s.workarea.width / 2) - (hw/2)) + s.workarea.x;
  hub.shape = rounded();
  container.shape = rounded();

  hub:setup {
    layout = wibox.container.margin,
    shape = rounded(),
    container,
  };

  return hub;
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
        font = "MaterialDesignIconsDesktop 14",
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

  screen.hub = make_hub(screen);
  screen.date = make_date(screen);
  screen.power = make_power(screen);
  screen.tags = make_taglist(screen);
  screen.launch = make_launcher(screen);
  screen.utility = make_utility(screen);

  watch_wifi(wifi_widgets);
  watch_pac(pac_widgets);
  watch_mem(mem_widgets);
  watch_vol(vol_widgets);

end);
