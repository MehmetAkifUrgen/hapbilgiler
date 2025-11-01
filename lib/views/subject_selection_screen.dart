import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/subject_category.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import 'word_game_screen.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<SubjectCategory> _subjects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSubjects();
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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _loadSubjects() async {
    try {
      final apiService = ApiService();
      final subjects = await apiService.getAllSubjects();
      
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });

      _startAnimations();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _selectSubject(SubjectCategory subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordGameScreen(
          subjectKey: subject.key,
          subjectName: subject.displayName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFFAFAFA),
                    Color(0xFFF5F5F5),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.getTextPrimaryColor(context),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Ders Seçimi',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20.w,
              mainAxisSpacing: 20.h,
              childAspectRatio: 0.85,
            ),
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              return _buildSubjectCard(_subjects[index], index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.getTextPrimaryColor(context)),
          ),
          SizedBox(height: 20.h),
          Text(
            'Dersler yükleniyor...',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppTheme.getTextPrimaryColor(context),
          ),
          SizedBox(height: 20.h),
          Text(
            'Dersler yüklenirken hata oluştu',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            _error ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadSubjects();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF667eea),
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              'Tekrar Dene',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SubjectCategory subject, int index) {
    final color = _getSubjectColor(subject.key);
    
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animValue = (_slideController.value - delay).clamp(0.0, 1.0);
        
        return Transform.scale(
          scale: 0.8 + (animValue * 0.2),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _selectSubject(subject),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Arka plan pattern
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              // İçerik
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Icon(
                        _getSubjectIcon(subject.key),
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      subject.displayName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.quiz,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${subject.questions.length}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Color _getSubjectColor(String subjectKey) {
    switch (subjectKey) {
      case 'tarih_sorulari':
        return const Color(0xFF8B5CF6);
      case 'matematik_sorulari':
        return const Color(0xFF3B82F6);
      case 'turkce_sorulari':
        return const Color(0xFF10B981);
      case 'cografya_sorulari':
        return const Color(0xFFF59E0B);
      case 'fen_sorulari':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getSubjectIcon(String subjectKey) {
    switch (subjectKey) {
      case 'tarih_sorulari':
        return Icons.history_edu;
      case 'matematik_sorulari':
        return Icons.calculate;
      case 'turkce_sorulari':
        return Icons.menu_book;
      case 'cografya_sorulari':
        return Icons.public;
      case 'fen_sorulari':
        return Icons.science;
      default:
        return Icons.school;
    }
  }
}