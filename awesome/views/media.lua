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
  
  local artist = wibox.widget.textbox();
  local song = wibox.widget.textbox();
  local album = wibox.widget.textbox();

  awful.spawn.easy_async_with_shell(config.commands.artist, function(o) artist.text = o end);
  awful.spawn.easy_async_with_shell(config.commands.song, function(o) song.text = o end);
  awful.spawn.easy_async_with_shell(config.commands.album, function(o) album.text = o end);
  awful.spawn.easy_async_with_shell(config.commands.art, function(o) album_art:set_image(gears.surface.load_uncached(config.media.cover)) end);

  local spotify_icon = wibox.widget.textbox(config.icons.spot);
  spotify_icon.font = config.fonts.tlb;
  spotify_icon:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn(config.commands.spotify) end)
  ));

  local play = wibox.widget.textbox(config.icons.play);
  play.font = config.fonts.txxlb;
  play:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn.easy_async_with_shell(config.commands.play, view.refresh) end)
  ));

  local next = wibox.widget.textbox(config.icons.next);
  next.font = config.fonts.txlb;
  next:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn.easy_async_with_shell(config.commands.next, view.refresh) end)
  ));

  local prev = wibox.widget.textbox(config.icons.prev);
  prev.font = config.fonts.txlb;
  prev:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn.easy_async_with_shell(config.commands.prev, view.refresh) end)
  ));

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
          forced_width = 100,
          forced_height = 100,
          album_art
        },
        {
          layout = wibox.layout.fixed.vertical,
          song,
          artist,
          album,
        }
      }
    },
    {
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
    }
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
    awful.button({}, 1, function() if root.hub then root.hub.close() end end)
  ));

  local heading = wibox.widget.textbox('Volume');
  heading.font = config.fonts.tlb;

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
    
    awful.spawn.easy_async_with_shell(config.commands.vol, function(o) 
      vol_slider:set_value(tonumber(o)); 
    end);

    awful.spawn.easy_async_with_shell(config.commands.ismuted, function(o,e,r,c) 
      if c == 0 then 
        vol_slider.bar_active_color = config.colors.b..'26';
        heading.markup = 'Volume <span font="'..config.fonts.tll..'">(muted)</span>';
        mute.text = config.icons.vol_mute 
      else 
        vol_slider.bar_active_color = config.colors.w;
        heading.text = 'Volume';
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
        forced_height = (config.global.m*6) + config.global.slider,
        {
          layout = wibox.layout.fixed.vertical,
          {
            layout = wibox.container.margin,
            margins = config.global.m,
            {
              layout = wibox.layout.align.horizontal,
              heading,
              nil,
              mute,
            }
          },
          {
            layout = wibox.container.margin,
            left = config.global.m,
            right = config.global.m,
            bottom = config.global.m,
            vol_slider
          }
        }
      },
      layout
    }
  }

  return view;
end