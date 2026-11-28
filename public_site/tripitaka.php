<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="favicon.png">
    <?php
    include('tri91_old/include_file/webconfig.php');
    ?>
    <title><?php echo $title; ?></title>

    <!-- Bootstrap Core CSS - Uses Bootswatch Flatly Theme: http://bootswatch.com/flatly/ -->
    <link href="tri91_old/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="tri91_old/css/freelancer.css" rel="stylesheet">
    <link href="tri91_old/css/tri-font.css" rel="stylesheet">

    <!-- เริ่มต้นโหลดหน้าให้ซ่อนเลขบรรทัดไว้ก่อน (ผู้ใช้กดปุ่ม "ซ่อน/แสดง หมายเลขบรรทัด" เพื่อแสดงเอง) -->
    <style>
        .hide-line{
            display: none;
        }
    </style>

    <!-- จอเล็ก (มือถือ) เท่านั้น: ปุ่ม "แสดงรายละเอียดในโหมดเว็บแอพ" กับ "แสดงเพิ่มเติม"
         เดิมใช้ pull-left/pull-right ซึ่งพอข้อความยาวจนตัดบรรทัด ทำให้เกิดช่องว่าง
         ตรงกลางเยอะเกินไปและดูไม่เป็นระเบียบ จอกว้างไม่แตะ ยังเป็น pull-left/right เดิม -->
    <style>
        @media (max-width: 649px){
            .tri-nav-buttons{
                display: flex;
                flex-direction: column;
                gap: 8px;
                margin-top: 10px;
            }
            .tri-nav-buttons .pull-left,
            .tri-nav-buttons .pull-right{
                float: none;
                width: 100%;
            }
            .tri-nav-buttons a{
                display: block;
            }
            .tri-nav-buttons .btn{
                width: 100%;
                margin: 0;
            }
        }
    </style>

    <!-- Custom CSS -->
    <link href="tri91_old/css/sb-admin-2.css" rel="stylesheet">

    <link href="tri91_old/js/jquery-ui.min.css" rel="stylesheet">
    <link href="tri91_old/jBox-master/Source/jBox.css" rel="stylesheet">
    <script src="tri91_old/js/ie-emulation-modes-warning.js"></script>

    <link rel="stylesheet" href="tri91_old/multiselect/css/bootstrap-multiselect.css" type="text/css">

    <!-- Custom Fonts -->
    <link href="tri91_old/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
    <link href="tri91_old/css/Montserrat.css" rel="stylesheet" type="text/css">
    <link href="tri91_old/css/Lato.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" type="text/css" href="tri91_old/css/component-2.css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

</head>

