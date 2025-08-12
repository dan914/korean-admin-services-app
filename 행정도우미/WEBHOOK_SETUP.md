# 웹훅(Webhook) 설정 가이드

이 가이드는 행정도우미 앱에서 새 상담 요청시 알림을 받기 위한 웹훅 설정 방법을 설명합니다.

## 🔔 지원되는 알림 방식

### 1. 이메일 알림 (EmailJS)

EmailJS를 사용하여 이메일 알림을 받을 수 있습니다.

#### 설정 방법:
1. [EmailJS](https://www.emailjs.com/) 계정 생성
2. 새 서비스 추가 (Gmail, Outlook 등)
3. 이메일 템플릿 생성
4. `lib/services/webhook_service.dart`에서 다음 값들을 업데이트:
   ```dart
   static const String _emailjsServiceId = 'YOUR_ACTUAL_SERVICE_ID';
   static const String _emailjsTemplateId = 'YOUR_ACTUAL_TEMPLATE_ID';
   static const String _emailjsPublicKey = 'YOUR_ACTUAL_PUBLIC_KEY';
   ```

#### 이메일 템플릿 예시:
```html
제목: 새로운 행정 상담 요청 - {{lead_name}}

안녕하세요,

새로운 상담 요청이 접수되었습니다.

고객 정보:
- 이름: {{lead_name}}
- 연락처: {{lead_phone}}
- 이메일: {{lead_email}}
- 문제 유형: {{issue_type}}
- 관련 기관: {{agency_code}}
- 접수 시간: {{submission_time}}

관리자 대시보드에서 자세한 내용을 확인하세요:
{{admin_url}}

감사합니다.
```

### 2. Slack 알림

Slack 채널로 알림을 받을 수 있습니다.

#### 설정 방법:
1. Slack 워크스페이스에서 새 앱 생성
2. Incoming Webhooks 활성화
3. 웹훅 URL 복사
4. `contact_screen.dart`에서 Slack 웹훅 코드 주석 해제:
   ```dart
   const slackWebhookUrl = 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK';
   await WebhookService.sendWebhookNotification(
     webhookUrl: slackWebhookUrl,
     lead: lead,
     format: 'slack',
   );
   ```

### 3. Discord 알림

Discord 채널로 알림을 받을 수 있습니다.

#### 설정 방법:
1. Discord 서버의 채널 설정에서 웹훅 생성
2. 웹훅 URL 복사
3. `contact_screen.dart`에서 Discord 웹훅 코드 주석 해제:
   ```dart
   const discordWebhookUrl = 'https://discord.com/api/webhooks/YOUR/WEBHOOK';
   await WebhookService.sendWebhookNotification(
     webhookUrl: discordWebhookUrl,
     lead: lead,
     format: 'discord',
   );
   ```

### 4. 범용 웹훅

Zapier, n8n, Make 등의 자동화 도구나 커스텀 서버로 데이터를 전송할 수 있습니다.

#### 전송되는 데이터 형식:
```json
{
  "event": "new_lead",
  "data": {
    "name": "홍길동",
    "phone": "+82-10-1234-5678",
    "email": "test@example.com",
    "issue_type": "영업정지·과태료·허가취소",
    "agency_code": "1010000",
    "answers": { ... },
    "submitted_at": "2024-01-01T10:00:00Z",
    "priority": "medium",
    "status": "new"
  }
}
```

## 🧪 웹훅 테스트

### webhook.site 사용
1. [webhook.site](https://webhook.site) 방문
2. 고유 URL 복사
3. `contact_screen.dart`의 `testWebhookUrl` 변수에 URL 설정
4. 테스트 웹훅 코드 주석 해제
5. 앱에서 폼 제출 후 webhook.site에서 데이터 확인

### 로컬 테스트 서버
```bash
# ngrok을 사용한 로컬 테스트
npm install -g ngrok
ngrok http 3000

# 간단한 테스트 서버 (Node.js)
const express = require('express');
const app = express();
app.use(express.json());

app.post('/webhook', (req, res) => {
  console.log('Received webhook:', JSON.stringify(req.body, null, 2));
  res.json({ status: 'ok' });
});

app.listen(3000, () => console.log('Webhook test server on port 3000'));
```

## 🛠 개발자 가이드

### 새로운 웹훅 유형 추가

1. `WebhookService`에 새 형식 추가:
   ```dart
   static Map<String, dynamic> _buildCustomPayload(Lead lead) {
     // 커스텀 데이터 형식 구현
   }
   ```

2. `sendWebhookNotification` 메서드에 새 형식 추가:
   ```dart
   case 'custom':
     payload = _buildCustomPayload(lead);
     break;
   ```

### 에러 처리
웹훅 전송 실패는 전체 폼 제출을 실패시키지 않습니다. 에러는 로그에 기록되며, 사용자에게는 성공 화면이 표시됩니다.

## 📋 체크리스트

- [ ] EmailJS 설정 (이메일 알림용)
- [ ] Slack 웹훅 URL 설정 (Slack 알림용)
- [ ] Discord 웹훅 URL 설정 (Discord 알림용)
- [ ] 테스트 웹훅으로 데이터 형식 확인
- [ ] 프로덕션 환경에서 웹훅 테스트
- [ ] 에러 로깅 및 모니터링 설정

## 🔐 보안 주의사항

1. **웹훅 URL 보호**: 웹훅 URL을 공개 저장소에 커밋하지 마세요
2. **환경 변수 사용**: 프로덕션에서는 환경 변수로 웹훅 URL 관리
3. **HTTPS 필수**: 모든 웹훅 엔드포인트는 HTTPS 사용
4. **데이터 검증**: 수신 서버에서 데이터 유효성 검사 구현

## 🆘 트러블슈팅

### 웹훅이 전송되지 않는 경우
1. 콘솔에서 에러 로그 확인
2. 웹훅 URL이 올바른지 확인
3. 대상 서버가 POST 요청을 받을 수 있는지 확인
4. CORS 설정 확인 (웹 앱의 경우)

### EmailJS가 작동하지 않는 경우
1. Service ID, Template ID, Public Key 확인
2. EmailJS 콘솔에서 사용량 한도 확인
3. 이메일 템플릿의 변수명 확인

더 자세한 도움이 필요하면 개발팀에 문의하세요.