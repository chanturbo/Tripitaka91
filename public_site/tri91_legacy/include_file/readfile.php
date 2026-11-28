<?php
    $f_contents = file("txt/tripitaka91.txt"); 
    //$line = $f_contents[rand(0, count($f_contents) - 1)];
	$line = $f_contents[rand(0,18355 - 1)];
	$word = (explode("|",$line));
	//fclose($f_contents);
?>