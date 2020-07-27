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

local locker = {
  prompt = nil,
  panel = nil,
  splash = nil,
  open = false,
  callback = nil,
};

function unlock(pwd)
  if pam.auth_current_user(pwd) and locker.splash.widget then
    locker.panel.layout:remove_widgets(locker.prompt.widget);
    locker.splash.widget.visible = false;
    locker.open = false;
    if locker.callback then
      locker.callback();
      locker.callback = nil;
    else
      for s in screen do s.tags[1].selected = true end;
      if root.elements.topbar then root.elements.topbar.show() end;
      if mouse.current_client then mouse.current_client:raise() end;
    end
  else
    return prompt();
  end
end

function lock(cb)
  local s = mouse.screen;

  if locker.panel.widget and locker.splash.layout then
    locker.splash.layout:move_widget(locker.panel.widget, {
      x = ((s.geometry.width/2) - config.lock.w/2) + s.geometry.x,
      y = ((s.geometry.height/2) - config.lock.h/2) + s.geometry.y,
    });
  end

  for s in screen do s.selected_tag.selected = false end;
  if root.elements.topbar then root.elements.topbar.hide() end;
  if root.elements.hub then root.elements.hub.visible = false end;
  if locker.splash.widget then locker.splash.widget.visible = true end;
  if cb then locker.callback = cb end;
end

function mask(b,a)
  return b:gsub('.','•'),a;
end

function reset()
  if locker.panel and locker.prompt then 
    locker.panel.button.text = config.icons.lock;
    locker.panel.layout:remove_widgets(locker.prompt.widget);
    locker.open = false;
  end
end

function prompt()
  if locker.open == true then return end

  locker.open = true;
  reset();

  locker.prompt = make_prompt();
  locker.panel.layout:add(locker.prompt.widget);

  locker.panel.button.text = config.icons.unlock;

  awful.prompt.run {
    textbox = locker.prompt.textbox,
    bg_cursor = config.colors.b,
    font = config.fonts.txlb,
    prompt = '',
    exe_callback = unlock,
    done_callback = reset,
    highlighter = mask,
  }
end

function make_splash()
  local h = 0;
  local w = 0;

  awful.screen.connect_for_each_screen(function(s)
    h = h + s.geometry.height;
    w = w + s.geometry.width;
  end);

  local layout = wibox.layout.manual();
  
  local box = wibox({
    type = 'splash',
    bg = config.colors.t,
    width = w, height = h,
    x = 0, y = 0,
    ontop = true,
    visible = false,
    widget = layout,
  });

  return { widget = box, layout = layout };
end

function make_panel()
  local headerbg = gears.color({
    type = 'linear',
    from = { 0, 0 },
    to = { config.lock.w, config.lock.hh },
    stops = { { 0, config.colors.x4 }, { 1, config.colors.x12 } }
  });

  local panel = wibox.container.background();
  panel.forced_width = config.lock.w;
  panel.foced_height = config.lock.h;
  panel.bg = config.colors.f;
  panel.shape = rounded();

  local header = wibox.container.background();
  header.bg = headerbg;

  local avatar = wibox.widget.imagebox();
  avatar.image = config.global.user;
  avatar.resize = true;
  avatar.forced_width = config.lock.a;
  avatar.forced_height = config.lock.a;
  avatar:set_clip_shape(function(c) return gears.shape.circle(c,config.lock.a,config.lock.a) end);
  
  local user = wibox.widget.textbox();
  user.font = config.fonts.tlb;
  awful.spawn.easy_async_with_shell('whoami', function(u) user.text = u:gsub("^%s*(.-)%s*$", "%1") end);

  local pbutton = wibox.widget.textbox(config.icons.lock);
  pbutton.font = config.fonts.txxlb;
  pbutton:buttons(gears.table.join(
    awful.button({}, 1, function() prompt() end)
  ));

  header:setup {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.container.margin,
      top = config.global.m*4,
      { layout = wibox.container.place, avatar }
    },
    {
      layout = wibox.container.margin,
      top = config.global.m,
      bottom = config.global.m*2,
      { layout = wibox.container.place, user }
    },
    {
      layout = wibox.container.margin,
      bottom = config.global.m*2,
      { layout = wibox.container.place, pbutton }
    }
  };

  local layout = wibox.layout.fixed.vertical();
  layout:add(header);

  panel:setup {
    layout = wibox.container.margin,
    layout
  };

  return { widget = panel, layout = layout, button = pbutton }
end

function make_prompt()
  local prompt = wibox.widget.textbox();
  
  local prompt_container = wibox.container.margin();
  prompt_container.margins = config.global.m;
  
  prompt_container:setup {
    layout = wibox.container.background,
    bg = config.colors.f,
    fg = config.colors.b,
    shape = rounded(),
    { layout = wibox.container.margin, margins = config.global.m, prompt }
  };

  return { textbox = prompt, widget = prompt_container }
end

return function()
  locker.lock = lock;
  locker.panel = make_panel();
  locker.splash = make_splash();
  locker.splash.layout:add_at(locker.panel.widget, { x = 10, y = 10});

  root.elements.lockscreen = locker;
end
