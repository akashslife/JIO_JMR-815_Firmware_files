var reser_cnt = 0;
var reser_new_str=new Array(RESERVATION_LIST_MAX);
var mode_resl = null;
var modify_num = -1;

function verifyIPv4 (str) {
 var blocks = str.split(".");
  if(blocks.length === 4) {
    if(isNaN(blocks[0])==true || isNaN(blocks[1])==true || isNaN(blocks[2])==true || isNaN(blocks[3])==true)
      return -1;
    if(blocks[0].length>3 || blocks[1].length>3 || blocks[2].length>3 || blocks[3].length>3)
      return -3;

    if((parseInt(blocks[0],10) ===192) && (parseInt(blocks[1],10) ===168)) {
      if((parseInt(blocks[2],10)<0 || (parseInt(blocks[2],10) >255)) ||(parseInt(blocks[3],10) <0 || parseInt(blocks[3],10) >255))
        return -1;
      else if(((parseInt(blocks[2],10) ==0)&& (parseInt(blocks[3],10) ==0)) || ((parseInt(blocks[2],10) ==255) && (parseInt(blocks[3],10) ==255)))
        return -1;
      else 
        return 0;
    }else
      return -2;
  }
  return -1;
}

function ipToLong(string)
{
  var parts = string.split(".");
  var sum = 0;
  for(var i = 0; i < 4; i++) {
    var partVal = Number(parts[i]);
    sum = (sum << 8) + partVal;
  }
  return sum;
}

function isValidMAC(str) { 
  var regex = /^([0-9a-fA-F]{2}[:]){5}([0-9a-fA-F]{2})$/;
  if(regex.test(str) == true) {
    return true; 
  }
  else {
    return false;
  }
}

function desc_check(str) { 
  var valid = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^*_+-:?";
  var c;
  if(str.length<=0 || str.length>20) { 
    return -2; 
  } 
  for(i=0; i<str.length; i++) { 
    c=str.charAt(i); 
    if(valid.indexOf(c) == -1) { 
      return -1; 
    } 
  } 
  return 0;
}

function reservation_display() {
  var str_all ="";
  
  str_all += "<table class=table_list width=100% border=0 id=dhcp_list align=center cellpadding=0 cellspacing=0 bordercolor=gray>";
  str_all +=" <tr>";
  str_all +=" <td width=80  bgcolor=#C0C0C0 class=text_list><div align=left>No</div></td>";
  str_all +=" <td width=150 bgcolor=#C0C0C0 class=text_list><div align=left>IP Address</div></td>";
  str_all +=" <td width=280 bgcolor=#C0C0C0 class=text_list><div align=left>Device Name</div></td>";
  str_all +=" <td width=110 bgcolor=#C0C0C0 class=text_list><div align=center>MAC Address</div></td>";
  str_all +=" <td width=90 bgcolor=#C0C0C0 height=20 class=text_list><div align=center>Delete/Modify</div></td></tr>";
  str_all +="<tr>";
  str_all +="<td colspan=5 height=2 background=\"../image/separate_line.jpg\"><img src=\"../image/separate_line.jpg\"></td></tr>";

  if( reser_cnt!= "0") {
    for(i=0;i<parseInt(reser_cnt);i++) {
      str_all +=" <tr>";
      str_all +=" <td class=text_list valign=middle align=left>   "+(i+1)+"</td>";
      str_all +=" <td class=text_list valign=middle align=left>   "+reser_new_str[i][0]+"</td>";
      str_all +=" <td class=text_list valign=middle align=left>   "+reser_new_str[i][2]+"</td>";
      str_all +=" <td class=text_list valign=middle align=left>   "+reser_new_str[i][1]+"</td>";
      str_all += "<td class=text_list align=center><input type=image src=\"../image/Red_min.jpg\" id=reser_del"+i+" onClick=\"delete_reser_list("+i+");return false;\">&nbsp;&nbsp;<input type=image src=\"../image/green_plus.jpg\" id=reser_del"+i+" onClick=\"reser_modify("+i+");return false;\"></td></tr>";      

      if(i !=parseInt(reser_cnt)-1) {
				str_all +="<tr>";
				str_all +="<td colspan=5 height=2 background=\"../image/separate_line.jpg\"><img src=\"../image/separate_line.jpg\"></td></tr>";
		  }
    }
    str_all +=" <tr>";
    str_all +="  <td colspan=5> </td></tr>";
    str_all +=" <tr>";
    str_all +="  <td colspan=5 height=10> </td></tr>";
  }
  else {
    str_all +=" <tr>";
    str_all +="  <td colspan=5 height=10> </td></tr>";
    str_all +=" <tr>";
    str_all +="  <td colspan=5 height=10> </td></tr>";
  }
  str_all +=" </table>";
  document.getElementById('add_to_dhcp_list').innerHTML=str_all;
}


