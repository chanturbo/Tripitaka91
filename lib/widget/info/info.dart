import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';

class TripitakaInfoWidget extends StatelessWidget {
  const TripitakaInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const ATextDiskplayLarge(text: 'เกี่ยวกับแอปพลิเคชัน TRIPITAKA91'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ATextTitleLarge(
                  text: 'เกี่ยวกับแอปพลิเคชัน TRIPITAKA91',
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
                  text: 'ข้อมูลอ้างอิง',
                ),
                const SizedBox(height: 8.0),
                const ATextTitleMedium(
                  text:
                      '          พระไตรปิฎก-> อ้างอิงจาก พระไตรปิฎกและอรรถกถาแปล ชุด 91 เล่ม ฉบับ มหามกุฏราชวิทยาลัย (เล่มสีน้ำเงิน)',
                ),
                const ATextTitleMedium(
                  text:
                      '          สำหรับฐานข้อมูลพระไตรปิฎกได้มาจากโปรแกรม E-Tipitaka เว็บไซต์ http://etipitaka.com/ ซึ่งอนุญาตแจกจ่ายได้ ฟรี ภายใต้สัญญา Apache License, Version 2.0',
                ),
                const ATextTitleMedium(
                  text:
                      '          หัวข้อธรรม -> เป็นหัวข้อธรรมที่รวบรวมโดยคณะวัดสามแยก http://www.samyaek.com',
                ),
                const ATextTitleMedium(
                  text:
                      '          พจนานุกรม ฉบับประมวลศัพท์ -> รวบรวมโดย พระพรหมคุณาภรณ์ (ป.อ. ปยุตฺโต) ฐานข้อมูลได้มาจาก เว็บไซต์ http://www.mahamodo.com/downloads/programsdetail.aspx?id=999995',
                ),
                const ATextTitleMedium(
                  text:
                      '          พจนานุกรม ไทย-บาลี -> ฐานข้อมูลได้มาจากโปรแกรม E-Tipitaka เว็บไซต์ http://etipitaka.com/ ซึ่งอนุญาตแจกจ่ายได้ ฟรี ภายใต้สัญญา Apache License, Version 2.0',
                ),
                const ATextTitleMedium(
                  text:
                      '          คำที่น่าจะพิมพ์ผิด (พิมพ์ตก, พิมพ์หล่น) -> ดำเนินการตรวจสอบและแจ้งโดยกลุ่ม ตรวจสอบคำที่น่าจะผิด (พิมพ์ตก, พิมพ์หล่น) และแจ้งคำที่ถูก เฉพาะคำที่เป็นภาษาไทย  Facebook Tripitaka91 และขณะนี้ยังไม่ได้มีการแก้ไขไฟล์ต้นฉบับแต่อย่างใด',
                ),
                const SizedBox(height: 16.0),
                const ATextTitleMedium(
                  text:
                      'หมายเหตุ : แอปพลิเคชันแห่งนี้จัดทำขึ้นมีวัตถุประสงค์เพื่อเปิดเผยพระธรรมวินัย ไม่ได้มุ่งหมายทำการค้าแต่อย่างใด โดยนำหัวข้อธรรมที่ทางคณะวัดสามแยกได้จัดทำขึ้นมาดำเนินการ และหากมีรูปภาพหรือข้อความส่วนใดที่ละเมิดลิขสิทธิ์ กรุณาแจ้งที่ อีเมล์ chanturbo@hotmail.com เพื่อจะดำเนินการลบข้อมูลออกจากแอปพลิเคชันต่อไป',
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double
                      .infinity, // กำหนดให้ Container มีความกว้างเท่ากับหน้าจอ
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 85,
                        height: 30,
                        child: InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                          },
                          child: ClipPath(
                            clipper: DoubleTriangleRectangleClipper(),
                            child: Container(
                              padding: const EdgeInsets.all(0.0),
                              color: Colors.red, // Change color as needed
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
      ),
    );
  }
}
