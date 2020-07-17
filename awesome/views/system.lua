local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local vars = require('helpers.vars');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

return function()
  local view = wibox.container.margin();
  view.left = vars.global.m;
  view.right = vars.global.m;

  local title = wibox.widget.textbox("System");
  title.font = vars.fonts.tlb;
  title.forced_height = vars.hub.i + vars.global.m + vars.global.m;

  local graph = wibox.container.background();
  graph.bg = vars.global.f2;
  graph.shape = rounded();
  graph.forced_height = 250;
  graph.forced_width = vars.hub.w - vars.hub.nw - (vars.global.m*4);
  graph.widget = wibox.widget.base.empty_widget();

  local scale = wibox.layout.align.vertical();
  local scale_max = wibox.widget.textbox('100%');
  local scale_min = wibox.widget.textbox('0%');
  scale_max.font = vars.fonts.tsl;
  scale_min.font = vars.fonts.tsl;
  scale.first = scale_max;
  scale.third = scale_min;
  scale.second = wibox.widget.base.empty_widget();
  scale.forced_width = 30;

  local ram_progress = wibox.widget.progressbar();
  ram_progress.max_value = 100;
  ram_progress.background_color = vars.global.t;
  ram_progress.color = xrdb.color12;
  ram_progress.value = 0;
  ram_progress.bar_shape = function(c,w,h) gears.shape.partially_rounded_rect(c,w,h, false, true, true, false, vars.global.r) end;

  local cpu_progress = wibox.widget.progressbar();
  cpu_progress.max_value = 100;
  cpu_progress.background_color = vars.global.t;
  cpu_progress.color = xrdb.color13;
  cpu_progress.value = 0;
  cpu_progress.bar_shape = function(c,w,h) gears.shape.partially_rounded_rect(c,w,h, false, true, true, false, vars.global.r) end;

  local disk_progress = wibox.widget.progressbar();
  disk_progress.max_value = 100;
  disk_progress.background_color = vars.global.t;
  disk_progress.color = xrdb.color11;
  disk_progress.value = 0;
  disk_progress.bar_shape = function(c,w,h) gears.shape.partially_rounded_rect(c,w,h, false, true, true, false, vars.global.r) end;

  local ram = wibox.container.rotate(ram_progress, 'east');
  local cpu = wibox.container.rotate(cpu_progress, 'east');
  local disk = wibox.container.rotate(disk_progress, 'east');

  local ram_value = wibox.widget.textbox();
  ram_value.font = vars.fonts.tsl;
  ram_value.visible = false;

  local cpu_value = wibox.widget.textbox();
  cpu_value.font = vars.fonts.tsl;
  cpu_value.visible = false;

  local disk_value = wibox.widget.textbox();
  disk_value.font = vars.fonts.tsl;
  disk_value.visible = false;

  local ram_key = wibox.widget.textbox("RAM");
  ram_key.font = vars.fonts.tmb;

  local cpu_key = wibox.widget.textbox("CPU");
  cpu_key.font = vars.fonts.tmb;

  local disk_key = wibox.widget.textbox("Disk");
  disk_key.font = vars.fonts.tmb;

  ram:connect_signal("mouse::enter", function() ram_value.visible = true end);
  ram:connect_signal("mouse::leave", function() ram_value.visible = false end);

  cpu:connect_signal("mouse::enter", function() cpu_value.visible = true end);
  cpu:connect_signal("mouse::leave", function() cpu_value.visible = false end);

  disk:connect_signal("mouse::enter", function() disk_value.visible = true end);
  disk:connect_signal("mouse::leave", function() disk_value.visible = false end);

  graph:setup {
    layout = wibox.layout.align.vertical,
    wibox.widget.base.empty_widget(),
    {
      layout = wibox.layout.align.horizontal,
      {
        layout = wibox.container.margin,
        margins = vars.global.m,
        scale,
      },
      {
        layout = wibox.container.margin,
        right = vars.global.m*5,
        {
          layout = wibox.container.background,
          fg = xrdb.foreground,
          {
            layout = wibox.layout.flex.horizontal,
            spacing = vars.global.m*2,
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
      left = vars.global.m*5, right = vars.global.m*5,
      {
        layout = wibox.layout.flex.horizontal,
        forced_height = vars.hub.i,
        spacing = vars.global.m*2,
        { layout = wibox.container.place, ram_key },
        { layout = wibox.container.place, cpu_key },
        { layout = wibox.container.place, disk_key },
      }
    }
  };

  local pac = wibox.container.background();
  pac.bg = xrdb.color12;
  pac.fg = xrdb.foreground;
  pac.shape = rounded();

  local pac_icon = wibox.widget.textbox(vars.icons.pac);
  pac_icon.font = vars.fonts.il;
  pac_icon.forced_height = vars.hub.i + vars.global.m + vars.global.m;

  local pac_title = wibox.widget.textbox('System Updates');
  pac_title.font = vars.fonts.tll;

  local pac_value = wibox.widget.textbox('none available');
  pac_value.font = vars.fonts.tmb;

  pac:setup {
    layout = wibox.layout.align.horizontal,
    { layout = wibox.container.margin, left = vars.global.m, pac_icon },
    { layout = wibox.container.margin, left = vars.global.m, pac_title },
    { layout = wibox.container.margin, right = vars.global.m, pac_value },
  };

  local proc = wibox.container.background();
  proc.bg = vars.global.f2;
  proc.shape = rounded();

  local proc_text = wibox.widget.textbox();
  proc_text.font = vars.fonts.mll;

  proc:setup {
    layout = wibox.container.margin,
    margins = vars.global.m,
    proc_text;
  }

  view:setup {
    layout = wibox.container.background,
    fg = vars.global.b,
    {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.container.place,
        title,
      },
      {
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        graph,
      },
      {
        layout = wibox.container.margin,
        margins = vars.global.m,
        pac,
      },
      {
        layout = wibox.container.margin,
        left = vars.global.m, right = vars.global.m,
        proc,
      }
    }
  }

  awful.widget.watch(vars.commands.ramcmd, 2, function(w,o)
    ram_progress:set_value(tonumber(o));
    ram_value.text = o:gsub("^%s*(.-)%s*$", "%1").."%";
  end);

  awful.widget.watch(vars.commands.cpucmd, 2, function(w,o,e,r,c)
    cpu_progress:set_value(tonumber(o));
    cpu_value.text = o:gsub("^%s*(.-)%s*$", "%1").."%";
  end);

  awful.widget.watch(vars.commands.diskcmd, 5, function(w,o)
    local val = o:gsub("%%",""):gsub("^%s*(.-)%s*$", "%1");
    disk_progress:set_value(tonumber(val));
    disk_value.text = val.."%";
  end);

  awful.widget.watch(vars.commands.updatescmd, 5, function(w,o)
    local n = tonumber(o);
    if n <= 0 then pac_value.text = 'none available' else pac_value.text = o:gsub("^%s*(.-)%s*$", "%1")..' available' end
  end);

  awful.widget.watch(vars.commands.proccmd, 5, function(w, o)
    proc_text.text = o;
  end);

  return view;
end