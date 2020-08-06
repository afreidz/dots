----------------------------------------------------------------------------
--- A notification app_name.
--
-- This widget is a specialized `wibox.widget.textbox` with the following extra
-- features:
--
-- * Honor the `beautiful` notification variables.
--
--
-- @author Andy Freidenfelds &lt;afreidenfelds@gmail.com&gt;
-- @copyright 2020 Andy Freidenfelds
-- @widgetmod naughty.widget.appname
-- @see wibox.widget.textbox
----------------------------------------------------------------------------
local gtable  = require("gears.table");
local beautiful = require("beautiful");
local textbox = require("wibox.widget.textbox");
local markup  = require("naughty.widget._markup").set_markup;
local appname = {};

function appname:set_notification(notif)
    if self._private.notification == notif then return end;

    markup(self, notif.app_name, notif.fg, notif.font);
    self._private.notification = notif;
    self:emit_signal("property::notification", notif);
end


local function new(args)
    args = args or {};
    local tb = textbox();
    tb:set_wrap("word");
    tb:set_font(beautiful.notification_font);

    gtable.crush(tb, appname, true);

    if args.notification then tb:set_notification(args.notification) end;

    return tb;
end

return setmetatable(appname, {__call = function(_, ...) return new(...) end});