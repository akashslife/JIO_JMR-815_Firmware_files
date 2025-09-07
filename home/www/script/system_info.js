var sys_timer;
var sys_resl = null;

function current_time() {
  var time = document.getElementById('up_time').value;
  time++;
  var h = Math.floor(time/3600);
  var m = Math.floor((time/60)%60);
  var s = Math.floor(time%60);
  m = m>9?m:"0"+m;
  s = s>9?s:"0"+s;

  document.getElementById('deviceUpTime').innerHTML=h+":"+m+":"+s;
  document.getElementById('up_time').value=time;
}

function sysRefresh()
{
  var refresh_t = 10000;
  var tmp_t = document.getElementById('re_time').value;
  refresh_t = tmp_t * 1000;
  sys_timer = setInterval("getSysData()", refresh_t);
  //sys_timer = setInterval("getSysData()", 500);
}

function getSysData()
{
  clearInterval(sys_timer);

  var timestamp = Number(new Date());
  dhtmlxAjax.get("/performance_ajax.cgi?"+timestamp, sys_Data);
}

function sys_Data(loader)
{
  var catch_err = 0;
  try
  {
    sys_resl = eval("(" + loader.xmlDoc.responseText + ")");

    document.getElementById('cpuMaxUsage').innerHTML = sys_resl.cpumax  + " %";
    document.getElementById('cpuMinUsage').innerHTML = sys_resl.cpumin  + " %";
    document.getElementById('maxMemoryUsage').innerHTML = sys_resl.memmax  + " kB";
    document.getElementById('minMemoryUsage').innerHTML = sys_resl.memmin  + " kB";
    
    document.getElementById('ulCurrentDataRate').innerHTML = sys_resl.txRate;
    document.getElementById('ulMaxDataRate').innerHTML = sys_resl.txmax;
    document.getElementById('ulMinDataRate').innerHTML = sys_resl.txmin;
    document.getElementById('dlCurrentDataRate').innerHTML = sys_resl.rxRate;
    document.getElementById('dlMaxDataRate').innerHTML = sys_resl.rxmax;
    document.getElementById('dlMinDataRate').innerHTML = sys_resl.rxmin;
  }
  catch(err)
  {
    clearInterval(sys_timer);
    parent.document.location.href = "index.html";
    catch_err = 1;
  }  
  loader.xmlDoc = null;
  
  if( catch_err == 0)
    sysRefresh();
}



