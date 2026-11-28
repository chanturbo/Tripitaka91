<?php
// รับค่า POST จาก AJAX
// Get parameters from the request

// --- เริ่ม: พอร์ตมาจากการแสดงผลฝั่งแอป (lib/features/book/pageviews_html.dart)
// เพื่อให้หน้าทดสอบนี้แสดงผลเหมือนในแอป: ล้างแท็กเก่า/ที่เพี้ยนออกจาก
// book_detail, ตรวจจับบรรทัดหัวข้อ (ตัวหนา) ก่อนล้างแท็ก, และแปลงโทเค็น
// เชิงอรรถ supNNNsup ให้เป็น <sup>NNN</sup> จริง (รองรับทั้งเลขไทย/อารบิก)
function tri91IsHeaderTaggedLine($raw) {
    // PHP 8.1+ deprecates passing null into preg_match_all()/strtoupper()/
    // preg_replace() (internal functions, non-nullable params) — cast first
    // so a NULL book_detail can never leak a warning into the AJAX response.
    $raw = (string) $raw;
    if (!preg_match_all('/<[^>]*>/u', $raw, $m)) {
        return false;
    }
    foreach ($m[0] as $tag) {
        $core = strtoupper((string) preg_replace('/[^A-Za-z0-9]/u', '', $tag));
        if (in_array($core, ['B', 'H1', 'H2', 'H3', 'H4'], true)) {
            return true;
        }
    }
    return false;
}

function tri91CleanLegacyTags($text) {
    $text = (string) $text;
    static $replacements = [
        '<  /B>' => '', '<  /SUP>' => '', '<  /H1>' => '', '<  /H2>' => '',
        '< /B>' => '', '< /H1>' => '', '< /H2>' => '',
        '<ฺฺB>' => '', '<ฺฺ/B>' => '',
        '</็H2>' => '', '<H/1>' => '', '</H2 >' => '', '</3 1>' => '',
        '</SUP' => '', '/SUP>' => '', 'SUP>' => '', '</H >' => '',
        '/B>' => '', '</H4' => '', '</H3' => '', '</H2' => '', '</H1' => '',
        '</I' => '', '</B' => '', 'H1>' => '', 'B>' => '',
        '</' => '', '<' => '', '>' => '',
    ];
    return str_replace(array_keys($replacements), array_values($replacements), $text);
}

function tri91RenderFootnotes($text) {
    return (string) preg_replace('/sup([๐-๙0-9]+)sup/iu', '<sup>$1</sup>', (string) $text);
}

