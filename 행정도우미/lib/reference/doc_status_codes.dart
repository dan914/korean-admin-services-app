import '../types/codes.dart';

const List<CodeItem> docStatusCodes = [
  CodeItem(code: 'UNK', ko: '잘 모르겠음', en: 'Not sure'),
  
  CodeItem(code: '1', ko: '서류완비', en: 'Documents Complete', source: '민원처리법'),
  CodeItem(code: '2', ko: '일부 준비됨', en: 'Partially Prepared', source: '민원처리법'),
  CodeItem(code: '3', ko: '전혀 없음', en: 'Not Prepared', source: '민원처리법'),
  CodeItem(code: '4', ko: '보완요구 받음', en: 'Requested for Supplementation', source: '민원처리법'),
  CodeItem(code: '5', ko: '재제출 필요', en: 'Resubmission Required', source: '민원처리법'),
  CodeItem(code: '6', ko: '서류 검토 중', en: 'Under Document Review', source: '민원처리법'),
  CodeItem(code: '7', ko: '추가서류 필요', en: 'Additional Documents Needed', source: '민원처리법'),
  CodeItem(code: '8', ko: '서류 분실', en: 'Documents Lost', source: '민원처리법'),
  CodeItem(code: '9', ko: '기타', en: 'Other', source: '민원처리법'),
];