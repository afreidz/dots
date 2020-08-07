local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

function make_connection(t, n)
  local container = wibox.container.margin();
  container.bottom = config.global.m;
  container.forced_width = config.hub.w - config.hub.nw - (config.global.m*2);

  local conx = wibox.container.background();
  conx.bg = config.colors.f;
  conx.shape = rounded();
  conx.fg = config.colors.b;

  local i = '';
  if t == 'wireless' then i = config.icons.wifi elseif t == 'bluetooth' then i = config.icons.bt elseif t == 'wired' then i = config.icons.lan else i = '' end;
  if n == 'disconnected' and t == 'wireless' then i = config.icons.wifix end;
  if n == 'disconnected' and t == 'wired' then i = config.icons.lanx end;
  local icon = wibox.widget.textbox(i)
  icon.font = config.fonts.il;

  local name = wibox.widget.textbox(n);
  name.font = config.fonts.tll;

  local type = wibox.widget.textbox(t);
  type.font = config.fonts.tmb;

  conx:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.container.margin,
      margins = config.global.m,
      icon,
    },
    name,
    { layout = wibox.container.margin, right = config.global.m, type },
  }

  container.widget = conx;

  return { widget = container, icon = icon, name = name };
end

return function()
  local view = wibox.container.margin();
  view.left = config.global.m;
  view.right = config.global.m;

  local title = wibox.widget.textbox("Connections");
  title.font = config.fonts.tlb;
  title.forced_height = config.hub.i + config.global.m + config.global.m;

  local close = wibox.widget.textbox(config.icons.close);
  close.font = config.fonts.il;
  close.forced_height = config.hub.i;
  close:buttons(gears.table.join(
    awful.button({}, 1, function() if root.elements.hub then root.elements.hub.close() end end)
  ));

  local connections = wibox.layout.fixed.vertical();

  local wireless = make_connection('wireless');
  local wired = make_connection('wired');
  connections:add(wireless.widget);
  connections:add(wired.widget);

  local btdevices = {};

  view:setup {
    layout = wibox.container.background,
    fg = config.colors.xf,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.layout.align.horizontal,
        nil,
        {
          layout = wibox.container.place,
          title
        },
        close
      },
      {
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        connections,
      }
    }
  }

  view.refresh = function()
    awful.spawn.easy_async_with_shell(config.commands.btdevices, function(o)
      local devices = o:gmatch("[^\r\n]+");
      for k,v in pairs(btdevices) do
        if not string.match(o, k) then
          connections:remove_widgets(btdevices[k].widget); 
          btdevices[k] = nil;
        end
      end
      for d in devices do
        local btd = nil;
        if btdevices[d] then btd = btdevices[d] else
          btd = make_connection('bluetooth', d);
          connections:add(btd.widget);
        end
        awful.spawn.easy_async_with_shell(config.commands.btdevice..' "'..d:gsub("^%s*(.-)%s*$", "%1")..'"', function(o,e,r,c)
          if(c == 0) then btd.icon.text = config.icons.bt else btd.icon.text = config.icons.btx end;
          if(c == 0) then btd.name.text = d..'(connected)' else btd.name.text = d..'(disconnected)' end;
        end);
        btdevices[d] = btd;
      end
    end);

    awful.spawn.easy_async_with_shell(config.commands.wifiup, function(o,e,r,c)
      if(c == 0) then 
        awful.spawn.easy_async_with_shell(config.commands.ssid, function(ssid)
          wireless.icon.text = config.icons.wifi;
          wireless.name.text = ssid:gsub("^%s*(.-)%s*$", "%1");
        end);
      else
        wireless.icon.text = config.icons.wifix;
        wireless.name.text = 'disconnected';
      end
    end);

    awful.spawn.easy_async_with_shell(config.commands.lanup, function(o,e,r,c)
      if(c == 0) then
        wired.icon.text = config.icons.lan;
        wired.name.text = 'connected';
      else
        wired.icon.text = config.icons.lanx;
        wired.name.text = 'disconnected';
      end
    end);
  end

  return view;
end