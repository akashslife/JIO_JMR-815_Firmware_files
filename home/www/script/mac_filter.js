var allow_new_cnt = 0;
var deny_new_cnt = 0;
var allow_curr_cnt = 0;
var deny_curr_cnt = 0;
var allow_new_str=new Array(MAC_FILTER_LIST_MAX);
var deny_new_str=new Array(MAC_FILTER_LIST_MAX);
var mode_resl = null;
var on_set=0;

function isValidMAC(str) { 
  var regex = /^([0-9a-fA-F]{2}[:]){5}([0-9a-fA-F]{2})$/;
  if(regex.test(str) == true) {
    return true; 
  }
  else {
    return false;
  }
}

function mac_allow_display(disp_type) {
  var allow_new_str_all ="";
  allow_new_str_all += "<table width=100% border=0 id=mac_accept_list style=\"DISPLAY:"+disp_type+"\" align=center cellpadding=0 cellspacing=0 bordercolor=gray>";
  allow_new_str_all +="<tr>";
  allow_new_str_all +="<td width=180 class=text_list><div align=left>MAC</div></td>";
  allow_new_str_all +="<td width=180 class=text_list><div align=left>Description</div></td>";
  allow_new_str_all +="<td width=80 class=text_list><div align=center>Enable</div></td>";
  allow_new_str_all +="<td width=80 height=20 class=text_list><div align=center>Delete</div></td></tr>";
  allow_new_str_all +="<tr>";
  allow_new_str_all +="<td colspan=4 height=2 background=\"../image/separate_line.jpg\"><img src=\"../image/separate_line.jpg\"></td></tr>";

  if(allow_new_cnt != "0") {
    for(i=0;i<parseInt(allow_new_cnt);i++) {
      allow_new_str_all +=" <tr>";
      allow_new_str_all +=" <td class=text_list valign=middle align=left>   "+allow_new_str[i][0]+"</td>";
      allow_new_str_all +="<td class=text_list valign=middle align=left>   "+allow_new_str[i][1]+"</td>";
      allow_new_str_all +="<td class=text_list><div align=center><input type=checkbox name=accept_checkEnable id=accept_Enable"+i+" value="+i+" onClick=\"en_change_on('a', "+i+");\" "+allow_new_str[i][2]+"></div></td>";
      allow_new_str_all +="<td class=text_list align=right width=100 height=30 align=center><input type=image src=\"../image/delete_btn_80.jpg\" id=accept_del"+i+" onClick=\"delete_accept_list("+i+");return false;\"></td></tr>";
      if(i !=parseInt(allow_new_cnt)-1) {
			   allow_new_str_all +="<tr>";
			   allow_new_str_all +="<td colspan=4 height=2 background=\"../image/separate_line.jpg\"><img src=\"../image/separate_line.jpg\"></td></tr>";
		  }
    }
    allow_new_str_all +=" <tr>";
    allow_new_str_all +="  <td colspan=4> </td></tr>";
    allow_new_str_all +=" <tr>";
    allow_new_str_all +="  <td colspan=4 height=10> </td></tr>";
    allow_new_str_all +=" <tr>";
    allow_new_str_all +="  <td colspan=4 height=40 align=center></td></tr>"; //    allow_new_str_all +="  <td colspan=4 height=40 align=center><input type=image src=\"../image/apply_btn.jpg\" id=accept_edit_btn onclick=\"accept_edit_apply();return false;\"></td></tr>"
    allow_new_str_all +=" <tr>";
    allow_new_str_all +="  <td colspan=4 height=10> </td></tr>";
    allow_new_str_all +=" <tr>";
    allow_new_str_all +="  <td colspan=4 height=10> </td></tr>";
  }
  else {
    if(allow_curr_cnt!=0) {
	    allow_new_str_all +=" <tr>";
	    allow_new_str_all +="  <td colspan=4 height=10> </td></tr>";
	    allow_new_str_all +=" <tr>";
	    allow_new_str_all +="  <td colspan=4 height=40 align=center></td></tr>";  //    allow_new_str_all +="  <td colspan=4 height=40 align=center><input type=image src=\"../image/apply_btn.jpg\" id=accept_edit_btn onclick=\"accept_edit_apply();return false;\"></td></tr>"
	    allow_new_str_all +=" <tr>";
	    allow_new_str_all +="  <td colspan=4 height=10> </td></tr>";
	    allow_new_str_all +=" <tr>";
	    allow_new_str_all +="  <td colspan=4 height=10> </td></tr>";
    }
  }
  allow_new_str_all +=" </table>";
  document.getElementById('add_to_allow_list').innerHTML=allow_new_str_all;
}

