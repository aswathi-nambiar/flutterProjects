import 'package:doctors_app/utils/responsive_extensions.dart';
import 'package:doctors_app/widgets/sizer_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'data_provider/chat_provider.dart';
import 'utils/custom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider( providers: [
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child:  MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'YourBuddyDoctor',
          theme: buildThemeData(),
          home: const CustomNavBar(),
        ),);

      },
    );
  }

  ThemeData buildThemeData() {
    return ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            headline1: GoogleFonts.yantramanav(
              fontSize: 22.0.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: Colors.black87,
            ),
            headline4: GoogleFonts.yantramanav(
              fontSize: 20.0.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: Colors.black87,
            ),
            headline3: GoogleFonts.yantramanav(
              fontSize: 16.0.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: Colors.black87,
            ),
            headline2: GoogleFonts.yantramanav(
              fontSize: 18.0.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: Colors.black87,
            ),
            bodyText1: GoogleFonts.yantramanav(
              fontSize: 12.0.sp,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w400,
            ),
            bodyText2: GoogleFonts.yantramanav(
                fontSize: 14.0.sp, letterSpacing: 1.0),
            headline5: GoogleFonts.yantramanav(
                fontSize: 16.0.sp, letterSpacing: 1.0),
          ),
          splashColor: const Color(0xff1651DA),
        );
  }
}
