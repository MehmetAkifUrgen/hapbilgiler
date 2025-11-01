import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/quick_fact.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class QuickFactsScreen extends StatefulWidget {
  const QuickFactsScreen({super.key});

  @override
  State<QuickFactsScreen> createState() => _QuickFactsScreenState();
}

class _QuickFactsScreenState extends State<QuickFactsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<SubjectQuickFacts> _allFacts = [];
  SubjectQuickFacts? _selectedSubject;
  bool _isLoading = true;
  String? _error;
  
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _loadQuickFacts();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadQuickFacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final facts = await _apiService.getAllQuickFacts();
      setState(() {
        _allFacts = facts;
        if (facts.isNotEmpty) {
          _selectedSubject = facts.first;
        }
        _isLoading = false;
      });
      _animController.forward();
    } catch (e) {
      setState(() {
        _error = 'Hap bilgiler yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(context),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64.sp, color: Colors.red.shade300),
                        SizedBox(height: 16.h),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: _loadQuickFacts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_allFacts.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Henüz hap bilgi bulunmuyor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildSubjectTabs(),
                        SizedBox(height: 16.h),
                        Expanded(child: _buildFactsList()),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28.sp),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hap Bilgiler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Önemli bilgileri öğren',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTabs() {
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _allFacts.length,
        itemBuilder: (context, index) {
          final subject = _allFacts[index];
          final isSelected = _selectedSubject?.subjectKey == subject.subjectKey;
          
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSubject = subject;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white.withAlpha(102),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    subject.subjectName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFactsList() {
    if (_selectedSubject == null || _selectedSubject!.sections.isEmpty) {
      return Center(
        child: Text(
          'Bu konuda bilgi bulunmuyor',
          style: TextStyle(color: Colors.white70, fontSize: 16.sp),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _selectedSubject!.sections.length,
      itemBuilder: (context, index) {
        final section = _selectedSubject!.sections[index];
        return _buildSectionCard(section, index);
      },
    );
  }

  Widget _buildSectionCard(QuickFactSection section, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getCardGradient(context, null),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withAlpha(51), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            expansionTileTheme: ExpansionTileThemeData(
              iconColor: Colors.white,
              collapsedIconColor: Colors.white70,
              textColor: Colors.white,
              collapsedTextColor: Colors.white,
            ),
          ),
          child: ExpansionTile(
            initiallyExpanded: index == 0,
            tilePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            childrenPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.lightbulb, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(51),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: section.items.asMap().entries.map((entry) {
                    final itemIndex = entry.key;
                    final fact = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: itemIndex < section.items.length - 1 ? 12.h : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 4.h),
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${itemIndex + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              fact.fact,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}