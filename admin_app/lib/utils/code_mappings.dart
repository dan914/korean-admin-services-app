// Maps wizard step codes to human-readable labels
class CodeMappings {
  // Step titles
  static const List<String> stepTitles = [
    '처리 목적', // Step 1
    '대상 기관', // Step 2  
    '현재 상황', // Step 3
    '사안 종류', // Step 4
    '신청인 유형', // Step 5
    '문서 준비 상태', // Step 6
    '지역', // Step 7
    '급박도', // Step 8
    '원하는 상담 방식', // Step 9
    '비용 인식', // Step 10
  ];

  // Step 1 - Purpose/목적
  static const Map<String, String> step1Codes = {
    'UNK': '잘 모르겠음',
    'relief': '권익구제(불이익 해소)',
    'permit': '인허가 신청 및 변경',
    'support': '보조금·장려금·정부지원',
    'immig': '출입국·체류·외국인',
    'appeal': '이의신청·행정심판·진정',
    'etc': '기타 민원 또는 일반 행정업무',
  };

  // Step 2 - Agency/대상 기관
  static const Map<String, String> step2Codes = {
    'UNK': '잘 모르겠음',
    '1010000': '기획재정부',
    '1020000': '교육부',
    '1030000': '과학기술정보통신부',
    '1040000': '외교부',
    '1050000': '통일부',
    '1060000': '법무부',
    '1070000': '국방부',
    '1080000': '행정안전부',
    '1090000': '문화체육관광부',
    '1100000': '농림축산식품부',
    '1110000': '산업통상자원부',
    '1120000': '보건복지부',
    '1130000': '환경부',
    '1140000': '고용노동부',
    '1150000': '여성가족부',
    '1160000': '국토교통부',
    '1170000': '해양수산부',
    '1180000': '중소벤처기업부',
    '2010000': '서울특별시청',
    '2020000': '부산광역시청',
    '2030000': '대구광역시청',
    '2040000': '인천광역시청',
    '2050000': '광주광역시청',
    '2060000': '대전광역시청',
    '2070000': '울산광역시청',
    '2080000': '세종특별자치시청',
    '2090000': '경기도청',
    '2100000': '강원도청',
    '2110000': '충청북도청',
    '2120000': '충청남도청',
    '2130000': '전라북도청',
    '2140000': '전라남도청',
    '2150000': '경상북도청',
    '2160000': '경상남도청',
    '2170000': '제주특별자치도청',
    '3010000': '국세청',
    '3020000': '관세청',
    '3030000': '조달청',
    '3040000': '통계청',
    '3050000': '경찰청',
    '3060000': '소방청',
    '3070000': '문화재청',
    '3080000': '농촌진흥청',
    '3090000': '산림청',
    '3100000': '특허청',
    '3110000': '기상청',
    '3120000': '행정중심복합도시건설청',
    '3130000': '새만금개발청',
    '4010000': '국민권익위원회',
    '4020000': '공정거래위원회',
    '4030000': '금융위원회',
    '4040000': '개인정보보호위원회',
    '4050000': '원자력안전위원회',
    '5010000': '감사원',
    '5020000': '국가인권위원회',
    '6010000': '법원',
    '6020000': '헌법재판소',
    '7010000': '중앙선거관리위원회',
    '8010000': '국회',
    '9010000': '대통령실',
    '9020000': '국가안보실',
    '9030000': '국무조정실',
    '9040000': '국무총리비서실',
    '9050000': '국가보훈부',
    '9060000': '식품의약품안전처',
    '9070000': '방송통신위원회',
    '9080000': '국가정보원',
    'etc': '기타 기관',
  };

  // Step 3 - Current Status/현재 상황
  static const Map<String, String> step3Codes = {
    'UNK': '잘 모르겠음',
    'notice': '처분/불이익 통보를 받음',
    'rejected': '신청했으나 불허됨',
    'unknown': '무엇을 신청해야 할지 모름',
    'supplement': '신청 중 보완요구 받음',
    'inquiry': '단순 행정문의',
  };