function mac_deny_display(disp_type) {
  var deny_new_str_all ="";
  deny_new_str_all += "<table width=100% border=0 id=mac_deny_list style=\"DISPLAY:"+disp_type+"\" align=center cellpadding=0 cellspacing=0 bordercolor=gray>";
  deny_new_str_all +=" <tr>";
  deny_new_str_all +=" <td width=180 class=text_list><div align=left>MAC</div></td>";
  deny_new_str_all +=" <td width=180 class=text_list><div align=left>Description</div></td>";
  deny_new_str_all +=" <td width=80 class=text_list><div align=center>Enable</div></td>";
  deny_new_str_all +=" <td width=80 height=20 class=text_list><div align=center>Delete</div></td></tr>";
  deny_new_str_all +="<tr>";
  deny_new_str_all +="<td colspan=4 height=2 background=\"../image/separate_line.jpg\"><img src=\"../image/separate_line.jpg\"></td></tr>";

  if(deny_new_cnt != "0") {
    for(i=0;i<parseInt(deny_new_cnt);i++) {
      deny_new_str_all +=" <tr>";
      deny_new_str_all +=" <td class=text_list valign=middle align=left>   "+deny_new_str[i][0]+"</td>";
      deny_new_str_all +=" <td class=text_list valign=middle align=left>   "+deny_new_str[i][1]+"</td>";
      deny_new_str_all +=" <td class=text_list><div align=center><input type=checkbox name=deny_checkEnable id=deny_Enable"+i+" value="+i+" onClick=\"en_change_on('d', "+i+");\" "+deny_new_str[i][2]+"></div></td>";
      deny_new_str_all += "<td class=text_list align=right width=100 height=30 align=center><input type=image src=\"../image/delete_btn_80.jpg\" id=deny_del"+i+" onClick=\"delete_deny_list("+i+");return false;\"></td></tr>";
      if(i !=parseInt(deny_new_cnt)-1) {
				deny_new_str_all +="<tr>";
				deny_new_str_all +="<td colspan=4 height=2 background=\"../image/separate_line.jpg\"><img src=\"../image/separate_line.jpg\"></td></tr>";
		  }
    }
    deny_new_str_all +=" <tr>";
    deny_new_str_all +="  <td colspan=4> </td></tr>";
    deny_new_str_all +=" <tr>";
    deny_new_str_all +="  <td colspan=4 height=10> </td></tr>";
    deny_new_str_all +=" <tr>";
    deny_new_str_all +="  <td colspan=4 height=40 align=center></td></tr>"; 
    deny_new_str_all +=" <tr>";
    deny_new_str_all +="  <td colspan=4 height=10> </td></tr>";
    deny_new_str_all +=" <tr>";
    deny_new_str_all +="  <td colspan=4 height=10> </td></tr>";
  }
  else {
    if(deny_curr_cnt!=0) {
	    deny_new_str_all +=" <tr>";
	    deny_new_str_all +="  <td colspan=4 height=10> </td></tr>";
	    deny_new_str_all +=" <tr>";
	    deny_new_str_all +="  <td colspan=4 height=40 align=center></td></tr>"; 
	    deny_new_str_all +=" <tr>";
	    deny_new_str_all +="  <td colspan=4 height=10> </td></tr>";
	    deny_new_str_all +=" <tr>";
	    deny_new_str_all +="  <td colspan=4 height=10> </td></tr>";
    }
  }
  deny_new_str_all +=" </table>";
  document.getElementById('add_to_deny_list').innerHTML=deny_new_str_all;
}

