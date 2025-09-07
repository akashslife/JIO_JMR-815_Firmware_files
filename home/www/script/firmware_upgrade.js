var resl_up = null;
var resl_back = null;

function get_backup()
{
  var timestamp = Number(new Date());
  var param = "token="+document.form_backup.token.value;
  dhtmlxAjax.post("/backup_ajax.cgi?"+timestamp,param,re_href);
}

function re_href(loader) { 
  try  {
    resl_back = eval("(" + loader.xmlDoc.responseText + ")"); 
    document.form_upgrade.token.value = resl_back.token;
    document.form_backup.token.value = resl_back.token;
    document.form_restore.token.value = resl_back.token;
    document.form_backup.submit(); 
  } 
  catch(err) {} 
  loader.xmlDoc = null; 
} 

function setting_DATA_connect()
{
  var timestamp = Number(new Date());
  var data_connection_mode = 0;
  var param = "data_connection_mode="+data_connection_mode +"&token="+document.form_upgrade.token.value;
  dhtmlxAjax.post("/data_off_ajax.cgi?"+timestamp,param,setting_DATA_response);
}

function setting_DATA_response(loader) { 
  try  {
    resl_up = eval("(" + loader.xmlDoc.responseText + ")");

    if(resl_up.resp=="Failed")
    {
      document.getElementById('firm_btn').disabled=false; 
      document.getElementById('firm_btn').src="../image/upgrade_btn.jpg"
      document.form_restore.config_file.disabled=false;
      document.getElementById('backup_btn').disabled=false; 
      document.getElementById('backup_btn').src="../image/backup_btn.jpg"
      document.getElementById('config_up_btn').disabled=false;
      document.getElementById('config_up_btn').src="../image/restore_btn.jpg"
      document.getElementById('firm_state').innerHTML   = "Upgrade Fail. . .";

      if(resl_up.error=="1") 
        alert('Update failed due to low battery');
      else if(resl_up.error=="2")
        alert('Cannot run a Software upgrade because a UpgradesManaged is set as a True.\r\n If you want to run a Software upgrade,\r\n SHOULD SET a UpgradesManaged as a False on the ACS.');
      else if(resl_up.error=="3")
        alert('Failed to ready for Software upgrade,\r\n Please Try again.');
    }
    else
    {
      document.form_upgrade.submit();
    }
  } 
  catch(err) {} 
  loader.xmlDoc = null; 
}

function IE_check()
{
	var agent = navigator.userAgent.toLowerCase();

	if ( (navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1) ) 
	{
      document.getElementById('up_file_name').size=10;
      document.getElementById('config_file_name').size=10;
	}
	else 
	{
      document.getElementById('up_file_name').size=25;
      document.getElementById('config_file_name').size=25;
	}
}
