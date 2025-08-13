# KakaoTalk AlimTalk (알림톡) Setup Guide

## Overview
This guide explains how to set up KakaoTalk business notifications for your admin services app.

## Prerequisites

### 1. Business Registration
- Korean business registration number (사업자등록번호)
- Business bank account for verification

### 2. Kakao Business Channel
1. Go to [Kakao Business](https://business.kakao.com)
2. Create a business account
3. Create a Kakao Channel for your business
4. Verify your business information

## AlimTalk Service Providers

Choose one of these providers (Solapi is recommended):

### Option 1: Solapi (Recommended)
- Website: https://solapi.com
- Pricing: ~15 KRW per message
- Good documentation and support
- Easy API integration

### Option 2: NHN Toast
- Website: https://www.toast.com
- Pricing: ~15-20 KRW per message
- Enterprise-focused
- More complex setup

### Option 3: Kakao Business Direct
- Direct integration with Kakao
- More complex approval process
- Lower cost but harder to implement

## Setup Steps

### Step 1: Register with Solapi
1. Sign up at https://solapi.com
2. Complete business verification
3. Add funds to your account (minimum 10,000 KRW)

### Step 2: Connect Kakao Channel
1. In Solapi dashboard, go to "카카오 비즈니스"
2. Click "채널 연동" (Connect Channel)
3. Login with your Kakao Business account
4. Authorize Solapi to send messages

### Step 3: Create AlimTalk Templates
Templates must be pre-approved by Kakao (takes 1-2 business days)

1. In Solapi, go to "알림톡 템플릿"
2. Create these templates:

#### Template 1: Application Received
```
[행정도우미] 신청 접수 완료

안녕하세요 #{이름}님,
신청이 정상적으로 접수되었습니다.

접수번호: #{접수번호}
접수일시: #{접수일시}
처리상태: 검토중

문의: #{전화번호}
```

#### Template 2: Status Changed
```
[행정도우미] 처리 상태 변경

#{이름}님의 신청 상태가 변경되었습니다.

접수번호: #{접수번호}
변경상태: #{상태}
변경일시: #{변경일시}

자세한 내용은 홈페이지에서 확인하세요.
```

#### Template 3: Consultation Reminder
```
[행정도우미] 상담 예약 알림

#{이름}님, 
예약하신 상담 일정을 안내드립니다.

상담일시: #{상담일시}
상담방법: #{상담방법}
담당자: #{담당자}

변경이 필요하신 경우 연락주세요.
문의: #{전화번호}
```

### Step 4: Get API Credentials
1. In Solapi dashboard, go to "API 키 관리"
2. Create new API key
3. Copy the API Key and API Secret

### Step 5: Configure the App

Update `/admin_app/lib/services/kakao_notification_service.dart`:

```dart
static const String apiKey = 'YOUR_SOLAPI_API_KEY';
static const String apiSecret = 'YOUR_SOLAPI_API_SECRET';
static const String pfId = 'YOUR_KAKAO_PROFILE_ID';
static const String senderId = '01012345678'; // Your business phone
```

### Step 6: Test Notifications

Run test from admin panel:
1. Select an application
2. Click "Send Test Notification"
3. Check if message is received

## Important Notes

### Template Approval
- Templates must be approved by Kakao
- Approval takes 1-2 business days
- Templates cannot contain marketing content
- Only transactional messages allowed

### Message Limitations
- Maximum 1000 characters
- No images in AlimTalk (use FriendTalk for images)
- Must include opt-out information
- Cannot send between 8 PM - 8 AM without prior consent

### Costs
- AlimTalk: ~15 KRW per message
- FriendTalk: ~20-30 KRW per message
- SMS fallback: ~20 KRW per message

### Legal Requirements
- Must have user consent for notifications
- Must provide opt-out option
- Must follow KISA spam regulations
- Keep notification logs for 6 months

## Testing Checklist

- [ ] Business channel created and verified
- [ ] Solapi account funded
- [ ] Templates submitted for approval
- [ ] Templates approved by Kakao
- [ ] API credentials configured
- [ ] Test message sent successfully
- [ ] Notification preferences working
- [ ] Error handling implemented

## Support

- Solapi Support: support@solapi.com
- Kakao Business: 1644-4755
- Documentation: https://docs.solapi.com

## Alternative: Simple SMS

If KakaoTalk setup is too complex, you can use simple SMS:

```dart
// Use Solapi for SMS too
static Future<bool> sendSMS(String phone, String message) async {
  // Same API, just change type from 'ATA' to 'SMS'
  // SMS doesn't need template approval
}
```

SMS is simpler but:
- More expensive (~20 KRW)
- Lower open rates
- No rich formatting