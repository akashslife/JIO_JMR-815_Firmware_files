$(document).ready(function(){
	indexList();
});

function indexList(){
	var indexView = $(".indexList");
	var indexNumber = $(".contentWrap .contentContainer").index(".contentWrap .contentContainer");
	var sub_index = 0;
	var strIndex = "";
	var strIndex2 = "";
	$(".contentWrap .contentContainer").each(function(indexNumber){

		$(".contentWrap .contentContainer").eq(indexNumber).attr('id', 'index'+(indexNumber+1));

		var indexH2 = $(".contentWrap .contentContainer h2").eq(indexNumber).text(); 
		var indexLink = $(".contentWrap .contentContainer").eq(indexNumber).attr("id");
		strIndex2 = "";
  	$(".contentWrap .contentContainer").eq(indexNumber).find('h3').each(function(sub_index){

  		$(".contentWrap .contentContainer").eq(indexNumber).find('h3').eq(sub_index).attr('id', 'index'+indexNumber+(sub_index+1));
		
  		var indexH3 = $(".contentWrap .contentContainer").eq(indexNumber).find('h3').eq(sub_index).text(); 
  		var indexLink2 = $(".contentWrap .contentContainer").eq(indexNumber).find('h3').eq(sub_index).attr("id");
  		strIndex2 += '<li><a href="#'+indexLink2+'">'+indexH3+'</a></li>\n';
		});
		strIndex += '<li><a href="#'+indexLink+'">'+indexH2+'</a>\n<dl>'+strIndex2+'</dl></li>\n';
	});
	$(indexView).html("<ul>\n"+strIndex+"\n</ul>");

}

