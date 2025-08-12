import '../types/codes.dart';

// 샘플 + TODO 주석
const List<CodeItem> visaCodes = [
  CodeItem(code: 'UNK', ko: '잘 모르겠음', en: 'Not sure'),
  
  CodeItem(code: 'A-1', ko: '외교', en: 'Diplomat', source: '출입국관리법'),
  CodeItem(code: 'F-4', ko: '재외동포', en: 'Overseas Korean', source: '출입국관리법'),
  CodeItem(code: 'H-2', ko: '방문취업', en: 'Work Visit', source: '출입국관리법'),
  
  // TODO: append all remaining 30+ codes from official table
  // A-2 (공무), A-3 (협정), B-1 (사증면제), B-2 (관광통과), C-1 (일시취재), 
  // C-2 (단기상용), C-3 (단기일반), C-4 (단기취업), D-1 (문화예술), D-2 (유학),
  // D-3 (기술연수), D-4 (일반연수), D-5 (취재), D-6 (종교), D-7 (주재), 
  // D-8 (기업투자), D-9 (무역경영), E-1 (교수), E-2 (회화지도), E-3 (연구),
  // E-4 (기술지도), E-5 (전문직업), E-6 (예술흥행), E-7 (특정활동), 
  // E-8 (비전문취업), E-9 (비전문취업), E-10 (선원취업), F-1 (방문동거),
  // F-2 (거주), F-3 (동반), F-5 (영주), F-6 (결혼이민), G-1 (기타)
];