function Reservation_Add() {

  if(modify_num ==-1 && reser_cnt >= RESERVATION_LIST_MAX)
  { 
  	var max_str = 'A maximum of '+RESERVATION_LIST_MAX+' IP addresses are allowed';
    alert(max_str);
    return false; 
  }

  var reser_Ip =document.getElementById('ip_add').value;
  var ipcheck=verifyIPv4(reser_Ip);
  if(ipcheck==-1)
  {
    alert('Can not used Specify IP addresses (192.168.0.0 ,192.168.255.255)'); 
    document.getElementById('ip_add').focus();
    return false;
  }
  else if(ipcheck==-2)
  {
    alert('Valid IP Should begin with 192.168.x.x');
    document.getElementById('ip_add').focus();
    return false;
  }
  else if(ipcheck==-3)
  {
    alert('Invalid IP address');
    document.getElementById('ip_add').focus();
    return false;
  }
  if(ipToLong(reser_Ip)===ipToLong(host_ip))
  {
   	var popup_str = host_ip+' is reserved for Gateway address';
    alert(popup_str);
    document.getElementById('ip_add').focus();
    return false;
  }
  var Macadd =document.getElementById('mac_add').value;
  var reser_Mac =Macadd.toLowerCase();
  if(isValidMAC(reser_Mac)==false)
  {
    alert('MAC address is not valid for the given request type ');
    document.getElementById('mac_add').focus();
    return false;
  }
  var reser_Desc =document.getElementById('des_add').value;
  var resp = desc_check(reser_Desc);
  if( resp==-2 ) { 
    alert('Enter Description, Maximum length is 20');
    document.getElementById('des_add').focus();
    return false;
  }
  else if( resp==-1 ) {
    alert('Alphanumeric and listed special character below is valid ~!@#$%^*_+-:?'); 
    document.getElementById('des_add').focus();
    return false;
  }

  for(var i=0; i<reser_cnt; i++) {
    if(modify_num == i)
      continue;
    if(reser_Mac.toLowerCase() ==reser_new_str[i][1].toLowerCase()) {
      alert('duplicated MAC address is found in the existing list');  
      document.getElementById('mac_add').focus();
      return false; 
    }
    if(ipToLong(reser_Ip) ==ipToLong(reser_new_str[i][0])) {
      alert('duplicated IP address is found in the existing list');  
      document.getElementById('ip_add').focus();
      return false; 
    }
  }

  if(modify_num ==-1) {
    reser_new_str[reser_cnt][0] = reser_Ip;      
    reser_new_str[reser_cnt][1] = reser_Mac;   
    reser_new_str[reser_cnt][2] = reser_Desc;    
    reser_cnt ++;
  }
  else {
    reser_new_str[modify_num][0] = reser_Ip;      
    reser_new_str[modify_num][1] = reser_Mac;   
    reser_new_str[modify_num][2] = reser_Desc;
  
    document.getElementById('add_btn').src="../image/add_btn_50.jpg";
    document.getElementById('cancel_btn').disabled=true; 
    document.getElementById('cancel_btn').src="../image/cancel_btn_50_dis.jpg";
    modify_num =-1;
  }
  reservation_display();
  document.getElementById('ip_add').value ='';
  document.getElementById('mac_add').value ='';
  document.getElementById('des_add').value ='';

  document.getElementById('apply_list_btn').disabled = false; 
  document.getElementById('apply_list_btn').src="../image/apply_btn.jpg";

}


function delete_reser_list(del_num) {
  reser_new_str[del_num] = ["","",""]; // IP, MAC, description
  if(del_num != reser_cnt-1) {  
    for(i=del_num;i<reser_cnt;i++) { 
      reser_new_str[i] = reser_new_str[i+1] ;
    }
    reser_new_str[reser_cnt-1] = ["","",""]; // IP, MAC, description
  }
  reser_cnt --; 
  reservation_display();

  if(modify_num !=-1) {
    Reservation_cancel();
  }
  document.getElementById('apply_list_btn').disabled = false; 
  document.getElementById('apply_list_btn').src="../image/apply_btn.jpg";
}


function reser_modify(str) {

  modify_num = str;
  document.getElementById('ip_add').value =reser_new_str[str][0];
  document.getElementById('mac_add').value =reser_new_str[str][1];
  document.getElementById('des_add').value =reser_new_str[str][2];

  document.getElementById('add_btn').src="../image/modify_btn_50.jpg";
  document.getElementById('cancel_btn').disabled=false; 
  document.getElementById('cancel_btn').src="../image/cancel_btn_50.jpg";

}

function Reservation_cancel() {
  modify_num = -1;
  document.getElementById('ip_add').value ='';
  document.getElementById('mac_add').value ='';
  document.getElementById('des_add').value ='';
  
  document.getElementById('add_btn').src="../image/add_btn_50.jpg";
  document.getElementById('cancel_btn').disabled=true; 
  document.getElementById('cancel_btn').src="../image/cancel_btn_50_dis.jpg";

}


