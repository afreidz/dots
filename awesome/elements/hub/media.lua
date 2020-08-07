local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();
local saved_spotify_state = nil;

return function()
  local view = wibox.container.margin();
  view.left = config.global.m;
  view.right = config.global.m;

  local title = wibox.widget.textbox("Media");
  title.font = config.fonts.tlb;
  title.forced_height = config.hub.i + config.global.m + config.global.m;

  local close = wibox.widget.textbox(config.icons.close);
  close.font = config.fonts.il;
  close.forced_height = config.global.slider;
  close:buttons(gears.table.join(
    awful.button({}, 1, function() if root.elements.hub then root.elements.hub.close() end end)
  ));

  local vol_heading = wibox.widget.textbox('Volume');
  vol_heading.font = config.fonts.tlb;

  local vol_footer = wibox.widget.textbox('test');
  vol_footer.font = config.fonts.tsl;
  vol_footer.align = 'right';

  local mic_footer = wibox.widget.textbox('test');
  mic_footer.font = config.fonts.tsl;
  mic_footer.align = 'right';

  local vol_slider = wibox.widget.slider();
  vol_slider.bar_shape = function(c,w,h) gears.shape.rounded_rect(c,w,h,config.global.slider/2) end;
  vol_slider.bar_height = config.global.slider;
  vol_slider.bar_color = config.colors.b..'26';
  vol_slider.bar_active_color = config.colors.w;
  vol_slider.handle_shape = gears.shape.circle;
  vol_slider.handle_width = config.global.slider;
  vol_slider.handle_color = config.colors.w;
  vol_slider.handle_border_width = 1;
  vol_slider.handle_border_color = config.colors.x7;
  vol_slider.minimum = 0;
  vol_slider.maximum = 100;
  vol_slider:connect_signal('property::value', function()
    awful.spawn.with_shell(config.commands.setvol..tostring(vol_slider.value));
  end);

  local mute = wibox.widget.textbox();
  mute.font = config.fonts.tlb;

  local album_icon = wibox.widget.imagebox();
  album_icon.clip_shape = rounded();
  album_icon.forced_height = 140;
  album_icon.forced_width = 140;
  album_icon.resize = true;

  local spotify_icon = wibox.widget {
    layout = wibox.container.background,
    bg = config.colors.w,
    forced_height = 140,
    forced_width = 140,
    shape = rounded(),
    {
      layout = wibox.container.place,
      valign = "center",
      halign = "center",
      {
        widget = wibox.widget.textbox,
        font = config.fonts.i..' 70',
        text = config.icons.spot,
      }
    }
  };

  local icon = spotify_icon;
  
  local spotify_title = wibox.widget.textbox('Nothing playing');
  local spotify_message = wibox.widget.textbox('');
  spotify_message.font = config.fonts.tml;
  spotify_title.font = config.fonts.tlb;

  local play = wibox.widget.textbox();
  play.font = config.fonts.txxlb;
  play.text = config.icons.play;
  play:buttons(gears.table.join(
    awful.button({}, 1, function() 
      awful.spawn.with_shell(config.commands.play);
    end)
  ));
  play:connect_signal('mouse::enter', function()
    play.markup = '<span foreground="'..config.colors.x4..'">'..play.text..'</span>';
  end);
  play:connect_signal('mouse::leave', function()
    play.text = play.text;
  end);

  local next = wibox.widget.textbox(config.icons.next);
  next.font = config.fonts.txxlb;
  next:buttons(gears.table.join(
    awful.button({}, 1, function() 
      awful.spawn.with_shell(config.commands.next);
    end)
  ));
  next:connect_signal('mouse::enter', function()
    next.markup = '<span foreground="'..config.colors.x4..'">'..next.text..'</span>';
  end);
  next:connect_signal('mouse::leave', function()
    next.text = next.text;
  end);

  local prev = wibox.widget.textbox(config.icons.prev);
  prev.font = config.fonts.txxlb;
  prev:buttons(gears.table.join(
    awful.button({}, 1, function() 
      awful.spawn.with_shell(config.commands.prev);
    end)
  ));
  prev:connect_signal('mouse::enter', function()
    prev.markup = '<span foreground="'..config.colors.x4..'">'..prev.text..'</span>';
  end);
  prev:connect_signal('mouse::leave', function()
    prev.text = prev.text;
  end);

  local spotify = wibox.layout.align.horizontal();
  spotify.third = nil;
  spotify.first = icon;
  spotify.second = wibox.widget {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.container.margin,
      left = config.global.m,
      {
        layout = wibox.layout.fixed.vertical,
        { layout = wibox.container.constraint, spotify_title },
        { layout = wibox.container.constraint, spotify_message },
      }
    },
    nil,
    {
      layout = wibox.layout.flex.horizontal,
      { layout = wibox.container.place, halign = 'right', prev },
      { layout = wibox.container.place, play },
      { layout = wibox.container.place, halign = 'left', next },
    }
  };

  awful.spawn.easy_async_with_shell(config.commands.song, function(o)
    spotify_title.text = o:gsub("^%s*(.-)%s*$", "%1");
  end);

  awful.spawn.easy_async_with_shell(config.commands.artist, function(o)
    spotify_message.text = o:gsub("^%s*(.-)%s*$", "%1");
  end);

  awful.widget.watch(config.commands.spotify_state, 1, function(w,o,e,r,c)
    local cmdstate = {}
    o:gsub("[^\r\n]+", function(m) table.insert(cmdstate, m) end);
    local i = gears.table.find_first_key(naughty.active, function(k,v) return v.app_name == 'Spotify' end);
    local spotify_state = naughty.active[i];
    
    if spotify_state then saved_spotify_state = spotify_state end;
    if not spotify_state and saved_spotify_state then spotify_state = saved_spotify_state end;

    play.text = (cmdstate[1] == 'not playing') and config.icons.play or config.icons.pause;
    
    if spotify_state and spotify_title.text ~= spotify_state.title then
      album_icon:set_image(gears.surface.load_silently(spotify_state.icon));
      spotify.first = album_icon;
      spotify_title.text = spotify_state.title;
      spotify_message.text = spotify_state.message;
    elseif not spotify_state then
      spotify.first = spotify_icon;
      spotify_title.text = cmdstate[2] or 'Nothing Playing';
      spotify_message.text = cmdstate[3] or '';
    end;    
  end);

  view.refresh = function()
    local temp_vol = vol_slider.value;
    
    awful.spawn.easy_async_with_shell(config.commands.audiosrc, function(o)
      if o then vol_footer.markup = 'Output: <span font="'..config.fonts.tsb..'">'..o:gsub("^%s*(.-)%s*$", "%1")..'</span>' end;
    end);
    
    awful.spawn.easy_async_with_shell(config.commands.micsrc, function(o,e)
      if o then mic_footer.markup = 'Input: <span font="'..config.fonts.tsb..'">'..o:gsub("^%s*(.-)%s*$", "%1")..'</span>' end;
    end);
    
    awful.spawn.easy_async_with_shell(config.commands.vol, function(o) 
      vol_slider:set_value(tonumber(o)); 
    end);
    
    awful.spawn.easy_async_with_shell(config.commands.ismuted, function(o,e,r,c) 
      if c == 0 then 
        vol_slider.bar_active_color = config.colors.b..'26';
        vol_heading.markup = 'Volume <span font="'..config.fonts.tll..'">(muted)</span>';
        mute.text = config.icons.vol_mute 
      else 
        vol_slider.bar_active_color = config.colors.w;
        vol_heading.text = 'Volume';
        mute.text = config.icons.vol_1 
      end;
    end);
  end
  
  mute:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn.easy_async_with_shell(config.commands.mute, view.refresh);
    end)
  ));
  
  view:setup {
    layout = wibox.container.background,
    fg = config.colors.xf,
    {
      layout = wibox.layout.fixed.vertical,
      spacing = config.global.m,
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
        layout = wibox.container.background,
        bg = config.colors.f,
        shape = rounded(),
        {
          layout = wibox.layout.fixed.vertical,
          {
            layout = wibox.container.margin,
            margins = config.global.m,
            {
              layout = wibox.layout.align.horizontal,
              vol_heading,
              nil,
              mute,
            }
          },
          {
            layout = wibox.container.margin,
            left = config.global.m,
            right = config.global.m,
            bottom = config.global.m,
            forced_height = config.global.slider + (config.global.m*2),
            vol_slider
          },
          {
            layout = wibox.container.margin,
            left = config.global.m,
            right = config.global.m,
            vol_footer,
          },
          {
            layout = wibox.container.margin,
            left = config.global.m,
            right = config.global.m,
            bottom = config.global.m,
            mic_footer,
          }
        }
      },
      {
        layout = wibox.container.background,
        bg = config.colors.f,
        shape = rounded(),
        forced_width = (config.hub.w - config.hub.nw) - (config.global.m*2),
        {
          layout = wibox.container.margin,
          margins = config.global.m,
          spotify
        }
      }
    }
  }

  return view;
end