var lan_timer;
var lan_resl = null;

function lanRefresh()
{
  var refresh_t = 10000;
  var tmp_t = document.getElementById('re_time').value;
  refresh_t = tmp_t * 1000;
  lan_timer = setInterval("getLanData()", refresh_t);    //100 --> 500
}

function getLanData()
{
  clearInterval(lan_timer);

  var timestamp = Number(new Date());
  dhtmlxAjax.get("/lan_ajax.cgi?"+timestamp, updateLanData);
}


function display_list()
{
 var counter = 0;
 var users_list =document.getElementById('userlistinfo').value;
 var trDataStr = users_list.split(";");
 var mlist = [];
 $.each(trDataStr,function(key,val) {
   counter++;
 var tdData = val.split(",");
 var trObj = {
   "Name": tdData[0],
   "MAC": tdData[1],
   "IP": tdData[2],
   "Leased_time": tdData[3],
   "Status": tdData[4]}
 mlist.push(trObj);
 });
 
 var content = "<table width=100% border=0 cellpadding=0 cellspacing=0><tr>";
 
 content += "<td colspan=5 class=text_title><strong>Client List</td></tr>";
 content += "  <tr><td colspan=5 height=2 background=\"../image/separate_line.jpg\"><img src=../image/separate_line.jpg></td></tr>";
 content += "  <tr><td colspan=5 height=10> </td></tr>";
 content += "  <tr>";
 content += "    <td width=150 height=20 class=text_subtitle_lan><div align=center>Name</div></td>";
 content += "    <td width=100 class=text_subtitle_lan><div align=center>MAC</div></td>";
 content += "    <td width=90 class=text_subtitle_lan><div align=center>IP</div></td>";
 content += "    <td width=90 class=text_subtitle_lan><div align=center>Leased&nbsp;Time</div></td>";
 content += "    <td width=90 class=text_subtitle_lan><div align=center>Status</div></td></tr>";
 content += "  <tr><td colspan=5 height=2 background=\"../image/separate_line.jpg\"><img src=../image/separate_line.jpg></td></tr>";
 for(i=0; i<  mlist.length; i++) {
   content += "<tr>";
   content += "<td class=text_list_word_break><div align=center>" + mlist[i].Name + "</div></td>";
   content += "<td class=text_list_lan><div align=center>"+ mlist[i].MAC + "</div></td>";
   content += "<td class=text_list_lan><div align=center>" + mlist[i].IP + "</div></td>";
   content += "<td class=text_list_lan><div align=center>"+ mlist[i].Leased_time + "</div></td>";
   content += "<td class=text_list_lan><div align=center>" + mlist[i].Status + "</div></td></tr>";
 }
 content += "</table>";
 $("#userList").html(content);
}

function updateLanData(loader)
{
  try
  {
    lan_resl = eval("(" + loader.xmlDoc.responseText + ")");

    document.getElementById('noOfClient').innerHTML = lan_resl.act_cnt;


     var counter = 0;
     var users_list = lan_resl.userlistinfo;
     var trDataStr = users_list.split(";");
     var mlist = [];
     $.each(trDataStr,function(key,val) {
       counter++;
     var tdData = val.split(",");
     var trObj = {
       "Name": tdData[0],
       "MAC": tdData[1],
       "IP": tdData[2],
       "Leased_time": tdData[3],
       "Status": tdData[4]}
     mlist.push(trObj);
     });
     
 var content = "<table width=100% border=0 cellpadding=0 cellspacing=0><tr>";
 
 content += "<td colspan=5 class=text_title><strong>Client List</td></tr>";
 content += "  <tr><td colspan=5 height=2 background=\"../image/separate_line.jpg\"><img src=../image/separate_line.jpg></td></tr>";
 content += "  <tr><td colspan=5 height=10> </td></tr>";
 content += "  <tr>";
 content += "    <td width=150 height=20 class=text_subtitle_lan><div align=center>Name</div></td>";
 content += "    <td width=100 class=text_subtitle_lan><div align=center>MAC</div></td>";
 content += "    <td width=90 class=text_subtitle_lan><div align=center>IP</div></td>";
 content += "    <td width=90 class=text_subtitle_lan><div align=center>Leased&nbsp;Time</div></td>";
 content += "    <td width=90 class=text_subtitle_lan><div align=center>Status</div></td></tr>";
 content += "  <tr><td colspan=5 height=2 background=\"../image/separate_line.jpg\"><img src=../image/separate_line.jpg></td></tr>";
 for(i=0; i<  mlist.length; i++) {
   content += "<tr>";
   content += " <td class=text_list_word_break><div align=center>" + mlist[i].Name + "</div></td>";
   content += " <td class=text_list_lan><div align=center>"+ mlist[i].MAC + "</div></td>";
   content += " <td class=text_list_lan><div align=center>" + mlist[i].IP + "</div></td>";
   content += " <td class=text_list_lan><div align=center>"+ mlist[i].Leased_time + "</div></td>";
   content += " <td class=text_list_lan><div align=center>" + mlist[i].Status + "</div></td></tr>";
 }
 content += "</table>";
        $("#userList").html(content);
        
  }
  catch(err)
  {
    clearInterval(lan_timer);
    parent.document.location.href = "index.html";
  }  
  loader.xmlDoc = null;
  lanRefresh();
}