function Range_check(start_ipb,start_ipc,end_ipb,end_ipc) {

  var s1 =parseInt(start_ipb,10);
  var s2 =parseInt(start_ipc,10);
  var e1 =parseInt(end_ipb,10);
  var e2 =parseInt(end_ipc,10);
  
  if(isNaN(start_ipb)==true || isNaN(end_ipb)==true)
    return 1;
  if(isNaN(start_ipc)==true || isNaN(end_ipc)==true)
    return 2;
  
  if((s1<0 || s1 >255) ||(s2 <0 || s2 >255) || (e1 <0 || e1 >255) || (e2 <0 || e2 >255))
    return 1;
  else if((s1==0 && s2 ==0) || (e1 ==255 && e2 ==255))
    return 1;
  else if(s1 != e1)
    return 4;
  else if(s2 >= e2)
    return 5;
  else if(e2-s2 < RANGE_MAX-1)
    return 6;
  else
    return 0;
}

function Lan_setup_apply() {

  var rc = Range_check(document.getElementById('sip_3').value,document.getElementById('sip_4').value,document.getElementById('eip_3').value,document.getElementById('eip_4').value);
  var start_Ip = "192.168."+document.getElementById('sip_3').value+"."+document.getElementById('sip_4').value;
  var end_Ip = "192.168."+document.getElementById('eip_3').value+"."+document.getElementById('eip_4').value;
  if(rc == 1) { //start 0.0 or end 255.255
    alert('Specify a valid range of IP addresses (192.168.0.1 to 192.168.255.254)');
    document.getElementById('sip_3').focus();
    return false;
  }
  if(ipToLong(start_Ip)===ipToLong(host_ip) || ipToLong(end_Ip)===ipToLong(host_ip)) {
  	var popup_str = host_ip+' is reserved for Gateway address';
    alert(popup_str);
    document.getElementById('sip_3').focus();
    return false;
  }  
  else if(rc == 4) { // class b was set to same
    alert("IP range can't transcend subnet C class 192.168.x.y to 192.168.x.z");
    document.getElementById('sip_3').focus();
    return false;
  }
  else if(rc == 5) { // bigger than ip
    alert('Ending IP address should be greater than Starting IP');
    document.getElementById('sip_4').focus();
    return false;
  }
  else if(rc == 6) { // range least 100
  	var popup_str = 'Valid IP range have to be able to contain '+RANGE_MAX+' number of IP at least ';
    alert(popup_str);
    document.getElementById('sip_4').focus();
    return false;
  }

  var ans = confirm('Do you want to apply Configurations?\r\n After applying,system will reboot.');
  if(ans == true)  {
    document.getElementById('add_btn').disabled = true;
    document.getElementById('add_btn').src="../image/add_btn_50_dis.jpg";
    document.getElementById('apply_btn').disabled = true; 
    document.getElementById('apply_btn').src="../image/apply_btn_dis.jpg";
    document.getElementById('apply_list_btn').disabled = true; 
    document.getElementById('apply_list_btn').src="../image/apply_btn_dis.jpg";
    document.form_dhcp.submit();
    return true; 
  }  
  else  { 
    return false; 
  }   

}

function Reser_list_apply() {
  var ans = confirm('Do you want to apply Configurations?\r\n After applying,system will reboot.');
  if(ans == true)  {
    var timestamp = Number(new Date());
    var param = "";
    param += "token="+document.getElementById('TokenID').value;
    param += "&form_type=dhcp_list";
    param += "&reser_cnt="+reser_cnt;
    for(var i=0;i<reser_cnt;i++){
      param += "&reser_"+i+"_ip="+reser_new_str[i][0]+"&reser_"+i+"_mac="+reser_new_str[i][1]+"&reser_"+i+"_desc="+reser_new_str[i][2];
    } 
    dhtmlxAjax.post("/DHCP_setting_ajax.cgi?"+timestamp,param,ajax_response);
  
    document.getElementById('add_btn').disabled = true;
    document.getElementById('add_btn').src="../image/add_btn_50_dis.jpg";
    document.getElementById('apply_btn').disabled = true; 
    document.getElementById('apply_btn').src="../image/apply_btn_dis.jpg";
    document.getElementById('apply_list_btn').disabled = true; 
    document.getElementById('apply_list_btn').src="../image/apply_btn_dis.jpg";

    return true; 
  }  
  else  { 
    return false; 
  }   

}

function ajax_response(loader) { 
  try  {
    mode_resl = eval("(" + loader.xmlDoc.responseText + ")");
    window.location = window.location;
  } 
  catch(err) {} 
  loader.xmlDoc = null; 
}

function handle_ip() {
  document.getElementById('eip_3').value =document.getElementById('sip_3').value;
  verify_ip();
}

function verify_ip() {
  var cu_ip = document.getElementById('current_ip').value;
  var new_ip =document.getElementById('sip_3').value+'.'+document.getElementById('sip_4').value+'-'+document.getElementById('eip_3').value+'.'+document.getElementById('eip_4').value;
  if(cu_ip ==new_ip)
  {
    document.getElementById('apply_btn').disabled = true; 
    document.getElementById('apply_btn').src="../image/apply_btn_dis.jpg";
  }
  else
  {
    document.getElementById('apply_btn').disabled = false; 
    document.getElementById('apply_btn').src="../image/apply_btn.jpg";
  }
}

