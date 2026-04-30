# 민원메이트 Play 재제출 준비 현황

작성일: 2026-04-29
목표 제출일: 2026-04-30

## 제출 전략

2026-04-30 제출 목표에서는 신규 기능 확장보다 심사 차단 요소 제거가 우선이다. 현재 준비 방향은 다음과 같다.

1. 앱 기능과 앱 문구의 불일치 제거
2. 개인정보 처리방침과 Data safety 신고 항목 일치
3. target API, 권한, 버전코드, 서명 상태 확인
4. 내부 테스트 트랙에서 실제 설치/접수/관리자 확인

## 현재 준비 상태

| 항목 | 상태 | 메모 |
| --- | --- | --- |
| 패키지명 | 완료 | `com.koreanadmin.helper` 유지 |
| 앱명 | 완료 | release manifest `민원메이트` |
| targetSdk | 완료 | Flutter Gradle 기본값 35 확인 |
| compileSdk | 완료 | Flutter Gradle 기본값 35 확인 |
| 권한 | 완료 | release manifest 직접 권한은 `INTERNET`만 확인 |
| 버전 | 완료 | `1.0.6+14`로 증가 |
| 업로드 키 | 대기 | 새 upload key는 2026-04-30 18:29 KST 이후 유효 |
| 고객 접수 | 완료 | Supabase RPC 접수, 접수번호 반환 |
| 상태조회 | 완료 | 접수번호 + 휴대폰 뒤 4자리 |
| 첨부파일 | 완료 | private Storage 실제 업로드 |
| 관리자 앱 | 완료 | 로그인, 목록, 상태 변경, 담당자, 메모, 이력, 첨부파일 열기 |
| 자동 알림 | 보류 | 제출 전에는 자동 발송처럼 보이지 않도록 문구 정리 |
| 개인정보 처리방침 | 준비 완료 | `행정도우미/privacy_policy.html`, `행정도우미/web/privacy_policy.html` 갱신 |
| 개인정보 처리방침 공개 URL | 확인 필요 | Netlify 배포가 연결되어 있으면 `https://<site>.netlify.app/privacy_policy.html` 확인 |
| Data safety 초안 | 준비 완료 | `MINWONMATE_DATA_SAFETY_DRAFT_2026-04-29.md` |

## 이번 정리에서 수정한 불일치

- 고객 앱 `알림 수신 동의`를 `희망 연락 방식`으로 변경했다.
- 카카오톡/SMS/이메일 문구를 자동 발송이 아니라 담당자 연락 방식 참고 문구로 변경했다.
- 성공 화면의 `현재는 파일명과 크기만 기록됨` 문구를 실제 업로드 동작에 맞게 변경했다.
- 관리자 앱의 `이메일 전송` 버튼을 실제 발송 버튼처럼 보이지 않도록 연락처 복사 동작으로 변경했다.
- 개인정보 동의 항목에 실제 첨부 문서 수집을 반영했다.
- 앱 내 개인정보처리방침 보기 다이얼로그를 추가했다.
- 관리자 웹 시작 중 Supabase 초기화가 지연/실패해도 흰 화면으로 멈추지 않도록 로딩/오류/재시도 화면을 추가했다.
- 관리자 웹 정적 빌드는 PWA 캐시 없이 local CanvasKit을 사용하도록 부트스트랩을 고정했다.

## 검증 결과

| 검증 항목 | 결과 | 메모 |
| --- | --- | --- |
| 고객 앱 `flutter test` | 통과 | 9 tests passed |
| 고객 앱 `flutter analyze --no-fatal-warnings --no-fatal-infos` | 통과 | 기존 warning/info 96건 |
| 관리자 앱 `flutter test` | 통과 | Admin smoke test 통과 |
| 관리자 앱 `flutter analyze --no-fatal-warnings --no-fatal-infos` | 통과 | 기존 info 48건 |
| 관리자 웹 `flutter build web --release --pwa-strategy=none --no-web-resources-cdn` | 통과 | `admin_app/build/web` 생성 |
| Supabase RLS 회귀 테스트 | 통과 | anon 직접 접근 차단, 공개 RPC만 허용 |

참고: 현재 Codex DevTools의 Headless Chrome에서는 CanvasKit WebGL 소프트웨어 fallback 제한 때문에 관리자 웹 화면 캡처가 빈 화면으로 보일 수 있다. 네트워크 로드는 성공했고, 실제 제출 전에는 일반 Chrome/Edge에서 관리자 로그인 화면과 신청서 상세를 별도로 확인해야 한다.

## 제출 전 남은 필수 작업

1. `privacy_policy.html`을 공개 URL로 배포한다.
   - 로그인 없이 접근 가능해야 한다.
   - PDF가 아니어야 한다.
   - 지역 차단이 없어야 한다.
   - Netlify에 연결된 사이트가 있으면 루트 경로 `/privacy_policy.html`로 접근되는지 확인한다.
2. Play Console App content에서 Data safety를 입력한다.
3. Play Console 개인정보 처리방침 URL에 공개 URL을 입력한다.
4. 2026-04-30 18:29 KST 이후 최종 AAB를 생성한다.
5. 내부 테스트 트랙에 업로드하고 실제 기기에서 다음을 확인한다.
   - 앱 설치
   - 신규 접수
   - 파일 업로드
   - 접수번호 표시
   - 상태조회
   - 관리자 로그인
   - 관리자 상세에서 첨부파일 열기
   - 상태 변경

## 공식 기준 참고

- Target API level requirements: https://support.google.com/googleplay/android-developer/answer/11926878
- Data safety section: https://support.google.com/googleplay/android-developer/answer/10787469
- User Data policy and privacy policy requirements: https://support.google.com/googleplay/android-developer/answer/10144311
- Play App Signing and upload key reset: https://support.google.com/googleplay/android-developer/answer/9842756
