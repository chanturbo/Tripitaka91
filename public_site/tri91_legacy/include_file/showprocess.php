<?php
	$mtime = microtime();
	$mtime = explode(" ",$mtime);
	$mtime = $mtime[1] + $mtime[0];
	$endtime = $mtime;
	$totaltime = round(($endtime - $starttime),4);
	echo " (หน้านี้ประมวลผล ".$totaltime." วินาที)";
?>