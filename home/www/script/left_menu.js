var childwin;

function namosw_list(parent, visible, width, height, size, fgColor, bgColor, indent, hbgColor, hfgColor) {   
  this.additem = namosw_l_additem;     
  this.addlist = namosw_l_addlist;    
  this.make    = namosw_l_make;     
  this.write   = namosw_l_write;    
  this.show    = namosw_l_show;    
  this.update  = namosw_l_update;    
  this.updateparent = namosw_l_updateparent;  
  this.items = new Array();   
  this.id = document.namosw_lists.length;   
  this.parent_id = 0;         
  this.x = 0;                 
  this.y = 0;                 
  this.visible = visible;     
  this.width    = width;      
  this.height   = height;     
  this.parent   = parent;     
  this.indent = indent;       
  this.fgColor = fgColor;     
  this.hfgColor = hfgColor;   
  this.bgColor  = bgColor;    
  this.hbgColor = hbgColor;   
  this.font_start = '';       
  this.font_end   = '';       
  this.font_start = '<font color=' + fgColor;   
  if (size != '' && size.indexOf('pt', 0) == -1) this.font_start += ' size=' + size;      
  this.font_start += ' style="font-family:\'HelveticaNeue-Light\',\'Helvetica Neue Light\',\'Helvetica Neue\',Meiryo,Arial,Tahoma,Sans-serif;"';
  this.font_start += '>';     
  this.font_start += '<span';   
  if (size.indexOf('pt', 0) != -1)   
    this.font_start += ' style="font-size:' +size+ ';"';                                  
  this.font_start += '>';     
  this.font_end  = '</span>';  
  this.font_end += '</font>';    
  this.made     = false;      
  this.shown    = false;      
  document.namosw_lists[document.namosw_lists.length] = this; 
}   
function namosw_l_setclip(layer, left, right, top, bottom) {  
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById;    
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  if (is_ns4) {               
    layer.clip.left   = left;     
    layer.clip.right  = right;     
    layer.clip.top    = top;  
    layer.clip.bottom = bottom;     
  } else if (is_ns6) {        
    layer.style.width  = right-left;      
    layer.style.height = bottom-top;      
    layer.style.clip="rect("+top+","+right+","+bottom+","+left+")";    
  } else {                    
    layer.style.pixelWidth  = right-left;    
    layer.style.pixelHeight = bottom-top;    
    layer.style.clip="rect("+top+","+right+","+bottom+","+left+")";    
  }  
}    
function namosw_l_write() {   
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById;       
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  var layer, clip, str;       
  for(var i = 0; i < this.items.length; i++) {        
    layer = this.items[i];    
    if (is_ns4)               
      layer.visibility = "hidden";
    else     
      layer.style.visibility = "hidden"; 
    str = ""; 
    str += "<table width="+this.width+" nowrap border='0' cellpadding='0' cellspacing='0'><tr>";       
    if (0 < this.indent) str += "<td width="+this.indent+" nowrap>&nbsp;</td>";           
    if (layer.type == 'list') {             
      str += "<td width=15  valign='middle' nowrap><a";  
      if (is_ns4) str += " href=\"javascript:void(0);\"";    
      else        str += " style=\"cursor:hand;\"";       
      str += " ><img src=\"collapsed.gif\" name=\"_img"+layer.list.id+"\" border='0'></a></td>";       
    } else {                  
      str += "<td width=15 nowrap>&nbsp;</td>";       
    }                         
    str += "<td height="+(this.height-3)+" width="+(this.width-15-this.indent)+" valign='middle' align='left'>";       
    if (this.font_start) str += this.font_start;      
    str += layer.text;        
    if (this.font_end) str += this.font_end;              
    if (layer.url)       str += "</a>";      
    str += "</td></table>";   
    str = str.replace("span", "span id='namoswlistspan" + layer.lid + "'");               
    if (is_ns4) {             
      layer.document.writeln(str);                    
      layer.document.close();                         
    } else if (is_ns6) {      
      layer.innerHTML = str;  
      layer.span = document.getElementById('namoswlistspan'+layer.lid);                   
    } else {                  
      layer.innerHTML = str;  
      layer.span = document.all['namoswlistspan'+layer.lid];                              
    }                         
    if (layer.type == 'list' && layer.list.visible)   
      this.items[i].list.write();                     
  }                           
  this.made = true;           
}                             
function namosw_l_show() {    
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById;                        
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  var layer;                  
  for(var i = 0; i < this.items.length; i++) {        
    layer = this.items[i];    
    namosw_l_setclip(layer, 0, this.width, 0, this.height-1);                             
    if (is_ns4) {             
      if (layer.oBgColor) layer.document.bgColor = layer.oBgColor;                        
      else layer.document.bgColor = this.bgColor;     
    } else {                  
      if (layer.oBgColor) layer.style.backgroundColor = layer.oBgColor;                   
      else layer.style.backgroundColor = this.bgColor;                                    
    }                         
    if (layer.type == 'list' && layer.list.visible)   
      layer.list.show();      
  }                           
  this.shown = true;          
}                             
function namosw_l_update(parent_visible, x, y) {      
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById;                        
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  var top = y, layer, list;   
  for(var i = 0; i < this.items.length; i++) {        
    layer = this.items[i];    
    list  = layer.list;       
    if (this.visible && parent_visible) {             
      if (is_ns4) {           
 layer.visibility = "visible";                       
 layer.top = top;            
 layer.left = x;             
      } else if (is_ns6) {    
 layer.style.visibility = "visible";                 
 layer.style.top   = top;    
 layer.style.left  = x;     
      } else {                
 layer.style.visibility = "visible";                 
 layer.style.pixelTop   = top;                       
 layer.style.pixelLeft  = x;                         
// if (layer.url) layer.style.cursor = "hand";       
      }                       
      top += this.height;     
    } else {                  
      if (is_ns4)      layer.visibility = "hidden";   
      else if (is_ns6) layer.style.visibility = "hidden";                                 
      else             layer.style.visibility = "hidden";                                 
    }                         
    if (layer.type == 'list') {                       
      if (list.visible) {     
        if (!list.made)  list.write();                
        if (!list.shown) list.show();                 
        if (is_ns4) layer.document.images[0].src = "collapsed.gif"; 
 else eval('document.images._img'+list.id+'.src = "collapsed.gif"');                     
      } else {                
 if (is_ns4) layer.document.images[0].src = "expanded.gif";                              
 else eval('document.images._img'+list.id+'.src = "expanded.gif"');                      
      }                       
      if (list.made)          
        top = list.update(this.visible && parent_visible, x, top);                        
    }                         
  }                           
  return top;                 
}                             
function namosw_l_updateparent(parent_id) {           
  this.parent_id = parent_id;                         
  for(var i = 0; i < this.items.length; i++)          
    if (this.items[i].type == 'list')                 
      this.items[i].list.updateparent(parent_id);     
}                             
function namosw_l_expand(i) {                         
  document.namosw_lists[i].visible = !document.namosw_lists[i].visible;                   
  list = document.namosw_lists[document.namosw_lists[i].parent_id];                       
  list.update(true, list.x, list.y);                  
}                             
function namosw_l_make(x, y) {                        
  this.updateparent(this.id);                         
  this.write();               
  this.show();                
  this.update(true, x, y);    
  this.x = x;                 
  this.y = y;                 
}                             
function namosw_l_additem(text, url, frame) {         
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById;                        
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  var layer = null;           
  if (is_ns4 && this.parent)  
    layer = eval('this.parent.document.layers.namoswlistitem'+document.namosw_lists.lid); 
  else if (is_ns6)            
    layer = document.getElementById("namoswlistitem" + document.namosw_lists.lid);        
  else                        
    layer = eval('document.all.namoswlistitem'+document.namosw_lists.lid);                
  if (layer == null && is_ns4)                        
    layer = this.parent ? new Layer(this.width, this.parent) : new Layer(this.width);     
  if (layer == null) return;  
  if (url)   layer.url   = url;                       
  if (frame) {                
    if (frame.indexOf('parent.') != 0)                
      layer.frame = "_" + frame;                      
    else                      
      layer.frame = frame.substring(7, frame.length); 
  }                           
  else //if frame is ""       
    layer.frame = "_self";    
  layer.type = 'item';        
  layer.text = text;          
  layer.lid  = document.namosw_lists.lid;             
  this.items[this.items.length] = layer;              
  layer.hbgColor = this.hbgColor;                     
  layer.oBgColor = this.bgColor;                      
  layer.fgColor = this.fgColor;                       
  layer.hfgColor = this.hfgColor;                     
  if (layer.captureEvents)    
    layer.captureEvents(Event.MOUSEOVER|Event.MOUSEOUT|Event.MOUSEUP);                    
  layer.onmouseover = namosw_l_onmouseover;           
  layer.onmouseout  = namosw_l_onmouseout;            
  layer.onmouseup   = namosw_2_onmouseup;           
  document.namosw_lists.lid++;                        
}                             
function namosw_l_addlist(list, text, url, frame) {   
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById;                        
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  var layer = null;           
  if (is_ns4 && this.parent)  
    layer = eval('this.parent.document.layers.namoswlistitem'+document.namosw_lists.lid); 
  else if (is_ns6)            
    layer = document.getElementById("namoswlistitem" + document.namosw_lists.lid);        
  else                        
    layer = eval('document.all.namoswlistitem'+document.namosw_lists.lid);                
  if (layer == null && is_ns4)                        
      layer = this.parent ? new Layer(this.width, this.parent) : new Layer(this.width);   
  if (layer == null) return;  
  if (url)   layer.url   = url;                       
  if (frame) {                
    if (frame.indexOf('parent.') != 0)                
      layer.frame = "_" + frame;                      
    else                      
      layer.frame = frame.substring(7, frame.length); 
  }                           
  else                        
    layer.frame = "_self";    
  layer.list = list;          
  layer.type = 'list';        
  layer.text = text;          
  layer.lid  = document.namosw_lists.lid;             
  this.items[this.items.length] = layer;              
  list.parent = this;         
  layer.hbgColor = this.hbgColor;                     
  layer.oBgColor = this.bgColor;                      
  layer.fgColor = this.fgColor;                       
  layer.hfgColor = this.hfgColor;                     
  if (layer.captureEvents)    
    layer.captureEvents(Event.MOUSEOVER|Event.MOUSEOUT|Event.MOUSEUP);                    
  layer.onmouseover = namosw_l_onmouseover;           
  layer.onmouseout  = namosw_l_onmouseout;            
  layer.onmouseup   = namosw_l_onmouseup;           
  document.namosw_lists.lid++;                        
}                             
function namosw_l_onmouseover()                       
{                             
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById;                        
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  if (is_ns4) {               
    if (this.hbgColor)        
      this.bgColor = this.hbgColor;                   
  } else {                    
    if (this.hbgColor) this.style.backgroundColor = this.hbgColor;                        
    if (this.hfgColor) this.span.style.color = this.hfgColor;                             
    this.style.cursor='hand';
  }                           
  if (this.url) self.status = this.url;               
}                             
function namosw_l_onmouseout()                        
{                             
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById;                        
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  if (is_ns4) {               
    this.bgColor = this.oBgColor;                     
  } else  {                   
    this.style.backgroundColor = this.oBgColor;       
    this.span.style.color = this.fgColor;             
  }                           
  if (this.url) self.status = '';                     
}                             
function namosw_l_onmouseup()                         
{                             
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById;                        
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  namosw_l_expand(this.list.id); 
}                             
function namosw_2_onmouseup()                         
{                             
  if(this.url) { 
    if(!childwin)
    //  childwin = window.open(this.url, this.frame); 
    childwin = go(this.url);
  }
}                             
                            
