/* 10-step wizard data with 4-1 ~ 4-3 conditional branches
   — codified exactly as provided by the product spec. */

import '../types/codes.dart';
import '../reference/agency_codes.dart';
import '../reference/region_codes.dart';
import '../reference/applicant_type_codes.dart';
import '../reference/doc_status_codes.dart';
// import '../reference/visa_codes.dart';     // TODO: Use for immigration sub-steps
// import '../reference/biz_type_codes.dart'; // TODO: Use for business type filtering

class StepOption {
  final String code;
  final String label;

  const StepOption({
    required this.code,
    required this.label,
  });
}

class SubStep {
  final String title;
  final List<StepOption> options;

  const SubStep({
    required this.title,
    required this.options,
  });
}

class WizardStep {
  final int id;
  final String title;
  final List<StepOption> options;
  final Map<String, List<SubStep>>? subSteps;

  const WizardStep({
    required this.id,
    required this.title,
    required this.options,
    this.subSteps,
  });
}

// Helper function to convert CodeItem to StepOption
List<StepOption> _codeItemsToOptions(List<CodeItem> codeItems) {
  return codeItems.map((item) => StepOption(code: item.code, label: item.ko)).toList();
}

class WizardSteps {
  static final List<WizardStep> steps = [
    /* 1단계 ─ 처리 목적 */
    WizardStep(
      id: 1,
      title: '어떤 목적으로 도와드릴까요?',
      options: const [
        StepOption(code: 'UNK', label: '잘 모르겠음'),
        StepOption(code: 'relief', label: '권익구제(불이익 해소)'),
        StepOption(code: 'permit', label: '인허가 신청 및 변경'),
        StepOption(code: 'support', label: '보조금·장려금·정부지원'),
        StepOption(code: 'immig', label: '출입국·체류·외국인'),
        StepOption(code: 'appeal', label: '이의신청·행정심판·진정'),
        StepOption(code: 'etc', label: '기타 민원 또는 일반 행정업무'),
      ],
    ),

    /* 2단계 ─ 대상 기관 */
    WizardStep(
      id: 2,
      title: '어느 기관 관련인가요?',
      options: _codeItemsToOptions(agencyCodes),
    ),

    /* 3단계 ─ 현재 상황 */
    WizardStep(
      id: 3,
      title: '현재 상황을 알려주세요.',
      options: const [
        StepOption(code: 'UNK', label: '잘 모르겠음'),
        StepOption(code: 'notice', label: '처분/불이익 통보를 받음'),
        StepOption(code: 'rejected', label: '신청했으나 불허됨'),
        StepOption(code: 'unknown', label: '무엇을 신청해야 할지 모름'),
        StepOption(code: 'supplement', label: '신청 중 보완요구 받음'),
        StepOption(code: 'inquiry', label: '단순 행정문의'),
      ],
    ),

    /* 4단계 ─ 사안 종류 (대·중·소 3단계 분기) */
    WizardStep(
      id: 4,
      title: '사안 종류를 선택해 주세요.',
      options: const [
        StepOption(code: 'UNK', label: '잘 모르겠음'),
        StepOption(code: 'penalty', label: '영업정지·과태료·허가취소 등'),
        StepOption(code: 'permit', label: '인허가 신청 및 변경'),
        StepOption(code: 'support', label: '보조금·장려금·정부지원'),
        StepOption(code: 'immig', label: '출입국·체류·외국인'),
        StepOption(code: 'appeal', label: '이의신청·행정심판·진정'),
        StepOption(code: 'etc', label: '기타'),
      ],
      subSteps: {
        'penalty': [
          SubStep(
            title: '어떤 법·분야와 관련인가요?',
            options: const [
              StepOption(code: 'UNK', label: '잘 모르겠음'),
              StepOption(code: 'food', label: '식품위생법'),
              StepOption(code: 'estate', label: '건축·부동산 중개'),
              StepOption(code: 'traffic', label: '도로교통·운수'),
              StepOption(code: 'labor', label: '노동관계법'),
              StepOption(code: 'tax', label: '세무·과세'),
              StepOption(code: 'env', label: '환경법'),
              StepOption(code: 'cancel', label: '허가 취소'),
            ],
          ),
        ],
        'permit': [
          SubStep(
            title: '인허가 종류를 선택해 주세요.',
            options: const [
              StepOption(code: 'UNK', label: '잘 모르겠음'),
              StepOption(code: 'biz-register', label: '영업(신고/허가)'),
              StepOption(code: 'change', label: '등록사항 변경'),
              StepOption(code: 'local', label: '지자체 승인(건축·공사 등)'),
              StepOption(code: 'medical', label: '복지·의료기관 설립'),
              StepOption(code: 'import', label: '수입허가·검역'),
              StepOption(code: 'land', label: '토지이용·개발허가'),
            ],
          ),
        ],
        'support': [
          SubStep(
            title: '지원금/장려금 종류를 선택해 주세요.',
            options: const [
              StepOption(code: 'UNK', label: '잘 모르겠음'),
              StepOption(code: 'sme', label: '소상공인 지원금'),
              StepOption(code: 'hire', label: '청년/노인 고용장려금'),
              StepOption(code: 'living', label: '주거·에너지·기초생활'),
              StepOption(code: 'emergency', label: '긴급복지·재난'),
              StepOption(code: 'startup', label: '창업·벤처지원'),
              StepOption(code: 'research', label: '연구개발·기술지원'),
            ],
          ),
          SubStep(
            title: '현재 어떤 상태이신가요?',
            options: const [
              StepOption(code: 'UNK', label: '잘 모르겠음'),
              StepOption(code: 'rejected', label: '신청했으나 거절됨'),
              StepOption(code: 'unclear', label: '요건이 잘 모호함'),
              StepOption(code: 'docs', label: '서류 준비가 복잡'),
              StepOption(code: 'notyet', label: '아직 신청 안 함'),
            ],
          ),
        ],
        'immig': [
          SubStep(
            title: '출입국·체류 업무를 선택해 주세요.',
            options: const [
              StepOption(code: 'UNK', label: '잘 모르겠음'),
              StepOption(code: 'extend', label: '체류기간 연장'),
              StepOption(code: 'temp', label: '임시입국허가'),
              StepOption(code: 'deport', label: '출국명령/퇴거 구제'),
              StepOption(code: 'natural', label: '국적·귀화'),
              StepOption(code: 'visa-change', label: '체류자격 변경'),
              StepOption(code: 'family', label: '가족초청·동반'),
            ],
          ),
        ],
        'appeal': [
          SubStep(
            title: '이의신청·심판 중 어떤 절차인가요?',
            options: const [
              StepOption(code: 'UNK', label: '잘 모르겠음'),
              StepOption(code: 'fine', label: '과태료 이의신청'),
              StepOption(code: 'cancel', label: '처분취소 행정심판'),
              StepOption(code: 'audit', label: '국민신문고·감사원'),
              StepOption(code: 'whistle', label: '내부 고발 보호'),
              StepOption(code: 'petition', label: '국정감사·청원'),
            ],
          ),
        ],
        'etc': [
          SubStep(
            title: '기타 사안 상세를 선택해 주세요.',
            options: const [
              StepOption(code: 'UNK', label: '잘 모르겠음'),
              StepOption(code: 'evict', label: '무단철거·토지수용'),
              StepOption(code: 'openinfo', label: '행정정보 공개 청구'),
              StepOption(code: 'tax', label: '지방세/과세 민원'),
              StepOption(code: 'welfare', label: '복지·연금 관련'),
              StepOption(code: 'education', label: '교육·학사 관련'),
              StepOption(code: 'other', label: '기타'),
            ],
          ),
        ],
      },
    ),

    /* 5단계 ─ 신청인 성격 */
    WizardStep(
      id: 5,
      title: '신청인 유형을 알려주세요.',
      options: _codeItemsToOptions(applicantTypeCodes),
    ),

    /* 6단계 ─ 문서 준비 상태 */
    WizardStep(
      id: 6,
      title: '관련 서류 준비 상태는?',
      options: _codeItemsToOptions(docStatusCodes),
    ),

    /* 7단계 ─ 지역 */
    WizardStep(
      id: 7,
      title: '신청인 거주 지역은?',
      options: _codeItemsToOptions(regionCodes),
    ),

    /* 8단계 ─ 급박도 */
    WizardStep(
      id: 8,
      title: '얼마나 급하신가요?',
      options: const [
        StepOption(code: 'UNK', label: '잘 모르겠음'),
        StepOption(code: 'day', label: '하루 이내'),
        StepOption(code: 'week', label: '일주일 내'),
        StepOption(code: 'month', label: '한 달 내'),
        StepOption(code: 'slow', label: '천천히 준비'),
      ],
    ),

    /* 9단계 ─ 원하는 상담 방식 */
    WizardStep(
      id: 9,
      title: '원하는 상담 방식을 골라주세요.',
      options: const [
        StepOption(code: 'UNK', label: '잘 모르겠음'),
        StepOption(code: 'phone', label: '전화 상담'),
        StepOption(code: 'email', label: '이메일 상담'),
        StepOption(code: 'visit', label: '직접 방문'),
        StepOption(code: 'online', label: '온라인 화상상담'),
        StepOption(code: 'delegate', label: '위임 계약(대행)'),
      ],
    ),

    /* 10단계 ─ 비용 인식 */
    WizardStep(
      id: 10,
      title: '비용에 대한 생각은?',
      options: const [
        StepOption(code: 'UNK', label: '잘 모르겠음'),
        StepOption(code: 'free', label: '무료만 원함'),
        StepOption(code: 'low', label: '저비용이면 OK'),
        StepOption(code: 'fair', label: '합리적 유료 대행 희망'),
        StepOption(code: 'urgent', label: '비용 불문, 신속·정확'),
      ],
    ),
  ];

  static WizardStep? getStepById(int id) {
    try {
      return steps.firstWhere((step) => step.id == id);
    } catch (e) {
      return null;
    }
  }

  static WizardStep? getStepByIndex(int index) {
    if (index >= 0 && index < steps.length) {
      return steps[index];
    }
    return null;
  }

  static int getTotalSteps() {
    return steps.length;
  }
}