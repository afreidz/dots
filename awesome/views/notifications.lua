local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local vars = require('helpers.vars');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

function make_note(n)
  local note = wibox.container.margin();
  note.bottom = vars.global.m;

  local title = nil;
  if(n.title ~= '') then 
    title = naughty.widget.title {
      notification = n,
      widget_template = {
        id = 'text_role',
        font = vars.fonts.tlb,
        widget = wibox.widget.textbox,
      }
    };
  else 
    title = wibox.widget.textbox('Notification');
    title.font = vars.fonts.tlb; 
  end;
  
  local msg = naughty.widget.message {
    notification = n,
    widget_template = {
      id = 'text_rold',
      font = vars.fonts.tml,
      widget = naughty.widget.textbox
    }
  };

  local app = wibox.widget.textbox(n.app_name or 'System');
  app.font = vars.fonts.tsl;
  app.align = 'right';

  note:buttons(gears.table.join(
    awful.button({ }, 1, function() n:destroy(); end)
  ));
  
  note:setup {
    layout = wibox.container.background,
    bg = vars.global.f2,
    fg = vars.global.b,
    shape = rounded(),
    {
      layout = wibox.container.margin,
      left = vars.global.m, right = vars.global.m, bottom = vars.global.m,
      {
        layout = wibox.layout.align.vertical,
        {
          layout = wibox.container.margin,
          top = vars.global.m,
          title,
        },
        {
          layout = wibox.container.margin,
          top = vars.global.m,
          msg,
        },
        {
          layout = wibox.container.margin,
          top = vars.global.m,
          app
        },
      }
    }
  }

  return note;
end

function show_empty()
  local empty = wibox.container.place()
  empty.forced_width = vars.hub.w - vars.hub.nw - (vars.global.m*4);
  empty.forced_height = vars.hub.h - (vars.global.m*3) - vars.hub.i;
  empty.valign = "center";
  empty.halign = "center";
  empty.widget = wibox.widget.textbox('you have no notifications!')
  return empty;
end

return function()
  local view = wibox.container.margin();
  view.left = vars.global.m;
  view.right = vars.global.m;

  local title = wibox.widget.textbox("Notifications");
  title.font = vars.fonts.tlb;
  title.forced_height = vars.hub.i + vars.global.m + vars.global.m;

  local container = wibox.layout.fixed.vertical();
  container.forced_width = vars.hub.w - vars.hub.nw - (vars.global.m*4);
  container.forced_height = vars.hub.h - (vars.global.m*3) - vars.hub.i;

  naughty.connect_signal('added', function(n)
    if n.urgency == 'low' then
      container:reset();
      table.insert(vars.notifications.active, n);
      for k,note in pairs(vars.notifications.active) do
        container:add(make_note(note));
      end
    end
  end);

  naughty.connect_signal('destroyed', function(n)
    local i = gears.table.hasitem(vars.notifications.active, n);
    if i then 
      table.remove(vars.notifications.active, i);
      container:reset();
      if #vars.notifications.active <= 0 then return container:add(show_empty()) end;
      for k,note in pairs(vars.notifications.active) do
        container:add(make_note(note));
      end
    end
  end);

  naughty.connect_signal('request::display', function(n)
    if n.urgency == 'low' then n.ignore = true; n.timeout = 0 end
    if n.urgency ~= 'low' then naughty.layout.box { notification = n } end
  end);

  container:add(show_empty());
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
        container,
      }
    }
  }

  return view;
end