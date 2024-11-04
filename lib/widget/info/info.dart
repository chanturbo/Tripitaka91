import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:url_launcher/url_launcher.dart';

class TripitakaInfoWidget extends StatelessWidget {
  const TripitakaInfoWidget({super.key});

  // ฟังก์ชันเปิดลิงก์
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const ATextDiskplayLarge(text: 'เกี่ยวกับเว็บไซต์ TRIPITAKA91.COM'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ATextTitleLarge(
                text: 'เกี่ยวกับเว็บไซต์ TRIPITAKA91.COM',
              ),
              const SizedBox(height: 8.0),
              const ATextTitleMedium(
                text:
                    '          เมื่อประมาณ ปี พ.ศ. 2555 ทีมงาน tripitaka91.com ได้ดำเนินการขออนุญาตกับทางวัดสามแยก เพื่อนำหัวข้อธรรม ที่สรุปและรวบรวมโดยคณะวัดสามแยก นำโดยอดีตพระอาจารย์เกษม อาจิณฺณสีโล ที่เล็งเห็นถึงความสำคัญของการศึกษาพระไตรปิฎก โดยให้คณะลูกศิษย์ (พระสงฆ์และฆราวาสขณะนั้น) อ่านพระไตรปิฎก พร้อมทั้งย่อสาระสำคัญในแต่ละเล่ม เพื่อสรุปเป็นหัวข้อธรรมให้ง่ายต่อการศึกษา และตกลงกันว่าจะใช้พระไตรปิฎก ฉบับ มหามกุฏราชวิทยาลัย ชุด 91 เล่ม พร้อมอรรถกถาแปล เป็นฉบับอ้างอิงสำหรับการดำเนินการ ในช่วงแรกของการจัดทำหัวข้อธรรม ได้จัดทำในรูปแบบหนังสือเป็นเล่มเพื่อแจกจ่ายให้กับผู้ที่ต้องการศึกษา โดยมีการจัดเรียงหัวข้อธรรมเป็นหมวดหมู่ไว้อย่างชัดเจน และต่อมาทางทีมงาน tripitaka91.com จึงนำหัวข้อธรรมดังกล่าวมาจัดทำเพื่อแสดงผลในรูปแบบของ Application ต่าง ๆ ไม่ว่าจะเป็น App บน iOS, Android, Windows และเว็บไซต์',
              ),
              const SizedBox(height: 16.0),
              const ATextTitleMedium(
                text:
                    '          สำหรับพระไตรปิฎกนั้น สรุปโดยย่อ คือ เป็นการจัดรวบรวมคำสอนของพระพุทธเจ้า ออกเป็นหมวดหมู่ และซักซ้อมทบทวนกันจนลงตัว ในระยะแรก พระไตรปิฎกถ่ายทอดต่อกันมาโดยการท่องจำปากเปล่า จนกระทั่งราว พ.ศ. 460 จึงมีการจารึกลงเป็นลายลักษณ์อักษร กล่าวได้ว่าพระพุทธศาสนาสืบทอดมาพร้อมกับพระไตรปิฎก จากสมัยพุทธกาลจนถึงวันนี้เป็นเวลากว่า 2,500 ปี พระไตรปิฎกบาลีของพระพุทธศาสนาฝ่ายเถรวาท เป็นที่ยอมรับกันว่า เป็นบันทึกคำสอนของพระพุทธเจ้าที่เก่าแก่ที่สุด ดั้งเดิมที่สุด สมบูรณ์ที่สุด และถูกต้องแม่นยำที่สุด ที่ยังคงมีอยู่ในปัจจุบัน',
              ),
              const SizedBox(height: 16.0),
              const ATextTitleLarge(
                text: 'ข้อมูลอ้างอิงเว็บไซต์',
              ),
              const SizedBox(height: 8.0),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _launchURL('http://etipitaka.com/'),
                  child: const ATextTitleMedium(
                    text:
                        '          สำหรับฐานข้อมูลพระไตรปิฎกได้มาจากโปรแกรม E-Tipitaka เว็บไซต์ http://etipitaka.com/ ซึ่งอนุญาตแจกจ่ายได้ ฟรี ภายใต้สัญญา Apache License, Version 2.0',
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _launchURL('http://www.samyaek.com'),
                  child: const ATextTitleMedium(
                    text:
                        '          หัวข้อธรรม -> เป็นหัวข้อธรรมที่รวบรวมโดยคณะวัดสามแยก http://www.samyaek.com',
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _launchURL(
                      'http://www.mahamodo.com/downloads/programsdetail.aspx?id=999995'),
                  child: const ATextTitleMedium(
                    text:
                        '          พจนานุกรม ฉบับประมวลศัพท์ -> รวบรวมโดย พระพรหมคุณาภรณ์ (ป.อ. ปยุตฺโต) ฐานข้อมูลได้มาจาก เว็บไซต์ http://www.mahamodo.com/downloads/programsdetail.aspx?id=999995',
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _launchURL('http://etipitaka.com/'),
                  child: const ATextTitleMedium(
                    text:
                        '          พจนานุกรม ไทย-บาลี -> ฐานข้อมูลได้มาจากโปรแกรม E-Tipitaka เว็บไซต์ http://etipitaka.com/ ซึ่งอนุญาตแจกจ่ายได้ ฟรี ภายใต้สัญญา Apache License, Version 2.0',
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _launchURL(
                      'https://www.facebook.com/groups/719264214834970/'),
                  child: const ATextTitleMedium(
                    text:
                        '          คำที่น่าจะพิมพ์ผิด (พิมพ์ตก, พิมพ์หล่น) -> ดำเนินการตรวจสอบและแจ้งโดยกลุ่ม ตรวจสอบคำที่น่าจะผิด (พิมพ์ตก, พิมพ์หล่น) และแจ้งคำที่ถูก เฉพาะคำที่เป็นภาษาไทย  Facebook Tripitaka91 และขณะนี้ยังไม่ได้มีการแก้ไขไฟล์ต้นฉบับแต่อย่างใด',
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const ATextTitleMedium(
                text:
                    'หมายเหตุ : เว็บไซต์แห่งนี้จัดทำขึ้นมีวัตถุประสงค์เพื่อเปิดเผยพระธรรมวินัย ไม่ได้มุ่งหมายทำการค้าแต่อย่างใด โดยนำหัวข้อธรรมที่ทางคณะวัดสามแยกได้จัดทำขึ้นมาดำเนินการ และหากมีรูปภาพหรือข้อความส่วนใดที่ละเมิดลิขสิทธิ์ กรุณาแจ้งที่ อีเมล์ chanturbo@hotmail.com เพื่อจะดำเนินการลบข้อมูลออกจากเว็บไซต์ต่อไป',
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 85,
                      height: 30,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: ClipPath(
                          clipper: DoubleTriangleRectangleClipper(),
                          child: Container(
                            padding: const EdgeInsets.all(0.0),
                            color: Colors.red,
                            child: const Center(
                              child: ATextDiskplayMedium(
                                text: 'ย้อนกลับ',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
