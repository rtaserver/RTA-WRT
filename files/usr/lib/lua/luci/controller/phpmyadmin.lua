module("luci.controller.phpmyadmin", package.seeall)
function index()
entry({"admin","services","phpmyadmin"}, template("phpmyadmin"), _("PhpMyAdmin"), 3).leaf=true
end