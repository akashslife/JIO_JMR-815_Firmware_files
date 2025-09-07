<?php


//------------------------------------------------------------------------------
function free_cache()
{
  @system("sync;echo 1 > /proc/sys/vm/drop_caches");
}
//------------------------------------------------------------------------------
function download_item($dir, $item) {		// download file
	if(Verify_csrf($GLOBALS["token"])==0) {
		show_csrf_error($GLOBALS["error_msg"]["csrferror"]);
	}	
	// Security Fix:
	$item=preg_replace( '/^.+[\\\\\\/]/', '', $item ); //basename($item);
	
	if(($GLOBALS["permissions"]&01)!=01) show_error($GLOBALS["error_msg"]["accessfunc"]);

	$file = get_abs_item($dir,$item);

	if(!file_exists($file) or $file==='' or !is_readable($file)){
	  header('HTTP/1.1 404 File not found',true);
	  exit;
	}
	
	$mime = "application/octet-stream"; // The MIME type of the file, this should be replaced with your own.
	header('Content-type: ' . $mime); // Send the content type header
	header('Content-Disposition: attachment; filename="'.$item.'"');
	$size = getfilesize($file); // The size of the file  

	header('Cache-Control: no-cache, must-revalidate');
  	header('Expires: Sat, 01 Jan 2000 00:00:00 GMT'); 
	header('Content-Transfer-Encoding: binary');
	header('Pragma: no-cache');
	
	ini_set('max_execution_time', 0); 
	$READ_RANGE=4096000*2;
	session_write_close(); //for with another request
	if(isset($_SERVER['HTTP_RANGE'])){ // Check if it's a HTTP range request

		$ranges = array_map(
		        'intval', // Parse the parts into integer
		        explode(
		            '-', // The range separator
		            substr($_SERVER['HTTP_RANGE'], 6) // Skip the `bytes=` part of the header
		        )
		);
		if($ranges[0] > 0) { $seek_start = intval($ranges[0]); }
		else $seek_start = 0;
    
    $ranges[1] = $seek_start+ $READ_RANGE -1;
    if($ranges[1] >=$size)
        $ranges[1] = $size - 1;
        
    // Send the appropriate headers
    header('HTTP/1.1 206 Partial Content');
    header('Accept-Ranges: bytes');

    header('Content-Length: ' . ($ranges[1] - $ranges[0] +1)); // The size of the range
    //header('Content-Length: ' . $size-$seek_start);    
 
    // Send the ranges we offered

    header(
        sprintf(
            'Content-Range: bytes %d-%d/%d', // The header format
            $ranges[0], // The start range
            $ranges[1], // The end range
            $size // Total size of the file
        )
    );
 
    // It's time to output the file
    $f = fopen($file, 'rb'); // Open the file in binary mode
    $chunkSize = $READ_RANGE/200; // The size of each chunk to output
 
    // Seek to the requested start range
    fseek($f, $ranges[0]);
 
    // Start outputting the data
    while(true){
        // Check if we have outputted all the data requested
        if(ftell($f) >= $ranges[1]){
            break;
        }
 
        // Output the data
        echo fread($f, $chunkSize);
        // Flush the buffer immediately
        flush();
    }
   	fclose($f);
		free_cache();
}
else 
{
  // It's not a range request, output the file anyway
  header('Content-Length: ' . $size);
	Header( "X-LIGHTTPD-send-file: " . $file);
	$fp = fopen($file, 'rb');

	while (!feof($fp)) {
		echo fread($fp, $READ_RANGE/2);
		flush();
		
	free_cache();

	}
	fclose($fp);

}
exit;

}
//------------------------------------------------------------------------------
?>
