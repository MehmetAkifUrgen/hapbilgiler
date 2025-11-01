import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/game_controller.dart';
import 'providers/theme_provider.dart';
import 'views/main_menu_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => GameController()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Hap bilgiler',
                theme: themeProvider.lightTheme.copyWith(
                  textTheme: GoogleFonts.poppinsTextTheme(
                    themeProvider.lightTheme.textTheme,
                  ),
                  appBarTheme: themeProvider.lightTheme.appBarTheme.copyWith(
                    titleTextStyle: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                darkTheme: themeProvider.darkTheme.copyWith(
                  textTheme: GoogleFonts.poppinsTextTheme(
                    themeProvider.darkTheme.textTheme,
                  ),
                  appBarTheme: themeProvider.darkTheme.appBarTheme.copyWith(
                    titleTextStyle: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                home: const MainMenuScreen(),
                debugShowCheckedModeBanner: false,
              );
            },
          ),
        );
      },
    );
  }
}
