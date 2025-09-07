var timerID;  
var in_cnt =0;

function current_date() {  
  var count =document.getElementById('se_time').value;
  in_cnt++;
  if(count == in_cnt)
  {
    clearInterval(timerID);

    var csrf = parent.document.getElementById('out_token').value;

    var param = "token="+csrf;
    var out_url= "logout_btn.cgi?"+param;
    parent.location.href =out_url; 
  }
}  

function session_timeout() { 
  var count =document.getElementById('se_time').value;
  if(count !=0)
    timerID = setInterval('current_date()', 60000);  
}

function stop_session_timeout() { 
  clearInterval(timerID);
  in_cnt = 0;
}
