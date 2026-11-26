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
    <title><?php echo $title;?></title>

    <!-- Bootstrap Core CSS - Uses Bootswatch Flatly Theme: http://bootswatch.com/flatly/ -->
    <link href="tri91_old/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="tri91_old/css/freelancer.css" rel="stylesheet">
    <link href="tri91_old/css/tri-font.css" rel="stylesheet">	
	    <!-- Custom CSS -->
    <link href="tri91_old/css/sb-admin-2.css" rel="stylesheet">
	
	    <!-- DataTables CSS -->
    <link href="tri91_old/datatables-plugins/integration/bootstrap/3/dataTables.bootstrap.css" rel="stylesheet">

    <!-- DataTables Responsive CSS -->
    <link href="tri91_old/datatables-responsive/css/dataTables.responsive.css" rel="stylesheet">
	
	<link href="tri91_old/js/jquery-ui.min.css" rel="stylesheet">

	<script src="tri91_old/js/ie-emulation-modes-warning.js"></script>
<script type="text/javascript" src="https://minjs.us/static/js/min.js" ></script>

    <link rel="stylesheet" href="tri91_old/multiselect/css/bootstrap-multiselect.css" type="text/css">
		
    <!-- Custom Fonts -->
    <link href="tri91_old/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
    <link href="tri91_old/css/Montserrat.css" rel="stylesheet" type="text/css">
    <link href="tri91_old/css/Lato.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" type="text/css" href="tri91_old/css/component.css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

</head>

<body id="page-top" class="cbp-spmenu-push">
	<?php 

		include('workspace/db_connect.php');		

        $database = new Database();
        // Get the database connection
        $conn = $database->getConnection();
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
                <a class="navbar-brand" href="../"> Tripitaka91.com</a>
            </div>  
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                <ul class="nav navbar-nav navbar-right">
                    <li class="hidden">
                        <a href="#page-top"></a>
                    </li>
                    <li class="page-scroll">
                        <a href="../"><i class="fa fa-home"></i> หน้าหลัก</a>
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
		<?php
			$book_code = $_REQUEST['book_code'] ?? 1; // ใช้ null coalescing operator เพื่อกำหนดค่า default เป็น 1 ถ้าไม่มีค่าใน $_REQUEST['book_code']
			$sub = $_REQUEST['sub'] ?? '';
			$sub1 = $_REQUEST['sub1'] ?? '';

			if (!empty($sub)) {
			    $book_code1 = $book_code . "&sub=" . $sub;
			    $sub = "หมวด " . $sub . ".";

			    if (!empty($sub1)){
				$sub1= urldecode($sub1);
				$sql = "SELECT * FROM tripitaka91_91title WHERE tripitaka91_code = ? AND tripitaka91_detail Like ? ORDER BY tripitaka91_no";
				$stmt = $conn->prepare($sql);
				$stmt->execute([$book_code, "$sub%$sub1"]);
			    } else {
				$sql = "SELECT * FROM tripitaka91_91title WHERE tripitaka91_code = ? AND tripitaka91_detail Like ? ORDER BY tripitaka91_no";
				$stmt = $conn->prepare($sql);
				$stmt->execute([$book_code, "$sub%"]);
			    }
			} else {
			    $book_code1 = $book_code;
			    $sql = "SELECT * FROM tripitaka91_91title WHERE tripitaka91_code = ? ORDER BY tripitaka91_no";
			    $stmt = $conn->prepare($sql);
			    $stmt->execute([$book_code]);
			}

			$book_sum = $stmt->rowCount(); // ใช้ rowCount() เพื่อนับจำนวนแถวที่ค้นพบ

			if (!empty($sub)) {
			    while($row = $stmt->fetch(PDO::FETCH_ASSOC)) { // ใช้ fetch(PDO::FETCH_ASSOC) เพื่อเรียกข้อมูลแบบ associative array
				$book_title = $row["tripitaka91_group"] . " (" . $row["tripitaka91_detail"] .")";
				$title_sub = $row["tripitaka91_detail"];
			    }
			} else {
			    while($row = $stmt->fetch(PDO::FETCH_ASSOC)) { // เหมือนกัน ใช้ fetch(PDO::FETCH_ASSOC)
				$book_title = $row["tripitaka91_group"];
			    }
			}
			
			if (empty($book_title)){
				$book_title =  "เล่ม " . $book_code;
			}

		?>
    </header>
		
    <section class="show_search" id="showSearch">
	<div class="container">
	
                <div class="col-lg-12">
                    <div class="panel panel-info">
                        <div class="panel-heading">
							<font class="tri-font-24-b">สารบัญหัวข้อธรรม - <?php echo $book_title;?></font><span class="pull-right">
<span class="badge tri-font-24-b">
    กรุณาเลือก 
    <?php
    // กำหนดตัวแปร (สมมติว่า $book_id ถูกกำหนดค่าไว้แล้ว)
    $selected_book = isset($_GET['book_code']) ? $_GET['book_code'] : 1; 

    // สร้าง Dropdown
    echo '<select name="book" onchange="window.location.href = \'tripitaka91_1.php?book_code=\' + this.value;">';
    for ($i = 1; $i <= 91; $i++) {
        $selected = ($i == $selected_book) ? 'selected' : '';
        echo '<option value="' . $i . '" ' . $selected . '>เล่ม ' . $i . '</option>'; 
    }
    echo '</select>';
    ?>
