import '../types/codes.dart';

const List<CodeItem> regionCodes = [
  CodeItem(code: 'UNK', ko: '잘 모르겠음', en: 'Not sure'),
  
  CodeItem(code: '11', ko: '서울특별시', en: 'Seoul Metropolitan City', source: '행정표준코드', note: '광역'),
  CodeItem(code: '21', ko: '부산광역시', en: 'Busan Metropolitan City', source: '행정표준코드', note: '광역'),
  CodeItem(code: '22', ko: '대구광역시', en: 'Daegu Metropolitan City', source: '행정표준코드', note: '광역'),
  CodeItem(code: '23', ko: '인천광역시', en: 'Incheon Metropolitan City', source: '행정표준코드', note: '광역'),
  CodeItem(code: '24', ko: '광주광역시', en: 'Gwangju Metropolitan City', source: '행정표준코드', note: '광역'),
  CodeItem(code: '25', ko: '대전광역시', en: 'Daejeon Metropolitan City', source: '행정표준코드', note: '광역'),
  CodeItem(code: '26', ko: '울산광역시', en: 'Ulsan Metropolitan City', source: '행정표준코드', note: '광역'),
  CodeItem(code: '29', ko: '세종특별자치시', en: 'Sejong Special Self-Governing City', source: '행정표준코드', note: '광역'),
  
  CodeItem(code: '31', ko: '경기도', en: 'Gyeonggi Province', source: '행정표준코드', note: '도'),
  CodeItem(code: '32', ko: '강원도', en: 'Gangwon Province', source: '행정표준코드', note: '도'),
  CodeItem(code: '33', ko: '충청북도', en: 'Chungcheongbuk-do', source: '행정표준코드', note: '도'),
  CodeItem(code: '34', ko: '충청남도', en: 'Chungcheongnam-do', source: '행정표준코드', note: '도'),
  CodeItem(code: '35', ko: '전라북도', en: 'Jeollabuk-do', source: '행정표준코드', note: '도'),
  CodeItem(code: '36', ko: '전라남도', en: 'Jeollanam-do', source: '행정표준코드', note: '도'),
  CodeItem(code: '37', ko: '경상북도', en: 'Gyeongsangbuk-do', source: '행정표준코드', note: '도'),
  CodeItem(code: '38', ko: '경상남도', en: 'Gyeongsangnam-do', source: '행정표준코드', note: '도'),
  CodeItem(code: '39', ko: '제주특별자치도', en: 'Jeju Special Self-Governing Province', source: '행정표준코드', note: '특별자치도'),
  
  CodeItem(code: '99', ko: '기타/해외', en: 'Other/Overseas', source: '행정표준코드', note: '기타'),
];