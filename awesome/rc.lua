local os = require('os');
local gears = require('gears');
local awful = require('awful');
local wibox = require('wibox');
local ruled = require('ruled');
local naughty = require('naughty');
local vars = require('helpers.vars');
local beautiful = require('beautiful');
require('./errors')();

-- PLACEHOLDERS
local hub = nil;
local topbar = nil;
local tagswitcher = nil;
local lockscreen = nil;

-- THEME
beautiful.useless_gap = 5;

-- MODKEY
modkey = 'Mod4';

-- APPS
browser = "brave-beta";
editor = "code";
terminal = "urxvt";
files = "nautilus";
rofi = "rofi -show drun -theme config-global"; 

-- LAYOUTS
tag.connect_signal('request::default_layouts', function()
	awful.layout.append_default_layouts({
		awful.layout.suit.tile,
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.floating
	});
end);

-- TAGS/LAYOUTS
local tags = require('helpers.tags');
screen.connect_signal('request::desktop_decoration', function(s)
	if s.index == 1 then
		awful.tag({ tags[1], tags[2] }, s, awful.layout.layouts[1]);
	else
		awful.tag({ tags[3], tags[4] }, s, awful.layout.layouts[1]);
	end
	s.tags[1]:view_only();
end);

--GLOBAL KEYBINDS/BUTTONS
awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "Return", function() awful.spawn(terminal) end),
	awful.key({ modkey }, "c", function() awful.spawn(editor) end),
	awful.key({ modkey }, "w", function() awful.spawn(browser) end),
	awful.key({ modkey }, "f", function() awful.spawn(files) end),
	awful.key({ modkey }, "space", function() awful.spawn(rofi) end),
	
	awful.key({ modkey, "Shift" }, "r", function() if lockscreen then lockscreen.lock(awesome.restart) end end),
	awful.key({ modkey, "Shift" }, "q", function() awesome.quit() end),
	awful.key({ modkey, "Shift" }, "l", function() if lockscreen then lockscreen.lock() end end),
	
	awful.key({ modkey }, "Left", function() awful.client.focus.byidx(-1) end),
	awful.key({ modkey }, "Right", function() awful.client.focus.byidx(1) end),
	awful.key({ modkey, "Shift" }, "Left", function() awful.client.swap.byidx(1) end),
	awful.key({ modkey, "Shift" }, "Right", function() awful.client.swap.byidx(-1) end),
	
	-- Resize
	awful.key({ modkey }, "]", function() awful.tag.incmwfact(0.05) end),
	awful.key({ modkey }, "[", function() awful.tag.incmwfact(-0.05) end), 
	awful.key({ modkey, "Shift" }, "]", function() awful.tag.incmwfact(0.01) end),
	awful.key({ modkey, "Shift" }, "[", function() awful.tag.incmwfact(-0.01) end)
});


-- TAG KEYBINDS
for i = 0, 9 do
	local spot = i;
	if(spot == 0) then spot = 10 end
	
	awful.keyboard.append_global_keybindings({
		awful.key({ modkey }, spot, function()
			local tag = root.tags()[i];
			if tag then tag:view_only() end;
		end),
		awful.key({ modkey, 'Control'}, spot, function()
			local tag = root.tags()[i];
			if tag then client.focus:move_to_tag(tag) end;
		end)
	});
end

awful.mouse.append_global_mousebindings({
	awful.button({}, 1, function() if hub then hub.close() end end),
	awful.button({}, 3, function()
		local s = awful.screen.focused();
		local h = s.hub
		h.visible = true;
		h.enable_view_by_index(1);
		h.x = (s.workarea.width - vars.hub.w - vars.global.m) + s.workarea.x;		
	end)
});

-- CLIENT KEYBINDS & BUTTONS
client.connect_signal("request::default_keybindings", function(c)
	awful.keyboard.append_client_keybindings({
		awful.key({ modkey }, "q", function (c) c.kill(c) end),
		awful.key({ modkey, "Control" }, "Right", function(c) c:move_to_screen(c.screen.index+1) end),
		awful.key({ modkey, "Control" }, "Left", function(c) c:move_to_screen(c.screen.index-1) end)
	});
end);

client.connect_signal("request::default_mousebindings", function(c)
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function (c)
			if hub then hub.close() end
			c:activate { context = "mouse_click";
		} end),
		awful.button({ modkey }, 1, function (c) c:activate { context = "mouse_click", action = "mouse_move" } end)
	});
end);

-- RULES
ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rule {
		id = 'global',
		rule = { },
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			size_hints_honor = false,
			placement = awful.placement.no_offscreen
		}
	}
end);

client.connect_signal("manage", function(c) 
	c.shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,5) end
end);

-- SPAWNS
awful.spawn.with_shell("$HOME/.config/awesome/startup/wall.sh");
awful.spawn.with_shell("$HOME/.config/awesome/startup/compositor.sh");
-- awful.spawn.with_shell("$HOME/.config/awesome/startup/lockscreenbg.sh");

-- WIDGETS
hub = require('elements.hub')();
topbar = require('elements.topbar')();
tagswitcher = require('elements.tagswitch')();
lockscreen = require('elements.lockscreen')();

awful.spawn.with_line_callback(vars.commands.idle, {
  stdout = function() lockscreen.lock() end
});

os.execute('sleep 0.1');
topbar.show();