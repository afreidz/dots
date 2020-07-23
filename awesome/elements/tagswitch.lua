local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local rounded = require('helpers.rounded');
local beautiful = require('beautiful');
local xrdb = beautiful.xresources.get_current_theme();
local config = require('helpers.config');

local m = config.global.m;
local b = config.colors.b;
local f = config.colors.f;
local f2 = config.colors.f;
local h = config.tagswitcher.h;
local tags = require('helpers.tags');

function toggle_tag_switcher()
  awful.screen.connect_for_each_screen(function(screen)
    screen.tagswitch.visible = not screen.tagswitch.visible;
  end);
end

function add_new_tag()
  local total = root.tags();

  if(#total >= 10) then return end;
  awful.tag.add(tags[#total+1], {
    screen = awful.screen.focused(),
    layout = awful.screen.focused().selected_tag.layout,
  });

  local stags = awful.screen.focused().tags;
  local switcher = awful.screen.focused().tagswitch;
  switcher.width = ((100+m) * (#stags+1)) + m;
  switcher.x = switcher.x - 55;
end

function delete_tag(t)
  t:delete();
  local stags = awful.screen.focused().tags;
  local switcher = awful.screen.focused().tagswitch;
  switcher.width = ((100+m) * (#stags+1)) + m;
  if(#stags == 1) then return end;
  switcher.x = switcher.x + 55;
end

function make_taglist(s)
  local w = ((100+m) * (#s.tags+1)) + m;
  local container = wibox({
    height = h,
    width = w,
    type = "toolbar",
    screen = s,
    ontop = true,
    visible = false,
    bg = f,
    fg = b,
  });

  local buttons = gears.table.join(
    awful.button({ 'Mod4' }, 1, function(t) t:view_only() end)
    --awful.button({ 'Mod4' }, 3, delete_tag)
  );

  local taglist = awful.widget.taglist({
    screen = s,
    buttons = buttons,
    filter = awful.widget.taglist.filter.all,
    style = {
      fg_focus = config.colors.w,
      bg_focus = config.colors.x4,
      shape_focus = rounded(),
    },
    widget_template = {
      layout = wibox.container.margin,
      right = m,
      {
        id = "background_role",
        layout = wibox.container.background,
        bg = f2,
        shape = rounded(),
        forced_width = 100,
        forced_height = 100,
        {
          id = "text_role",
          widget = wibox.widget.textbox,
          font = "MaterialDesignIconsDesktop 40",
          align = 'center',
          valign = 'center',
        }
      }
    }
  });

  local add = wibox.container.background();
  add.bg = f2;
  add.forced_height = 100;
  add.forced_width = 100;
  add.shape = rounded();
  add:buttons(gears.table.join(
    awful.button({ 'Mod4' }, 1, add_new_tag)
  ));

  add:setup {
    widget = wibox.widget.textbox,
    text = "󱇬",
    font = "MaterialDesignIconsDesktop 15",
    align = 'center',
    valign = 'center',
  }

  container.x = ((s.workarea.width / 2) - w/2) + s.workarea.x;
  container.y = s.workarea.height - (h+m);
  container.shape = rounded();

  container:setup {
    layout = wibox.container.margin,
    top = m, bottom = m, left = m,
    {
      layout = wibox.layout.fixed.horizontal,
      taglist,
      add,
    }
  }

  return container;
end

return function()
  awful.screen.connect_for_each_screen(function(screen)
    screen.tagswitch = make_taglist(screen);
  end);

  awful.keygrabber {
    keybindings = {
      {{'Mod4'}, 'Tab', function() awful.tag.viewnext(awful.screen.focused()) end},
      {{'Mod4', 'Shift'}, 'Tab', function() awful.tag.viewprev(awful.screen.focused()) end}
    },
    stop_key = 'Mod4',
    stop_event = 'release',
    export_keybindings = true,
    start_callback = toggle_tag_switcher,
    stop_callback = toggle_tag_switcher,
  }
end