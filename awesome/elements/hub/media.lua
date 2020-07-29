local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

function make_spotify(view)
  local spot = wibox.container.background()
  spot.bg = config.colors.f;
  spot.shape = rounded();
  
  local album_art = wibox.widget.imagebox();
  album_art.resize = true;
  album_art.shape = rounded();
  album_art.clip_shape = rounded();

  local no_album = wibox.widget.textbox(config.icons.spot);
  no_album.font = config.fonts.i..' 50';
  no_album:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn.raise_or_spawn(config.commands.spotify) end)
  ));

  local artist = wibox.widget.textbox();
  local song = wibox.widget.textbox();
  local album = wibox.widget.textbox();
  song.font = config.fonts.tlb;
  song.forced_height = 20;
  artist.font = config.fonts.tmb;
  artist.forced_height = 20;
  album.font = config.fonts.tml;
  album.forced_height = 20;

  local play_pause_action = config.commands.play;

  local spotify_icon = wibox.widget.textbox(config.icons.spot);
  spotify_icon.font = config.fonts.tlb;
  spotify_icon:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn.raise_or_spawn(config.commands.spotify) end)
  ));

  local play = wibox.widget.textbox();
  play.font = config.fonts.txxlb;
  play:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn.easy_async_with_shell(play_pause_action, view.refresh) end)
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
    awful.button({}, 1, function() awful.spawn.easy_async_with_shell(config.commands.next, view.refresh) end)
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
    awful.button({}, 1, function() awful.spawn.easy_async_with_shell(config.commands.prev, view.refresh) end)
  ));
  prev:connect_signal('mouse::enter', function()
    prev.markup = '<span foreground="'..config.colors.x4..'">'..prev.text..'</span>';
  end);
  prev:connect_signal('mouse::leave', function()
    prev.text = prev.text;
  end);

  local controls = wibox.widget {
    layout = wibox.container.margin,
    margins = config.global.m,
    {
      layout = wibox.layout.flex.horizontal,
      {
        layout = wibox.container.place,
        halign = 'right',
        valign = 'center',
        prev
      },
      {
        layout = wibox.container.place,
        halign = 'center',
        valign = 'center',
        play
      },
      {
        layout = wibox.container.place,
        halign = 'left',
        valign = 'center',
        next
      },
    }
  };

  awful.spawn.easy_async_with_shell(config.commands.song, function(o,e)
    if e ~= '' then
      song.text = "Nothing"
      artist.text = "Nobody";
      album.text = "";
      controls.visible = false;
      return
    end 
    artist.text = o;
    awful.spawn.easy_async_with_shell(config.commands.isplaying, function(o,e,a,c)
      if c == 0 then 
        play.text = config.icons.pause;
        play_pause_action = config.commands.pause;
      else
        play.text = config.icons.play;
        play_pause_action = config.commands.play;
      end 
    end);
    awful.spawn.easy_async_with_shell(config.commands.song, function(o) song.text = o end);
    awful.spawn.easy_async_with_shell(config.commands.album, function(o) album.text = o end);
    awful.spawn.easy_async_with_shell(config.commands.art, function(o)
      album_art:set_image(gears.surface.load_uncached(o:gsub("^%s*(.-)%s*$", "%1"))); 
    end);
  end);

  


  spot:setup {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.container.margin,
      margins = config.global.m,
      {
        layout = wibox.layout.align.horizontal,
        {
          widget = wibox.widget.textbox,
          text = 'Now Playing',
          font = config.fonts.tlb,
        },
        nil,
        spotify_icon,
      }
    },
    {
      layout = wibox.container.margin,
      left = config.global.m,
      right = config.global.m,
      bottom = config.global.m,
      {
        layout = wibox.layout.align.horizontal,
        {
          layout = wibox.container.background,
          shape = rounded(),
          forced_width = 100,
          forced_height = 100,
          fg = config.colors.b..'40',
          bg = config.colors.b..'40',
          {
            layout = wibox.layout.stack,
            { layout = wibox.container.place, valign = "center", no_album },
            album_art,
          }
        },
        {
          layout = wibox.container.margin,
          margins = config.global.m,
          {
            layout = wibox.layout.fixed.vertical,
            { layout = wibox.container.background, song },
            { layout = wibox.container.background, artist },
            { layout = wibox.container.background, album },
          }
        }
      }
    },
    controls
  }
  
  return wibox.widget {
    layout = wibox.container.margin,
    top = config.global.m,
    spot
  };
end

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

  local layout = wibox.layout.flex.horizontal();
  layout:add(make_spotify(view));

  view.refresh = function()
    local temp_vol = vol_slider.value;

    layout:set(1, make_spotify(view));

    awful.spawn.easy_async_with_shell(config.commands.audiosrc, function(o)
      vol_footer.markup = 'Output: <span font="'..config.fonts.tsb..'">'..o:gsub("^%s*(.-)%s*$", "%1")..'</span>';
    end);

    awful.spawn.easy_async_with_shell(config.commands.micsrc, function(o,e)
      mic_footer.markup = 'Input: <span font="'..config.fonts.tsb..'">'..o:gsub("^%s*(.-)%s*$", "%1")..'</span>';
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
    fg = config.colors.b,
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
      layout
    }
  }

  return view;
end