var pbc_timer;

function pbc_ajaxDone(req)
{
  if(req.readyState == 4) 
  {
    try  
    {  
      resl = eval("(" + req.responseText + ")");
      document.form_wps.token.value = resl.token;
      document.form_pbc.token.value = resl.token;

      if(resl.status =="pbc_on")
      {
        document.getElementById('wscd_time').innerHTML = resl.time+" Sec";
        document.getElementById('pbc_btn').disabled = false;
        document.getElementById('pbc_btn').src="../image/cancel_btn.jpg";
      }
      else if(resl.status =="pbc_off")
      {
        document.getElementById('wscd_time').innerHTML = " ";        
        document.getElementById('pbc_btn').disabled = false;
        document.getElementById('pbc_btn').src="../image/connect_btn.jpg";
      }
      document.getElementById('pbc_state').value = resl.status;
    }  
    catch(err)  
    {  
    }     
    req = null;  
  }   
} 

function pbc_ajax(url,target) { 

  var params = "status=pbc&token="+document.form_pbc.token.value;

  if (window.XMLHttpRequest) 
  { 
    req = new XMLHttpRequest(); 
    req.onreadystatechange = function(){pbc_ajaxDone(req);}; 
    req.open('POST', url, true); 
    req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    req.send(params); 
  }
  else if (window.ActiveXObject) 
  { 
    req = new ActiveXObject('MSXML2.XMLHTTP'); 
    if (!req) { 
    req = new ActiveXObject('Microsoft.XMLHTTP'); 
  } 
  req.onreadystatechange = function() {pbc_ajaxDone(req);}; 
  req.open('POST', url, true); 
  req.setRequestHeader('Content-Type', "application/x-www-form-urlencoded"); 
  req.setRequestHeader('Content-Length', params.length); 
  req.setRequestHeader('Connection', 'close'); 
  req.send(params); 
  } 
} 

function check_pbc()
{
  pbc_timer = setInterval("pbc_ajax('/wps_ajax.cgi' ,null)", 5000);
}

