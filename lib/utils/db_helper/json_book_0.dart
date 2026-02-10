import 'dart:convert';

import 'package:tripitaka91/utils/models/book_tri91.dart';

String jsonBookString = '''
[
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 1,
        "book_detail": "                                             คำนำ",
        "book_lines": 1,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 2,
        "book_detail": "          พระพุทธวจนะ คือ พระไตรปิฎก รวมเป็นศาสนธรรมคำสอนของ",
        "book_lines": 2,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 3,
        "book_detail": "พระพุทธเจ้า จัดเป็นองค์ 9 คือ",
        "book_lines": 3,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 4,
        "book_detail": "          สุตตะ ได้แก่อุภโตวิภังค์ นินเทส ขันธกะ ปริวาร พระสูตรต่างๆ",
        "book_lines": 4,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 5,
        "book_detail": "มีมงคลสูตรเป็นต้น",
        "book_lines": 5,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 6,
        "book_detail": "          เคยยะ คือพระสูตรที่ประกอบด้วยคาถาทั้งหมด",
        "book_lines": 6,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 7,
        "book_detail": "          เวยยากรณะ คือพระอภิธรรมปิฎกทั้งหมด พระสูตรที่ไม่มีคาถา",
        "book_lines": 7,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 8,
        "book_detail": "และพระพุทธวจนะที่ไม่ได้จัดเข้าในองค์ 8 ได้ชื่อว่าเวยยากรณะทั้งหมด",
        "book_lines": 8,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 9,
        "book_detail": "          คาถา คือพระธรรมบท เถรคาถา เถรีคาถา และคาถาล้วนๆ ที่ไม่มี",
        "book_lines": 9,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 10,
        "book_detail": "ชื่อว่าสูตรในสูตตนิบาต",
        "book_lines": 10,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 11,
        "book_detail": "          อุทาน คือพระสูตร 82 สูตร ที่พระพุทธเจ้าทรงเปล่งด้วยโสมนัสญาณ",
        "book_lines": 11,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 12,
        "book_detail": "          อิติวุตตกะ คือพระสูตร 110 สูตร ที่ขึ้นต้นด้วยคำว่า ข้อนี้สมจริง",
        "book_lines": 12,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 13,
        "book_detail": "ดังคำที่พระผู้มีพระภาคเจ้าตรัสไว้",
        "book_lines": 13,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 14,
        "book_detail": "          ชาดก เป็นการแสดงเรื่องในอดีตชาติของพระพุทธเจ้า มีอปัณณก-",
        "book_lines": 14,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 15,
        "book_detail": "ชาดกเป็นต้น มีทั้งหมด 550",
        "book_lines": 15,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 16,
        "book_detail": "          อัพภูตธรรม คือพระสูตรที่ปฏิสังยุตด้วยอัจฉริยอัพภูตธรรมทั้งหมด",
        "book_lines": 16,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 17,
        "book_detail": "          เวทัลละ คือระเบียบคำที่ผู้ถามได้ความรู้แจ้งและความยินดี แล้วถาม",
        "book_lines": 17,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 18,
        "book_detail": "ต่อๆ ขึ้นไป ดังจูฬเวทัลลสูตร มหาเวทัลลสูตร สัมมาทิฏฐิสูตร และ",
        "book_lines": 18,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 19,
        "book_detail": "สักกปัญหสูตร เป็นต้น",
        "book_lines": 19,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 20,
        "book_detail": "          พระพุทธวจนะเหล่านี้ โดยสภาพแห่งธรรมแล้ว เป็นสัจจธรรมที่ทรง",
        "book_lines": 20,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 21,
        "book_detail": "แสดงว่า เป็นธรรมที่ลึกซึ้งรู้ได้ยาก รู้ตามเห็นตามได้ยาก สงบ ",
        "book_lines": 21,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 22,
        "book_detail": "LineNull",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 23,
        "book_detail": "                                              (-๒-)",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 24,
        "book_detail": "LineNull",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 25,
        "book_detail": "ประณีต ไม่อาจจะรู้ได้ด้วยการตรึก ละเอียด เป็นธรรมอัน",
        "book_lines": 1,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 26,
        "book_detail": "บัณฑิตจะรู้ได้ เพราะสภาวะแห่งธรรมมีลักษณะดังกล่าว จึงจำต้องชี้แจง",
        "book_lines": 2,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 27,
        "book_detail": "ให้เกิดความเข้าใจทั้งโดยอรรถะ และพยัญชนะ เพื่อให้สามารถหยั่งรู้ธรรม",
        "book_lines": 3,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 28,
        "book_detail": "ทั้งหลายตามความเป็นจริงในเรื่องนั้นๆ",
        "book_lines": 4,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 29,
        "book_detail": "          เนื่องจากพื้นเพอัธยาศัยของคนแตกต่างกันในด้านต่างๆ ชึ่งทรงอุปมา",
        "book_lines": 5,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 30,
        "book_detail": "ไว้เหมือนดอกบัว 4 เหล่า พระพุทธเจ้าจึงทรงมีวิธีในการแสดงธรรม ตาม",
        "book_lines": 6,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 31,
        "book_detail": "อาการสอนธรรมของพระองค์ 3 ประการ คือ",
        "book_lines": 7,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 32,
        "book_detail": "          1. ทรงสอนให้ผู้ฟังรู้ยิ่งเห็นจริง ในสิ่งที่ควรรู้ควรเห็น",
        "book_lines": 8,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 33,
        "book_detail": "          2. ทรงแสดงธรรมมีเหตุที่ผู้ฟังอาจตรงตามให้เห็นจริงได้",
        "book_lines": 9,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 34,
        "book_detail": "          3. ทรงแสดงธรรมเป็นอัศจรรย์ คือผู้ปฎิบัติตามจะได้รับ",
        "book_lines": 10,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 35,
        "book_detail": "ประโยชน์ตามสมควรแก่การประพฤติปฏิบัติ",
        "book_lines": 11,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 36,
        "book_detail": "          แต่เพราะพระพุทธเจ้าทรงประกอบด้วยปาฏิหาริย์ ทรงฉลาดในโวหาร",
        "book_lines": 12,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 37,
        "book_detail": "เพราะทรงเป็นเจ้าแห่งธรรมก่อนจะทรงแสดงธรรมแก่ใคร ทรงตรวจสอบ",
        "book_lines": 13,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 38,
        "book_detail": "ภูมิหลังด้านต่างๆ ของคนเหล่านั้นด้วยพระญาณแล้ว ผลจากการฟังในพุทธ-",
        "book_lines": 14,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 39,
        "book_detail": "สำนึกจึงไม่มีปัญหาว่า คนฟังจะไม่เข้าใจ ผลจากการฟังธรรมสมัยพุทธกาล",
        "book_lines": 15,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 40,
        "book_detail": "จึงมีความอัศจรรย์",
        "book_lines": 16,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 41,
        "book_detail": "          หลังจากพระพุทธเจ้าปรินิพพานไปแล้ว ทรงตั้งพระธรรมวินัยไว้เป็น",
        "book_lines": 17,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 42,
        "book_detail": "พระศาสดาแทนพระองค์ธรรมที่ทรงแสดงไว้ยังเป็นเช่นเดิม แต่ระดับสติ",
        "book_lines": 18,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 43,
        "book_detail": "ปัญญา บารมี ความสนใจในธรรมของคนเปลี่ยนแปลงไปทำให้การตีความ",
        "book_lines": 19,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 44,
        "book_detail": "พระธรรมวินัยตามความเข้าใจของตนเองเกิดขึ้น จนทำให้สูญเสียความเสมอกัน",
        "book_lines": 20,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 45,
        "book_detail": "ในด้านศีลและทิฐิครั้งแล้วครั้งเล่า บางสมัยเกิดแตกแยกกันเป็นนิกายต่างๆ ",
        "book_lines": 21,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 46,
        "book_detail": "ถึง ๑๘ นิกาย",
        "book_lines": 22,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 47,
        "book_detail": "          พระอรรถกถาจารย์ผู้ทราบพุทธาธิบาย ทั้งโดยอรรถะและพยัญชนะ",
        "book_lines": 23,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 48,
        "book_detail": "แห่งพระพุทธวจนะ เพราะการศึกษาจำต้องสืบต่อกันมาตามลำดับ มีฉันทะ",
        "book_lines": 24,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 49,
        "book_detail": "LineNull",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 50,
        "book_detail": "                                              (-๓-)",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 51,
        "book_detail": "LineNull",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 52,
        "book_detail": "อุตสาหะอย่างสูงมาก ได้อรรถาธิบายพระพุทธวจนะ ในพระไตรปิฎก ส่วนที่",
        "book_lines": 1,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 53,
        "book_detail": "ยากแก่การเข้าใจ ให้เกิดความเข้าใจง่ายขึ้นสำหรับผู้ศึกษาและปฏิบัติ ความ",
        "book_lines": 2,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 54,
        "book_detail": "สำคัญแห่งคัมภีร์ในพระพุทธศาสนาจึงมีลดหลั่นกันลงมา คือ",
        "book_lines": 3,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 55,
        "book_detail": "          ๑. พระสูตร คือพระพุทธวจนะที่เรียกว่า พระไตรปิฎกทั้งพระวินัย",
        "book_lines": 4,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 56,
        "book_detail": "ปิฎก พระสุตตันตปิฎก และพระอภิธรรมปิฎก",
        "book_lines": 5,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 57,
        "book_detail": "          ๒. สุตตานุโลม คือพระคัมภีร์ที่พระอรรถกถาจารย์รจนาขึ้น อธิบาย",
        "book_lines": 6,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 58,
        "book_detail": "ข้อความที่ยากในพระไตรปิฎก",
        "book_lines": 7,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 59,
        "book_detail": "          ๓. อาจริยวาท วาทะของอาจารย์ต่างๆ ตั้งแต่ชั้นฎีกาอนุฎีกา และ",
        "book_lines": 8,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 60,
        "book_detail": "บุรพาจารย์ในรุ่นหลัง",
        "book_lines": 9,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 61,
        "book_detail": "          ๔. อัตโนมติ ความคิดเห็นของผู้พูด ผู้แสดงธรรมในพระพุทธ-",
        "book_lines": 10,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 62,
        "book_detail": "ศาสนา",
        "book_lines": 11,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 63,
        "book_detail": "          ในกาลต่อมา มีการอธิบายธรรมประเภทอาจริยวาท คือ ถือตามที่",
        "book_lines": 12,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 64,
        "book_detail": "อาจารย์ของตนสอนไว้ กับอัตโนมติ ว่าไปตามมติของตนกันมากขึ้น ทั้งนี้",
        "book_lines": 13,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 65,
        "book_detail": "อาจจะเป็นเพราะพระคัมภีร์พระพุทธศาสนาที่เป็นหลักสำคัญ คือพระไตรปิฎก ",
        "book_lines": 14,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 66,
        "book_detail": "และอรรถกถามีไม่แพร่หลาย อรรถกถาส่วนมากยังเป็นภาษาบาลี คนมี",
        "book_lines": 15,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 67,
        "book_detail": "ฉันทะในภาษาบาลีน้อยลง สำนวนภาษาบาลีที่แปลออกมาแล้วยากต่อการทำ",
        "book_lines": 16,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 68,
        "book_detail": "ความเข้าใจของคนที่ไม่ได้ศึกษามาก่อน ขาดกัลยาณมิตรที่เป็นสัตบุรุษใน",
        "book_lines": 17,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 69,
        "book_detail": "พระพุทธศาสนาเป็นต้น",
        "book_lines": 18,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 70,
        "book_detail": "          การอธิบายธรรมที่เป็นผลจากการตรัสรู้ ของพระอรหันตสัมมา-",
        "book_lines": 19,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 71,
        "book_detail": "สัมพุทธเจ้านั้น เป็นอันตรายมากเพราะโอกาสที่จะเข้าใจผิด พูดผิด ปฏิบัติ",
        "book_lines": 20,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 72,
        "book_detail": "ผิดมีได้ง่าย พระไตรปิฎกเป็นเหมือนรัฐธรรมนูญ กฎหมายทั่วไปจะขัดแย้ง",
        "book_lines": 21,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 73,
        "book_detail": "กับกฎหมายรัฐธรรมนูญไม่ได้ฉันใด การอธิบายธรรมขัดแย้งกับพระไตรปิฎก",
        "book_lines": 22,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 74,
        "book_detail": "พุทธศาสนิกชนที่ดีย่อมถือว่าทำไม่ได้เช่นเดียวกันฉันนั้น",
        "book_lines": 23,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 75,
        "book_detail": "LineNull",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 76,
        "book_detail": "                                              (-๔-)",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 77,
        "book_detail": "LineNull",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 78,
        "book_detail": "          เพื่อให้พระพุทธวจนะอันปรากฏในพระไตรปิฎก แพร่หลายออกมา",
        "book_lines": 1,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 79,
        "book_detail": "ในรูปภาษาไทย และให้เกิดความรู้ความเข้าใจพระพุทธศาสนา ตรงตามหลัก",
        "book_lines": 2,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 80,
        "book_detail": "ที่ปรากฏในพระไตรปิฎก และที่พระอรรถกถาจารย์อธิบายไว้ จะได้เกิดทิฏฐิ",
        "book_lines": 3,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 81,
        "book_detail": "สามัญญตา ความเสมอกันในด้านทิฐิ และ สีลสามัญญตา ความเสมอกันใน",
        "book_lines": 4,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 82,
        "book_detail": "ด้านศีล ของชาวพุทธทั้งฝ่ายบรรพชิตและคฤหัสถ์ มหามกุฏราชวิทยาลัยจึงได้",
        "book_lines": 5,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 83,
        "book_detail": "จัดให้มีการแปลพระไตรปิฎกและอรรถกถาขึ้น โดยมีหลักการในการดำเนินงาน",
        "book_lines": 6,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 84,
        "book_detail": "ดังต่อไปนี้ คือ",
        "book_lines": 7,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 85,
        "book_detail": "          ๑. นำเอาพระสูตรและอรรถกถาแห่งพระสูตรนั้นๆ มาพิมพ์เชื่อม",
        "book_lines": 8,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 86,
        "book_detail": "ต่อกันไป เพื่อช่วยให้ท่านที่ไม่เข้าใจข้อความในพระสูตร สามารถหาคำตอบ",
        "book_lines": 9,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 87,
        "book_detail": "ได้จากอรรถกถาในเล่มเดียวกัน",
        "book_lines": 10,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 88,
        "book_detail": "          ๒. เนื่องจากพระวินัยปิฎกเป็นเรื่องของพระภิกษุสามเณรโดย",
        "book_lines": 11,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 89,
        "book_detail": "เฉพาะ อรรถกถาพระวินัยได้แปลกันมากแล้ว พระอภิธรรมปิฎกก็ได้แปล",
        "book_lines": 12,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 90,
        "book_detail": "แพร่หลายแล้วพร้อมทั้งอรรถกถา แต่มีการศึกษากันในวงจำกัด การ",
        "book_lines": 13,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 91,
        "book_detail": "ทำงานในคราวแรก จึงเริ่มที่พระสุตตันตปิฎกก่อน โดยเรียงตามลำดับนิกาย",
        "book_lines": 14,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 92,
        "book_detail": "          ๓. ในการแปลนั้นกำหนดให้ข้อความเป็นภาษาไทยมากที่สุด ใน",
        "book_lines": 15,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 93,
        "book_detail": "ขณะเดียวกันต้องมองเห็นศัพท์ภาษาบาลีด้วย เพื่อช่วยให้คนที่ไม่ศึกษา",
        "book_lines": 16,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 94,
        "book_detail": "ภาษาบาลีอ่านเข้าใจ และนักศึกษาภาษาบาลีได้หลักในการสอบทานเทียบ",
        "book_lines": 17,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 95,
        "book_detail": "เคียง",
        "book_lines": 18,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 96,
        "book_detail": "          ๔. คณะกรรมการผู้ทำงานได้คัดเลือกท่านที่มีความชำนิชำนาญใน",
        "book_lines": 19,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 97,
        "book_detail": "ภาษาบาลี มีความรักงาน มีความเสียสละ พร้อมที่จะทำงานเพื่อเป็น",
        "book_lines": 20,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 98,
        "book_detail": "พุทธบูชา",
        "book_lines": 21,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 99,
        "book_detail": "LineNull",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 100,
        "book_detail": "                                              (-๕-)",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 101,
        "book_detail": "LineNull",
        "book_lines": 0,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 102,
        "book_detail": "          ๕. ผลงานที่จะพิมพ์ขึ้นมาตามลำดับนั้น พยายามหาผู้ใจบุญ",
        "book_lines": 1,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 103,
        "book_detail": "ช่วยเสียสละรับหน้าที่เป็นเจ้าภาพในการพิมพ์แต่ละเล่ม เมื่อพิมพ์เสร็จแล้วจัด",
        "book_lines": 2,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 104,
        "book_detail": "จำหน่ายด้วยราคาเกินทุนที่ใช้พิมพ์เพียงเล็กน้อยเท่านั้น เพื่อให้ผู้มีความ",
        "book_lines": 3,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 105,
        "book_detail": "สนใจทั่วๆ ไป สามารถซื้อหาไปอ่านได้",
        "book_lines": 4,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 106,
        "book_detail": "          งานเหล่านี้จะดำเนินไปโดยลำดับ ตามกำลังทรัพย์และกำลังศรัทธา",
        "book_lines": 5,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 107,
        "book_detail": "ของท่านที่เห็นผลประโยชน์จากงานนี้จะให้การสนับสนุน",
        "book_lines": 6,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 108,
        "book_detail": "          มหามกุฎราชวิทยาลัยหวังว่า งานแปลพระไตรปิฎก อรรถกถา และ",
        "book_lines": 7,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 109,
        "book_detail": "ปริวรรตอรรถกถาแต่ละเล่มคงอำนวยประโยชน์ให้แก่พระพุทธศาสนา พระภิกษุ ",
        "book_lines": 8,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 110,
        "book_detail": "สามเณร ท่านพุทธศาสนิกชนผู้สนใจในหลักธรรม และคงเป็นถาวรกรรม",
        "book_lines": 9,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 111,
        "book_detail": "อันอำนวยประโยชน์ได้นานแสนนาน",
        "book_lines": 10,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 112,
        "book_detail": "          งานในคราวแรกนี้ อาจจะมีความผิดพลาดบกพร่องอยู่บ้าง ซึ่งหวังว่า",
        "book_lines": 11,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 113,
        "book_detail": "คงได้รับความเมตตากรุณาชี้แนะจากท่านผู้รู้ทั้งหลาย เพื่อปรับปรุงแก้ไขให้มี",
        "book_lines": 12,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 114,
        "book_detail": "ความสมบูรณ์ยิ่งขึ้นในโอกาสต่อไป",
        "book_lines": 13,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 115,
        "book_detail": "          มหามกุฎราชวิทยาลัย ต้องการให้พระคัมภีร์เล่มนี้ เป็นอนุสรณ์",
        "book_lines": 14,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 116,
        "book_detail": "เนื่องในวโรกาสครบ 200 ปีแห่งพระราชวงศ์จักรีกรุงรัตนโกสินทร์อีกด้วย",
        "book_lines": 15,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 117,
        "book_detail": "          ขออานุภาพแห่งพระรัตนตรัย ได้ดลบันดาลให้ท่าน",
        "book_lines": 16,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 118,
        "book_detail": "ผู้สนับสนุนในการแปล ปริวรรต ให้ทุนพิมพ์และจัดซื้อพระคัมภีร์",
        "book_lines": 17,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 119,
        "book_detail": "แปลเล่มนี้ และเล่มอื่นๆ จงประสบความเจริญในธรรม อัน",
        "book_lines": 18,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 120,
        "book_detail": "พระผู้มีพระภาคเจ้าทรงประกาศไว้ดีแล้วโดยทั่วกัน.",
        "book_lines": 19,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 121,
        "book_detail": "LineNull",
        "book_lines": 20,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 122,
        "book_detail": "                                        มหามกุฎราชวิทยาลัย",
        "book_lines": 21,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    },
    {
        "book_id": 0,
        "book_pages": 1,
        "book_line": 123,
        "book_detail": "                                                  ๒๕๒๗_",
        "book_lines": 22,
        "book_edit": null,
        "book_dict": null,
        "book_detail_old": null
        
    }
]
''';

List<BookTri91>? parseBooks(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => BookTri91.fromJson(json)).toList();
}
