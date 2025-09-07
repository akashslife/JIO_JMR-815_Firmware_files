var dev_timer;
var dev_resl = null;

function Device_info_Refresh()
{
  var refresh_t = 10000;
  var tmp_t = document.getElementById('re_time').value;
  refresh_t = tmp_t * 1000;
  dev_timer = setInterval("get_Device_info_Data()", refresh_t);
}

function get_Device_info_Data()
{
  clearInterval(dev_timer);

  var timestamp = Number(new Date());
  dhtmlxAjax.get("/Device_info_ajax.cgi?"+timestamp, device_Data);
}

function device_Data(loader)
{
  try
  {
    dev_resl = eval("(" + loader.xmlDoc.responseText + ")");
    document.getElementById('batterylevel').innerHTML = dev_resl.batterylevel;    
    document.getElementById('batterystatus').innerHTML = dev_resl.batterystatus;
    document.getElementById('currentTime').innerHTML = dev_resl.curr_time;    
  }
  catch(err)
  {
    clearInterval(dev_timer);
    parent.document.location.href = "index.html";
  }  
  loader.xmlDoc = null;
  Device_info_Refresh();
}
