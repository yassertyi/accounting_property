import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("عن التطبيق")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "🧾 نبذة عن المشروع:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            const Text(
              "هذا النظام المحاسبي الشخصي يهدف إلى تسهيل إدارة العمال والموردين والمدفوعات والمواد بطريقة سهلة ومنظمة. "
              "تم تصميمه ليكون بسيطاً وسريعاً وفعالاً في إدارة المشاريع الصغيرة والمتوسطة.",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              "👨‍💻 تم تطوير التطبيق بواسطة:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            const Text(
              "ياسر العنيس\n📞 770997501\n🌐 GitHub: https://github.com/yassertyi \n🌐 Email: yasser.aloniass@gmail.com",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                "الإصدار 1.0.0",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
