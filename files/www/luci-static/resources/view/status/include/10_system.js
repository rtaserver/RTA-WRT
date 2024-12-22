'use strict';'require baseclass';'require fs';'require rpc';var callLuciVersion=rpc.declare({object:'luci',method:'getVersion'});var callSystemBoard=rpc.declare({object:'system',method:'board'});var callSystemInfo=rpc.declare({object:'system',method:'info'});return baseclass.extend({title:_('System'),load:function(){return Promise.all([L.resolveDefault(callSystemBoard(),{}),L.resolveDefault(callSystemInfo(),{}),L.resolveDefault(callLuciVersion(),{revision:_('unknown version'),branch:'LuCI'})]);},render:function(data){var boardinfo=data[0],systeminfo=data[1],luciversion=data[2];luciversion=luciversion.branch+' '+luciversion.revision;var datestr=null;if(systeminfo.localtime){var date=new Date(systeminfo.localtime*1000);datestr='%04d-%02d-%02d %02d:%02d:%02d'.format(date.getUTCFullYear(),date.getUTCMonth()+1,date.getUTCDate(),date.getUTCHours(),date.getUTCMinutes(),date.getUTCSeconds());}
var fields=[_('⚝ Model'),"B860H ✧ s905x",_('⚝ Architecture'),boardinfo.system,_('⚝ Target Platform'),(L.isObject(boardinfo.release)?boardinfo.release.target:''),_('⚝ Firmware Version'),"OpenWrt 24.10.0⭒Rc2 ⚝ BuilD By Xidz",_('⚝ Kernel Version'),boardinfo.kernel,_('⚝ Local Time'),datestr,_('⚝ Uptime'),systeminfo.uptime?'%t'.format(systeminfo.uptime):null_];var table=E('table',{'class':'table'});for(var i=0;i<fields.length;i+=2){table.appendChild(E('tr',{'class':'tr'},[E('td',{'class':'td left','width':'33%'},[fields[i]]),E('td',{'class':'td left'},[(fields[i+1]!=null)?fields[i+1]:'?'])]));}
return table;}});
