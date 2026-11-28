<?php
require_once 'workspace/member_session.php';
member_require_login();

$me = member_current();
$csrfToken = member_csrf_token();
?>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>หน้าสมาชิก - Tripitaka91</title>
    <link rel="shortcut icon" href="favicon.png">
    <link href="tri91_legacy/css/bootstrap.min.css" rel="stylesheet">
    <link href="tri91_legacy/font-awesome/css/font-awesome.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Thai:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root{
            --navy:#2c3e50; --navy-dark:#233140; --teal:#18bc9c; --teal-dark:#149d82;
            --amber:#f39c12; --amber-dark:#c87f0a; --red:#e74c3c; --red-dark:#c0392b;
            --blue:#2980b9;
            --bg:#f3f5f8; --card:#ffffff; --border:#e6e9ef;
            --text:#2c3e50; --text-muted:#8a94a6;
            --radius:12px; --radius-sm:8px;
            --shadow:0 2px 10px rgba(32,45,65,.06); --shadow-hover:0 8px 24px rgba(32,45,65,.10);
        }
        *{ box-sizing:border-box; }
        body{
            font-family:"Noto Sans Thai","Segoe UI","Lato",sans-serif;
            background:var(--bg); color:var(--text); -webkit-font-smoothing:antialiased;
        }

        /* ---------- Navbar ---------- */
        .navbar-member{
            background:linear-gradient(135deg, var(--navy) 0%, var(--navy-dark) 100%);
            border:0; box-shadow:0 2px 12px rgba(0,0,0,.15); margin-bottom:28px;
        }
        .navbar-member .navbar-brand{
            color:#fff !important; font-weight:600; display:flex; align-items:center; gap:10px;
        }
        .navbar-member .navbar-brand i{ color:var(--teal); }
        .navbar-member .navbar-text{ color:rgba(255,255,255,.85) !important; display:flex; align-items:center; }
        .navbar-member a{ color:var(--teal) !important; font-weight:500; }
        .navbar-member a:hover{ color:#fff !important; text-decoration:none; }
        .avatar-circle{
            display:inline-flex; align-items:center; justify-content:center;
            width:30px; height:30px; border-radius:50%; background:var(--teal);
            color:#fff; font-weight:600; font-size:14px; margin-right:10px;
        }

        /* ---------- Stat cards ---------- */
        .stat-card{
            background:var(--card); border:1px solid var(--border); border-top:3px solid var(--navy);
            border-radius:var(--radius); padding:20px 16px; margin-bottom:18px;
            box-shadow:var(--shadow); text-align:center; transition:box-shadow .15s ease, transform .15s ease;
        }
        .stat-card:hover{ box-shadow:var(--shadow-hover); transform:translateY(-2px); }
        .stat-card .icon{ font-size:20px; color:var(--text-muted); margin-bottom:6px; }
        .stat-card .num{ font-size:30px; font-weight:700; color:var(--navy); line-height:1.2; }
        .stat-card .label{
            color:var(--text-muted); font-size:13px; margin-top:2px;
            overflow-wrap:break-word; word-break:break-word;
        }
        @media (max-width:480px){
            .stat-card{ padding:14px 8px; }
            .stat-card .num{ font-size:24px; }
            .stat-card .label{ font-size:11.5px; }
        }
        .stat-card.pending{ border-top-color:var(--amber); }
        .stat-card.pending .icon, .stat-card.pending .num{ color:var(--amber-dark); }
        .stat-card.confirmed{ border-top-color:var(--teal); }
        .stat-card.confirmed .icon, .stat-card.confirmed .num{ color:var(--teal-dark); }
        .stat-card.disputes{ border-top-color:var(--red); }
        .stat-card.disputes .icon, .stat-card.disputes .num{ color:var(--red-dark); }

        /* ---------- Panels ---------- */
        .panel-member{
            background:var(--card); border:1px solid var(--border); border-radius:var(--radius);
            box-shadow:var(--shadow); padding:24px; margin-bottom:24px;
        }
        .section-title{
            margin:0 0 18px; font-size:19px; font-weight:700; color:var(--navy);
            display:flex; align-items:center; gap:10px;
        }
        .section-title .icon-chip{
            width:34px; height:34px; border-radius:9px; display:inline-flex;
            align-items:center; justify-content:center; background:rgba(24,188,156,.12); color:var(--teal-dark);
            font-size:15px; flex:0 0 auto;
        }
        .section-title.tone-danger .icon-chip{ background:rgba(231,76,60,.12); color:var(--red-dark); }
        .section-title.tone-sound .icon-chip{ background:rgba(41,128,185,.12); color:var(--blue); }
        .system-summary{
            color:var(--text-muted); font-size:13.5px; margin:-6px 0 20px; padding-bottom:14px;
            border-bottom:1px dashed var(--border);
        }

        /* ---------- Tabs ---------- */
        .nav-tabs{ border-bottom:1px solid var(--border); margin-bottom:0; }
        .nav-tabs>li>a{
            border:0; border-radius:0; color:var(--text-muted); font-weight:500;
            padding:10px 16px; margin-right:4px; background:transparent;
        }
        .nav-tabs>li>a:hover{ border:0; background:rgba(24,188,156,.08); color:var(--teal-dark); }
        .nav-tabs>li.active>a, .nav-tabs>li.active>a:hover, .nav-tabs>li.active>a:focus{
            border:0; border-bottom:2px solid var(--teal); color:var(--navy); background:transparent; font-weight:600;
        }

        /* ---------- Tables ---------- */
        .table-scroll{ overflow-x:auto; -webkit-overflow-scrolling:touch; margin-top:16px; }
        table.table{ margin-bottom:0; min-width:560px; }
        table.table td, table.table th{ vertical-align:middle; white-space:nowrap; }
        table.table thead th{
            text-transform:uppercase; font-size:11.5px; letter-spacing:.04em; color:var(--text-muted);
            font-weight:600; border-bottom:2px solid var(--border); border-top:0; background:#fafbfc;
        }
        table.table-striped>tbody>tr:nth-of-type(odd){ background:#fbfcfd; }
        table.table-striped>tbody>tr:hover{ background:rgba(24,188,156,.06); }
        .word-wrong{ color:var(--red-dark); text-decoration:line-through; }
        .word-correct{ color:var(--teal-dark); font-weight:600; }

        /* ---------- Badges & buttons ---------- */
        .status-badge{
            display:inline-block; padding:4px 11px; border-radius:20px; font-size:11.5px;
            font-weight:600; letter-spacing:.02em; color:#fff;
        }
        .status-pending{ background:var(--amber); }
        .status-confirmed{ background:var(--teal); }
        .status-reverted{ background:var(--blue); }
        .status-rejected{ background:var(--text-muted); }
        .btn{ border-radius:var(--radius-sm); font-weight:500; }
        .btn-primary{ background:var(--teal); border-color:var(--teal); }
        .btn-primary:hover, .btn-primary:focus{ background:var(--teal-dark); border-color:var(--teal-dark); }
        .btn i.fa{ margin-right:6px; }
        .btn-outline-danger{
            background:#fff; border:1px solid var(--red); color:var(--red-dark);
        }
        .btn-outline-danger:hover{ background:var(--red); color:#fff; }
        .pager-row{ text-align:center; margin-top:16px; }
        .pager-row .btn{ min-width:100px; }
        #speech-add-btn{ margin-bottom:18px; }

        /* ---------- Modals ---------- */
        .modal-content{ border:0; border-radius:var(--radius); box-shadow:0 20px 50px rgba(10,20,35,.25); }
        .modal-header{ border-bottom:1px solid var(--border); padding:16px 20px; }
        .modal-title{ font-weight:700; color:var(--navy); font-size:16px; }
        .modal-footer{ border-top:1px solid var(--border); }
    </style>
</head>
<body>

<nav class="navbar navbar-member navbar-static-top">
    <div class="container">
        <span class="navbar-brand"><i class="fa fa-book"></i> Tripitaka91 &middot; หน้าสมาชิก</span>
        <span class="navbar-text pull-right">
            <span class="avatar-circle"><?php echo htmlspecialchars(mb_substr($me['name'], 0, 1, 'UTF-8'), ENT_QUOTES, 'UTF-8'); ?></span>
            สวัสดี, <?php echo htmlspecialchars($me['name'], ENT_QUOTES, 'UTF-8'); ?>
            &nbsp;|&nbsp; <a href="logout.php"><i class="fa fa-sign-out"></i> ออกจากระบบ</a>
        </span>
    </div>
</nav>

<div class="container" style="margin-bottom:60px;">

    <div class="row" id="my-summary-cards">
        <div class="col-sm-3 col-xs-6">
            <div class="stat-card">
                <div class="icon"><i class="fa fa-flag"></i></div>
                <div class="num" id="stat-total">-</div>
                <div class="label">รายการที่ฉันแจ้งทั้งหมด</div>
            </div>
        </div>
        <div class="col-sm-3 col-xs-6">
            <div class="stat-card pending">
                <div class="icon"><i class="fa fa-clock-o"></i></div>
                <div class="num" id="stat-pending">-</div>
                <div class="label">รอดำเนินการ</div>
            </div>
        </div>
        <div class="col-sm-3 col-xs-6">
            <div class="stat-card confirmed">
                <div class="icon"><i class="fa fa-check-circle"></i></div>
                <div class="num" id="stat-confirmed">-</div>
                <div class="label">ยืนยัน/แก้ไขแล้ว</div>
            </div>
        </div>
        <div class="col-sm-3 col-xs-6">
            <div class="stat-card disputes">
                <div class="icon"><i class="fa fa-exclamation-triangle"></i></div>
                <div class="num" id="stat-disputes">-</div>
                <div class="label">ข้อโต้แย้งที่รอตรวจสอบ</div>
            </div>
        </div>
    </div>

    <p class="system-summary" id="system-summary">กำลังโหลดภาพรวมระบบ...</p>

    <div class="panel-member">
        <h3 class="section-title"><span class="icon-chip"><i class="fa fa-pencil"></i></span> รายการคำผิด-คำถูกที่ฉันแจ้ง</h3>

        <ul class="nav nav-tabs" id="status-tabs">
            <li class="active" data-status="all"><a href="#">ทั้งหมด</a></li>
            <li data-status="pending"><a href="#">คำที่มีปัญหา (รอดำเนินการ)</a></li>
            <li data-status="confirmed"><a href="#">คำที่ยืนยันแล้ว</a></li>
        </ul>

        <div class="table-scroll">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>เล่ม/หน้า/บรรทัด</th>
                        <th>คำผิด</th>
                        <th>คำถูก</th>
                        <th>ความเห็น</th>
                        <th>วันที่แจ้ง</th>
                        <th>สถานะ</th>
                        <th>การดำเนินการ</th>
                    </tr>
                </thead>
                <tbody id="my-list-body">
                    <tr><td colspan="7" class="text-center">กำลังโหลด...</td></tr>
                </tbody>
            </table>
        </div>

        <div class="pager-row">
            <button class="btn btn-default btn-sm" id="my-list-prev">&laquo; ก่อนหน้า</button>
            <span id="my-list-page-label" style="margin:0 10px;">หน้า 1</span>
            <button class="btn btn-default btn-sm" id="my-list-next">ถัดไป &raquo;</button>
        </div>
    </div>

    <div class="panel-member">
        <h3 class="section-title tone-danger"><span class="icon-chip"><i class="fa fa-undo"></i></span> ข้อโต้แย้งที่ฉันแจ้งไว้ (แจ้งคืนการแก้ไข)</h3>
        <div class="table-scroll">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>เล่ม/หน้า/บรรทัด</th>
                        <th>ความเห็นของฉัน</th>
                        <th>วันที่แจ้ง</th>
                        <th>สถานะ</th>
                    </tr>
                </thead>
                <tbody id="my-disputes-body">
                    <tr><td colspan="4" class="text-center">กำลังโหลด...</td></tr>
                </tbody>
            </table>
        </div>
        <div class="pager-row">
            <button class="btn btn-default btn-sm" id="my-disputes-prev">&laquo; ก่อนหน้า</button>
            <span id="my-disputes-page-label" style="margin:0 10px;">หน้า 1</span>
            <button class="btn btn-default btn-sm" id="my-disputes-next">ถัดไป &raquo;</button>
        </div>
    </div>

    <div class="panel-member">
        <h3 class="section-title tone-sound"><span class="icon-chip"><i class="fa fa-volume-up"></i></span> แจ้งการอ่านออกเสียง (คำอ่านผิด)</h3>

        <div class="row" style="margin-bottom:10px;">
            <div class="col-sm-4 col-xs-4">
                <div class="stat-card">
                    <div class="icon"><i class="fa fa-flag"></i></div>
                    <div class="num" id="speech-stat-total">-</div>
                    <div class="label">คำที่ฉันแจ้งทั้งหมด</div>
                </div>
            </div>
            <div class="col-sm-4 col-xs-4">
                <div class="stat-card pending">
                    <div class="icon"><i class="fa fa-clock-o"></i></div>
                    <div class="num" id="speech-stat-pending">-</div>
                    <div class="label">รอดำเนินการ</div>
                </div>
            </div>
            <div class="col-sm-4 col-xs-4">
                <div class="stat-card confirmed">
                    <div class="icon"><i class="fa fa-check-circle"></i></div>
                    <div class="num" id="speech-stat-confirmed">-</div>
                    <div class="label">ยืนยัน/แก้ไขแล้ว</div>
                </div>
            </div>
        </div>

        <p class="system-summary" id="speech-system-summary">กำลังโหลดภาพรวมระบบ...</p>

        <button class="btn btn-primary btn-sm" id="speech-add-btn">
            <i class="fa fa-plus"></i> แจ้งคำอ่านผิด
        </button>

        <ul class="nav nav-tabs" id="speech-status-tabs">
            <li class="active" data-status="all"><a href="#">ทั้งหมด</a></li>
            <li data-status="pending"><a href="#">รอดำเนินการ</a></li>
            <li data-status="confirmed"><a href="#">ยืนยันแล้ว</a></li>
        </ul>

        <div class="table-scroll">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>คำต้นฉบับ</th>
                        <th>คำอ่านที่แจ้ง</th>
                        <th>หมายเหตุ</th>
                        <th>จำนวนยืนยัน</th>
                        <th>วันที่แจ้ง</th>
                        <th>สถานะ</th>
                    </tr>
                </thead>
                <tbody id="speech-list-body">
                    <tr><td colspan="6" class="text-center">กำลังโหลด...</td></tr>
                </tbody>
            </table>
        </div>

        <div class="pager-row">
            <button class="btn btn-default btn-sm" id="speech-list-prev">&laquo; ก่อนหน้า</button>
            <span id="speech-list-page-label" style="margin:0 10px;">หน้า 1</span>
            <button class="btn btn-default btn-sm" id="speech-list-next">ถัดไป &raquo;</button>
        </div>
    </div>

</div>

<!-- Modal: แจ้งคำอ่านผิด (speech report) -->
<div class="modal fade" id="speechModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">แจ้งคำอ่านผิด</h4>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>คำต้นฉบับ</label>
                    <input type="text" class="form-control" id="speech-words" placeholder="เช่น สังฆราช">
                </div>
                <div class="form-group">
                    <label>คำอ่านที่ถูกต้อง</label>
                    <input type="text" class="form-control" id="speech-words-speak" placeholder="เช่น สัง-คะ-ราด">
                </div>
                <div class="form-group">
                    <label>หมายเหตุ (ถ้ามี)</label>
                    <textarea class="form-control" id="speech-comments" rows="2"></textarea>
                </div>
                <div class="alert alert-danger" id="speech-error" style="display:none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">ยกเลิก</button>
                <button type="button" class="btn btn-primary" id="speech-submit">บันทึก</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: แจ้งคืนการแก้ไข (dispute) -->
<div class="modal fade" id="disputeModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">แจ้งคืนการแก้ไข</h4>
            </div>
            <div class="modal-body">
                <p>แจ้งว่าการแก้ไขของรายการนี้ไม่ถูกต้อง เล่ม <span id="dispute-book"></span>
                   หน้า <span id="dispute-page"></span> บรรทัด <span id="dispute-line"></span></p>
                <div class="form-group">
                    <label>เหตุผล / รายละเอียดที่ยังไม่ถูกต้อง</label>
                    <textarea class="form-control" id="dispute-comment" rows="4" placeholder="เช่น แก้ไขแล้วแต่ยังมีคำผิดอยู่ หรือแก้ไขผิดจุด"></textarea>
                </div>
                <div class="alert alert-danger" id="dispute-error" style="display:none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">ยกเลิก</button>
                <button type="button" class="btn btn-danger" id="dispute-submit">ส่งข้อโต้แย้ง</button>
            </div>
        </div>
    </div>
</div>

<script src="tri91_legacy/js/jquery.js"></script>
<script src="tri91_legacy/js/bootstrap.min.js"></script>
<script>
(function () {
    'use strict';

    var CSRF_TOKEN = <?php echo json_encode($csrfToken); ?>;
    var currentStatus = 'all';
    var myListPage = 1;
    var myListHasMore = false;
    var myDisputesPage = 1;
    var myDisputesHasMore = false;

    function esc(s) {
        return String(s === null || s === undefined ? '' : s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function statusBadge(bookSuscess) {
        return bookSuscess == 1
            ? '<span class="status-badge status-confirmed">ยืนยันแล้ว</span>'
            : '<span class="status-badge status-pending">รอดำเนินการ</span>';
    }

    function disputeStatusBadge(status) {
        status = parseInt(status, 10);
        if (status === 1) return '<span class="status-badge status-reverted">แก้ไขกลับแล้ว</span>';
        if (status === 2) return '<span class="status-badge status-rejected">ไม่อนุมัติ</span>';
        return '<span class="status-badge status-pending">รอตรวจสอบ</span>';
    }

    function bookLink(book, page, line) {
        var url = 'tripitaka.php?book=' + encodeURIComponent(book) + '&page=' + encodeURIComponent(page) + '&line=' + encodeURIComponent(line);
        return '<a href="' + url + '" target="_blank">เล่ม ' + esc(book) + ' / หน้า ' + esc(page) + ' / บรรทัด ' + esc(line) + '</a>';
    }

    function loadSummary() {
        fetch('workspace/member_api.php?action=my_summary').then(function (r) { return r.json(); }).then(function (res) {
            if (!res.success) return;
            document.getElementById('stat-total').textContent = res.data.total;
            document.getElementById('stat-pending').textContent = res.data.pending;
            document.getElementById('stat-confirmed').textContent = res.data.confirmed;
            document.getElementById('stat-disputes').textContent = res.data.pending_disputes;
        });

        fetch('workspace/member_api.php?action=system_summary').then(function (r) { return r.json(); }).then(function (res) {
            if (!res.success) return;
            document.getElementById('system-summary').textContent =
                'ภาพรวมทั้งระบบ: แจ้งแล้วทั้งหมด ' + res.data.total.toLocaleString('th-TH') +
                ' รายการ, ยืนยัน/แก้ไขแล้ว ' + res.data.confirmed.toLocaleString('th-TH') +
                ' รายการ, รอดำเนินการ ' + res.data.pending.toLocaleString('th-TH') +
                ' รายการ, ข้อโต้แย้งรอตรวจสอบ ' + res.data.pending_disputes.toLocaleString('th-TH') + ' รายการ';
        });
    }

    function loadMyList() {
        var tbody = document.getElementById('my-list-body');
        tbody.innerHTML = '<tr><td colspan="7" class="text-center">กำลังโหลด...</td></tr>';

        fetch('workspace/member_api.php?action=my_list&status=' + encodeURIComponent(currentStatus) + '&page=' + myListPage)
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (!res.success) {
                    tbody.innerHTML = '<tr><td colspan="7" class="text-center text-danger">โหลดข้อมูลไม่สำเร็จ</td></tr>';
                    return;
                }
                myListHasMore = res.has_more;
                document.getElementById('my-list-page-label').textContent = 'หน้า ' + res.page;

                if (res.data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="7" class="text-center">ไม่พบรายการ</td></tr>';
                    return;
                }

                var html = '';
                res.data.forEach(function (row) {
                    html += '<tr>';
                    html += '<td>' + bookLink(row.tripitaka91_book, row.tripitaka91_page, row.tripitaka91_line) + '</td>';
                    html += '<td class="word-wrong">' + esc(row.tripitaka91_wordincorrect) + '</td>';
                    html += '<td class="word-correct">' + esc(row.tripitaka91_wordcorrect) + '</td>';
                    html += '<td>' + esc(row.tripitaka91_wordcorrectcomment) + '</td>';
                    html += '<td>' + esc(row.tripitaka91_dateadd) + '</td>';
                    html += '<td>' + statusBadge(row.book_suscess) + '</td>';
                    html += '<td>';
                    if (row.book_suscess == 1) {
                        html += '<button class="btn btn-xs btn-outline-danger btn-dispute" ' +
                            'data-book="' + esc(row.tripitaka91_book) + '" ' +
                            'data-page="' + esc(row.tripitaka91_page) + '" ' +
                            'data-line="' + esc(row.tripitaka91_line) + '"><i class="fa fa-undo"></i> แจ้งคืนการแก้ไข</button>';
                    }
                    html += '</td>';
                    html += '</tr>';
                });
                tbody.innerHTML = html;
            });
    }

    function loadMyDisputes() {
        var tbody = document.getElementById('my-disputes-body');
        tbody.innerHTML = '<tr><td colspan="4" class="text-center">กำลังโหลด...</td></tr>';

        fetch('workspace/member_api.php?action=my_disputes&page=' + myDisputesPage)
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (!res.success) {
                    tbody.innerHTML = '<tr><td colspan="4" class="text-center text-danger">โหลดข้อมูลไม่สำเร็จ</td></tr>';
                    return;
                }
                myDisputesHasMore = res.has_more;
                document.getElementById('my-disputes-page-label').textContent = 'หน้า ' + res.page;

                if (res.data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="4" class="text-center">ยังไม่มีข้อโต้แย้งที่แจ้งไว้</td></tr>';
                    return;
                }

                var html = '';
                res.data.forEach(function (row) {
                    html += '<tr>';
                    html += '<td>' + bookLink(row.tripitaka91_book, row.tripitaka91_page, row.tripitaka91_line) + '</td>';
                    html += '<td>' + esc(row.tripitaka91_comment) + '</td>';
                    html += '<td>' + esc(row.tripitaka91_dateadd) + '</td>';
                    html += '<td>' + disputeStatusBadge(row.status) + '</td>';
                    html += '</tr>';
                });
                tbody.innerHTML = html;
            });
    }

    document.getElementById('status-tabs').addEventListener('click', function (e) {
        var li = e.target.closest('li');
        if (!li) return;
        e.preventDefault();
        Array.prototype.forEach.call(document.querySelectorAll('#status-tabs li'), function (el) {
            el.classList.remove('active');
        });
        li.classList.add('active');
        currentStatus = li.getAttribute('data-status');
        myListPage = 1;
        loadMyList();
    });

    document.getElementById('my-list-prev').addEventListener('click', function () {
        if (myListPage > 1) { myListPage--; loadMyList(); }
    });
    document.getElementById('my-list-next').addEventListener('click', function () {
        if (myListHasMore) { myListPage++; loadMyList(); }
    });
    document.getElementById('my-disputes-prev').addEventListener('click', function () {
        if (myDisputesPage > 1) { myDisputesPage--; loadMyDisputes(); }
    });
    document.getElementById('my-disputes-next').addEventListener('click', function () {
        if (myDisputesHasMore) { myDisputesPage++; loadMyDisputes(); }
    });

    document.getElementById('my-list-body').addEventListener('click', function (e) {
        var btn = e.target.closest('.btn-dispute');
        if (!btn) return;
        document.getElementById('dispute-book').textContent = btn.getAttribute('data-book');
        document.getElementById('dispute-page').textContent = btn.getAttribute('data-page');
        document.getElementById('dispute-line').textContent = btn.getAttribute('data-line');
        document.getElementById('dispute-comment').value = '';
        document.getElementById('dispute-error').style.display = 'none';
        document.getElementById('dispute-submit').setAttribute('data-book', btn.getAttribute('data-book'));
        document.getElementById('dispute-submit').setAttribute('data-page', btn.getAttribute('data-page'));
        document.getElementById('dispute-submit').setAttribute('data-line', btn.getAttribute('data-line'));
        window.jQuery('#disputeModal').modal('show');
    });

    document.getElementById('dispute-submit').addEventListener('click', function () {
        var btn = this;
        var comment = document.getElementById('dispute-comment').value.trim();
        var errorBox = document.getElementById('dispute-error');

        if (comment === '') {
            errorBox.textContent = 'กรุณากรอกเหตุผล';
            errorBox.style.display = 'block';
            return;
        }

        var body = new URLSearchParams();
        body.set('action', 'submit_dispute');
        body.set('csrf_token', CSRF_TOKEN);
        body.set('book', btn.getAttribute('data-book'));
        body.set('page', btn.getAttribute('data-page'));
        body.set('line', btn.getAttribute('data-line'));
        body.set('comment', comment);

        fetch('workspace/member_api.php', { method: 'POST', body: body })
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (!res.success) {
                    errorBox.textContent = res.message || 'เกิดข้อผิดพลาด';
                    errorBox.style.display = 'block';
                    return;
                }
                window.jQuery('#disputeModal').modal('hide');
                loadMyList();
                loadMyDisputes();
                loadSummary();
            });
    });

    // ===== แจ้งการอ่านออกเสียง (log_speak) =====
    var speechStatus = 'all';
    var speechListPage = 1;
    var speechListHasMore = false;

    function speechStatusBadge(speakSuscess) {
        return speakSuscess == 1
            ? '<span class="status-badge status-confirmed">ยืนยันแล้ว</span>'
            : '<span class="status-badge status-pending">รอดำเนินการ</span>';
    }

    function loadSpeechSummary() {
        fetch('workspace/member_api.php?action=speech_my_summary').then(function (r) { return r.json(); }).then(function (res) {
            if (!res.success) return;
            document.getElementById('speech-stat-total').textContent = res.data.total;
            document.getElementById('speech-stat-pending').textContent = res.data.pending;
            document.getElementById('speech-stat-confirmed').textContent = res.data.confirmed;
        });

        fetch('workspace/member_api.php?action=speech_system_summary').then(function (r) { return r.json(); }).then(function (res) {
            if (!res.success) return;
            document.getElementById('speech-system-summary').textContent =
                'ภาพรวมทั้งระบบ: แจ้งคำอ่านทั้งหมด ' + res.data.total.toLocaleString('th-TH') +
                ' คำ, ยืนยัน/แก้ไขแล้ว ' + res.data.confirmed.toLocaleString('th-TH') +
                ' คำ, รอดำเนินการ ' + res.data.pending.toLocaleString('th-TH') + ' คำ';
        });
    }

    function loadSpeechList() {
        var tbody = document.getElementById('speech-list-body');
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">กำลังโหลด...</td></tr>';

        fetch('workspace/member_api.php?action=speech_my_list&status=' + encodeURIComponent(speechStatus) + '&page=' + speechListPage)
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (!res.success) {
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center text-danger">โหลดข้อมูลไม่สำเร็จ</td></tr>';
                    return;
                }
                speechListHasMore = res.has_more;
                document.getElementById('speech-list-page-label').textContent = 'หน้า ' + res.page;

                if (res.data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center">ไม่พบรายการ</td></tr>';
                    return;
                }

                var html = '';
                res.data.forEach(function (row) {
                    html += '<tr>';
                    html += '<td>' + esc(row.words) + '</td>';
                    html += '<td>' + esc(row.words_speak) + '</td>';
                    html += '<td>' + esc(row.comments) + '</td>';
                    html += '<td>' + esc(row.words_comfirm) + '</td>';
                    html += '<td>' + esc(row.words_dataaddedit) + '</td>';
                    html += '<td>' + speechStatusBadge(row.speak_suscess) + '</td>';
                    html += '</tr>';
                });
                tbody.innerHTML = html;
            });
    }

    document.getElementById('speech-status-tabs').addEventListener('click', function (e) {
        var li = e.target.closest('li');
        if (!li) return;
        e.preventDefault();
        Array.prototype.forEach.call(document.querySelectorAll('#speech-status-tabs li'), function (el) {
            el.classList.remove('active');
        });
        li.classList.add('active');
        speechStatus = li.getAttribute('data-status');
        speechListPage = 1;
        loadSpeechList();
    });

    document.getElementById('speech-list-prev').addEventListener('click', function () {
        if (speechListPage > 1) { speechListPage--; loadSpeechList(); }
    });
    document.getElementById('speech-list-next').addEventListener('click', function () {
        if (speechListHasMore) { speechListPage++; loadSpeechList(); }
    });

    document.getElementById('speech-add-btn').addEventListener('click', function () {
        document.getElementById('speech-words').value = '';
        document.getElementById('speech-words-speak').value = '';
        document.getElementById('speech-comments').value = '';
        document.getElementById('speech-error').style.display = 'none';
        window.jQuery('#speechModal').modal('show');
    });

    document.getElementById('speech-submit').addEventListener('click', function () {
        var words = document.getElementById('speech-words').value.trim();
        var wordsSpeak = document.getElementById('speech-words-speak').value.trim();
        var comments = document.getElementById('speech-comments').value.trim();
        var errorBox = document.getElementById('speech-error');

        if (words === '' || wordsSpeak === '') {
            errorBox.textContent = 'กรุณากรอกคำต้นฉบับและคำอ่านให้ครบถ้วน';
            errorBox.style.display = 'block';
            return;
        }

        var body = new URLSearchParams();
        body.set('action', 'submit_speech');
        body.set('csrf_token', CSRF_TOKEN);
        body.set('words', words);
        body.set('words_speak', wordsSpeak);
        body.set('comments', comments);

        fetch('workspace/member_api.php', { method: 'POST', body: body })
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (!res.success) {
                    errorBox.textContent = res.message || 'เกิดข้อผิดพลาด';
                    errorBox.style.display = 'block';
                    return;
                }
                window.jQuery('#speechModal').modal('hide');
                loadSpeechList();
                loadSpeechSummary();
            });
    });

    loadSummary();
    loadMyList();
    loadMyDisputes();
    loadSpeechSummary();
    loadSpeechList();
})();
</script>
</body>
</html>