function delete_accept_list(del_num) {  
  allow_new_str[del_num] = ["","","",""]; // MAC, description, Enable or Disable in Allow List
  if(del_num != allow_new_cnt-1) {  
    for(i=del_num;i<allow_new_cnt;i++) { 
      allow_new_str[i] = allow_new_str[i+1] ;
    } 
    allow_new_str[allow_new_cnt-1] = ["","","",""]; // MAC, description, Enable or Disable in Allow List
  }
  allow_new_cnt -- ; 

  mac_allow_display("table");
  on_set =1;
  disp_apply(on_set);
} 

function delete_deny_list(del_num) {  
  deny_new_str[del_num] = ["","","",""]; // MAC, description, Enable or Disable in Deny List
  if(del_num != deny_new_cnt-1) {  
    for(i=del_num;i<deny_new_cnt;i++) { 
      deny_new_str[i] = deny_new_str[i+1] ;
    }
    deny_new_str[deny_new_cnt-1] = ["","","",""]; // MAC, description, Enable or Disable in Allow List
  }
  deny_new_cnt --; 
  mac_deny_display("table");
  on_set =1;
  disp_apply(on_set);
 } 

function checkStr(str)
{
  var num ="`()<>&\"'";
  for (var i=0;i<str.length;i++) {
    if(-1 != num.indexOf(str.charAt(i)))
      return 0;
  }
  return 1; 
}

function Macaddress_accept_Add() {      
  var input_mac_value = document.getElementById('mac_addr_accept_add').value;           
  var input_description_value = document.getElementById('description_accept_add').value;           
  if(allow_new_cnt >= MAC_FILTER_LIST_MAX){
  	var max_str = 'Maximum Support Count : '+MAC_FILTER_LIST_MAX+' EA';
    alert(max_str); 
    return false; 
  }

  if(input_mac_value=='') {  
    alert('Please enter the MAC Address');  
    return false; 
  }  
  if(isValidMAC(input_mac_value) == false) {  
    alert('MAC address is not valid ');  
    return false; 
  }  

  for(var i=0; i<allow_new_cnt; i++) {
    if(input_mac_value.toLowerCase() ==allow_new_str[i][0].toLowerCase()) {
      alert('duplicated MAC address is found in the existing list');  
      return false; 
    }
  }  

  if(checkStr(input_description_value) == false) {  
    alert("`()<>&\"' are not available.");
    document.getElementById('description_accept_add').value ="";
    return false; 
  }  
  
  allow_new_str[allow_new_cnt][0] = input_mac_value;      
  allow_new_str[allow_new_cnt][1] = input_description_value;   
  allow_new_str[allow_new_cnt][2] = "checked";
  allow_new_str[allow_new_cnt][3] = "";
  allow_new_cnt ++; 
  mac_allow_display("table");
  on_set =1;
  disp_apply(on_set);
}       

function Macaddress_deny_Add() {      
  var input_mac_value = document.getElementById('mac_addr_deny_add').value;           
  var input_description_value = document.getElementById('description_deny_add').value;           

  if(deny_new_cnt >= MAC_FILTER_LIST_MAX){ 
  	var max_str = 'Maximum Support Count : '+MAC_FILTER_LIST_MAX+' EA';
    alert(max_str);
    return false; 
  }

  if(input_mac_value=='') {  
    alert('Please enter the MAC Address');  
    return false; 
  }
  
  if(isValidMAC(input_mac_value) == false) {  
    alert('MAC address is not valid');  
    return false; 
  }

  for(var i=0; i<deny_new_cnt; i++) {
    if(input_mac_value.toLowerCase() ==deny_new_str[i][0].toLowerCase()) {
      alert('duplicated MAC address is found in the existing list');  
      return false; 
    }
  }

  if(checkStr(input_description_value) == false) {  
    alert("`()<>&\"' are not available.");
    document.getElementById('description_deny_add').value="";
    return false; 
  }  
  
  deny_new_str[deny_new_cnt][0] = input_mac_value;      
  deny_new_str[deny_new_cnt][1] = input_description_value;   
  deny_new_str[deny_new_cnt][2] = "checked";    
  deny_new_str[deny_new_cnt][3] = "";            
  deny_new_cnt ++;
  mac_deny_display("table");
  on_set =1;
  disp_apply(on_set);
}       

