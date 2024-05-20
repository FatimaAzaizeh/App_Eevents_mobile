import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/home_screen.dart';

class checkoutscreen extends StatefulWidget {
  static const String screenRoute = 'checkout_screen';

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<checkoutscreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: ColorPink_100,
        scaffoldBackgroundColor: ColorPink_20,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorPink_100,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPink_100,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('تأكيد الطلب'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ملخص الطلب',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text('عدد العناصر: 2'),
              Text('السعر الإجمالي: \$25.00'),
              SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  _validateAndConfirmOrder(context);
                },
                child: Text('تأكيد الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndConfirmOrder(BuildContext context) {
    String name = _nameController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    String address = _addressController.text.trim();
    String missingFields = '';

    if (name.isEmpty) {
      missingFields += 'الاسم مفقود.\n';
    }
    if (phoneNumber.isEmpty) {
      missingFields += 'رقم الهاتف مفقود.\n';
    }
    if (address.isEmpty) {
      missingFields += 'العنوان مفقود.\n';
    }

    if (missingFields.isNotEmpty) {
      _showMissingFieldsDialog(context, missingFields);
    } else {
      _confirmOrder(context, name, phoneNumber, address);
    }
  }

  void _showMissingFieldsDialog(BuildContext context, String missingFields) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('خطأ في الإدخال'),
          content: Text(missingFields),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('حسنًا'),
            ),
          ],
        );
      },
    );
  }

  void _confirmOrder(
      BuildContext context, String name, String phoneNumber, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الطلب'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تم تأكيد الطلب بنجاح!'),
              SizedBox(height: 16),
              Text('الاسم: $name'),
              Text('رقم الهاتف: $phoneNumber'),
              Text('العنوان: $address'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تأكيد الطلب'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushReplacementNamed(context, HomeScreen.screenRoute);
              },
              child: Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }
}
