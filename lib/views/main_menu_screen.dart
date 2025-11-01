import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import 'flag_game_screen.dart';
import 'subject_selection_screen.dart';
import 'quick_facts_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(context),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),
                  _buildHeader(),
                  SizedBox(height: 80.h),
                  _buildGameOptions(),
                  SizedBox(height: 40.h),
                  _buildFooter(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade400,
                    Colors.red.shade400,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withAlpha(102),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.games,
                size: 60.w,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            'Hap Bilgiler',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'KPSS & Bayrak Bulma Oyunu',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOptions() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGameCard(
            title: 'KPSS Soruları',
            subtitle: 'Ders seçerek soru çöz',
            icon: Icons.school,
            gradient: [Colors.green.shade600, Colors.teal.shade600],
            onTap: () => _navigateToSubjectSelection(),
          ),
          SizedBox(height: 30.h),
          _buildGameCard(
            title: 'Bayrak Bulma',
            subtitle: 'Ülke bayraklarını tanı',
            icon: Icons.flag,
            gradient: [Colors.orange.shade600, Colors.red.shade600],
            onTap: () => _navigateToFlagGame(),
          ),
          SizedBox(height: 30.h),
          _buildGameCard(
            title: 'Hap Bilgiler',
            subtitle: 'Önemli bilgileri öğren',
            icon: Icons.lightbulb,
            gradient: [Colors.purple.shade600, Colors.blue.shade600],
            onTap: () => _navigateToQuickFacts(),
          ),
          SizedBox(height: 40.h),
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withAlpha(102),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(
                icon,
                size: 30.w,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha(178),
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withAlpha(51)
                  : Colors.grey.withAlpha(51),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'İstatistikler',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Toplam Oyun',
                    '0', // Will be updated with real stats
                    Icons.games,
                    Colors.blue.shade400,
                  ),
                  _buildStatItem(
                    'En Yüksek Skor',
                    '0', // Will be updated with real stats
                    Icons.star,
                    Colors.amber.shade400,
                  ),
                  _buildStatItem(
                    'Doğruluk',
                    '0%', // Will be updated with real stats
                    Icons.trending_up,
                    Colors.green.shade400,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.w),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFooterButton(
                'Ayarlar',
                Icons.settings,
                () => _showSettingsDialog(),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: Colors.white.withAlpha(51),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 18.w),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFlagGame() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChangeNotifierProvider(
          create: (context) => GameController(),
          child: const FlagGameScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSubjectSelection() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SubjectSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToQuickFacts() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const QuickFactsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text(
          'Ayarlar',
          style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
        ),
        content: Consumer<ThemeProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  title: Text(
                    'Koyu Tema',
                    style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                  ),
                  trailing: Switch(
                    value: provider.isDarkMode,
                    onChanged: (value) {
                      provider.toggleTheme();
                    },
                    activeThumbColor: Colors.orange.shade400,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.volume_up,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  title: Text(
                    'Ses Efektleri',
                    style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                  ),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: Colors.orange.shade400,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.vibration,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  title: Text(
                    'Titreşim',
                    style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                  ),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: Colors.orange.shade400,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tamam',
              style: TextStyle(color: Colors.orange.shade400),
            ),
          ),
        ],
      ),
    );
  }

  
}