<body id="page-top" class="cbp-spmenu-push">
    <?php
    // ดึงความกว้างของหน้าจอ
    $screenWidth = $_SERVER['HTTP_USER_AGENT'];

    // แปลง string เป็น integer
    $screen = 1;

    include('workspace/db_connect.php');

    $database = new Database();
    // Get the database connection
    $conn = $database->getConnection();

    // รับค่าจาก $_REQUEST และตรวจสอบการมีอยู่ของข้อมูล
	$book_id = isset($_REQUEST['book']) && is_numeric($_REQUEST['book']) ? intval($_REQUEST['book']) : 1;
	$book_pages = isset($_REQUEST['page']) && is_numeric($_REQUEST['page']) ? intval($_REQUEST['page']) : 1;
	$book_line = isset($_REQUEST['line']) ? trim($_REQUEST['line']) : 0;
	$keyword = isset($_REQUEST['keyword']) ? $_REQUEST['keyword'] : '';
	$keyword = urldecode($keyword);
	
	// ตรวจสอบค่าที่ส่งมาว่าอยู่ในรูปแบบที่เหมาะสม
	$book_id = max(1, $book_id); // อย่างน้อย book_id ต้องเป็น 1
	$book_pages = max(1, $book_pages); // อย่างน้อย page ต้องเป็น 1
	$book_line = is_numeric($book_line) ? intval($book_line) : 0; // บรรทัดต้องเป็นตัวเลข

	// จำนวนบรรทัดแรก
	$row_count_first = 3;

	// คำนวณหน้าที่ผ่านมา (ห้ามติดลบ)
	$book_pages_back = max(0, $book_pages - 1);

    $sql = "SELECT * FROM tripitaka91_91title_1 WHERE book_ids = :book_id";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':book_id', $book_id, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $book_title = $row["book_title_tri"];
    $book_pageMax = $row["book_pages_total"];

    ?>

    <!-- Navigation -->
    <nav class="navbar navbar-default navbar-fixed-top">
        <div class="container">
            <!-- Brand and toggle get grouped for better mobile display -->
            <div class="navbar-header page-scroll">
            	<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="../"> Tripitaka91.com (TEST)</a>
            </div>
            <!-- Collect the nav links, forms, and other content for toggling -->
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                <ul class="nav navbar-nav navbar-right">
                    <li class="hidden">
                        <a href="#page-top"></a>
                    </li>
                    <li class="page-scroll">
                        <a href="../"><i class="fa fa-home"></i> หน้าหลัก</a>
                    </li>
                    <li class="page-scroll" id="showLeft">
                        <a href="tripitaka91_1.php?book_code=<?php echo $book_id; ?>"><i class="fa fa-home"></i>  สารบัญหัวข้อธรรม เล่ม <?php echo $book_id;?></a>
                    </li>		                    								
                </ul>
			
            </div>
        </div>
        <!-- /.container-fluid -->

    </nav>
    <!-- Header -->
    <header>
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="intro-text">
                    </div>
                </div>
            </div>
        </div>
    </header>

    <section class="show_search">
        <div class="container">
            <div class="col-lg-12">
                <div class="panel panel-info">
                    <div class="panel-heading">
                        <font class="tri-font-24-b">(เล่ม <?php echo $book_id; ?>) <?php echo $book_title; ?> มีทั้งหมด
                            <?php echo number_format($book_pageMax); ?> หน้า</font>
                            <span class="pull-right">
                            
                            <a href="tripitaka91_1.php?book_code=<?php echo $book_id; ?>">
                            <span class="badge tri-font-24-b"><span class="glyphicon glyphicon-home"></span> สารบัญหัวข้อธรรม เล่ม <?php echo $book_id;?></span></a>&nbsp;<a href="../"><span class="badge tri-font-24-b"><span class="glyphicon glyphicon-search"></span> ค้นหาข้อมูล...</span></a></span></span>
                    </div>
                    <div id="title1"></div>
                    <!-- /.panel-heading -->
                    <div class="panel-body" id="showSearch">
			<div class="panel-body">
				<span class="pull-left"><button id="more-data-back" class="btn btn-success">แสดงก่อนหน้า</button></span>
			</div>
				<div id="response"></div>
			
                        <div class="tri-nav-buttons">
                            <span class="pull-left">
                                <a
                                    href='/?book=<?php echo "$book_id"; ?>&page=<?php echo "$book_pages"; ?>&line=<?php echo "$book_line"; ?>'>
                                    <button id="more-data-all" class="btn btn-success">แสดงรายละเอียดในโหมดเว็บแอพ
                                        ...</button>
                                </a>
                            </span>
                            <span class="pull-right"><button id="more-data-next" class="btn btn-success">แสดงเพิ่มเติม</button></span>
                        </div>
                    </div>
                    <!-- /.panel-body -->
                </div>
                <!-- /.panel -->
            </div>
        </div>
    </section>

    <script>
        hide_line = true;
        if (window.innerWidth >= 650) {
            // สร้าง div element
            var divElement = document.createElement("div");
            divElement.id = "config_shared";

            // สร้าง button element
            var buttonElement = document.createElement("button");
            buttonElement.id = "hide_line";
            buttonElement.className = "btn btn-success";

            // สร้าง icon element
            var iconElement = document.createElement("i");
            iconElement.className = "fa fa-chevron-left";

            // เพิ่ม icon element เข้าไปใน button element
            buttonElement.appendChild(iconElement);

            // เพิ่มข้อความและช่องว่างเข้าไปใน button element
            var buttonText = document.createTextNode("\u00a0\u00a0ซ่อน/แสดง หมายเลขบรรทัด");
            buttonElement.appendChild(buttonText);

            // เพิ่ม button element เข้าไปใน div element
            divElement.appendChild(buttonElement);

            // เพิ่ม div element เข้าไปในเอกสาร HTML
            document.body.appendChild(divElement);
        }
    </script>

    <!--
    <div id="config_shared">
        <button id="hide_line" class="btn btn-success"><i class="fa fa-chevron-left"></i>&nbsp;&nbsp;ซ่อน/แสดง หมายเลขบรรทัด</button>
    </div>
    <div id="indicator"><img src="img/page-loader.gif" class="img-responsive"></div>
    -->


    <footer class="text-center">
        <div class="footer-below">
            <div class="container">
                <div class="row">
                    <div class="col-lg-12">
	                    <span class="pull-right">
			<div id="showHitStats" class="tri-font-24"></div>
			</span>
                    </div>
                </div>
            </div>
        </div>
    </footer>

    <!-- Scroll to Top Button (Only visible on small and extra-small screen sizes) -->
    <div class="scroll-top page-scroll visible-xs visible-sm">
        <a class="btn btn-primary" href="#page-top">
            <i class="fa fa-chevron-up"></i>
        </a>
    </div>
    <!-- jQuery -->
    <script src="tri91_old/js/jquery.js"></script>
    <script src="tri91_old/js/jquery-ui.min.js"></script>
    <script src="tri91_old/jBox-master/Source/jBox.min.js"></script>

	<script>

	    window.onload = function () {
		// โหลดข้อมูลครั้งแรก
		sendData(<?php echo $book_id; ?>,
			<?php echo $book_pages; ?>,
			<?php echo $book_line; ?>,
			<?php echo $book_pageMax; ?>,
			<?php echo $row_count_first; ?>,
			"<?php echo addslashes($keyword); ?>",
			false,
			false);
		// เรียกสถิติการเข้าใช้งานครั้งแรก
	        updateHitStats();
	    };

	    // ฟังก์ชันสำหรับอัปเดตสถิติ
	    function updateHitStats() {
		$.ajax({
		    url: "hitstats.php",
		    type: "POST",
		    dataType: "text",
		    cache: false,
		    success: function(result) {
		        $('#showHitStats').html(result);
		    }
		});
	    }
	    
	    // ฟังก์ชันหลักในการส่งข้อมูล
	    function sendData(book_id, book_page, book_line, book_pageMax, row_count_first,keyword,append = false,prepend = false) {
		var screen = window.innerWidth <= 650 ? 1 : 0;
		var screen_width = window.innerWidth;
		if (append){book_line =0;}
		if (prepend){

			row_count_first = 1;
			book_line = 0;
		
		}
		// สร้าง XMLHttpRequest object
		var xhttp = new XMLHttpRequest();

		xhttp.onreadystatechange = function () {
		    if (this.readyState == 4 && this.status == 200) {
		    	let pageBackFirst = parseInt(book_page, 10) - 1;
		    	let pageNext = parseInt(book_page, 10) + row_count_first;
		    	
			if (book_page >= book_pageMax){
				pageNext = book_pageMax;
			}
//console.log(pageNext);
			let pageNextTarget = pageNext;			
			for (let i = 1; i < row_count_first; i++) {				
				if (pageNextTarget > book_pageMax) {			
					break;					
				}
				pageNextTarget = parseInt(pageNextTarget, 10) + 1;
			}
//console.log(pageNextTarget);
			
			let lineLast = book_pageMax - (parseInt(book_page, 10) + row_count_first);
//console.log(lineLast);

			// เมื่อได้ข้อมูลกลับมาจากเซิร์ฟเวอร์
			if (append) {
			    // ถ้า append ข้อมูลให้เพิ่มข้อมูลใหม่ต่อท้าย
			    document.getElementById("response").innerHTML += this.responseText;			    
			    if (pageNextTarget >= book_pageMax) {
				    $('button#more-data-next').text('แสดงเพิ่มเติม หน้าที่ ' + pageNext + ' ถึงหน้าที่ ' + book_pageMax);
			    }else{
				    $('button#more-data-next').text('แสดงเพิ่มเติม หน้าที่ ' + pageNext + ' ถึงหน้าที่ ' + pageNextTarget);
			    }
			    
  			    let linkElement = document.querySelector("a[href*='line']");
			        linkElement.href = `/?book=${book_id}&page=${pageNext-1}&line=0`;
			        
			    if ((pageNextTarget > book_pageMax) && (lineLast < 0)){
			    	$('button#more-data-next').css('display', 'none');
			    	linkElement.href = `/?book=${book_id}&page=${book_pageMax}&line=0`;
			    }

			}else if (prepend) {
			    const currentContent = document.getElementById("response").innerHTML;
			    document.getElementById("response").innerHTML = this.responseText + currentContent;
			    if ((book_page) <= 0){
			    	$('button#more-data-back').css('display', 'none');
			    }else if (book_page == 1){
			    	$('button#more-data-back').text('แสดงคำนำ');
			    }else{
			    	$('button#more-data-back').text('แสดงเพิ่มเติม หน้าที่ ' + (book_page-1));
			    }

			
			} else {
			    // ถ้าไม่ใช่ append ให้แทนที่ข้อมูลเดิม
			    document.getElementById("response").innerHTML = this.responseText;			    
			    
			    if (pageNextTarget >= book_pageMax) {
				    $('button#more-data-next').text('แสดงเพิ่มเติม หน้าที่ ' + pageNext + ' ถึงหน้าที่ ' + book_pageMax);
			    }else{
				    $('button#more-data-next').text('แสดงเพิ่มเติม หน้าที่ ' + pageNext + ' ถึงหน้าที่ ' + pageNextTarget);
				    if(pageBackFirst == 0){
				    $('button#more-data-back').text('แสดงคำนำ');
				    }else{
				    $('button#more-data-back').text('แสดงเพิ่มเติม หน้าที่ ' + pageBackFirst);
				    }
			    }

    			    let linkElement = document.querySelector("a[href*='line']");
				linkElement.href = `/?book=${book_id}&page=${pageNext-1}&line=0`;
				    
			    if ((pageNextTarget > book_pageMax) && (lineLast < 0)){
			    	$('button#more-data-next').css('display', 'none');
			    	linkElement.href = `/?book=${book_id}&page=${book_pageMax}&line=0`;
			    }
			    
			    	if(book_line > '18'){
					document.location.href="#bottom";
				}else if(book_line > '8'){
					document.location.href="#middle";
				}
				

			}

		        // jBox tooltip handled via event delegation (see below)
		    }
		};

		// กำหนด method และ URL ที่จะส่งข้อมูลไปยัง
		xhttp.open("POST", "tri91_process_test.php", true);
		xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

		// ส่งข้อมูล
		var data = "book_id=" + encodeURIComponent(book_id) +
		    "&book_page=" + encodeURIComponent(book_page) +
		    "&book_line=" + encodeURIComponent(book_line) +
		    "&screen=" + screen +
		    "&screen_width=" + encodeURIComponent(screen_width) +
		    "&book_pageMax=" + encodeURIComponent(book_pageMax) +
		    "&row_count=" + encodeURIComponent(row_count_first) +
		    "&keyword=" + encodeURIComponent(keyword);
		    
		xhttp.send(data);
	    }

	    // ฟังก์ชันสำหรับจัดการเมื่อคลิกปุ่ม
	    $(function () {
		var book_id = <?php echo $book_id; ?>;
		var book_page = <?php echo $book_pages; ?>;
		var book_line = <?php echo $book_line; ?>;
		var book_pageMax = <?php echo $book_pageMax; ?>;
		var row_count = <?php echo $row_count_first; ?>;
	        var start_row_back = <?php echo $book_pages; ?>;
	        var keyword = "<?php echo addslashes($keyword); ?>";
		// เมื่อคลิกปุ่ม "แสดงเพิ่มเติม"
		$('button#more-data-next').click(function () {		   				
		        book_page = parseInt(book_page, 10) + row_count;
		        sendData(book_id, book_page, book_line, book_pageMax, row_count,keyword, true); // append ข้อมูลใหม่
		    
		});
		// เมื่อคลิกปุ่ม "back"
		$('button#more-data-back').click(function () {	
			start_row_back = start_row_back - 1;
			if (start_row_back  < 0){
				start_row_back = 0;
			}
		        sendData(book_id, start_row_back, 0, book_pageMax, row_count,keyword, false,true); // append ข้อมูลใหม่
		    
		});		
	    });
	</script>

    
    <script type="text/javascript">
        $('#hide_line').click(function () {
            if (hide_line) {
                $('.hide-line').css('display', 'block');
                hide_line = false;
            } else {
                $('.hide-line').css('display', 'none');
                hide_line = true;
            }
        });

    </script>

    <!-- Bootstrap Core JavaScript -->
    <script src="tri91_old/js/bootstrap.min.js"></script>

    <script src="tri91_old/js/ie10-viewport-bug-workaround.js"></script>

    <!-- Plugin JavaScript -->
    <script src="tri91_old/js/jquery.easing.min.js"></script>
    <script src="tri91_old/js/classie.js"></script>
    <script src="tri91_old/js/cbpAnimatedHeader.js"></script>

    <script src="tri91_old/js/modernizr.custom.js"></script>

    <!-- Contact Form JavaScript -->
    <script src="tri91_old/js/jqBootstrapValidation.js"></script>
    <script src="tri91_old/js/contact_me.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="tri91_old/js/metisMenu/dist/metisMenu.min.js"></script>


    <!-- Custom Theme JavaScript -->
    <script src="tri91_old/js/sb-admin-2.js"></script>

    <!-- Custom Theme JavaScript -->
    <script src="tri91_old/js/freelancer.js"></script>

    
    <script>
    // jBox tooltip via event delegation — ไม่ bind ซ้ำ รองรับ element ที่ append ใหม่ได้เสมอ
    var jBoxInstance = null;
    var jBoxCloseTimer = null;

    $(document).on('mouseenter', '.showCorrect', function () {
        var $el = $(this);
        var $titleHolder = $el.children('[title]').length ? $el.children('[title]') : $el;

        // เอา title ของเบราว์เซอร์ออกไปเก็บใน data-tip แทน (ทำครั้งเดียว) กันไม่ให้
        // tooltip ดั้งเดิมของเบราว์เซอร์ (แสดง HTML แบบดิบ ไม่ใช่ข้อความที่จัดรูปแบบแล้ว)
        // ขึ้นซ้อนทับกับกล่อง jBox ที่เราสร้างเอง
        if ($titleHolder.attr('title')) {
            $titleHolder.attr('data-tip', $titleHolder.attr('title'));
            $titleHolder.removeAttr('title');
        }

        var titleContent = $titleHolder.attr('data-tip') || '';
        if (!titleContent) return;

        // ยกเลิก timer ปิดถ้าเมาส์กลับเข้ามา
        if (jBoxCloseTimer) {
            clearTimeout(jBoxCloseTimer);
            jBoxCloseTimer = null;
        }

        if (jBoxInstance) {
            jBoxInstance.destroy();
            jBoxInstance = null;
        }

        jBoxInstance = new jBox('Tooltip', {
            content: titleContent,
	    target: $el,

	    position: {
		x: 'right',
		y: 'center'
	    },
	    outside: 'x',
	    offset: { x: -10, y: 10 },  
	    adjustPosition: true,
	    adjustTracker: true,
	    boundary: 'window',   // ⭐ สำคัญมาก
	    pointer: true,
	    animation: false,
	    closeOnMouseleave: false,
            onCreated: function () {
                var self = this;
                // เมื่อเมาส์เข้า jBox wrapper ให้ยกเลิก timer ปิด
                $(self.wrapper).on('mouseenter', function () {
                    if (jBoxCloseTimer) {
                        clearTimeout(jBoxCloseTimer);
                        jBoxCloseTimer = null;
                    }
                });
                // เมื่อเมาส์ออกจาก jBox wrapper ให้ปิด
                $(self.wrapper).on('mouseleave', function () {
                    jBoxCloseTimer = setTimeout(function () {
                        if (jBoxInstance) {
                            jBoxInstance.close();
                        }
                    }, 100);
                });
            }
        });
        jBoxInstance.open();
    });

    $(document).on('mouseleave', '.showCorrect', function () {
        // หน่วงเวลาเล็กน้อยเพื่อให้เมาส์มีโอกาสเข้า jBox wrapper ก่อน
        jBoxCloseTimer = setTimeout(function () {
            if (jBoxInstance) {
                jBoxInstance.close();
            }
        }, 100);
    });
    </script>

    <script>
    /*
        $("html, body").delay(2000).animate({ scrollTop: $('#title1').offset().top }, 2000);
    */
    </script>
</body>

</html>
