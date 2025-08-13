import '../types/codes.dart';

const List<CodeItem> bizTypeCodes = [
  CodeItem(code: 'UNK', ko: '잘 모르겠음', en: 'Not sure'),
  
  CodeItem(code: '01', ko: '개인사업자', en: 'Sole Proprietor', source: '국세청'),
  CodeItem(code: '81', ko: '일반법인', en: 'General Corporation', source: '국세청'),
  CodeItem(code: '82', ko: '비영리법인', en: 'Non-profit Corp', source: '국세청'),
  CodeItem(code: '86', ko: '국가기관', en: 'Government Agency', source: '국세청'),
  
  // TODO: Add more detailed business type codes from National Tax Service
  // 02 (개인사업자-간이과세), 03 (개인사업자-면세), 11 (법인사업자-일반),
  // 12 (법인사업자-간이), 13 (법인사업자-면세), 21 (단체), 22 (조합),
  // 23 (재단법인), 24 (사단법인), 25 (종교단체) 등
];