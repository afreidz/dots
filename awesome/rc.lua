local gears = require('gears');
local awful = require('awful');
local wibox = require('wibox');
local naughty = require('naughty');
local vars = require('helpers.vars');
local beautiful = require('beautiful');

local hub = require('./hub')();
require('awful.autofocus');
require('./errors')();

-- THEME
beautiful.useless_gap = 5;

-- MODKEY
modkey = 'Mod4';

-- SPAWNS
awful.spawn.with_shell("$HOME/.config/awesome/startup/wall.sh");
awful.spawn.with_shell("$HOME/.config/awesome/startup/compositor.sh");
awful.spawn.with_shell("$HOME/.config/awesome/startup/screenlock.sh");


-- APPS
browser = "brave-beta";
editor = "code";
terminal = "urxvt";
files = "thunar";
rofi = "rofi -show drun -theme config-global"; 

-- LAYOUTS
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.floating
};


-- TAGS/LAYOUTS
local tags = require('helpers.tags');
awful.screen.connect_for_each_screen(function(s)	
	if s.index == 1 then
		awful.tag({ tags[1], tags[2] }, s, awful.layout.layouts[1]);
	else
		awful.tag({ tags[3], tags[4] }, s, awful.layout.layouts[1]);
	end
	s.tags[1]:view_only();
	s.hub = hub;
end);

-- HELPERS
function closehubs()
	awful.screen.connect_for_each_screen(function(s) s.hub.visible = false end);
end


-- GLOBAL KEYBINDS/BUTTONS
local keys = gears.table.join(

	awful.key({ modkey }, "Return", function() awful.spawn(terminal, { tag = mouse.screen.selected_tag }) end),
	awful.key({ modkey }, "c", function() awful.spawn(editor, { tag = mouse.screen.selected_tag }) end),
	awful.key({ modkey }, "w", function() awful.spawn(browser, { tag = mouse.screen.selected_tag }) end),
	awful.key({ modkey }, "f", function() awful.spawn(files, { tag = mouse.screen.selected_tag }) end),
	awful.key({ modkey }, "space", function() awful.spawn(rofi, { tag = mouse.screen.selected_tag }) end),
	
	awful.key({ modkey, "Shift" }, "r", awesome.restart),
	awful.key({ modkey, "Shift" }, "q", awesome.quit),
	
	awful.key({ modkey }, "Left", function() awful.client.focus.byidx(-1) end),
	awful.key({ modkey }, "Right", function() awful.client.focus.byidx(1) end),
	awful.key({ modkey, "Shift" }, "Left", function() awful.client.swap.byidx(1) end),
	awful.key({ modkey, "Shift" }, "Right", function() awful.client.swap.byidx(-1) end),
	
	-- Resize
	awful.key({ modkey }, "]", function() awful.tag.incmwfact(0.05) end),
	awful.key({ modkey }, "[", function() awful.tag.incmwfact(-0.05) end), 
	awful.key({ modkey, "Shift" }, "]", function() awful.tag.incmwfact(0.01) end),
	awful.key({ modkey, "Shift" }, "[", function() awful.tag.incmwfact(-0.01) end)
);

-- TAG KEYBINDS
for i = 0, 9 do
	local spot = i;
	if(spot == 0) then spot = 10 end
	
	keys = gears.table.join(keys,
		awful.key({ modkey }, spot, function()
			local tag = root.tags()[i];
			if tag then tag:view_only() end;
		end),
		awful.key({ modkey, 'Control'}, spot, function()
			local tag = root.tags()[i];
			if tag then client.focus:move_to_tag(tag) end;
		end)
	);
end

local buttons = gears.table.join(
	awful.button({ }, 1, function() closehubs() end),
	awful.button({ }, 3, function()
		local s = awful.screen.focused();
		local h = s.hub
		h.visible = true;
		h.enable_view_by_index(1);
		h.x = (s.workarea.width - vars.hub.w - vars.global.m) + s.workarea.x;
	end)
);

root.keys(keys);
root.buttons(buttons); -- apply them


-- CLIENT KEYBINDS & BUTTONS
clientkeys = gears.table.join(
	awful.key({ modkey }, "q", function (c) c.kill(c) end),
	awful.key({ modkey, "Control" }, "Right", function(c) c:move_to_screen(c.screen.index+1) end),
	awful.key({ modkey, "Control" }, "Left", function(c) c:move_to_screen(c.screen.index-1) end)
);

clientbtns = gears.table.join(
	awful.button({ }, 1, function (c)
		closehubs();
		client.focus = c;
		c:raise();
	end)
);

-- RULES
awful.rules.rules = {
	{
		rule = { },
		properties = {
			focus = true,
			keys = clientkeys,
			buttons = clientbtns,
			size_hints_honor = false,
		}
	}
};

client.connect_signal("manage", function(c) 
	c.shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,5) end
end);

-- WIDGETS
require('./topbar');
require('./tagswitch');