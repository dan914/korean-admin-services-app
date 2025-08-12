import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_button.dart';
import '../ui/design_tokens.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.bgDefault,
      body: SafeArea(
        child: Column(
          children: [
            // Mobile App Bar
            _buildMobileAppBar(),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(DesignTokens.spacingBase),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: DesignTokens.spacingXl),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    DesignTokens.success,
                                    DesignTokens.success.withOpacity(0.8),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: DesignTokens.success.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: DesignTokens.spacingXl),
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: Column(
                        children: [
                          Text(
                            '신청이 완료되었습니다! 🎉',
                            style: TextStyle(
                              fontSize: DesignTokens.fontXxl,
                              fontWeight: FontWeight.bold,
                              color: DesignTokens.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: DesignTokens.spacingBase),
                          Text(
                            '전문 행정사가 입력해 주신 내용을\n검토하여 빠른 시일 내에 연락드리겠습니다',
                            style: TextStyle(
                              fontSize: DesignTokens.fontBase,
                              color: DesignTokens.textSecondary,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: DesignTokens.spacingXl),
                          
                          // Attorney Profile Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(DesignTokens.spacingLg),
                            decoration: BoxDecoration(
                              color: DesignTokens.bgCard,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                              border: Border.all(color: DesignTokens.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(DesignTokens.spacingXs),
                                      decoration: BoxDecoration(
                                        color: DesignTokens.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                      ),
                                      child: Icon(
                                        Icons.person_outline_rounded,
                                        color: DesignTokens.primary,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(width: DesignTokens.spacingSm),
                                    Text(
                                      '담당 행정사',
                                      style: TextStyle(
                                        fontSize: DesignTokens.fontLg,
                                        fontWeight: FontWeight.bold,
                                        color: DesignTokens.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: DesignTokens.spacingLg),
                                Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: DesignTokens.primary,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: _buildProfileImage(),
                                      ),
                                    ),
                                    SizedBox(width: DesignTokens.spacingBase),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '대표 / 행정사',
                                            style: TextStyle(
                                              fontSize: DesignTokens.fontSm,
                                              color: DesignTokens.textSecondary,
                                            ),
                                          ),
                                          SizedBox(height: DesignTokens.spacingXs),
                                          Text(
                                            '유병찬',
                                            style: TextStyle(
                                              fontSize: DesignTokens.fontXl,
                                              fontWeight: FontWeight.bold,
                                              color: DesignTokens.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: DesignTokens.spacingXs),
                                          Text(
                                            '유앤유 행정사 사무소',
                                            style: TextStyle(
                                              fontSize: DesignTokens.fontSm,
                                              color: DesignTokens.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: DesignTokens.spacingLg),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(DesignTokens.spacingBase),
                                  decoration: BoxDecoration(
                                    color: DesignTokens.bgDefault.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '주요 경력',
                                        style: TextStyle(
                                          fontSize: DesignTokens.fontSm,
                                          fontWeight: FontWeight.w600,
                                          color: DesignTokens.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: DesignTokens.spacingSm),
                                      _buildMobileProfileItem('서울대학교 고고미술사학 학사'),
                                      _buildMobileProfileItem('서울대학교 행정대학원 석사'),
                                      _buildMobileProfileItem('영국 쉐필드대학교 도시계획학 석사'),
                                      _buildMobileProfileItem('행정고시 (제35회)'),
                                      _buildMobileProfileItem('감사원 27년 근무 (감사처장 등)'),
                                      _buildMobileProfileItem('우리금융 고문'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: DesignTokens.spacingXl),
                          
                          // Process Info Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(DesignTokens.spacingLg),
                            decoration: BoxDecoration(
                              color: DesignTokens.bgCard,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                              border: Border.all(color: DesignTokens.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(DesignTokens.spacingXs),
                                      decoration: BoxDecoration(
                                        color: DesignTokens.info.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                      ),
                                      child: Icon(
                                        Icons.schedule_rounded,
                                        color: DesignTokens.info,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(width: DesignTokens.spacingSm),
                                    Text(
                                      '다음 단계 안내',
                                      style: TextStyle(
                                        fontSize: DesignTokens.fontLg,
                                        fontWeight: FontWeight.bold,
                                        color: DesignTokens.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: DesignTokens.spacingBase),
                                _buildMobileInfoRow(
                                  Icons.access_time_rounded,
                                  '예상 연락 시간',
                                  '평일 기준 1~2일 이내',
                                ),
                                SizedBox(height: DesignTokens.spacingBase),
                                _buildMobileInfoRow(
                                  Icons.phone_in_talk_rounded,
                                  '전화 상담',
                                  '첫 10분 무료, 이후 유료',
                                ),
                                SizedBox(height: DesignTokens.spacingBase),
                                _buildMobileInfoRow(
                                  Icons.notifications_active_rounded,
                                  '알림 방식',
                                  '카카오톡 또는 SMS',
                                ),
                                SizedBox(height: DesignTokens.spacingBase),
                                _buildMobileInfoRow(
                                  Icons.mail_outline_rounded,
                                  '상세 정보',
                                  '이메일로 전송',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Fixed bottom buttons
            _buildMobileBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingBase,
        vertical: DesignTokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.bgAlt,
        border: Border(
          bottom: BorderSide(color: DesignTokens.borderLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: DesignTokens.success,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: DesignTokens.spacingBase),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '신청 완료',
                style: TextStyle(
                  fontSize: DesignTokens.fontLg,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.textPrimary,
                ),
              ),
              Text(
                '전문 행정사 상담',
                style: TextStyle(
                  fontSize: DesignTokens.fontSm,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.spacingBase,
        DesignTokens.spacingBase,
        DesignTokens.spacingBase,
        DesignTokens.spacingBase + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.bgAlt,
        border: Border(
          top: BorderSide(color: DesignTokens.borderLight, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                elevation: DesignTokens.elevationMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_rounded, size: 20),
                  SizedBox(width: DesignTokens.spacingSm),
                  Text(
                    '홈으로 돌아가기',
                    style: TextStyle(
                      fontSize: DesignTokens.fontBase,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: DesignTokens.spacingSm),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                context.go('/');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.primary,
                side: BorderSide(color: DesignTokens.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
                ),
              ),
              child: Text(
                '새로운 상담 시작',
                style: TextStyle(
                  fontSize: DesignTokens.fontSm,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Image.asset(
      'assets/images/attorney_profile.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: DesignTokens.primary,
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 50,
          ),
        );
      },
    );
  }

  Widget _buildMobileProfileItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: EdgeInsets.only(
              top: DesignTokens.spacingSm,
              right: DesignTokens.spacingSm,
            ),
            decoration: BoxDecoration(
              color: DesignTokens.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: DesignTokens.fontSm,
                color: DesignTokens.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(DesignTokens.spacingXs),
          decoration: BoxDecoration(
            color: DesignTokens.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Icon(
            icon,
            size: 16,
            color: DesignTokens.info,
          ),
        ),
        SizedBox(width: DesignTokens.spacingBase),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: DesignTokens.fontSm,
                  color: DesignTokens.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: DesignTokens.fontBase,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}