# 🚀 CI/CD 설정 가이드

이 문서는 행정도우미 Flutter 웹 앱의 자동 빌드 및 배포 설정 방법을 설명합니다.

## 📋 목차
1. [GitHub Actions 설정](#github-actions-설정)
2. [배포 플랫폼 선택](#배포-플랫폼-선택)
3. [환경 변수 설정](#환경-변수-설정)
4. [테스트 및 확인](#테스트-및-확인)

---

## 🔧 GitHub Actions 설정

### 1단계: GitHub 저장소 생성

```bash
# 로컬 프로젝트를 GitHub에 연결
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/admin-helper.git
git push -u origin main
```

### 2단계: GitHub Secrets 설정

GitHub 저장소 → Settings → Secrets and variables → Actions 에서 추가:

#### 필수 Secrets:
- `SUPABASE_URL`: https://xgmswifetbmttyrtzjpv.supabase.co
- `SUPABASE_ANON_KEY`: eyJhbGc... (your key)

#### 선택적 Secrets (배포 플랫폼별):
- `FIREBASE_SERVICE_ACCOUNT`: Firebase 서비스 계정 JSON
- `FIREBASE_PROJECT_ID`: Firebase 프로젝트 ID
- `VERCEL_TOKEN`: Vercel 인증 토큰
- `VERCEL_ORG_ID`: Vercel 조직 ID
- `VERCEL_PROJECT_ID`: Vercel 프로젝트 ID

---

## 🌐 배포 플랫폼 선택

### 옵션 1: GitHub Pages (무료, 가장 쉬움) ✅

**장점:**
- 완전 무료
- 설정 가장 간단
- GitHub와 완벽 통합

**설정 방법:**
1. GitHub 저장소 → Settings → Pages
2. Source: "GitHub Actions" 선택
3. 커밋 푸시하면 자동 배포

**접속 URL:** `https://YOUR_USERNAME.github.io/admin-helper/`

### 옵션 2: Vercel (무료, 빠른 성능)

**장점:**
- 매우 빠른 로딩 속도
- 자동 HTTPS
- 프리뷰 배포 지원

**설정 방법:**
1. [Vercel](https://vercel.com) 계정 생성
2. GitHub 저장소 연결
3. 빌드 설정:
   - Framework: Other
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`

### 옵션 3: Netlify (무료, 사용 편리)

**장점:**
- 드래그 앤 드롭 배포
- 폼 처리 기능
- 자동 HTTPS

**설정 방법:**
1. [Netlify](https://netlify.com) 계정 생성
2. GitHub 저장소 연결
3. `netlify.toml` 파일 이미 설정됨

### 옵션 4: Firebase Hosting (Google 제품)

**장점:**
- Google 인프라
- 다른 Firebase 서비스와 통합
- 커스텀 도메인 쉽게 연결

**설정 방법:**
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 프로젝트 초기화
firebase login
firebase init hosting

# 수동 배포 테스트
flutter build web --release
firebase deploy --only hosting
```

---

## 🔐 환경 변수 설정

### 개발 환경 (.env 파일)
```env
SUPABASE_URL=https://xgmswifetbmttyrtzjpv.supabase.co
SUPABASE_ANON_KEY=your_key_here
```

### CI/CD 환경 (GitHub Secrets)
1. 저장소 Settings → Secrets → New repository secret
2. 다음 값들 추가:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

---

## ✅ 테스트 및 확인

### 1. 로컬 빌드 테스트
```bash
# 웹 빌드 테스트
flutter build web --release

# 로컬 서버로 테스트
cd build/web
python3 -m http.server 8000
# 브라우저에서 http://localhost:8000 접속
```

### 2. GitHub Actions 확인
1. 코드 푸시: `git push origin main`
2. GitHub 저장소 → Actions 탭
3. 워크플로우 실행 상태 확인
4. 녹색 체크 표시 = 성공!

### 3. 배포 확인
- **GitHub Pages**: `https://YOUR_USERNAME.github.io/admin-helper/`
- **Vercel**: Vercel 대시보드에서 URL 확인
- **Netlify**: Netlify 대시보드에서 URL 확인
- **Firebase**: `https://YOUR_PROJECT.web.app`

---

## 🐛 문제 해결

### Build 실패 시
```yaml
# .github/workflows/flutter-web.yml 에서 테스트 단계 주석 처리
# - name: 🧪 Run tests
#   run: flutter test
```

### 배포 실패 시
1. GitHub Secrets 확인
2. 배포 플랫폼 인증 토큰 확인
3. Actions 로그에서 에러 메시지 확인

### Flutter 버전 문제
```yaml
# .github/workflows/flutter-web.yml 에서 버전 변경
env:
  FLUTTER_VERSION: '3.16.0'  # 또는 최신 안정 버전
```

---

## 📚 추가 리소스

- [GitHub Actions 문서](https://docs.github.com/actions)
- [Flutter 웹 배포 가이드](https://docs.flutter.dev/deployment/web)
- [Vercel 문서](https://vercel.com/docs)
- [Netlify 문서](https://docs.netlify.com)
- [Firebase Hosting 문서](https://firebase.google.com/docs/hosting)

---

## 🎯 다음 단계

1. ✅ GitHub에 코드 푸시
2. ✅ GitHub Actions 실행 확인
3. ✅ 배포된 사이트 접속 테스트
4. ⬜ 커스텀 도메인 연결 (선택)
5. ⬜ 모니터링 설정 (선택)

질문이 있으시면 이슈를 생성해주세요!