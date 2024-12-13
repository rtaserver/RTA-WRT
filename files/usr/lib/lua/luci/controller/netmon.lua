module("luci.controller.netmon", package.seeall)
function index()
entry({"admin","status","netmon"}, template("netmon"), _("NetMonitor"), 7).leaf=true
end