function accept_edit_apply() {
  var timestamp = Number(new Date());
  var check_name;
  var accept_check;
  var param = "";

  param += "token="+document.getElementById('TokenID').value;
  param += "&mode=1";
  param += "&allow_cnt="+allow_new_cnt; 	

  for(i=0;i<allow_new_cnt;i++) {
    check_name = 'accept_Enable'+i;
  	accept_check = document.getElementById(check_name);  	
    if(accept_check.type == "checkbox") {
      if(accept_check.checked == false)
        allow_new_str[i][2] = " ";
      else
        allow_new_str[i][2] = "checked";
    }
    else { 
      for(j=0;j<accept_check.length;j++){
        if(accept_check[j].checked == false)
          allow_new_str[i][2] = " ";
      else
        allow_new_str[i][2] = "checked";
      }
    }
     param += "&allow_"+i+"_mac="+allow_new_str[i][0]+"&allow_"+i+"_dis="+allow_new_str[i][1]+"&allow_"+i+"_enable="+allow_new_str[i][2]+"&allow_"+i+"_key="+allow_new_str[i][3];
  }
  dhtmlxAjax.post("/MAC_Filter_ajax.cgi?"+timestamp,param,ajax_response);

  document.getElementById('add_acc_btn').disabled = true; 
  document.getElementById('add_acc_btn').src="../image/add_btn_80_dis.jpg";
  for(i=0;i<allow_new_cnt;i++) {    
    document.getElementById('accept_del'+i).disabled = true;
    document.getElementById('accept_del'+i).src="../image/delete_btn_80_dis.jpg";
 	}
 	return true; 
}

function deny_edit_apply() {
  var timestamp = Number(new Date());
  var check_name;
  var deny_check;  
  var param = "";

  param += "token="+document.getElementById('TokenID').value;
  param += "&mode=2";
  param += "&deny_cnt="+deny_new_cnt;
  for(i=0;i<deny_new_cnt;i++){
    check_name = 'deny_Enable'+i;
  	deny_check = document.getElementById(check_name);  	
    if(deny_check.type == "checkbox") {
      if(deny_check.checked == false)
        deny_new_str[i][2] = " ";
      else
        deny_new_str[i][2] = "checked";
    }
    else { 
      for(j=0;j<deny_check.length;j++){
        if(deny_check[j].checked == false)
          deny_new_str[i][2] = " ";
      else
        deny_new_str[i][2] = "checked";
      }
    }
    param += "&deny_"+i+"_mac="+deny_new_str[i][0]+"&deny_"+i+"_dis="+deny_new_str[i][1]+"&deny_"+i+"_enable="+deny_new_str[i][2]+"&deny_"+i+"_key="+deny_new_str[i][3];
  } 
  dhtmlxAjax.post("/MAC_Filter_ajax.cgi?"+timestamp,param,ajax_response);

	
  document.getElementById('add_den_btn').disabled = true;
  document.getElementById('add_den_btn').src="../image/add_btn_80_dis.jpg";
  for(i=0;i<deny_new_cnt;i++) {    
    document.getElementById('deny_del'+i).disabled = true;
    document.getElementById('deny_del'+i).src="../image/delete_btn_80_dis.jpg";
 	}
 	return true; 
} 

function macfilter_change_on(flag_on) {
  var mod = document.getElementById('cumodiD').value;     
  if(flag_on==0) {  // Disable
    document.getElementById('form_addlist_accept').style.display="none";     
    document.getElementById('form_addlist_deny').style.display="none";     
    document.getElementById('mac_accept_list').style.display="none";     
    document.getElementById('active_accept_list').style.display="none";
    document.getElementById('mac_deny_list').style.display="none";
    document.getElementById('active_deny_list').style.display="none";
    document.getElementById('add_to_allow_list').style.display="none";
    document.getElementById('add_to_deny_list').style.display="none";
  } 
  else if(flag_on==1) {  // Allow
    document.getElementById('form_addlist_deny').style.display="none";     
    document.getElementById('mac_deny_list').style.display="none";
    document.getElementById('add_to_deny_list').style.display="none";
    document.getElementById('active_deny_list').style.display="none";    

    document.getElementById('form_addlist_accept').style.display="block";     
    document.getElementById('mac_accept_list').style.display="block";     
    document.getElementById('active_accept_list').style.display="block";
    document.getElementById('add_to_allow_list').style.display="block";
  } 
  else if(flag_on==2) {  // Deny
    document.getElementById('form_addlist_accept').style.display="none";     
    document.getElementById('mac_accept_list').style.display="none";     
    document.getElementById('active_accept_list').style.display="none";
    document.getElementById('add_to_allow_list').style.display="none";

    document.getElementById('form_addlist_deny').style.display="block";     
    document.getElementById('mac_deny_list').style.display="block";     
    document.getElementById('add_to_deny_list').style.display="block";
    document.getElementById('active_deny_list').style.display="block";     
  }
  if(mod == flag_on) {
	    document.getElementById('mode_btn').disabled = true; //basic_apply_button
	    document.getElementById('mode_btn').src="../image/apply_btn_dis.jpg";
  }
  else {
    document.getElementById('mode_btn').disabled = false; //basic_apply_button
    document.getElementById('mode_btn').src="../image/apply_btn.jpg";
  }
}

