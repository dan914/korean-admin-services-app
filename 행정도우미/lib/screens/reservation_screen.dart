import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/design_tokens.dart';
import '../widgets/app_button.dart';
import '../providers/wizard_provider.dart';
import 'package:intl/intl.dart';

class ReservationScreen extends ConsumerStatefulWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  DateTime? selectedDate;
  String? firstTimeSlot;
  String? secondTimeSlot;
  
  final List<String> morningSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30'
  ];
  
  final List<String> afternoonSlots = [
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30'
  ];

  bool get canProceed => 
      selectedDate != null && 
      firstTimeSlot != null && 
      secondTimeSlot != null &&
      firstTimeSlot != secondTimeSlot;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMobileHeader(),
                    SizedBox(height: DesignTokens.spacingXl),
                    _buildMobileDateSelection(),
                    if (selectedDate != null) ...[
                      SizedBox(height: DesignTokens.spacingXl),
                      _buildMobileTimeSelection(),
                    ],
                    if (firstTimeSlot != null && secondTimeSlot != null) ...[
                      SizedBox(height: DesignTokens.spacingXl),
                      _buildMobileSelectionSummary(),
                    ],
                  ],
                ),
              ),
            ),
            // Fixed Bottom Button
            _buildMobileBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAppBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.spacingBase,
        DesignTokens.spacingSm,
        DesignTokens.spacingBase,
        DesignTokens.spacingBase,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.bgAlt,
        border: Border(
          bottom: BorderSide(color: DesignTokens.borderLight, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: DesignTokens.bgDefault,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: IconButton(
              onPressed: () => context.go('/memo'),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: DesignTokens.textPrimary,
              ),
              padding: EdgeInsets.all(DesignTokens.spacingSm),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ),
          SizedBox(width: DesignTokens.spacingBase),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '상담 예약',
                  style: TextStyle(
                    fontSize: DesignTokens.fontLg,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                Text(
                  '희망 시간대 선택',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSm,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: DesignTokens.secondary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.secondary,
            DesignTokens.secondary.withOpacity(0.8),
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
              Icons.access_time_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: DesignTokens.spacingBase),
          Text(
            '상담 시간 선택',
            style: TextStyle(
              fontSize: DesignTokens.fontXxl,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: DesignTokens.spacingSm),
          Text(
            '2개의 희망 시간대를 선택하시면\n행정사가 가능한 시간에 연락드립니다',
            style: TextStyle(
              fontSize: DesignTokens.fontBase,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: DesignTokens.spacingBase),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingBase,
              vertical: DesignTokens.spacingSm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
            ),
            child: Text(
              '💬 전화 상담 첫 10분은 무료입니다',
              style: TextStyle(
                fontSize: DesignTokens.fontSm,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDateSelection() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacingLg),
      decoration: BoxDecoration(
        color: DesignTokens.bgCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: DesignTokens.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: DesignTokens.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Icon(
                  Icons.event_rounded,
                  color: DesignTokens.primary,
                  size: 18,
                ),
              ),
              SizedBox(width: DesignTokens.spacingSm),
              Text(
                '상담 희망 날짜',
                style: TextStyle(
                  fontSize: DesignTokens.fontLg,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spacingLg),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(DesignTokens.spacingLg),
              decoration: BoxDecoration(
                color: selectedDate != null ? DesignTokens.primaryLight : DesignTokens.bgDefault,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                border: Border.all(
                  color: selectedDate != null ? DesignTokens.primary : DesignTokens.borderLight,
                  width: selectedDate != null ? 2 : 1,
                ),
                boxShadow: selectedDate != null ? [
                  BoxShadow(
                    color: DesignTokens.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(DesignTokens.spacingSm),
                    decoration: BoxDecoration(
                      color: selectedDate != null ? DesignTokens.primary : DesignTokens.textMuted.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: selectedDate != null ? Colors.white : DesignTokens.textMuted,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: DesignTokens.spacingBase),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDate != null
                              ? DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(selectedDate!)
                              : '날짜를 선택해 주세요',
                          style: TextStyle(
                            fontSize: DesignTokens.fontBase,
                            fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                            color: selectedDate != null 
                                ? DesignTokens.primary
                                : DesignTokens.textMuted,
                          ),
                        ),
                        if (selectedDate != null)
                          Text(
                            '선택 완료',
                            style: TextStyle(
                              fontSize: DesignTokens.fontSm,
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    selectedDate != null ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                    color: selectedDate != null ? DesignTokens.primary : DesignTokens.textMuted,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTimeSelection() {
    return Column(
      children: [
        _buildMobileTimeSlotSection(
          title: '첫 번째 희망 시간',
          subtitle: '가장 선호하는 시간대',
          icon: Icons.looks_one_rounded,
          isFirst: true,
        ),
        SizedBox(height: DesignTokens.spacingXl),
        _buildMobileTimeSlotSection(
          title: '두 번째 희망 시간',
          subtitle: '대안 시간대',
          icon: Icons.looks_two_rounded,
          isFirst: false,
        ),
      ],
    );
  }

  Widget _buildMobileTimeSlotSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isFirst,
  }) {
    final selectedTime = isFirst ? firstTimeSlot : secondTimeSlot;
    
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacingLg),
      decoration: BoxDecoration(
        color: DesignTokens.bgCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: selectedTime != null ? DesignTokens.primary : DesignTokens.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: selectedTime != null ? DesignTokens.primary.withOpacity(0.1) : DesignTokens.textMuted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: selectedTime != null ? DesignTokens.primary : DesignTokens.textMuted,
                  size: 18,
                ),
              ),
              SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: DesignTokens.fontLg,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: DesignTokens.fontSm,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedTime != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingBase,
                    vertical: DesignTokens.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryLight,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: Text(
                    selectedTime,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSm,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: DesignTokens.spacingLg),
          _buildMobileTimeSlots(morningSlots, afternoonSlots, isFirst),
        ],
      ),
    );
  }

  Widget _buildMobileTimeSlots(List<String> morning, List<String> afternoon, bool isFirst) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeSlotGroup('오전 🌅', morning, isFirst),
        SizedBox(height: DesignTokens.spacingLg),
        _buildTimeSlotGroup('오후 ☀️', afternoon, isFirst),
      ],
    );
  }

  Widget _buildTimeSlotGroup(String label, List<String> times, bool isFirst) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: DesignTokens.spacingSm),
          child: Text(
            label,
            style: TextStyle(
              fontSize: DesignTokens.fontSm,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textSecondary,
            ),
          ),
        ),
        SizedBox(height: DesignTokens.spacingSm),
        Wrap(
          spacing: DesignTokens.spacingSm,
          runSpacing: DesignTokens.spacingSm,
          children: times.map((time) => _buildMobileTimeChip(time, isFirst)).toList(),
        ),
      ],
    );
  }

  Widget _buildMobileTimeChip(String time, bool isFirst) {
    final isSelected = isFirst 
        ? firstTimeSlot == time 
        : secondTimeSlot == time;
    final isDisabled = isFirst 
        ? secondTimeSlot == time
        : firstTimeSlot == time;

    return GestureDetector(
      onTap: isDisabled ? null : () {
        setState(() {
          if (isFirst) {
            firstTimeSlot = isSelected ? null : time;
          } else {
            secondTimeSlot = isSelected ? null : time;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingBase,
          vertical: DesignTokens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? DesignTokens.primary 
              : (isDisabled 
                  ? DesignTokens.borderLight.withOpacity(0.5)
                  : DesignTokens.bgDefault),
          borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
          border: Border.all(
            color: isSelected 
                ? DesignTokens.primary 
                : (isDisabled 
                    ? DesignTokens.borderLight
                    : DesignTokens.borderLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: DesignTokens.primary.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                margin: EdgeInsets.only(right: DesignTokens.spacingXs),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              time,
              style: TextStyle(
                fontSize: DesignTokens.fontSm,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? Colors.white 
                    : (isDisabled 
                        ? DesignTokens.textMuted.withOpacity(0.5)
                        : DesignTokens.textPrimary),
              ),
            ),
            if (isDisabled)
              Container(
                width: 6,
                height: 6,
                margin: EdgeInsets.only(left: DesignTokens.spacingXs),
                decoration: BoxDecoration(
                  color: DesignTokens.textMuted.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSelectionSummary() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.success.withOpacity(0.1),
            DesignTokens.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: DesignTokens.success.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.success.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacingSm),
                decoration: BoxDecoration(
                  color: DesignTokens.success,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: DesignTokens.spacingBase),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택 완료',
                      style: TextStyle(
                        fontSize: DesignTokens.fontLg,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    Text(
                      '희망 시간대가 모두 선택되었습니다',
                      style: TextStyle(
                        fontSize: DesignTokens.fontSm,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spacingLg),
          Container(
            padding: EdgeInsets.all(DesignTokens.spacingBase),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
            ),
            child: Column(
              children: [
                _buildMobileSummaryRow(
                  Icons.event_rounded,
                  '상담 날짜',
                  DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(selectedDate!),
                ),
                SizedBox(height: DesignTokens.spacingBase),
                _buildMobileSummaryRow(
                  Icons.looks_one_rounded,
                  '1순위 시간',
                  firstTimeSlot!,
                ),
                SizedBox(height: DesignTokens.spacingBase),
                _buildMobileSummaryRow(
                  Icons.looks_two_rounded,
                  '2순위 시간',
                  secondTimeSlot!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(DesignTokens.spacingXs),
          decoration: BoxDecoration(
            color: DesignTokens.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Icon(
            icon,
            color: DesignTokens.primary,
            size: 16,
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DesignTokens.textDefault,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(const Duration(days: 1)); // Tomorrow
    final DateTime lastDate = now.add(const Duration(days: 30)); // 30 days from now

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: DesignTokens.primary,
              onPrimary: Colors.white,
              surface: DesignTokens.bgAlt,
              onSurface: DesignTokens.textDefault,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildMobileBottomButton() {
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
          if (!canProceed) ...[
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
                      '날짜와 2개의 시간대를 모두 선택해주세요',
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
              onPressed: canProceed
                  ? () {
                      // Save reservation data to provider
                      ref.read(wizardProvider.notifier).setAnswer('reservationDate', selectedDate.toString());
                      ref.read(wizardProvider.notifier).setAnswer('firstTimeSlot', firstTimeSlot);
                      ref.read(wizardProvider.notifier).setAnswer('secondTimeSlot', secondTimeSlot);
                      
                      // Navigate to summary
                      context.go('/summary');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: DesignTokens.textMuted.withOpacity(0.3),
                elevation: canProceed ? DesignTokens.elevationMedium : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '예약 완료하기',
                    style: TextStyle(
                      fontSize: DesignTokens.fontLg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: DesignTokens.spacingSm),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
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