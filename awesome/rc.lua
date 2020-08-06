local os = require('os');
local gears = require('gears');
local awful = require('awful');
local wibox = require('wibox');
local ruled = require('ruled');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
require('./errors')();

-- ELEMENT STORE
root.elements = root.elements or {};

-- THEME
beautiful.useless_gap = 5;

-- MODKEY
modkey = 'Mod4';

-- LAYOUTS
tag.connect_signal('request::default_layouts', function()
	awful.layout.append_default_layouts({
		awful.layout.suit.tile,
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.floating
	});
end);

-- TAGS/LAYOUTS
screen.connect_signal('request::desktop_decoration', function(s)
	if s.index == 1 then
		awful.tag({1,2,3}, s, awful.layout.layouts[1]);
	else
		awful.tag({4,5,6}, s, awful.layout.layouts[1]);
	end
	s.tags[1]:view_only();
end);

--GLOBAL KEYBINDS/BUTTONS
awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "Return", function() awful.spawn(config.commands.terminal) end),
	awful.key({ modkey }, "c", function() awful.spawn(config.commands.editor) end),
	awful.key({ modkey }, "b", function() awful.spawn(config.commands.browser) end),
	awful.key({ modkey }, "f", function() awful.spawn(config.commands.files) end),
	awful.key({ modkey }, "space", function() awful.spawn(config.commands.rofi) end),
	
	-- awful.key({ modkey, "Shift" }, "r", awesome.restart),
	awful.key({ modkey, "Shift" }, "q", function() awesome.quit() end),
	awful.key({ modkey, "Shift" }, "l", function() if root.elements.powermenu then root.elements.powermenu.lock() end end),
	awful.key({ modkey, "Shift" }, "p", function() awful.spawn(config.commands.scrot) end),
	awful.key({ modkey, "Shift" }, "r", function() if root.elements.powermenu then root.elements.powermenu.lock(awesome.restart) end end),
	
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
	if(spot == 10) then spot = 0 end
	
	awful.keyboard.append_global_keybindings({
		awful.key({ modkey }, spot, function()
			local tag = root.tags()[i];
			if tag then tag:view_only() end;
		end),
		awful.key({ modkey, 'Control'}, spot, function()
			local tag = root.tags()[i];
			if tag and client.focus then client.focus:move_to_tag(tag) end;
		end)
	});
end

awful.mouse.append_global_mousebindings({
	awful.button({}, 1, function()
		if root.elements.hub then root.elements.hub.close() end 
	end),
	awful.button({}, 3, function()
		root.elements.hub.enable_view_by_index(5, mouse.screen);
	end)
});

-- CLIENT KEYBINDS & BUTTONS
client.connect_signal("request::default_keybindings", function(c)
	awful.keyboard.append_client_keybindings({
		awful.key({ modkey }, "q", function (c) c.kill(c) end),
		awful.key({ modkey, "Control" }, "Right", function(c) c:move_to_screen(c.screen.index+1) end),
		awful.key({ modkey, "Control" }, "Left", function(c) c:move_to_screen(c.screen.index-1) end),
		awful.key({ modkey, "Control" }, "f", function(c) c.fullscreen = not c.fullscreen end),
		awful.key({ modkey, "Shift" }, "f", function(c) c.floating = not c.floating end)
	});
end);

client.connect_signal("request::default_mousebindings", function(c)
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function (c)
			if root.elements.hub then root.elements.hub.close() end
			c:activate { context = "mouse_click", raise = true } 
		end),
		awful.button({ modkey }, 1, function (c) 
			c.floating = true;
			c:activate { context = "mouse_click", action = "mouse_move" } 
		end),
		awful.button({ modkey }, 3, function (c) 
			c:activate { context = "mouse_click", action = "mouse_resize" } 
		end)
	});
end);

-- RULES
ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rule {
		id = 'global',
		rule = { },
		properties = {
			raise = true,
			switch_to_tags = true,
			size_hints_honor = false,
			screen = awful.screen.preferred,
			focus = awful.client.focus.filter,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen,
		}
	}
	ruled.client.append_rule {
		id = 'code',
		rule = { class = 'Code' },
		properties = { 
			floating = false,
			tag = screen[2].tags[1] or screen.primary.tags[1],
		}
	}
	ruled.client.append_rule {
		id = 'browser',
		rule = { role = 'browser' },
		properties = { 
			floating = false,
			fullscreen = false,
			maximized = false,
			size_hints_honor = false,
		}
	}
	ruled.client.append_rule {
		id = 'files',
		rule = { role = 'GtkFileChooserDialog' },
		properties = { 
			floating = true,
			placement = awful.placement.centered,
			size_hints_honor = true,
		}
	}
	ruled.client.append_rule {
		id = 'files',
		rule = { type = 'dialog' },
		properties = { 
			floating = true,
			placement = awful.placement.centered,
			size_hints_honor = true,
		}
	}
	ruled.client.append_rule {
		id = 'files',
		rule = { class = 'Nitrogen' },
		properties = { 
			floating = true,
			placement = awful.placement.centered,
			size_hints_honor = true,
		}
	}
	ruled.client.append_rule {
		id = 'files',
		rule = { class = 'Org.gnome.Nautilus' },
		properties = { 
			floating = true,
			placement = awful.placement.centered,
			size_hints_honor = true,
		}
	}
end);

-- NOTIFICATIONS
ruled.notification.connect_signal('request::rules', function()
	ruled.notification.append_rule {
		rule = {},
		properties = { timeout = 0 }
	}
end);

-- SPAWNS
awful.spawn.with_shell("$HOME/.config/awesome/scripts/screen.sh");
awful.spawn.with_shell("$HOME/.config/awesome/scripts/wallpaper.sh");
awful.spawn.with_shell("$HOME/.config/awesome/scripts/compositor.sh");

-- ELEMENTS
if not root.elements.hub then require('elements.hub')() end;
if not root.elements.topbar then require('elements.topbar')() end;
if not root.elements.tagswitcher then require('elements.tagswitch')() end;
if not root.elements.powermenu then require('elements.powermenu')() end;

-- IDLE
awful.spawn.with_line_callback(config.commands.idle, {
	stdout = function(o)
		if o == 'lock' and root.elements.powermenu then  
			root.elements.powermenu.lock();
		elseif o == 'suspend' then
			awful.spawn(config.commands.suspend);
		end
	end
});

os.execute('sleep 0.1');
if root.elements.topbar then root.elements.topbar.show() end;