function desabled_apply() {
  var timestamp = Number(new Date());
  var check_name;
  var deny_check;  

  var param = "";

  param += "token="+document.getElementById('TokenID').value;
  param += "&mode=0";

  dhtmlxAjax.post("/MAC_Filter_ajax.cgi?"+timestamp,param,ajax_response);
 	return true; 
} 

function ajax_response(loader) { 
  try  {
    mode_resl = eval("(" + loader.xmlDoc.responseText + ")");
    window.location = window.location;
    alert(mode_resl.state); 
  } 
  catch(err) {} 
  loader.xmlDoc = null; 
} 
function filter_apply() {
  var mode = document.getElementById('id_macf_acl').value;
  var curr_mod = document.getElementById('cumodiD').value;
  if(mode ==1 && allow_new_cnt==0 )
  {
    var ans = confirm('Setting without allowed list is not recommended.\nMAC filter mode will be set to \"Disable\".\nDo you want a change to mode ?');  
    if(ans == true)  { 
	  	accept_edit_apply();
      document.getElementById('mode_btn').disabled = true; //basic_apply_button
      document.getElementById('mode_btn').src="../image/apply_btn_dis.jpg";
      return true;
    }   
    else {
      document.location.href = "MAC_Filter.cgi";
      return false; 
    }
  }
  else {
    var ans = confirm('Do you want a change to MAC Filter mode?');  
    if(ans == true)  { 
    	if(mode ==0)
  	  	desabled_apply();
    	else if(mode ==1)
  	  	accept_edit_apply();
    	else if(mode ==2)
  	  	deny_edit_apply();
      document.getElementById('mode_btn').disabled = true; //basic_apply_button
      document.getElementById('mode_btn').src="../image/apply_btn_dis.jpg";
      return true;
    }   
    else 
      return false; 
  }
}

function disp_apply(f_set)
{
	var curr_mode = document.getElementById('cumodiD').value;     
	var set_mode = document.getElementById('id_macf_acl').value;
	if(curr_mode !=set_mode) {
		document.getElementById('mode_btn').disabled = false; //basic_apply_button
		document.getElementById('mode_btn').src="../image/apply_btn.jpg";
	}
	else{
		if(f_set ==0) {
			document.getElementById('mode_btn').disabled = true; //basic_apply_button
			document.getElementById('mode_btn').src="../image/apply_btn_dis.jpg";
		}
		else {
			document.getElementById('mode_btn').disabled = false; //basic_apply_button
			document.getElementById('mode_btn').src="../image/apply_btn.jpg";
		}
	}
}

function en_change_on(mode, num)
{
	if( mode==='a') {
		var check_name = 'accept_Enable'+num;
		if(((allow_new_str[num][2] == 'checked')&& (document.getElementById(check_name).checked==false))
		|| ((allow_new_str[num][2] != 'checked')&& (document.getElementById(check_name).checked==true)))
		{
			on_set =1;
			disp_apply(on_set);
		}
	}
	else if( mode==='d') {
		var check_name = 'deny_Enable'+num;
		if(((deny_new_str[num][2] == 'checked')&& (document.getElementById(check_name).checked==false))
		|| ((deny_new_str[num][2] != 'checked')&& (document.getElementById(check_name).checked==true)))
		{
			on_set =1;
			disp_apply(on_set);
		}
	}
}
