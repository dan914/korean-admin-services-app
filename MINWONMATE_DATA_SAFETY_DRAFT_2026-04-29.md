# 민원메이트 Google Play Data Safety 입력 초안

작성일: 2026-04-29

이 문서는 Play Console의 Data safety 입력을 준비하기 위한 개발팀 초안이다. 최종 제출 전 실제 운영 방식, 개인정보 처리방침 공개 URL, Play Console 화면의 최신 문구와 다시 대조해야 한다.

## 기준

- 앱명: 민원메이트
- 패키지명: `com.koreanadmin.helper`
- 준비 버전: `1.0.6+14`
- 공식 확인 기준:
  - Google Play Target API level requirements: https://support.google.com/googleplay/android-developer/answer/11926878
  - Google Play Data safety guide: https://support.google.com/googleplay/android-developer/answer/10787469
  - Google Play User Data policy: https://support.google.com/googleplay/android-developer/answer/10144311

## 데이터 수집 여부

- 앱이 사용자 데이터를 수집함: 예
- 데이터가 전송 중 암호화됨: 예, HTTPS/Supabase TLS 사용
- 사용자가 데이터 삭제를 요청할 수 있음: 예, 개인정보 문의 이메일 `chan128do@gmail.com`
- 데이터가 제3자와 공유됨: 원칙적으로 아니오
- 광고 목적 사용: 아니오
- 앱 내 계정 생성: 아니오

## 수집 데이터 유형

| Play 분류 | 세부 항목 | 앱 내 실제 항목 | 목적 | 필수 여부 |
| --- | --- | --- | --- | --- |
| Personal info | Name | 이름 | 상담 접수자 식별 | 필수 |
| Personal info | Email address | 이메일 | 이메일 연락 희망 시 연락 | 선택 |
| Personal info | Phone number | 휴대전화번호 | 상담 연락, 상태조회 본인 확인 | 필수 |
| Location | Approximate location | 사용자가 선택한 지역 | 사안 지역 분류 | 접수 답변 |
| User-generated content | Other user-generated content | 행정상황 답변, 자유 메모, 첨부파일 | 상담 전 사실관계 확인 | 접수 답변/선택 |
| App activity | Other user activity | 접수 상태, 접수번호, 상태 변경 이력 | 접수 운영, 상태조회 | 자동 생성 |
| App info and performance | Diagnostics 또는 기타 로그 | 보안/오류 로그 | 보안, 안정성 유지 | 자동 생성 가능 |

## 수집 목적 선택 후보

- App functionality: 상담 접수, 첨부파일 업로드, 상태조회, 관리자 처리
- Developer communications: 담당자의 연락 방식 확인 및 상담 안내
- Fraud prevention, security, and compliance: RLS, 보안 로그, 부정 이용 방지
- Account management: 해당 없음
- Advertising or marketing: 선택하지 않음
- Analytics: 현재 명시적 분석 SDK 없음

## 공유 여부 판단

Play Data safety에서 "공유"는 제3자에게 사용자 데이터를 전송하는 경우를 의미한다. 현재 앱은 사용자 데이터를 광고 네트워크나 외부 마케팅 업체에 제공하지 않는다. Supabase는 서비스 제공을 위한 클라우드 처리자/인프라로 사용한다.

최종 입력 권장:

- 사용자 데이터를 제3자와 공유함: 아니오
- 단, 개인정보처리방침에는 Supabase 등 처리 위탁/국외 처리 가능성을 명시

## 개인정보 처리방침 반영 상태

로컬 파일:

- `행정도우미/privacy_policy.html`
- `행정도우미/web/privacy_policy.html`

반영된 항목:

- 앱명과 문의 이메일
- 수집 항목: 이름, 휴대전화번호, 이메일, 행정상황 답변, 상담 희망 시간, 첨부파일, 접수번호, 보안 로그
- 이용 목적
- 보관/삭제 정책
- Supabase 처리 위탁
- 첨부파일 비공개 저장소와 관리자 접근 제한

남은 제출 전 필수 작업:

- Play Console에 입력할 공개 URL로 `privacy_policy.html`을 배포
- URL이 로그인 없이 접근 가능하고 PDF가 아니며 지역 차단이 없는지 확인
- Netlify 배포가 연결된 경우 `https://<site>.netlify.app/privacy_policy.html` 경로를 우선 확인

## 권한 신고

현재 release manifest의 직접 권한:

- `android.permission.INTERNET`

별도 민감 권한 사용 없음:

- 위치 권한 없음
- 카메라 권한 없음
- 연락처 권한 없음
- SMS 읽기/발송 권한 없음
- 외부 저장소 전체 접근 권한 없음

파일 선택은 Android 시스템 파일 선택기를 통해 사용자가 직접 선택한 파일만 처리한다.

## 최종 제출 전 확인

1. Data safety의 수집 항목과 개인정보처리방침 항목이 일치하는지 확인한다.
2. 앱 내 연락 방식 문구가 자동 알림 발송처럼 보이지 않는지 확인한다.
3. 첨부파일이 실제 업로드된다는 문구와 Storage 동작이 일치하는지 확인한다.
4. 공개 개인정보처리방침 URL을 Play Console과 앱 설명/지원 정보에 반영한다.