// ต้นฉบับเว้นวรรคคั่นคำ/ย่อหน้าด้วยช่องว่างหลายตัว (3-8 ตัว) แต่ HTML จะยุบช่องว่าง
// ติดกันเหลือตัวเดียวเสมอ (ต่างจาก Flutter Text ที่ไม่ยุบ) ทำให้ระยะย่อหน้าบนเว็บ
// หายไปเมื่อเทียบกับแอป จึงแปลงช่องว่างในแต่ละ "ชุดที่ติดกันตั้งแต่ 2 ตัวขึ้นไป"
// เป็น &nbsp; เพื่อให้เบราว์เซอร์คงความกว้างไว้ (ช่องว่างเดี่ยวระหว่างคำปล่อยไว้ตามเดิม
// เพื่อให้ยังตัดขึ้นบรรทัดใหม่ตรงนั้นได้ตามปกติ) จอแคบ (มือถือ, screen=1) ย่อเหลือ 2 ตัว
// เสมอ เหมือน isSmallScreen ในแอป จอกว้างคงจำนวนเดิมไว้ทั้งหมด
function tri91PreserveIndentSpacing($text, $screen) {
    return preg_replace_callback('/ {2,}/', function ($m) use ($screen) {
        $len = ($screen == 1) ? 2 : strlen($m[0]);
        return str_repeat('&nbsp;', $len);
    }, (string) $text);
}
// --- จบส่วนที่พอร์ตมาจากแอป

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
			// ขนาดตัวอักษรของรายละเอียด: 3 ระดับตาม breakpoint เดิมของ
			// .tri-font-detail ใน tri91_old/css/tri-font.css แต่ปรับจอเล็กสุด
			// (≤480px) จาก 24 เป็น 25 ตามที่ขอ (เดิมเล็กไป) ส่วน 481-767px=25,
			// ≥768px=26 ยังเท่าเดิม — กำหนดตรงๆ ในไฟล์นี้แทนที่จะพึ่ง CSS
			// ที่ใช้ร่วมกับหน้าอื่น
			$screen_width = $_POST['screen_width'] ?? 768;
			if ($screen_width <= 480){
				$detail_font_size = 26;
			}elseif ($screen_width <= 767){
				$detail_font_size = 25;
			}else{
				$detail_font_size = 26;
			}
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
				    if ($screen == 1){
					$intro_div_style = "color:#475859;font-size:{$detail_font_size}px;line-height:1.35;text-align:center;";
				    }else{
					$intro_div_style = "color:#475859;font-size:{$detail_font_size}px;line-height:1.35;display:table;margin:0 auto;max-width:100%;text-align:left;";
				    }
				    if ($row['book_detail'] == "LineNull"){
					$book_detail_text = "<div class=\"tri-font-detail\" style=\"{$intro_div_style}\"><br></div>";
				    }else{
					$is_header_line = tri91IsHeaderTaggedLine($row['book_detail']);
					$clean_text = tri91PreserveIndentSpacing(tri91RenderFootnotes(tri91CleanLegacyTags($row['book_detail'])), $screen);
					if ($is_header_line) {
					    $clean_text = "<span style=\"font-weight:500;\">" . $clean_text . "</span>";
					}
				    	$book_detail_text = "<div class=\"tri-font-detail\" style=\"{$intro_div_style}\"> " .$clean_text ."<br></div>";
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

                            // ตำแหน่ง/ความกว้างให้ตรงกับแอป (lib/features/book/pageviews_html.dart):
                            // เนื้อหาถูกจำกัดความกว้างสูงสุด 700px กึ่งกลางจอ (ไม่ใช่เต็มความกว้าง
                            // พาเนลแบบเดิม) และบรรทัดหัวข้อ (ชื่อเล่ม-หน้าที่) ขยับย่อหน้าเพิ่มตาม
                            // หมวด: พระวินัยปิฎก (1-10) และพระอภิธรรมปิฎก (75-91) ขยับ 10 เคาะ,
                            // พระสุตตันตปิฎก (11-74) ขยับ 8 เคาะ — คำนวณจาก fontSize เดสก์ท็อป
                            // ของแอป (24) เหมือนสูตร headerIndent * _fontSize * 0.25 ในแอป
                            // เหมือนแอป: จอแคบ (isSmallScreen) ไม่เยื้องเลย (headerIndent = 0)
                            $is_vinaya_or_abhidhamma = ($book_id >= 1 && $book_id <= 10) || ($book_id >= 75 && $book_id <= 91);
                            $is_suttanta = ($book_id >= 11 && $book_id <= 74);
                            $header_indent_chars = ($screen == 1) ? 0 : ($is_vinaya_or_abhidhamma ? 10 : ($is_suttanta ? 8 : 0));
                            $header_indent_px = $header_indent_chars * 24 * 0.25;

                            // จอแคบ (มือถือ, screen=1): ไม่มีที่ว่างพอสำหรับกล่องหดพอดีเนื้อหา +
                            // ไอคอนดินสอ/เลขบรรทัดตรึงขอบจริง จึงจัดกึ่งกลางแบบธรรมดาแทน เหมือนแอป
                            // (isSmallScreen ? TextAlign.center) จอกว้างยังใช้กล่องหดพอดี + ไอคอน/
                            // เลขบรรทัดตรึงขอบจริงเหมือนเดิม
                            $gutter_left_style = ($screen == 1) ? '' : 'position:absolute;left:0;';
                            $gutter_right_style = ($screen == 1) ? '' : 'position:absolute;right:0;';

                            // Loop through rows to display book details
                            for ($i = $start_row; $i < $start_row + $row_count; $i++) {
                            	if ($i > $book_pageMax){break;}
	                        $chk_book_line =0;
                                // ตำแหน่ง/ความกว้างของ "รายละเอียด" (เนื้อหาตัวบท) คืนกลับไปเหมือนเดิม
                                // ก่อนที่จะเริ่มลองจำกัด max-width:700px (ผู้ใช้ขอให้คืนค่านี้) — เหลือ
                                // ไว้แค่กล่องหัวเรื่องที่ยังเยื้องข้อความซ้าย/ขวาตามหมวดหนังสือด้านล่าง
                                // ใช้ padding-left แทน margin-left: พื้นหลังสีเทาของกล่องหัวเรื่องยังเต็ม
                                // ความกว้างคอลัมน์เหมือนเดิม (ไม่ถูกบีบแคบจากด้านซ้าย) มีแค่ตัวอักษร
                                // ข้างในที่ถูกเยื้องขวาเข้ามาตามหมวดหนังสือ
                                echo "<div class=\"well well-sm tri-font-24\" style=\"color:#475859;font-weight:800;text-align:center;padding-left:{$header_indent_px}px;\">" . $book_title . " - หน้าที่ " . $i ."</div>";

                                $sql = "SELECT * FROM tripitaka91_91book_line WHERE book_id = :book_id AND book_pages = :page ORDER BY book_line";
                                $stmt = $conn->prepare($sql);
                                $stmt->bindParam(':book_id', $book_id, PDO::PARAM_INT);
                                $stmt->bindParam(':page', $i, PDO::PARAM_INT);
                                $stmt->execute();
                                $book_detail = "";

                                while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                                    $is_header_line = ($row["book_detail"] !== "LineNull") && tri91IsHeaderTaggedLine($row["book_detail"]);
                                    $book_detail_text = ($row["book_detail"] == "LineNull") ? "<br>" : tri91PreserveIndentSpacing(tri91RenderFootnotes(tri91CleanLegacyTags($row["book_detail"])), $screen);
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
					    $targetDate2 = strtotime('2026-08-30'); // บวชถึงวันที่ 29 ส.ค. 2026 (รวมวันนั้น) จึงใช้ 30 ส.ค. เป็นขอบเขตบนแบบ exclusive
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
				            $book_detail .= "<span style=\"{$gutter_left_style}\"><span class=\"showCorrect\" title=\"<u>บรรทัดนี้มีการแจ้งคำที่น่าจะผิดภาษาไทย</u> <br>$tmpCorrection\"><i class=\"fa fa-edit\"></i></span></span>";
				        }

                                    // Highlight search keywords
                                    if (!empty($keyword)) {
                                        $keyword = str_replace(" ", "+", $keyword);
                                        $keywords = explode("+", $keyword);
                                        foreach ($keywords as $keyword_replace) {
                                            $book_detail_text = str_ireplace($keyword_replace, "<span style=\"color: red;\">$keyword_replace</span>", $book_detail_text);
                                        }
                                    }

                                    // บรรทัดหัวข้อ (เดิมมีแท็ก <B>/<H1>-<H4> ก่อนล้างแท็ก) ให้ตัวหนาเหมือนแอป
                                    if ($is_header_line && $book_detail_text !== "<br>") {
                                        $book_detail_text = "<span style=\"font-weight:500;\">" . $book_detail_text . "</span>";
                                    }

                                    // Display book detail
                                    if (($book_line == $book_lines) && ($book_pages == $i) && ($chk_book_line == '0')){
						if($book_lines=='7'){
							$book_detail_text = "<span class=\"badge badge-warning1\"><span class=\"tri-font-detail\" id=\"middle\">" .$book_detail_text ."</span></span>";
							if (($screen == 0) && ($row["book_detail"] != "LineNull")){
							$book_detail = $book_detail . $book_detail_text . "<span style=\"{$gutter_right_style}\"><span class=\"hide-line\"><span class=\"badge badge-warning1\"><span class=\"tri-font-detail\">" . $book_lines . "</span></span></span></span><br>";
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
							$book_detail = $book_detail . $book_detail_text . "<span style=\"{$gutter_right_style}\"><span class=\"hide-line\"><span class=\"badge badge-warning1\"><span class=\"tri-font-detail\">" . $book_lines . "</span></span></span></span><br>";
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
							$book_detail = $book_detail . $book_detail_text . "<span style=\"{$gutter_right_style}\"><span class=\"hide-line\"><span class=\"badge badge-warning1\"><span class=\"tri-font-detail\">" . $book_lines . "</span></span></span></span><br>";
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
							$book_detail = $book_detail . $book_detail_text . "<span style=\"{$gutter_right_style}\" id=\"middle\"><span class=\"hide-line\">" . $book_lines . "</span></span><br>";
							}else{
								$book_detail = $book_detail . $book_detail_text . "<span style=\"{$gutter_right_style}\" id=\"middle\"></span><br>";
							}
						}elseif($book_lines=='17'){
							if (($screen == 0) && ($row["book_detail"] != "LineNull")){
							$book_detail = $book_detail . $book_detail_text . "<span style=\"{$gutter_right_style}\" id=\"bottom\"><span class=\"hide-line\">" . $book_lines . "</span></span><br>";
							}else{
								$book_detail = $book_detail . $book_detail_text . "<span style=\"{$gutter_right_style}\" id=\"bottom\"></span><br>";
							}
						}else{
							if (($screen == 0) && ($row["book_detail"] != "LineNull")){
							$book_detail = $book_detail . $book_detail_text . "<span style=\"{$gutter_right_style}\"><span class=\"hide-line\">" . $book_lines . "</span></span><br>";
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

                                if ($screen == 1){
                                    echo "<div class=\"tri-font-detail\" style=\"color:#475859;font-size:{$detail_font_size}px;line-height:1.35;text-align:center;\">$book_detail<br></div>";
                                }else{
                                    echo "<div style=\"position:relative;padding:0 36px;\"><div class=\"tri-font-detail\" style=\"color:#475859;font-size:{$detail_font_size}px;line-height:1.35;display:table;margin:0 auto;max-width:100%;text-align:left;\">$book_detail<br></div></div>";
                                }
                            }
			}
?>
