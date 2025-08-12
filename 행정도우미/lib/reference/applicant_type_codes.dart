import '../types/codes.dart';

const List<CodeItem> applicantTypeCodes = [
  CodeItem(code: 'UNK', ko: '잘 모르겠음', en: 'Not sure'),
  
  CodeItem(code: '1', ko: '개인', en: 'Individual', source: '민원처리법'),
  CodeItem(code: '2', ko: '개인사업자', en: 'Sole Proprietor', source: '사업자등록법'),
  CodeItem(code: '3', ko: '법인사업자', en: 'Corporate Business', source: '사업자등록법'),
  CodeItem(code: '4', ko: '외국인', en: 'Foreigner', source: '출입국관리법'),
  CodeItem(code: '5', ko: '대리인(가족)', en: 'Agent (Family)', source: '민원처리법'),
  CodeItem(code: '6', ko: '대리인(전문가)', en: 'Agent (Professional)', source: '민원처리법'),
  CodeItem(code: '7', ko: '비영리단체', en: 'Non-profit Organization', source: '민원처리법'),
  CodeItem(code: '8', ko: '협동조합', en: 'Cooperative', source: '협동조합기본법'),
  CodeItem(code: '9', ko: '소상공인', en: 'Small Merchant', source: '소상공인 보호 및 지원에 관한 법률'),
  CodeItem(code: '10', ko: '기타', en: 'Other', source: '민원처리법'),
];