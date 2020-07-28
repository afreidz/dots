local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

function make_note(n)
  local note = wibox.container.margin();
  note.bottom = config.global.m;

  local title = nil;
  if(n.title ~= '') then 
    title = naughty.widget.title {
      notification = n,
      widget_template = {
        id = 'text_role',
        font = config.fonts.tlb,
        widget = wibox.widget.textbox,
      }
    };
  else 
    title = wibox.widget.textbox('Notification');
    title.font = config.fonts.tlb; 
  end;
  
  local msg = naughty.widget.message {
    notification = n,
    widget_template = {
      id = 'text_role',
      font = config.fonts.tml,
      widget = naughty.widget.textbox
    }
  };

  local app = wibox.widget.textbox(n.app_name or 'System');
  app.font = config.fonts.tsl;
  app.align = 'right';

  note:buttons(gears.table.join(
    awful.button({ }, 1, function() n:destroy(); end)
  ));
  
  note:setup {
    layout = wibox.container.background,
    bg = config.colors.f,
    fg = config.colors.b,
    shape = rounded(),
    {
      layout = wibox.container.margin,
      left = config.global.m, right = config.global.m, bottom = config.global.m,
      {
        layout = wibox.layout.align.vertical,
        {
          layout = wibox.container.margin,
          top = config.global.m,
          title,
        },
        {
          layout = wibox.container.margin,
          top = config.global.m,
          msg,
        },
        {
          layout = wibox.container.margin,
          top = config.global.m,
          app
        },
      }
    }
  }

  return note;
end

function show_empty()
  local empty = wibox.container.place()
  empty.forced_width = config.hub.w - config.hub.nw - (config.global.m*4);
  empty.forced_height = config.hub.h - (config.global.m*3) - config.hub.i;
  empty.valign = "center";
  empty.halign = "center";
  empty.widget = wibox.widget.textbox('you have no notifications!')
  return empty;
end

return function()
  local view = wibox.container.margin();
  view.left = config.global.m;
  view.right = config.global.m;

  local title = wibox.widget.textbox("Notifications");
  title.font = config.fonts.tlb;
  title.forced_height = config.hub.i + config.global.m + config.global.m;

  local close = wibox.widget.textbox(config.icons.close);
  close.font = config.fonts.il;
  close.forced_height = config.hub.i;
  close:buttons(gears.table.join(
    awful.button({}, 1, function() if root.elements.hub then root.elements.hub.close() end end)
  ));

  local clear = wibox.widget.textbox(config.icons.clear);
  clear.font = config.fonts.il;
  clear.forced_height = config.hub.i;
  clear:buttons(gears.table.join(
    awful.button({}, 1, function() naughty.destroy_all_notifications() end)
  ));

  local container = wibox.layout.fixed.vertical();
  container.forced_width = config.hub.w - config.hub.nw - (config.global.m*4);
  container.forced_height = config.hub.h - (config.global.m*3) - config.hub.i;

  naughty.connect_signal('destroyed', function(n)
    local i = gears.table.hasitem(config.notifications.active, n);
    if i then 
      table.remove(config.notifications.active, i);
      container:reset();
      if #config.notifications.active <= 0 then
        for _,i in pairs(root.elements.note_icons) do i.fg = config.colors.w end;
        return container:add(show_empty()) 
      end;
      for k,note in pairs(config.notifications.active) do
        container:add(make_note(note));
      end
    end
  end);

  naughty.connect_signal('request::display', function(n)
    if n.urgency == 'low' then 
      n.ignore = true; 
      n.timeout = 0;
      container:reset();
      table.insert(config.notifications.active, n);
      for k,note in pairs(config.notifications.active) do
        container:add(make_note(note));
      end
      for _,i in pairs(root.elements.note_icons) do i.fg = config.colors.x10 end;
    end
    if n.urgency ~= 'low' then naughty.layout.box { notification = n } end
  end);

  container:add(show_empty());
  view:setup {
    layout = wibox.container.background,
    fg = config.colors.b,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.layout.align.horizontal,
        clear,
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
        container,
      }
    }
  }

  return view;
end