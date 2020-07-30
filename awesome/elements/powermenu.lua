local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local pam = require('liblua_pam');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

root.elements = root.elements or {};
root.elements.powermenu = root.elements.powermenu or {};
root.elements.powermenu.open = false;

function mask(a,b)
   return a:gsub('.','•'),b;
end

function reset()
  if root.elements.powermenu.icon_lock and root.elements.powermenu.prompt then
    root.elements.powermenu.icon_lock.children[1].text = config.icons.lock;
    root.elements.powermenu.icon_lock.children[2].text = 'lock';
    root.elements.powermenu.icon_lock.children[2].visible = false;
    root.elements.powermenu.prompt.visible = false;
    root.elements.powermenu.prompt.widget = nil;
  end
end

function unlock(pwd)
  if pam.auth_current_user(pwd) then
    hide();
  else
    return prompt();
  end
end

function prompt()
  local box = wibox.widget.textbox();

  awful.prompt.run {
    bg_cursor = config.colors.w,
    font = config.fonts.txlb,
    textbox = box,
    exe_callback = unlock,
    done_callback = reset,
    highlighter = mask,
    prompt = '',
  }

  if root.elements.powermenu.prompt then 
    root.elements.powermenu.prompt.widget = box;
    root.elements.powermenu.prompt.visible = true; 
  end;
end

function lock(cb)
  if root.elements.powermenu.open then return end;
  root.elements.powermenu.open = true;

  -- Show splash screen and add panel to mouse screen
  for _,s in pairs(root.elements.powermenu.splash) do s.visible = true end
  if root.elements.powermenu.panel then
    local y = mouse.screen.geometry.height * 0.35;
    local x = (mouse.screen.geometry.width/2) - (config.powermenu.w/2);
    root.elements.powermenu.splash[mouse.screen.index].widget:add_at(root.elements.powermenu.panel, { x = x, y = y });
  end
  
  -- Hide other elements on the screen
  if root.elements.topbar then root.elements.topbar.hide() end;
  if root.elements.hub then root.elements.hub.visible = false end;
  for s in screen do if s.selected_tag then s.selected_tag.selected = false end end;
  
  -- Set the callback to be called when unlocking
  if cb then root.elements.powermenu.lockcallback = cb end;
  
  -- Hide other icons in powermenu
  if root.elements.powermenu.buttons then
    root.elements.powermenu.buttons:reset();
    root.elements.powermenu.buttons:add(root.elements.powermenu.icon_lock);
  end

  -- Set lock text
  if root.elements.powermenu.user then 
    if root.elements.powermenu.user then
      awful.spawn.easy_async_with_shell('whoami', function(u) 
        root.elements.powermenu.user.markup = '<span font="'..config.fonts.tll..'">Locked by: </span>'..u:gsub("^%s*(.-)%s*$", "%1") 
      end);
    end
  end

  -- Setup hover/click state for lock icon
  if root.elements.powermenu.icon_lock then
    root.elements.powermenu.icon_lock:connect_signal("mouse::enter", function()
      root.elements.powermenu.icon_lock.children[1].text = config.icons.unlock;
      root.elements.powermenu.icon_lock.children[2].text = 'unlock';
      root.elements.powermenu.icon_lock.children[2].visible = true;
    end);
    root.elements.powermenu.icon_lock:connect_signal("mouse::leave", function()
      root.elements.powermenu.icon_lock.children[1].text = config.icons.lock;
      root.elements.powermenu.icon_lock.children[2].text = 'lock';
      root.elements.powermenu.icon_lock.children[2].visible = false;
    end);
    root.elements.powermenu.icon_lock:buttons(gears.table.join(
      awful.button({}, 1, function()
        if root.elements.powermenu.prompt then prompt() end
      end)
    ));
  end

end

function show()
  if root.elements.powermenu.open then return end;
  root.elements.powermenu.open = true;

  -- Show splash screen and add panel to mouse screen
  for _,s in pairs(root.elements.powermenu.splash) do s.visible = true end
  if root.elements.powermenu.panel then
    local y = mouse.screen.geometry.height * 0.35;
    local x = (mouse.screen.geometry.width/2) - (config.powermenu.w/2);
    root.elements.powermenu.splash[mouse.screen.index].widget:add_at(root.elements.powermenu.panel, { x = x, y = y });
  end
  
  -- Hide other elements on the screen
  if root.elements.topbar then root.elements.topbar.hide() end;
  if root.elements.hub then root.elements.hub.visible = false end;
  for s in screen do if s.selected_tag then s.selected_tag.selected = false end end;
  
  -- Show other icons in powermenu
    -- Hide other icons in powermenu
  if root.elements.powermenu.buttons then
    root.elements.powermenu.buttons:reset();
    root.elements.powermenu.buttons:add(root.elements.powermenu.icon_shutdown);
    root.elements.powermenu.buttons:add(root.elements.powermenu.icon_suspend);
    root.elements.powermenu.buttons:add(root.elements.powermenu.icon_restart);
    root.elements.powermenu.buttons:add(root.elements.powermenu.icon_logout);
    root.elements.powermenu.buttons:add(root.elements.powermenu.icon_lock);
    root.elements.powermenu.buttons:add(root.elements.powermenu.icon_cancel);
  end

  -- Set text
  if root.elements.powermenu.user then
    awful.spawn.easy_async_with_shell('whoami', function(u) root.elements.powermenu.user.text = u:gsub("^%s*(.-)%s*$", "%1") end);
  end

  -- Setup hover/click state for lock icon
  if root.elements.powermenu.icon_lock then
    root.elements.powermenu.icon_lock:connect_signal("mouse::enter", function()
      root.elements.powermenu.icon_lock.children[1].text = config.icons.lock;
      root.elements.powermenu.icon_lock.children[2].text = 'lock';
      root.elements.powermenu.icon_lock.children[2].visible = true;
    end);
    root.elements.powermenu.icon_lock:connect_signal("mouse::leave", function()
      root.elements.powermenu.icon_lock.children[2].visible = false;
    end);
    root.elements.powermenu.icon_lock:buttons(gears.table.join(
      awful.button({}, 1, function() lock() end)
    ));
  end

