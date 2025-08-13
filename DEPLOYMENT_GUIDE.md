# 🚀 Production Deployment Guide

## Prerequisites

### 1. Environment Setup
- Flutter SDK 3.0+ installed
- Dart SDK 2.19+ installed
- Supabase account with project created
- Domain name for production deployment
- SSL certificate (Let's Encrypt recommended)

### 2. Required Environment Variables
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key  # Admin app only
ADMIN_PASSWORD=secure-admin-password
ENABLE_LOGGING=false  # Set to true only for debugging
```

## 📦 Build Process

### 1. Install Dependencies
```bash
# Main app
cd 행정도우미
flutter pub get

# Admin app
cd ../admin_app
flutter pub get
```

### 2. Run Tests
```bash
# Main app
cd 행정도우미
flutter test
flutter analyze

# Admin app
cd ../admin_app
flutter test
flutter analyze
```

### 3. Build for Production

#### Web Deployment
```bash
# Main app (행정도우미)
cd 행정도우미
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ADMIN_PASSWORD=$ADMIN_PASSWORD \
  --dart-define=ENABLE_LOGGING=false

# Admin app
cd ../admin_app
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_KEY=$SUPABASE_SERVICE_KEY \
  --dart-define=ENABLE_LOGGING=false
```

#### Mobile Deployment (if needed)
```bash
# Android
flutter build apk --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# iOS
flutter build ios --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## 🗄️ Database Setup

### 1. Run Database Migrations
```sql
-- Execute in Supabase SQL Editor
-- File: database_schema_clean.sql
```

### 2. Enable Row Level Security
```sql
-- Execute in Supabase SQL Editor
-- File: security_policies.sql
```

### 3. Create Admin User
```sql
-- In Supabase Authentication
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at)
VALUES ('admin@yourdomain.com', crypt('YourSecurePassword', gen_salt('bf')), now());
```

## 🌐 Web Server Configuration

### Nginx Configuration
```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self' https://*.supabase.co; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;

    # Main app
    location / {
        root /var/www/korean-admin/main-app;
        try_files $uri $uri/ /index.html;
    }

    # Admin app (subdomain or path)
    location /admin {
        alias /var/www/korean-admin/admin-app;
        try_files $uri $uri/ /admin/index.html;
    }

    # Gzip compression
    gzip on;
    gzip_types text/plain application/javascript text/css application/json;
    gzip_min_length 1000;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### Apache Configuration
```apache
<VirtualHost *:443>
    ServerName your-domain.com
    DocumentRoot /var/www/korean-admin/main-app

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/your-domain.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/your-domain.com/privkey.pem

    # Security headers
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Content-Security-Policy "default-src 'self' https://*.supabase.co;"

    # Main app
    <Directory /var/www/korean-admin/main-app>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Admin app
    Alias /admin /var/www/korean-admin/admin-app
    <Directory /var/www/korean-admin/admin-app>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

## 🔧 Deployment Steps

### 1. Prepare Server
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install web server (Nginx)
sudo apt install nginx certbot python3-certbot-nginx -y

# Create directories
sudo mkdir -p /var/www/korean-admin/{main-app,admin-app}
```

### 2. Deploy Built Files
```bash
# Copy main app files
sudo cp -r 행정도우미/build/web/* /var/www/korean-admin/main-app/

# Copy admin app files
sudo cp -r admin_app/build/web/* /var/www/korean-admin/admin-app/

# Set permissions
sudo chown -R www-data:www-data /var/www/korean-admin
sudo chmod -R 755 /var/www/korean-admin
```

### 3. Configure SSL
```bash
# Get SSL certificate with Let's Encrypt
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

### 4. Start Services
```bash
# Restart web server
sudo systemctl restart nginx

# Enable auto-start
sudo systemctl enable nginx
```

## 📊 Monitoring & Maintenance

### 1. Setup Monitoring
```bash
# Install monitoring tools
sudo apt install htop netdata -y

# Configure log rotation
sudo nano /etc/logrotate.d/korean-admin
```

### 2. Backup Strategy
```bash
# Daily database backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
pg_dump $DATABASE_URL > /backups/db_backup_$DATE.sql
find /backups -name "*.sql" -mtime +30 -delete
```

### 3. Health Checks
```javascript
// health-check.js
const https = require('https');

const sites = [
  'https://your-domain.com',
  'https://your-domain.com/admin'
];

sites.forEach(site => {
  https.get(site, (res) => {
    console.log(`${site}: ${res.statusCode}`);
  }).on('error', (e) => {
    console.error(`${site}: ${e.message}`);
    // Send alert
  });
});
```

## 🔒 Security Checklist

### Pre-Deployment
- [ ] Remove all debug code
- [ ] Disable console logging
- [ ] Update all dependencies
- [ ] Run security audit: `flutter pub audit`
- [ ] Test all authentication flows
- [ ] Verify RLS policies work correctly

### Post-Deployment
- [ ] Verify SSL certificate is valid
- [ ] Test all security headers
- [ ] Check for exposed sensitive endpoints
- [ ] Monitor error logs for security issues
- [ ] Set up fail2ban for brute force protection
- [ ] Configure firewall rules

## 🚨 Rollback Plan

### Quick Rollback Steps
```bash
# Keep previous version backup
sudo cp -r /var/www/korean-admin /var/www/korean-admin-backup

# If issues occur, rollback
sudo rm -rf /var/www/korean-admin
sudo mv /var/www/korean-admin-backup /var/www/korean-admin
sudo systemctl restart nginx
```

## 📝 Environment-Specific Configurations

### Development
```bash
flutter run --dart-define=ENABLE_LOGGING=true
```

### Staging
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=$STAGING_SUPABASE_URL \
  --dart-define=ENABLE_LOGGING=true
```

### Production
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=$PROD_SUPABASE_URL \
  --dart-define=ENABLE_LOGGING=false
```

## 🔄 CI/CD with GitHub Actions

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      
      - name: Build Main App
        run: |
          cd 행정도우미
          flutter pub get
          flutter build web --release \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
      
      - name: Deploy to Server
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          source: "행정도우미/build/web/*"
          target: "/var/www/korean-admin/main-app"
```

## 📞 Support Contacts

- **Technical Issues**: tech@yourdomain.com
- **Security Issues**: security@yourdomain.com
- **Emergency Hotline**: +82-10-XXXX-XXXX

## 📚 Additional Resources

- [Flutter Deployment Docs](https://flutter.dev/docs/deployment/web)
- [Supabase Production Checklist](https://supabase.com/docs/guides/platform/going-into-prod)
- [OWASP Security Guidelines](https://owasp.org/www-project-web-security-testing-guide/)