var wan_timer;
var wan_resl = null;

function wan_Refresh()
{
  var refresh_t = 10000;
  var tmp_t = document.getElementById('re_time').value;
  refresh_t = tmp_t * 1000;
  wan_timer = setInterval("getwanData()", refresh_t);
}

function getwanData()
{
  clearInterval(wan_timer);

  var timestamp = Number(new Date());
  dhtmlxAjax.get("/wan_info_ajax.cgi?"+timestamp, wan_Data);
}

function wan_Data(loader)
{
  try
  {
    wan_resl = eval("(" + loader.xmlDoc.responseText + ")");

     var now_ipv4 = document.getElementById('ipv4Address').value;
     var now_ipv6 = document.getElementById('ipv6Address').value;

  if(now_ipv4 != wan_resl.ip)
  {
      document.getElementById('ipv4Address').innerHTML   = wan_resl.ip;
      document.getElementById('ipv4SubnetMask').innerHTML   = wan_resl.subnet;
      document.getElementById('ipv4Gateway').innerHTML     = wan_resl.gw;
      document.getElementById('ipv4DNSServer').innerHTML   = wan_resl.dns1;
      document.getElementById('sec_dns').innerHTML   = wan_resl.dns2;
    }

  if(now_ipv6 != wan_resl.ip6g)
  {
      document.getElementById('ipv6Address').innerHTML     = wan_resl.ip6g;
      document.getElementById('ipv6PrefixLen').innerHTML     = wan_resl.ip6prefix;      
      document.getElementById('ipv6Geateway').innerHTML     = wan_resl.ip6gw;
      document.getElementById('ipv6DNSServer').innerHTML   = wan_resl.ip6dns1;
      document.getElementById('ip6_sec_dns').innerHTML   = wan_resl.ip6dns2;    
    }
    document.getElementById('use_duration_ul').innerHTML   = wan_resl.duration_ul;
    document.getElementById('use_duration_dl').innerHTML   = wan_resl.duration_dl;

  }
  catch(err)
  {
    clearInterval(wan_timer);
    parent.document.location.href = "index.html";
  }  
  loader.xmlDoc = null;
  wan_Refresh();
}

function data_reset()
{
  var timestamp = Number(new Date());
  var param = "token="+document.getElementById('token_id').value;

  document.getElementById('reset_btn').disabled = true; 
  document.getElementById('reset_btn').src="../image/reset_btn_dis.jpg";

  dhtmlxAjax.post("/wan_data_reset.cgi?"+timestamp,param,result_ajax);
}

function result_ajax(loader)
{
  try
  {
    var resl = eval("(" + loader.xmlDoc.responseText + ")");
    document.getElementById('token_id').value   = resl.token;
    document.getElementById('use_duration_ul').innerHTML   = resl.duration_ul;
    document.getElementById('use_duration_dl').innerHTML   = resl.duration_dl;
    document.getElementById('reset_btn').disabled = false; 
    document.getElementById('reset_btn').src="../image/reset_btn.jpg";

  }
  catch(err)
  {
    parent.document.location.href = "index.html";
  }  
  loader.xmlDoc = null;
}