function go (zz)
{
  top.webbody.location=zz;
  return true;
}
function namosw_ns_resize()   
{                             
  window.history.go(0);       
}

function namosw_init_list(top_layer) { 
  if (parseInt(navigator.appVersion) < 4) return; 
  if (top_layer == '') return; 
  document.namosw_lists     = new Array(); 
  document.namosw_lists.lid = 0; 
  var is_ns4 = navigator.appName.indexOf('Netscape', 0) != -1 && !document.getElementById; 
  var is_ns6 = navigator.appName.indexOf('Netscape', 0) != -1 && document.getElementById; 
  var layer;
  if (is_ns4)      layer = document.layers[top_layer]; 
  else if (is_ns6) layer = document.getElementById(top_layer); 
  else             layer = document.all[top_layer]; 
  var string = ""; 
  for (i = 0; i < 32; i++) {  
    string = string + "<div id='namoswlistitem" + (document.namosw_lists.lid+i) + "' " +  
                       "style=''></div>";    // "style='position: absolute;'></div>"; 
  } 
  layer.innerHTML += string;  
l1 = new namosw_list(layer, true, 225, 40, '3', 'white', '#50B6BF', 0, '#8E61BC');
  l1.additem('Connection URL', 'connection_url.cgi', 'parent.right'); 
  l2 = new namosw_list(layer, true, 225, 35, '2', '#50B6BF', '#FFFFFF', 0, '#FFF799');
  l1.addlist(l2, 'Status Information', '', 'parent.right'); 
    l2.additem('LTE Information', 'LTE_info.cgi', 'parent.right');
    l2.additem('LAN Information', 'LAN_info.cgi', 'parent.right');
    l2.additem('WAN Information', 'WAN_info.cgi', 'parent.right');
    l2.additem('Device Details', 'Device_info.cgi', 'parent.right'); 
    l2.additem('System Performance', 'System_performance.cgi', 'parent.right'); 
  
  l1.make(0, 14); 
} 
/*
window.oncontextmenu = function() {
  alert('Right Click Disabled');
  return false;
}
*/