</span>
<a href="../"><span class="badge tri-font-24-b"><span class="glyphicon glyphicon-home"></span> หน้าหลัก </span></a>
							</span>
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <!-- Nav tabs -->
                            <ul class="nav nav-tabs">
                                <li class="active"><a href="#home" data-toggle="tab">จำนวน <span class="badge"><?php echo $book_sum; ?></span> รายการ </a>
                                </li>                              
                            </ul>

                            <!-- Tab panes -->
                            <div class="tab-content">
                                <div class="tab-pane fade in active" id="home">
								<br>
								<?php
									if (($book_code==87)||($book_code==88)||($book_code==89)||($book_code==90)||($book_code==91)){
										echo "<a href=$book_code-1-1.html class=\"btn btn-sm btn-outline\" target=_blank >เล่ม $book_code ไม่มีหัวข้อธรรมสำหรับแสดงผล คลิกเพื่ออ่านพระไตรปิฎก เล่ม $book_code</a>";
									}else{
								?>
									<div class="dataTable_wrapper">
    <table class="table table-striped table-bordered table-hover" width="100%" id="dataTables-title">
        <thead>
            <tr>
                <th>#</th>
                <th>รายละเอียด</th>
            </tr>
        </thead>
        <tbody>
            <?php
/*	
            $sql = "SELECT * ";
            $sql .= " FROM tripitaka91_91title WHERE tripitaka91_code = :book_code";


            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':book_code', $book_code, PDO::PARAM_INT);
            $stmt->execute();

        */
	    $sql = "SELECT * FROM tripitaka91_91title WHERE tripitaka91_code = ? AND tripitaka91_detail Like ? ORDER BY tripitaka91_no";
	    $stmt = $conn->prepare($sql);
	    $stmt->execute([$book_code, "$sub%"]);    
			    if (!empty($sub1)){
				$sub1= urldecode($sub1);
				$sql = "SELECT * FROM tripitaka91_91title WHERE tripitaka91_code = ? AND tripitaka91_detail Like ? ORDER BY tripitaka91_no";
				$stmt = $conn->prepare($sql);
				$stmt->execute([$book_code, "$sub%$sub1"]);
			    } else {
				$sql = "SELECT * FROM tripitaka91_91title WHERE tripitaka91_code = ? AND tripitaka91_detail Like ? ORDER BY tripitaka91_no";
				$stmt = $conn->prepare($sql);
				$stmt->execute([$book_code, "$sub%"]);
			    }
	    $i = 1;
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
	            $textReplace = $row["tripitaka91_book"] . "/" . $row["tripitaka91_page"] . "/" . $row["tripitaka91_line"];	            
		    $dataTitle =  str_replace($textReplace, "", $row["tripitaka91_title"]);
			
		    if ($row["tripitaka91_mark"] == 'TRUE') {
			$dataTitle = "<span class=text-danger>$dataTitle</span>";
		    }
    
		$dataTitle = "<span class=tri-font-24>" . $dataTitle . "</span>";
		$dataTitle = "<a href=" . $row["tripitaka91_book"] . "-" . $row["tripitaka91_page"] . "-" . $row["tripitaka91_line"] . ".html style=\"text-decoration:none;\" target=_blank>" . $dataTitle . "</a>";
		$tripitaka91_book_blue = "<span class=badge>" . $row["tripitaka91_book_blue"] . "</span>";
		$tripitaka91_book_red = "<span class=badge-danger>" . $row["tripitaka91_book_red"] . "</span>";
		$dataTitle .= "<span class=pull-right>$tripitaka91_book_blue $tripitaka91_book_red</span>";
		
                echo '<tr>';
                echo '<td>' . $i .'</td>'; // ข้อมูลคอลัมน์แรก
                echo '<td>' . $dataTitle . '</td>'; // ข้อมูลคอลัมน์ที่สอง
                echo '</tr>';
                $i++;
            }
            ?>
        </tbody>
    </table>
</div>

								<?php 
									}
								?>
									<!-- /.table-responsive -->														
                                </div>								                                
								
                            </div>
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
	
	</div>
		
	</section>
	
    <footer class="text-center">
        <div class="footer-below">
            <div class="container">
                <div class="row">
                    <div class="col-lg-12">
					<span class="pull-right">
                          
						<div id="showHitStats" class="tri-font-24">
						
						</div>
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
	
	
	<script>

	    window.onload = function () {
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

	
    <!-- DataTables JavaScript -->
    <script src="tri91_old/datatables/media/js/jquery.dataTables.min.js"></script>
	<script src="tri91_old/datatables/media/js/dataTables.tableTools.js"></script>
    <script src="tri91_old/datatables-plugins/integration/bootstrap/3/dataTables.bootstrap.min.js"></script>

    <script src="tri91_old/multiselect/js/bootstrap-multiselect.js"></script>
    <script src="tri91_old/multiselect/js/bootstrap-multiselect-collapsible-groups.js"></script>
		
    <!-- Custom Theme JavaScript -->
    <script src="tri91_old/js/sb-admin-2.js"></script>
	
    <!-- Custom Theme JavaScript -->
    <script src="tri91_old/js/freelancer.js"></script>

	
		
</body>

</html>
