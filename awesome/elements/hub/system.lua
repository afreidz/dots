local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

return function()
  local view = wibox.container.margin();
  view.left = config.global.m;
  view.right = config.global.m;

  local title = wibox.widget.textbox("System");
  title.font = config.fonts.tlb;
  title.forced_height = config.hub.i + config.global.m + config.global.m;

  local close = wibox.widget.textbox(config.icons.close);
  close.font = config.fonts.il;
  close.forced_height = config.hub.i;
  close:buttons(gears.table.join(
    awful.button({}, 1, function() if root.elements.hub then root.elements.hub.close() end end)
  ));

  local graph = wibox.container.background();
  graph.bg = config.colors.f;
  graph.shape = rounded();
  graph.forced_height = 200;
  graph.forced_width = config.hub.w - config.hub.nw - (config.global.m*2);
  graph.widget = wibox.widget.base.empty_widget();

  local scale = wibox.layout.align.vertical();
  local scale_max = wibox.widget.textbox('100%');
  local scale_min = wibox.widget.textbox('0%');
  scale_max.font = config.fonts.tsl;
  scale_min.font = config.fonts.tsl;
  scale.first = scale_max;
  scale.third = scale_min;
  scale.second = wibox.widget.base.empty_widget();
  scale.forced_width = 30;

  local ram_progress = wibox.widget.progressbar();
  ram_progress.max_value = 100;
  ram_progress.background_color = config.colors.t;
  ram_progress.color = config.colors.x12;
  ram_progress.value = 0;
  ram_progress.bar_shape = function(c,w,h) gears.shape.partially_rounded_rect(c,w,h, false, true, true, false, config.global.r) end;

  local cpu_progress = wibox.widget.progressbar();
  cpu_progress.max_value = 100;
  cpu_progress.background_color = config.colors.t;
  cpu_progress.color = config.colors.x13;
  cpu_progress.value = 0;
  cpu_progress.bar_shape = function(c,w,h) gears.shape.partially_rounded_rect(c,w,h, false, true, true, false, config.global.r) end;

  local disk_progress = wibox.widget.progressbar();
  disk_progress.max_value = 100;
  disk_progress.background_color = config.colors.t;
  disk_progress.color = config.colors.x11;
  disk_progress.value = 0;
  disk_progress.bar_shape = function(c,w,h) gears.shape.partially_rounded_rect(c,w,h, false, true, true, false, config.global.r) end;

  local ram = wibox.container.rotate(ram_progress, 'east');
  local cpu = wibox.container.rotate(cpu_progress, 'east');
  local disk = wibox.container.rotate(disk_progress, 'east');

  local ram_value = wibox.widget.textbox();
  ram_value.font = config.fonts.tsl;
  ram_value.visible = false;

  local cpu_value = wibox.widget.textbox();
  cpu_value.font = config.fonts.tsl;
  cpu_value.visible = false;

  local disk_value = wibox.widget.textbox();
  disk_value.font = config.fonts.tsl;
  disk_value.visible = false;

  local ram_key = wibox.widget.textbox("RAM");
  ram_key.font = config.fonts.tmb;

  local cpu_key = wibox.widget.textbox("CPU");
  cpu_key.font = config.fonts.tmb;

  local disk_key = wibox.widget.textbox("Disk");
  disk_key.font = config.fonts.tmb;

  ram:connect_signal("mouse::enter", function() ram_value.visible = true end);
  ram:connect_signal("mouse::leave", function() ram_value.visible = false end);

  cpu:connect_signal("mouse::enter", function() cpu_value.visible = true end);
  cpu:connect_signal("mouse::leave", function() cpu_value.visible = false end);

  disk:connect_signal("mouse::enter", function() disk_value.visible = true end);
  disk:connect_signal("mouse::leave", function() disk_value.visible = false end);

  graph:setup {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.container.margin,
      top = config.global.m,
      wibox.widget.base.empty_widget(),
    },
    {
      layout = wibox.layout.align.horizontal,
      {
        layout = wibox.container.margin,
        margins = config.global.m,
        scale,
      },
      {
        layout = wibox.container.margin,
        right = config.global.m*5,
        {
          layout = wibox.container.background,
          fg = config.colors.w,
          {
            layout = wibox.layout.flex.horizontal,
            spacing = config.global.m*2,
            {
              layout = wibox.layout.stack,
              ram,
              { layout = wibox.container.place, valign = "bottom", ram_value }
            },
            {
              layout = wibox.layout.stack,
              cpu,
              { layout = wibox.container.place, valign = "bottom", cpu_value }
            },
            {
              layout = wibox.layout.stack,
              disk,
              { layout = wibox.container.place, valign = "bottom", disk_value }
            },
          }
        }
      }
    },
    {
      layout = wibox.container.margin,
      left = config.global.m*5, right = config.global.m*5,
      {
        layout = wibox.layout.flex.horizontal,
        forced_height = config.hub.i,
        spacing = config.global.m*2,
        { layout = wibox.container.place, ram_key },
        { layout = wibox.container.place, cpu_key },
        { layout = wibox.container.place, disk_key },
      }
    }
  };

  local pac = wibox.container.background();
  pac.bg = config.colors.x12;
  pac.fg = config.colors.w;
  pac.shape = rounded();
  pac:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn(config.commands.software) end)
  ));

  local pac_icon = wibox.widget.textbox(config.icons.pac);
  pac_icon.font = config.fonts.il;
  pac_icon.forced_height = config.hub.i + config.global.m + config.global.m;

  local pac_title = wibox.widget.textbox('System Updates');
  pac_title.font = config.fonts.tll;

  local pac_value = wibox.widget.textbox('none available');
  pac_value.font = config.fonts.tmb;

  pac:setup {
    layout = wibox.layout.align.horizontal,
    { layout = wibox.container.margin, left = config.global.m, pac_icon },
    { layout = wibox.container.margin, left = config.global.m, pac_title },
    { layout = wibox.container.margin, right = config.global.m, pac_value },
  };

  local proc = wibox.container.background();
  proc.bg = config.colors.f;
  proc.shape = rounded();

  local proc_text = wibox.widget.textbox();
  proc_text.font = config.fonts.mll;

  proc:setup {
    layout = wibox.container.margin,
    margins = config.global.m,
    proc_text;
  }

  local bat = nil;
  local bat_value = nil;
  local bat_progress = nil;
  if config.topbar.utilities.bat then
    bat = wibox.container.background();
    bat.bg = config.colors.f;
    bat.shape = rounded();

    bat_progress = wibox.widget.progressbar();
    bat_progress.background_color = config.colors.b..'26';
    bat_progress.color = config.colors.x10;
    bat_progress.shape = rounded();
    bat_progress.max_value = 100;
    bat_progress.value = 0;

    bat_value = wibox.widget.textbox();
    bat_value.font = config.fonts.txxlb;
    bat_value.align = "center";
    bat_value.valign = "center";
    bat_value.visible = false;
    bat_value.opacity = 0.5;

    bat:connect_signal('mouse::enter', function() bat_value.visible = true end);
    bat:connect_signal('mouse::leave', function() bat_value.visible = false end);

    bat:setup {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.container.margin,
        margins = config.global.m,
        {
          font = config.fonts.tlb,
          text = "Battery",
          widget = wibox.widget.textbox,
        }
      },
      {
        layout = wibox.layout.stack,
        {
          layout = wibox.container.margin,
          left = config.global.m,
          right = config.global.m,
          bottom = config.global.m,
          forced_height = 60,
          bat_progress,
        },
        bat_value,
      }
    }
  end

  view:setup {
    layout = wibox.container.background,
    fg = config.colors.xf,
    {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.align.horizontal,
        nil,
        {
          layout = wibox.container.place,
          title
        },
        close
      },
      { layout = wibox.container.margin, bottom = config.global.m, bat },
      graph,
      { layout = wibox.container.margin, top = config.global.m, bottom = config.global.m, pac },
      proc,
    }
  }

  awful.widget.watch(config.commands.ramcmd, 5, function(w,o)
    local n = tonumber(o);
    ram_progress:set_value(n);
    ram_value.text = o:gsub("^%s*(.-)%s*$", "%1").."%";
    for _,i in pairs(root.elements.mem_icons) do
      if n >= 75 then i.update(config.icons.mem, config.colors.x9) 
      elseif n >= 50 then i.update(config.icons.mem, config.colors.x11) 
      else i.update(config.icons.mem, config.colors.x10) end;
    end;
  end);

  awful.widget.watch(config.commands.cpucmd, 5, function(w,o,e,r,c)
    cpu_progress:set_value(tonumber(o));
    cpu_value.text = o:gsub("^%s*(.-)%s*$", "%1").."%";
  end);

  awful.widget.watch(config.commands.diskcmd, 5, function(w,o)
    local val = o:gsub("%%",""):gsub("^%s*(.-)%s*$", "%1");
    disk_progress:set_value(tonumber(val));
    disk_value.text = val.."%";
  end);

  awful.widget.watch(config.commands.proccmd, 5, function(w, o)
    proc_text.text = o:gsub("^%s*(.-)%s*$", "%1");
  end);

  if config.topbar.utilities.bat then
    awful.widget.watch(config.commands.batcmd, 5, function(w, o)
      local n = tonumber(o);
      if bat_progress then bat_progress:set_value(n) end;
      if bat_value then bat_value.text = tostring(n)..'%' end;
      for _,i in pairs(root.elements.bat_icons) do
        if n <= 10 then i.update(config.icons.bat10, config.colors.x9)
        elseif n <= 20 then i.update(config.icons.bat20, config.colors.x9)
        elseif n <= 30 then i.update(config.icons.bat30, config.colors.x9)
        elseif n <= 40 then i.update(config.icons.bat40, config.colors.x11)
        elseif n <= 50 then i.update(config.icons.bat50, config.colors.x11)
        elseif n <= 60 then i.update(config.icons.bat60, config.colors.x11)
        elseif n <= 70 then i.update(config.icons.bat70, config.colors.w)
        elseif n <= 80 then i.update(config.icons.bat80, config.colors.w)
        elseif n <= 90 then i.update(config.icons.bat90, config.colors.w)
        else i.update(config.icons.bat, config.colors.w) end
      end
    end);
  end

  view.refresh = function()
    awful.spawn.easy_async_with_shell(config.commands.updatescmd, function(o,e)
      local n = tonumber(o);
      if n <= 0 then 
        pac_value.text = 'none available';
        for _,i in pairs(root.elements.pac_icons) do i.update(config.icons.pac, config.colors.w); end; 
      else 
        pac_value.text = o:gsub("^%s*(.-)%s*$", "%1")..' available' 
        for _,i in pairs(root.elements.pac_icons) do i.update(config.icons.pac, config.colors.x10); end;
      end
    end);

    if config.topbar.utilities.bat then
      awful.spawn.easy_async(config.commands.batcmd, function(o)
        local n = tonumber(o);
        if bat_progress then bat_progress:set_value(n) end;
        if bat_value then bat_value.text = tostring(n)..'%' end;
      end);
    end
  end

  view.refresh();

  return view;
end