local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local vars = require('helpers.vars');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

function make_connection(t, n)
  local container = wibox.container.margin();
  container.bottom = vars.global.m;
  container.forced_width = vars.hub.w - vars.hub.nw - (vars.global.m*2);

  local conx = wibox.container.background();
  conx.bg = vars.global.f2;
  conx.shape = rounded();
  conx.fg = vars.global.b;

  local i = '';
  if t == 'wireless' then i = '󰖩' elseif t == 'bluetooth' then i = '󰂯' elseif t == 'wired' then i = '󰲝' else i = '' end;
  if n == 'disconnected' and t == 'wireless' then i = '󰖪' end;
  if n == 'disconnected' and t == 'wired' then i = '󰲜' end;
  local icon = wibox.widget.textbox(i)
  icon.font = vars.fonts.il;

  local name = wibox.widget.textbox(n);
  name.font = vars.fonts.tll;

  local type = wibox.widget.textbox(t);
  type.font = vars.fonts.tmb;

  conx:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.container.margin,
      margins = vars.global.m,
      icon,
    },
    name,
    { layout = wibox.container.margin, right = vars.global.m, type },
  }

  container.widget = conx;

  return { widget = container, icon = icon, name = name };
end

return function()
  local view = wibox.container.margin();
  view.left = vars.global.m;
  view.right = vars.global.m;

  local title = wibox.widget.textbox("Connections");
  title.font = vars.fonts.tlb;
  title.forced_height = vars.hub.i + vars.global.m + vars.global.m;

  local connections = wibox.layout.fixed.vertical();

  local wireless = make_connection('wireless');
  local wired = make_connection('wired');
  connections:add(wireless.widget);
  connections:add(wired.widget);

  local btdevices = {};

  awful.widget.watch(vars.commands.btdevices, 5, function(w,o)
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
      awful.spawn.easy_async_with_shell(vars.commands.btdevice..' "'..d:gsub("^%s*(.-)%s*$", "%1")..'"', function(o,e,r,c)
        if(c == 0) then btd.icon.text = vars.icons.bt else btd.icon.text = vars.icons.btx end;
        if(c == 0) then btd.name.text = d..'(connected)' else btd.name.text = d..'(disconnected)' end;
      end);
      btdevices[d] = btd;
    end
  end);

  awful.widget.watch(vars.commands.wifiup, 3, function(w,o,e,r,c)
    if(c == 0) then 
      awful.spawn.easy_async_with_shell(vars.commands.ssid, function(ssid)
        wireless.icon.text = vars.icons.wifi;
        wireless.name.text = ssid:gsub("^%s*(.-)%s*$", "%1");
      end);
    else
      wireless.icon.text = vars.icons.wifix;
      wireless.name.text = 'disconnected';
    end
  end);

  awful.widget.watch(vars.commands.lanup, 3, function(w,o,e,r,c)
    if(c == 0) then
      wired.icon.text = vars.icons.lan;
      wired.name.text = 'connected';
    else
      wired.icon.text = vars.icons.lanx;
      wired.name.text = 'disconnected';
    end
  end);

  view:setup {
    layout = wibox.container.background,
    fg = vars.global.b,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.container.place,
        title,
      },
      {
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        connections,
      }
    }
  }

  return view;
end