  // Step 4 - Service Type/사안 종류
  static const Map<String, String> step4Codes = {
    'UNK': '잘 모르겠음',
    'penalty': '영업정지·과태료·허가취소 등',
    'permit': '인허가 신청 및 변경',
    'support': '보조금·장려금·정부지원',
    'immig': '출입국·체류·외국인',
    'appeal': '이의신청·행정심판·진정',
    'etc': '기타',
  };

  // Step 5 - Applicant Type/신청인 유형
  static const Map<String, String> step5Codes = {
    'UNK': '잘 모르겠음',
    '1': '개인',
    '2': '개인사업자',
    '3': '법인사업자',
    '4': '외국인',
    '5': '대리인(가족)',
    '6': '대리인(전문가)',
    '7': '비영리단체',
    '8': '협동조합',
    '9': '소상공인',
    '10': '기타',
  };

  // Step 6 - Document Status/문서 준비 상태
  static const Map<String, String> step6Codes = {
    'UNK': '잘 모르겠음',
    '1': '서류완비',
    '2': '일부 준비됨',
    '3': '전혀 없음',
    '4': '보완요구 받음',
    '5': '재제출 필요',
    '6': '서류 검토 중',
    '7': '추가서류 필요',
    '8': '서류 분실',
    '9': '기타',
  };

  // Step 7 - Region/지역
  static const Map<String, String> step7Codes = {
    'UNK': '잘 모르겠음',
    '11': '서울특별시',
    '21': '부산광역시',
    '22': '대구광역시',
    '23': '인천광역시',
    '24': '광주광역시',
    '25': '대전광역시',
    '26': '울산광역시',
    '29': '세종특별자치시',
    '31': '경기도',
    '32': '강원도',
    '33': '충청북도',
    '34': '충청남도',
    '35': '전라북도',
    '36': '전라남도',
    '37': '경상북도',
    '38': '경상남도',
    '39': '제주특별자치도',
  };

  // Step 8 - Urgency/급박도
  static const Map<String, String> step8Codes = {
    'UNK': '잘 모르겠음',
    'day': '하루 이내',
    'week': '일주일 내',
    'month': '한 달 내',
    'slow': '천천히 준비',
  };

  // Step 9 - Consultation Method/상담 방식
  static const Map<String, String> step9Codes = {
    'UNK': '잘 모르겠음',
    'phone': '전화 상담',
    'email': '이메일 상담',
    'visit': '직접 방문',
    'online': '온라인 화상상담',
    'delegate': '위임 계약(대행)',
  };

  // Step 10 - Cost Perception/비용 인식
  static const Map<String, String> step10Codes = {
    'UNK': '잘 모르겠음',
    'free': '무료만 원함',
    'low': '저비용이면 OK',
    'fair': '합리적 유료 대행 희망',
    'urgent': '비용 불문, 신속·정확',
  };

  // Get label for any step
  static String getStepLabel(int stepNumber, String? code) {
    if (code == null || code.isEmpty) return '-';
    
    switch (stepNumber) {
      case 1:
        return step1Codes[code] ?? code;
      case 2:
        return step2Codes[code] ?? code;
      case 3:
        return step3Codes[code] ?? code;
      case 4:
        return step4Codes[code] ?? code;
      case 5:
        return step5Codes[code] ?? code;
      case 6:
        return step6Codes[code] ?? code;
      case 7:
        return step7Codes[code] ?? code;
      case 8:
        return step8Codes[code] ?? code;
      case 9:
        return step9Codes[code] ?? code;
      case 10:
        return step10Codes[code] ?? code;
      default:
        return code;
    }
  }

  static String getStepTitle(int stepNumber) {
    if (stepNumber > 0 && stepNumber <= stepTitles.length) {
      return stepTitles[stepNumber - 1];
    }
    return 'Step $stepNumber';
  }

  // Legacy methods for backward compatibility
  static String getPurposeLabel(String? code) => getStepLabel(1, code);
  static String getStatusLabel(String? code) => getStepLabel(3, code);
  static String getServiceTypeLabel(String? code) => getStepLabel(4, code);
}