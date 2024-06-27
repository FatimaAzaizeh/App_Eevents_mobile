import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Cart.dart';
import 'package:testtapp/models/User.dart';
import 'package:testtapp/screens/Home_screen.dart';

class LoginSignupScreen extends StatefulWidget {
  static const String screenRoute = 'login_signup';
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController emailSignUpController = TextEditingController();
  TextEditingController passwordSignUpController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isSignupScreen = true;
  bool isMale = true;
  bool isAdmin = false;

  void _authenticateUser() async {
    try {
      if (isSignupScreen) {
        if (passwordSignUpController.text.length < 6) {
          ErrorAlert(
            context,
            "كلمة مرور خاطئة",
            'كلمة السر يجب أن تكون 6 أحرف على الأقل',
          );
          return;
        }

        final newUser = await _auth.createUserWithEmailAndPassword(
          email: emailSignUpController.text.trim(),
          password: passwordSignUpController.text,
        );

        if (newUser.user != null) {
          String? uid = newUser.user!.uid;

          UserDataBase newUserDatabase = UserDataBase(
            UID: uid,
            email: emailSignUpController.text,
            name: nameController.text,
            user_type_id:
                FirebaseFirestore.instance.collection('user_types').doc('2'),
            phone: '',
            address: '',
            isActive: true,
            imageUrl: '',
          );

          String result = await newUserDatabase.saveToDatabase();
          if (result == 'User added to the database successfully!') {
            SuccessAlert(context, "تم تسجيل دخولك كمستخدم جديد بنجاح");
          }
          User? currentUser = FirebaseAuth.instance.currentUser;
          Cart cartItem = Cart(userId: currentUser!.uid, vendors: {});
          cartItem.uploadToFirebase();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        User? currentUser = FirebaseAuth.instance.currentUser;
        Cart cartItem = Cart(userId: currentUser!.uid, vendors: {});
        cartItem.uploadToFirebase();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print('Authentication Error: $e');

      if (e is FirebaseAuthException) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
            break;
          case 'user-not-found':
            errorMessage = 'البريد الإلكتروني غير مسجل';
            break;
          case 'wrong-password':
            errorMessage = 'كلمة السر غير صحيحة';
            break;
          case 'weak-password':
            errorMessage = 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
            break;
          default:
            errorMessage = 'حدث خطأ ما. حاول مرة أخرى.';
        }

        ErrorAlert(context, "خطأ", errorMessage);
      }
    }
  }

//main Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/rrr.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          buildBottomHalfContainer(true),
          Center(
            child: AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.bounceInOut,
              top: isSignupScreen ? 200 : 230,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.bounceInOut,
                height: isSignupScreen ? 380 : 250,
                width: MediaQuery.of(context).size.width - 40,
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTab("تسجيل الدخول", !isSignupScreen),
                          _buildTab("مستخدم جديد", isSignupScreen),
                        ],
                      ),
                      if (isSignupScreen) buildSignupSection(),
                      if (!isSignupScreen) buildSigninSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          buildBottomHalfContainer(false),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSignupScreen = text == "مستخدم جديد";
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: StyleTextAdmin(
                16, isSelected ? Palette.activeColor : AdminButton),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 3),
              height: 2,
              width: 55,
              color: Color.fromARGB(255, 231, 107, 128),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            isSignupScreen ? "أو التسجيل بواسطة" : "أو تسجيل الدخول بواسطة",
            style: StyleTextAdmin(12, Colors.black),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTextButton(Icons.g_mobiledata, "Google",
                  Color.fromARGB(255, 182, 103, 127)),
            ],
          ),
        ],
      ),
    );
  }

  Container buildSigninSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildTextField(Icons.mail_outline, "info@dana.com", false, true,
                emailController),
            buildTextField(Icons.lock_outline, "**********", true, false,
                passwordController),
          ],
        ),
      ),
    );
  }

  Container buildSignupSection() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(
          top: 20, left: screenWidth * 0.1, right: screenWidth * 0.1),
      child: Column(
        children: [
          buildTextField(Icons.account_box_outlined, "اسم المستخدم", false,
              false, nameController),
          buildTextField(Icons.email_outlined, "البريد الالكتروني", false, true,
              emailSignUpController),
          buildTextField(Icons.lock_outline, "كلمة السر", true, false,
              passwordSignUpController),
          Container(
            width: screenWidth * 0.4, // Adjust the width based on screen size
            margin: EdgeInsets.only(top: 8),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: " عند الضغط على الزر فانك موافق ",
                  style: TextStyle(fontSize: 10, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "على الشروط و الاحكام",
                      style: TextStyle(fontSize: 10, color: Colors.orange),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  TextButton buildTextButton(
      IconData icon, String title, Color backgroundColor) {
    return TextButton(
      // register a new user using Google Sign-In.
      onPressed: () async {
        // Initialize GoogleSignIn instance
        final GoogleSignIn googleSignIn = GoogleSignIn();

        try {
          final GoogleSignInAccount? googleSignInAccount =
              await googleSignIn.signIn();
          // Retrieve authentication details
          final GoogleSignInAuthentication googleSignInAuthentication =
              await googleSignInAccount!.authentication;
          // Create credentials for Firebase Authentication
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          // Sign in to Firebase with Google credentials
          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          final User? user = userCredential.user;

          // Extract Gmail email address
          String gmailEmail = googleSignInAccount.email;

          // Extract user's name
          String? userName = googleSignInAccount.displayName;

          UserDataBase newUser = UserDataBase(
            UID: user!.uid,
            email: gmailEmail,
            name: userName ?? '', // If displayName is null, use an empty string
            user_type_id:
                FirebaseFirestore.instance.collection('user_types').doc('2'),
            phone: '',
            address: '',
            isActive: true,
            imageUrl: '',
          );
          await newUser.saveToDatabase();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } catch (e) {
          print(e.toString());
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(width: 1, color: Colors.grey),
        minimumSize: Size(145, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: backgroundColor,
      ),
      child: Row(
        children: [
          Icon(
            icon,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            title,
          )
        ],
      ),
    );
  }

  Widget buildBottomHalfContainer(bool showShadow) {
    // Get screen height using MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate top position relative to screen height
    double topPosition =
        isSignupScreen ? screenHeight * 0.65 : screenHeight * 0.6;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      curve: Curves.bounceInOut,
      top: topPosition,
      right: 0,
      left: 0,
      child: Center(
        child: Container(
          height: 90,
          width: 90,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.3),
                      spreadRadius: 1.5,
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: !showShadow
              ? GestureDetector(
                  onTap: _authenticateUser,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 241, 199, 135),
                          Color.fromARGB(255, 243, 134, 132),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                )
              : Center(),
        ),
      ),
    );
  }

  Widget buildTextField(IconData icon, String hintText, bool isPassword,
      bool isEmail, TextEditingController controllerTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        style: StyleTextAdmin(14, Colors.black),
        obscureText: isPassword,
        controller: controllerTextField,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Palette.iconColor,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Palette.textColor1),
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Palette.textColor1),
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
          ),
          contentPadding: EdgeInsets.all(10),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
        ),
      ),
    );
  }
}
