var lte_timer;
var lte_resl = null;
var timercon; 

function connect_time() 
{ 
  clearInterval(timercon);
  
  var time = document.getElementById('con_time').value;
  if(time ==0)
  {
    count_contime();
    return 0;
  }
  
  time++; 
  var d = Math.floor(time/86400);
  var h = Math.floor((time/3600)%24); 
  var m = Math.floor((time/60)%60); 
  var s = Math.floor(time%60);

  h = h>9?h:"0"+h;
  m = m>9?m:"0"+m;
  s = s>9?s:"0"+s;
  d = d>9?d:"0"+d;
  document.getElementById('ConnectionTime').innerHTML=d+":"+h+":"+m+":"+s;
  document.getElementById('con_time').value=time;
  count_contime();
} 

function count_contime()
{
  timercon = setInterval('connect_time()', 1000);
}

function count_time_stop()
{
  clearInterval(timercon);
  document.getElementById('ConnectionTime').innerHTML="00:00:00:00";
  document.getElementById('con_time').value="0";
  document.getElementById('con_state').value = "0";
}

function LTEInfoRefresh()
{
  var refresh_t = 10000;
  var tmp_t = document.getElementById('re_time').value;
  refresh_t = tmp_t * 1000;
  lte_timer = setInterval("getLTEData()", refresh_t);    //100 --> 500
}

function getLTEData()
{
  clearInterval(lte_timer);

  var timestamp = Number(new Date());
  dhtmlxAjax.get("/lte_ajax.cgi?"+timestamp, updateLTEData);
}

function updateLTEData(loader)
{
  try
  {
    lte_resl = eval("(" + loader.xmlDoc.responseText + ")");

    document.getElementById('connectedStatus').innerHTML = lte_resl.status;
 
    document.getElementById('operatingMode').innerHTML = lte_resl.opmode;
    document.getElementById('operatingBand').innerHTML = lte_resl.opband;
    document.getElementById('rsrp').innerHTML = lte_resl.rsrp;
    document.getElementById('rsrq').innerHTML = lte_resl.rsrq;
    document.getElementById('sinr').innerHTML = lte_resl.sinr;
    document.getElementById('bandwidth').innerHTML = lte_resl.bandwidth;
    document.getElementById('lteEARFCN').innerHTML = lte_resl.earfcn;
    document.getElementById('plmn').innerHTML = lte_resl.plmn;
    document.getElementById('usedAPN').innerHTML = lte_resl.apn;
    document.getElementById('globalCellId').innerHTML = lte_resl.gcellID;
    document.getElementById('physicalCellId').innerHTML = lte_resl.pcellID;
    document.getElementById('ecgi').innerHTML = lte_resl.ecgi;
    document.getElementById('eutran_cellid').innerHTML = lte_resl.eutran;  
    if(document.getElementById('con_state').value !=0 )
    {
      if( lte_resl.con_status==0)
        count_time_stop();
      else
      {
        document.getElementById('con_time').value=lte_resl.time;
      }
    }
    if(document.getElementById('con_state').value ==0 && lte_resl.con_status!=0)
    {
      document.getElementById('ConnectionTime').innerHTML=lte_resl.time_str;
      document.getElementById('con_time').value=lte_resl.time;
      document.getElementById('con_state').value = lte_resl.con_status;
      count_contime();
    }
    
    LTEInfoRefresh();

  }
  catch(err)
  {
    clearInterval(lte_timer);
    count_time_stop();
    parent.document.location.href = "index.html";
  }  
  loader.xmlDoc = null;

}

function alert_msg()
{
  alert('To security purpose, recommend to change the ID/PW');
}