end

function hide()
  for s in screen do
    s.tags[1].selected = true;
    root.elements.powermenu.splash[s.index].widget:reset();
    root.elements.powermenu.splash[s.index].visible = false;
  end;
  
  if root.elements.topbar then root.elements.topbar.show() end;
  awful.screen.focus(mouse.screen or screen.primary);
  
  if mouse.current_client and not awful.client.focus then 
    awful.client.focus = mouse.current_client;
  end;
  
  if root.elements.powermenu.lockcallback then root.elements.powermenu.lockcallback() end;
  root.elements.powermenu.lockcallback = nil;
  root.elements.powermenu.open = false;
end

function make_button(i,t)
  local button = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    forced_height = config.global.m*5,
    {
      widget = wibox.widget.textbox,
      text = i,
      font = config.fonts.txxlb,
      align = 'center',
      valign = 'center',
    },
    {
      widget = wibox.widget.textbox,
      text = t,
      font = config.fonts.tml,
      align = 'center',
      valign = 'center',
      visible = false,
    }
  }
  button:connect_signal("mouse::enter", function()
    button.children[2].visible = true;
  end);
  button:connect_signal("mouse::leave", function() 
    button.children[2].visible = false;
  end);

  return button;
end

function make_powermenu()
  local panelbg = gears.color({
    type = 'linear',
    from = { 0, 0 },
    to = { config.powermenu.w, config.powermenu.hh },
    stops = { { 0, config.colors.x4 }, { 1, config.colors.x12 } }
  });

  local splash = {};

  awful.screen.connect_for_each_screen(function(s)
    local layout = wibox.layout.manual();
    splash[s.index] = wibox({
      screen = s,
      ontop = true,
      visible = false,
      type = 'splash',
      widget = layout,
      width = s.geometry.width,
      bg = config.colors.b..'66',
      height = s.geometry.height,
    });
  end);

  local shutdown = make_button(config.icons.power, 'shutdown');
  local restart = make_button(config.icons.restart, 'restart');
  local suspend = make_button(config.icons.suspend, 'suspend');
  local logout = make_button(config.icons.logout, 'logout');
  local cancel = make_button(config.icons.close, 'cancel');
  local lock = make_button(config.icons.lock, 'lock');

  shutdown:buttons(gears.table.join(awful.button({}, 1, function() awful.spawn.with_shell(config.commands.shutdown) end)));
  restart:buttons(gears.table.join(awful.button({}, 1, function() awful.spawn.with_shell(config.commands.restart) end)));
  suspend:buttons(gears.table.join(awful.button({}, 1, function() awful.spawn.with_shell(config.commands.suspend) end)));
  logout:buttons(gears.table.join(awful.button({}, 1, function() awesome.quit() end)));
  cancel:buttons(gears.table.join(awful.button({}, 1, function() hide() end)));

  local avatar = wibox.widget.imagebox();
  avatar.image = config.global.user;
  avatar.resize = true;
  avatar.forced_width = config.powermenu.a;
  avatar.forced_height = config.powermenu.a;
  avatar:set_clip_shape(function(c) return gears.shape.circle(c,config.powermenu.a,config.powermenu.a) end);

  local user = wibox.widget.textbox();
  user.font = config.fonts.tlb;
  awful.spawn.easy_async_with_shell('whoami', function(u) user.text = u:gsub("^%s*(.-)%s*$", "%1") end);

  local prompt = wibox.widget { 
    layout = wibox.container.margin, 
    margins = config.global.m*2,
    visible = false,
  }

  local buttons = wibox.layout.flex.horizontal();

  local panel = wibox.widget {
    shape = rounded(),
    bg = config.colors.f,
    forced_width = config.powermenu.w,
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.container.background,
        bg = panelbg,
        {
          layout = wibox.container.margin,
          bottom = config.global.m*2,
          right = config.global.m*2,
          left = config.global.m*2,
          top = config.global.m*3,
          {
            layout = wibox.layout.fixed.vertical,
            {
              layout = wibox.container.place,
              valign = "center",
              avatar
            },
            {
              layout = wibox.container.margin,
              margins = config.global.m*2,
              { layout = wibox.container.place, user }
            },
            {
              layout = wibox.container.margin,
              top = config.global.m,
              buttons
            }
          }
        }
      },
      prompt,
    }
  }

  root.elements.powermenu.buttons = buttons;
  root.elements.powermenu.icon_shutdown = shutdown;
  root.elements.powermenu.icon_suspend = suspend;
  root.elements.powermenu.icon_restart = restart;
  root.elements.powermenu.icon_logout = logout;
  root.elements.powermenu.icon_cancel = cancel;
  root.elements.powermenu.icon_lock = lock;
  root.elements.powermenu.prompt = prompt;
  root.elements.powermenu.splash = splash;
  root.elements.powermenu.panel = panel;
  root.elements.powermenu.user = user;
end

return function()
  make_powermenu();
  root.elements.powermenu.lock = lock;
  root.elements.powermenu.show = show;
end
