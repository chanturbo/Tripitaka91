<?php
// รับค่า POST จาก AJAX
// Get parameters from the request

			include('workspace/db_connect.php');
			$database = new Database();
		        // Get the database connection
		        $conn = $database->getConnection();
		        
                        $book_pages = $_POST['book_page'] ?? '1';
			$start_row = $book_pages;
			$book_id = $_POST['book_id'] ?? '1';
			$book_line = $_POST['book_line'] ?? '1';
			$book_pageMax = $_POST['book_pageMax'] ?? '1';
			$keyword = $_POST['keyword'] ?? '';
			$book_line = trim($book_line);
			$screen = $_POST['screen'];		
                        $row_count = $_POST['row_count'] ?? '3';
			if ($book_pages <= 0){
				
				$sql = "
				    SELECT * 
				    FROM tripitaka91_91book_line
				    WHERE book_id = :book_id AND book_pages = :book_pages
				    ORDER BY book_line
				";

				$stmt = $conn->prepare($sql);
				$stmt->bindValue(':book_id', 0, PDO::PARAM_INT);
				$stmt->bindValue(':book_pages', 1, PDO::PARAM_INT);
				$stmt->execute();

				// วนลูปแสดงข้อมูลแต่ละแถวจากคำสั่ง SQL
				while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				    if ($row['book_detail'] == "LineNull"){
					$book_detail_text = "<div style=\"text-align: center\" class=\"tri-font-detail\"><br></div>";
				    }else{
				    	$book_detail_text = "<div style=\"text-align: center\" class=\"tri-font-detail\"> " .$row['book_detail'] ."<br></div>";
				    }
				    echo "$book_detail_text";
				}

				            
			}else{
                            // Fetch book title and maximum page count
                            $sql = "SELECT * FROM tripitaka91_91title_1 WHERE book_ids = :book_id";
                            $stmt = $conn->prepare($sql);
                            $stmt->bindParam(':book_id', $book_id, PDO::PARAM_INT);
                            $stmt->execute();
                            $row = $stmt->fetch(PDO::FETCH_ASSOC);
                            $book_title = $row["book_title_tri"];                                                   

                            // Ensure start row does not exceed maximum page count
                            $start_row = min($start_row, $book_pageMax);
	
                            // Loop through rows to display book details
                            for ($i = $start_row; $i < $start_row + $row_count; $i++) {
                            	if ($i > $book_pageMax){break;}
	                        $chk_book_line =0;
                                echo "<div style=\"text-align: center\" class=\"well well-sm tri-font-24\">" . $book_title . " - หน้าที่ " . $i ."</div>";

                                $sql = "SELECT * FROM tripitaka91_91book_line WHERE book_id = :book_id AND book_pages = :page ORDER BY book_line";
                                $stmt = $conn->prepare($sql);
                                $stmt->bindParam(':book_id', $book_id, PDO::PARAM_INT);
                                $stmt->bindParam(':page', $i, PDO::PARAM_INT);
                                $stmt->execute();
                                $book_detail = "";
                                
                                while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                                    $book_detail_text = ($row["book_detail"] == "LineNull") ? "<br>" : $row["book_detail"];
                                    $book_lines = $row["book_lines"];
                                    
                                    $tmp_bookid = $row["book_id"];
				    $tmp_bookpages = $row["book_pages"];
				    $tmp_bookline = $book_lines;

				    // ตรวจสอบการแก้ไขจาก log_edit
				    $sql = "SELECT log_edit.*, users.*
				            FROM log_edit                             
				            INNER JOIN users ON (log_edit.tripitaka91_user = users.username)
				            WHERE log_edit.tripitaka91_book = :tmp_bookid
				            AND log_edit.tripitaka91_page = :tmp_bookpages 
				            AND log_edit.tripitaka91_line = :tmp_bookline";
				    
				    $stmt_correct = $conn->prepare($sql);
				    $stmt_correct->bindValue(':tmp_bookid', $tmp_bookid, PDO::PARAM_INT);
				    $stmt_correct->bindValue(':tmp_bookpages', $tmp_bookpages, PDO::PARAM_INT);
				    $stmt_correct->bindValue(':tmp_bookline', $tmp_bookline, PDO::PARAM_INT);
				    $stmt_correct->execute();
				    $result_correct = $stmt_correct->fetchAll(PDO::FETCH_ASSOC);

				    if (count($result_correct) > 0) {
					$show_correct = true;
					$tmpCorrection = '';
					
					foreach ($result_correct as $row_correct) {
					    // กำหนดวันที่เป้าหมายที่ต้องการเปรียบเทียบ
					    $targetDate1 = strtotime('2023-11-13'); // วันที่เริ่มบวช
					    $targetDate2 = strtotime('2026-08-30'); // วันที่สึกเป็นฆราวาส
					    $dateAdd = strtotime($row_correct["tripitaka91_dateadd"]); // แปลงวันที่ในฐานข้อมูลเป็น timestamp

					    // **เพิ่มการตรวจสอบ username ที่นี่**
					    if ($row_correct["username"] == "Rotor206") {
						if ($dateAdd < $targetDate1) {
							$displayFirstNameId = 'นาย'; // ก่อนบวช
						} elseif ($dateAdd < $targetDate2) {
							$displayFirstNameId = 'พระ'; // ช่วงที่ยังเป็นพระ
						} else {
							$displayFirstNameId = 'นาย'; // สึกแล้ว
						}
					    } else {
						$displayFirstNameId = $row_correct["first_nameid"]; // ใช้ค่าจากฐานข้อมูล
					    }

					$tmpCorrection .= "คำที่น่าจะผิด: <strong><font color=blue>" . $row_correct["tripitaka91_wordincorrect"] . "</font></strong> คำที่น่าจะถูก: <strong><font color=blue>" . $row_correct["tripitaka91_wordcorrect"] . "</font></strong> แจ้งโดย: " . $displayFirstNameId . $row_correct["firstName"] . " " . $row_correct["lastName"] . "<br>";
					}			

					if ($row_correct["book_suscess"] == 1) {
						$tmpCorrectionComment = "หมายเหตุ: <font color=green>มีการแก้ไขข้อมูลแล้ว</font><br>";
					}else if ($row_correct["book_suscess"] == 0) {
						if ($row_correct["book_confirm"] == 0) {
							$tmpCorrectionComment = "หมายเหตุ: <font color=red>ยังไม่มีการแก้ไข</font><br>";
						}else{
							$tmpCorrectionComment = "หมายเหตุ: <font color=orange>อยู่ในกระบวนการแก้ไขข้อมูล</font><br>";
						}
						
					}
					$tmpCorrection .= $tmpCorrectionComment;
					
				} else {
					$show_correct = false;
				}
				    
				    // แสดงผลรายละเอียดของหนังสือ
                    
				        if ($show_correct) {
				            $book_detail .= "<span class=\"pull-left\"><span class=\"showCorrect\" title=\"<u>บรรทัดนี้มีการแจ้งคำที่น่าจะผิดภาษาไทย</u> <br>$tmpCorrection\"><i class=\"fa fa-edit\"></i></span></span>";
				        }
				        
                                    // Highlight search keywords
                                    if (!empty($keyword)) {
                                        $keyword = str_replace(" ", "+", $keyword);
                                        $keywords = explode("+", $keyword);
                                        foreach ($keywords as $keyword_replace) {
                                            $book_detail_text = str_ireplace($keyword_replace, "<span style=\"color: red;\">$keyword_replace</span>", $book_detail_text);
                                        }
                                    }
                                    
                                    // Display book detail
                                    if (($book_line == $book_lines) && ($book_pages == $i) && ($chk_book_line == '0')){
						if($book_lines=='7'){
							$book_detail_text = "<span class=\"badge badge-warning1\"><span class=\"tri-font-detail\" id=\"middle\">" .$book_detail_text ."</span></span>";
							if (($screen == 0) && ($row["book_detail"] != "LineNull")){
							$book_detail = $book_detail . $book_detail_text . "<span class=\"pull-right\"><span class=\"hide-line\"><span class=\"badge badge-warning1\"><span class=\"tri-font-detail\">" . $book_lines . "</span></span></span></span><br>";
							}else{
								if ($row["book_detail"] == "LineNull"){
									$book_detail = $book_detail . "<br>";
								}else{
									$book_detail = $book_detail . $book_detail_text . "<br>";
								}
							}
							$chk_book_line++;						
						}elseif($book_lines=='17'){
							$book_detail_text = "<span class=\"badge badge-warning1\"><span class=\"tri-font-detail\" id=\"bottom\">" .$book_detail_text ."</span></span>";
							if (($screen == 0) && ($row["book_detail"] != "LineNull")){
							$book_detail = $book_detail . $book_detail_text . "<span class=\"pull-right\"><span class=\"hide-line\"><span class=\"badge badge-warning1\"><span class=\"tri-font-detail\">" . $book_lines . "</span></span></span></span><br>";
							}else{
								if ($row["book_detail"] == "LineNull"){
									$book_detail = $book_detail . "<br>";
								}else{
									$book_detail = $book_detail . $book_detail_text . "<br>";
								}
							}
							$chk_book_line++;
						}else{
							$book_detail_text = "<span class=\"badge badge-warning1\"><span class=\"tri-font-detail\">" .$book_detail_text ."</span></span>";
							if (($screen == 0) && ($row["book_detail"] != "LineNull")){
							$book_detail = $book_detail . $book_detail_text . "<span class=\"pull-right\"><span class=\"hide-line\"><span class=\"badge badge-warning1\"><span class=\"tri-font-detail\">" . $book_lines . "</span></span></span></span><br>";
							}else{
								if ($row["book_detail"] == "LineNull"){
									$book_detail = $book_detail . "<br>";
								}else{
									$book_detail = $book_detail . $book_detail_text . "<br>";
								}
								
							}
							$chk_book_line++;
						}
                                    }else{
                                    		if($book_lines=='7'){
							if (($screen == 0) && ($row["book_detail"] != "LineNull")){
							$book_detail = $book_detail . $book_detail_text . "<span class=\"pull-right\" id=\"middle\"><span class=\"hide-line\">" . $book_lines . "</span></span><br>";
							}else{
								$book_detail = $book_detail . $book_detail_text . "<span class=\"pull-right\" id=\"middle\"></span><br>";
							}
						}elseif($book_lines=='17'){
							if (($screen == 0) && ($row["book_detail"] != "LineNull")){
							$book_detail = $book_detail . $book_detail_text . "<span class=\"pull-right\" id=\"bottom\"><span class=\"hide-line\">" . $book_lines . "</span></span><br>";
							}else{
								$book_detail = $book_detail . $book_detail_text . "<span class=\"pull-right\" id=\"bottom\"></span><br>";
							}
						}else{
							if (($screen == 0) && ($row["book_detail"] != "LineNull")){
							$book_detail = $book_detail . $book_detail_text . "<span class=\"pull-right\"><span class=\"hide-line\">" . $book_lines . "</span></span><br>";
							}else{
								if ($row["book_detail"] != "LineNull"){
								$book_detail = $book_detail . $book_detail_text . "<br>";
								}else{
								$book_detail = $book_detail . $book_detail_text;
								}
							}
						}
                                    
                                    }
                                    
                                    //$book_detail .= $book_detail_text . "<br>";
                                    
                                }
                                
                                echo "<div style=\"text-align: center\" class=\"tri-font-detail\">$book_detail<br></div>";
                            }
			}
?>

