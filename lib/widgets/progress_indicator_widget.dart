import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final int current;
  final int total;
  final Color primaryColor;
  final Color backgroundColor;

  const ProgressIndicatorWidget({
    super.key,
    required this.current,
    required this.total,
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.grey,
  });

  @override
  State<ProgressIndicatorWidget> createState() => _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _updateProgress();
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current || oldWidget.total != widget.total) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final newProgress = widget.total > 0 ? widget.current / widget.total : 0.0;
    
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: newProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _previousProgress = newProgress;
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLinearProgress(),
        SizedBox(height: 20.h),
        _buildCircularGauge(),
      ],
    );
  }

  Widget _buildLinearProgress() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.primaryColor.withAlpha(76),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İlerleme',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${widget.current}/${widget.total}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor.withAlpha(76),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Container(
                    height: 8.h,
                    width: MediaQuery.of(context).size.width * _progressAnimation.value * 0.8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.primaryColor,
                          widget.primaryColor.withAlpha(204),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4.r),
                      boxShadow: [
                        BoxShadow(
                          color: widget.primaryColor.withAlpha(102),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircularGauge() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.primaryColor.withAlpha(76),
          width: 1,
        ),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return SizedBox(
            width: 120.w,
            height: 120.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: CircularProgressIndicator(
                    value: _progressAnimation.value,
                    strokeWidth: 8.w,
                    backgroundColor: widget.backgroundColor.withAlpha(76),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Tamamlandı',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SimpleProgressIndicator extends StatefulWidget {
  final int current;
  final int total;
  final Color primaryColor;
  final Color backgroundColor;
  final double height;

  const SimpleProgressIndicator({
    super.key,
    required this.current,
    required this.total,
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.height = 6.0,
  });

  @override
  State<SimpleProgressIndicator> createState() => _SimpleProgressIndicatorState();
}

class _SimpleProgressIndicatorState extends State<SimpleProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _updateProgress();
  }

  @override
  void didUpdateWidget(SimpleProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current || oldWidget.total != widget.total) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final progress = widget.total > 0 ? widget.current / widget.total : 0.0;
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _progressAnimation.value,
          backgroundColor: widget.backgroundColor.withAlpha(76),
          valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
          minHeight: widget.height,
        );
      },
    );
  }
}