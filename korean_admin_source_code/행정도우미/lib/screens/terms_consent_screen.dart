import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/design_tokens.dart';
import '../widgets/app_button.dart';
import '../providers/wizard_provider.dart';

class TermsConsentScreen extends ConsumerStatefulWidget {
  const TermsConsentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TermsConsentScreen> createState() => _TermsConsentScreenState();
}

class _TermsConsentScreenState extends ConsumerState<TermsConsentScreen> {
  bool _privacyConsent = false;
  bool _feeConsent = false;
  bool _termsConsent = false;
  
  // Admin access counter
  int _adminTapCount = 0;
  DateTime? _lastAdminTap;

  bool get _allConsentsGiven => _privacyConsent && _feeConsent && _termsConsent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.bgDefault,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar for mobile
            _buildMobileAppBar(),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  DesignTokens.spacingBase,
                  0,
                  DesignTokens.spacingBase,
                  DesignTokens.spacingBase,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    SizedBox(height: DesignTokens.spacingXl),
                    _buildServiceNotice(),
                    SizedBox(height: DesignTokens.spacingXl),
                    _buildConsentSection(),
                  ],
                ),
              ),
            ),
            // Fixed bottom button
            _buildFixedBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAppBar() {
    return GestureDetector(
      onTap: () {
        final now = DateTime.now();
        if (_lastAdminTap != null && now.difference(_lastAdminTap!).inSeconds < 2) {
          _adminTapCount++;
          if (_adminTapCount >= 5) {
            // Reset counter
            _adminTapCount = 0;
            // Show admin access dialog
            _showAdminAccessDialog();
          }
        } else {
          _adminTapCount = 1;
        }
        _lastAdminTap = now;
      },
      child: Container(
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
                color: DesignTokens.primary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Icon(
                Icons.description_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: DesignTokens.spacingBase),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '행정도우미',
                  style: TextStyle(
                    fontSize: DesignTokens.fontLg,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                Text(
                  '서비스 이용약관',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSm,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignTokens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.primary,
            DesignTokens.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
            ),
            child: Icon(
              Icons.handshake_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: DesignTokens.spacingBase),
          Text(
            '안녕하세요!',
            style: TextStyle(
              fontSize: DesignTokens.fontXxl,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: DesignTokens.spacingSm),
          Text(
            '전문 행정사와의 상담을 위한\n서비스 이용 동의가 필요합니다',
            style: TextStyle(
              fontSize: DesignTokens.fontBase,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceNotice() {
    return Container(
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
                  Icons.info_outline,
                  color: DesignTokens.info,
                  size: 18,
                ),
              ),
              SizedBox(width: DesignTokens.spacingSm),
              Text(
                '서비스 안내',
                style: TextStyle(
                  fontSize: DesignTokens.fontLg,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spacingBase),
          ..._buildNoticeItems(),
        ],
      ),
    );
  }

  List<Widget> _buildNoticeItems() {
    final items = [
      '이 서비스는 정부기관이 아닌, 행정사와의 상담 연결을 중개하는 플랫폼입니다.',
      '전화 상담 첫 10분은 무료이며, 추가 시간은 유료로 전환될 수 있습니다.',
      '상담·대행 과정은 유료일 수 있으며, 비용은 연결된 행정사가 사전 고지·동의 후 청구합니다.',
      '입력하신 정보는 상담 연결 및 사전 검토 목적으로 행정사에게 제공됩니다.',
    ];

    return items.map((item) => Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacingSm),
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
              item,
              style: TextStyle(
                fontSize: DesignTokens.fontSm,
                height: 1.6,
                color: DesignTokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildConsentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '필수 동의 항목',
          style: TextStyle(
            fontSize: DesignTokens.fontXl,
            fontWeight: FontWeight.bold,
            color: DesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: DesignTokens.spacingBase),
        _buildConsentCard(
          icon: Icons.privacy_tip_outlined,
          title: '개인정보 수집·이용 동의',
          value: _privacyConsent,
          onChanged: (value) => setState(() => _privacyConsent = value ?? false),
          details: _buildPrivacyDetails(),
        ),
        SizedBox(height: DesignTokens.spacingBase),
        _buildConsentCard(
          icon: Icons.payment_outlined,
          title: '유료 상담 연계 안내 확인',
          value: _feeConsent,
          onChanged: (value) => setState(() => _feeConsent = value ?? false),
          details: Text(
            '전화 상담 첫 10분은 무료, 이후 추가 시간 및 대행은 유료일 수 있으며 비용, 환불·취소 기준은 각 행정사 고지를 따릅니다.',
            style: TextStyle(
              fontSize: DesignTokens.fontSm,
              color: DesignTokens.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: DesignTokens.spacingBase),
        _buildConsentCard(
          icon: Icons.article_outlined,
          title: '이용약관 동의',
          value: _termsConsent,
          onChanged: (value) => setState(() => _termsConsent = value ?? false),
          details: null,
        ),
      ],
    );
  }

  Widget _buildPrivacyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('수집 항목', 
          '성명, 이메일, 전화번호, 행정상황 답변, 첨부 문서의 메타데이터, 접수일시, IP/로그(보안 목적)'),
        SizedBox(height: DesignTokens.spacingSm),
        _buildDetailRow('이용 목적', 
          '상담 연결, 자격 검토, 문의 대응, 기록 관리'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: DesignTokens.fontSm,
            fontWeight: FontWeight.w600,
            color: DesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: DesignTokens.spacingXs),
        Text(
          content,
          style: TextStyle(
            fontSize: DesignTokens.fontSm,
            color: DesignTokens.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildConsentCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    Widget? details,
  }) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacingLg),
      decoration: BoxDecoration(
        color: value ? DesignTokens.primaryLight : DesignTokens.bgCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: value ? DesignTokens.primary : DesignTokens.borderLight,
          width: value ? 1.5 : 1,
        ),
        boxShadow: value ? [
          BoxShadow(
            color: DesignTokens.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacingXs),
                decoration: BoxDecoration(
                  color: value ? DesignTokens.primary.withOpacity(0.1) : DesignTokens.textMuted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: value ? DesignTokens.primary : DesignTokens.textMuted,
                  size: 18,
                ),
              ),
              SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: Text(
                  '[필수] $title',
                  style: TextStyle(
                    fontSize: DesignTokens.fontBase,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textPrimary,
                  ),
                ),
              ),
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  activeColor: DesignTokens.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                  ),
                ),
              ),
            ],
          ),
          if (details != null) ...[
            SizedBox(height: DesignTokens.spacingBase),
            Container(
              padding: EdgeInsets.all(DesignTokens.spacingBase),
              decoration: BoxDecoration(
                color: DesignTokens.bgDefault.withOpacity(0.5),
                borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
              ),
              child: details,
            ),
          ],
        ],
      ),
    );
  }

  void _showAdminAccessDialog() {
    final TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('관리자 로그인'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('관리자 비밀번호를 입력하세요'),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // Simple password check - you should use more secure authentication
                if (passwordController.text == 'admin1234') {
                  Navigator.of(context).pop();
                  context.go('/admin');
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('잘못된 비밀번호입니다')),
                  );
                }
              },
              child: Text('로그인'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFixedBottomButton() {
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
          if (!_allConsentsGiven) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingBase,
                vertical: DesignTokens.spacingSm,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: DesignTokens.warning,
                    size: 16,
                  ),
                  SizedBox(width: DesignTokens.spacingSm),
                  Expanded(
                    child: Text(
                      '모든 필수 항목에 동의해주세요',
                      style: TextStyle(
                        fontSize: DesignTokens.fontSm,
                        color: DesignTokens.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: DesignTokens.spacingBase),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _allConsentsGiven ? () {
                ref.read(wizardProvider.notifier).setConsentAgreed();
                context.go('/wizard');
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: DesignTokens.textMuted.withOpacity(0.3),
                elevation: _allConsentsGiven ? DesignTokens.elevationMedium : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_allConsentsGiven) ...[
                    Icon(Icons.arrow_forward_rounded, size: 20),
                    SizedBox(width: DesignTokens.spacingSm),
                  ],
                  Text(
                    '상담 신청 시작하기',
                    style: TextStyle(
                      fontSize: DesignTokens.fontBase,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}