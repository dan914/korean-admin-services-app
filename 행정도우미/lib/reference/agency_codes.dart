import '../types/codes.dart';

// 항상 첫 줄 = 잘 모르겠음
const List<CodeItem> agencyCodes = [
  CodeItem(code: 'UNK', ko: '잘 모르겠음', en: 'Not sure'),

  CodeItem(code: '1010000', ko: '기획재정부', en: 'Ministry of Economy and Finance', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1020000', ko: '교육부', en: 'Ministry of Education', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1030000', ko: '과학기술정보통신부', en: 'Ministry of Science and ICT', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1040000', ko: '외교부', en: 'Ministry of Foreign Affairs', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1050000', ko: '통일부', en: 'Ministry of Unification', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1060000', ko: '법무부', en: 'Ministry of Justice', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1070000', ko: '국방부', en: 'Ministry of National Defense', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1080000', ko: '행정안전부', en: 'Ministry of the Interior and Safety', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1090000', ko: '문화체육관광부', en: 'Ministry of Culture, Sports and Tourism', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1100000', ko: '농림축산식품부', en: 'Ministry of Agriculture, Food and Rural Affairs', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1110000', ko: '산업통상자원부', en: 'Ministry of Trade, Industry and Energy', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1120000', ko: '보건복지부', en: 'Ministry of Health and Welfare', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1130000', ko: '환경부', en: 'Ministry of Environment', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1140000', ko: '고용노동부', en: 'Ministry of Employment and Labor', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1150000', ko: '여성가족부', en: 'Ministry of Gender Equality and Family', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1160000', ko: '국토교통부', en: 'Ministry of Land, Infrastructure and Transport', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1170000', ko: '해양수산부', en: 'Ministry of Oceans and Fisheries', source: 'code.go.kr', note: '중앙부처'),
  CodeItem(code: '1180000', ko: '중소벤처기업부', en: 'Ministry of SMEs and Startups', source: 'code.go.kr', note: '중앙부처'),
  
  // 광역시/도청
  CodeItem(code: '2010000', ko: '서울특별시청', en: 'Seoul Metropolitan Government', source: 'code.go.kr', note: '지자체'),
  CodeItem(code: '2020000', ko: '부산광역시청', en: 'Busan Metropolitan City', source: 'code.go.kr', note: '지자체'),
  CodeItem(code: '2030000', ko: '대구광역시청', en: 'Daegu Metropolitan City', source: 'code.go.kr', note: '지자체'),
  CodeItem(code: '2040000', ko: '인천광역시청', en: 'Incheon Metropolitan City', source: 'code.go.kr', note: '지자체'),
  CodeItem(code: '2050000', ko: '광주광역시청', en: 'Gwangju Metropolitan City', source: 'code.go.kr', note: '지자체'),
  CodeItem(code: '2060000', ko: '대전광역시청', en: 'Daejeon Metropolitan City', source: 'code.go.kr', note: '지자체'),
  CodeItem(code: '2070000', ko: '울산광역시청', en: 'Ulsan Metropolitan City', source: 'code.go.kr', note: '지자체'),
  CodeItem(code: '2080000', ko: '경기도청', en: 'Gyeonggi Provincial Government', source: 'code.go.kr', note: '지자체'),
  CodeItem(code: '2090000', ko: '강원도청', en: 'Gangwon Provincial Government', source: 'code.go.kr', note: '지자체'),
  CodeItem(code: '2100000', ko: '충청북도청', en: 'Chungcheongbuk-do Provincial Government', source: 'code.go.kr', note: '지자체'),
  
  // 공공기관
  CodeItem(code: '3010000', ko: '한국토지주택공사(LH)', en: 'Korea Land & Housing Corporation', source: 'code.go.kr', note: '공공기관'),
  CodeItem(code: '3020000', ko: '한국전력공사', en: 'Korea Electric Power Corporation', source: 'code.go.kr', note: '공공기관'),
  CodeItem(code: '3030000', ko: '국민건강보험공단', en: 'National Health Insurance Service', source: 'code.go.kr', note: '공공기관'),
  CodeItem(code: '3040000', ko: '국민연금공단', en: 'National Pension Service', source: 'code.go.kr', note: '공공기관'),
  CodeItem(code: '3050000', ko: '건강보험심사평가원', en: 'Health Insurance Review & Assessment Service', source: 'code.go.kr', note: '공공기관'),
  CodeItem(code: '3060000', ko: '근로복지공단', en: 'Korea Workers\' Compensation & Welfare Service', source: 'code.go.kr', note: '공공기관'),
  
  CodeItem(code: '4010000', ko: '기타 국가기관', en: 'Other National Agency', source: 'code.go.kr', note: '기타·위원회'),
];