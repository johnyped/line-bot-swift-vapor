# LINE Bot Development Plan - Swift Vapor

## 🎯 Project Overview
Build a LINE bot using Swift Vapor that can join LINE group chats, listen to messages, and store metadata and content in Google Sheets and Google Drive.

---

## 🏗️ Architecture Overview

### Tech Stack
- **Backend Framework:** Swift Vapor 4.x
- **Database:** PostgreSQL (for message queuing and state management)
- **External APIs:** 
  - LINE Messaging API
  - Google Sheets API
  - Google Drive API
- **Deployment:** Docker + Cloud Run or VPS
- **Authentication:** JWT for LINE webhook verification

### System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   LINE Group    │───▶│  Vapor Server   │───▶│  Google Sheets  │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  Google Drive   │
                       │                 │
                       └─────────────────┘
```

---

## 📋 Development Phases

### Phase 1: Project Setup & Foundation (Week 1)
**Duration:** 5-7 days

#### 1.1 Project Initialization
- [ ] Create new Vapor project: `vapor new line-bot-server`
- [ ] Set up project structure with proper organization
- [ ] Configure Swift Package Manager dependencies
- [ ] Set up development environment (Xcode/VSCode)

#### 1.2 Core Dependencies
```swift
// Package.swift dependencies
.package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
.package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
.package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
.package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
.package(url: "https://github.com/googleapis/google-api-swift.git", from: "1.0.0"),
.package(url: "https://github.com/apple/swift-crypto.git", from: "2.0.0")
```

#### 1.3 Environment Configuration
- [ ] Create `.env` file for configuration
- [ ] Set up environment variables for:
  - LINE Channel Secret
  - LINE Channel Access Token
  - Google Service Account credentials
  - Database connection string
  - Google Drive root folder ID
  - Google Sheets spreadsheet ID

#### 1.4 Database Setup
- [ ] Configure PostgreSQL connection
- [ ] Create data models:
  ```swift
  // Message model for queuing
  struct Message: Model {
      var id: UUID?
      var lineMessageId: String
      var senderId: String
      var senderName: String
      var messageType: MessageType
      var content: String?
      var mediaUrl: String?
      var timestamp: Date
      var processed: Bool
  }
  
  enum MessageType: String, Codable {
      case text, image, video, audio, file, link
  }
  ```

### Phase 2: LINE Bot Integration (Week 2)
**Duration:** 5-7 days

#### 2.1 LINE Webhook Setup
- [ ] Create webhook endpoint: `POST /webhook/line`
- [ ] Implement LINE signature verification
- [ ] Handle LINE webhook events (message, join, leave)
- [ ] Add message parsing and validation

#### 2.2 LINE Message Handling
```swift
// Core message handling structure
struct LineWebhookController {
    func handleWebhook(req: Request) async throws -> HTTPStatus
    
    private func processMessage(_ message: LineMessage) async throws
    private func handleTextMessage(_ message: LineTextMessage) async throws
    private func handleMediaMessage(_ message: LineMediaMessage) async throws
    private func handleJoinEvent(_ event: LineJoinEvent) async throws
}
```

#### 2.3 Message Processing Pipeline
- [ ] Implement message type detection
- [ ] Create message queue system
- [ ] Add retry mechanism for failed operations
- [ ] Implement message deduplication

#### 2.4 LINE Bot Permissions
- [ ] Configure bot to join groups automatically
- [ ] Set up bot profile and capabilities
- [ ] Test group join/leave functionality

### Phase 3: Google Sheets Integration (Week 3)
**Duration:** 5-7 days

#### 3.1 Google Sheets API Setup
- [ ] Set up Google Sheets API client
- [ ] Implement authentication with service account
- [ ] Create sheet management utilities

#### 3.2 Sheet Management
```swift
struct GoogleSheetsService {
    func ensureDailySheetExists() async throws -> String
    func appendMessage(_ message: ProcessedMessage) async throws
    func createNewSheet(for date: Date) async throws -> String
    func getSheetId(for date: Date) async throws -> String?
}
```

#### 3.3 Daily Sheet Creation
- [ ] Implement automatic daily sheet creation
- [ ] Set up sheet headers and formatting
- [ ] Add timestamp-based sheet naming (`yyyy_MM_dd`)
- [ ] Implement sheet existence checking

#### 3.4 Message Logging
- [ ] Create message formatting for sheets
- [ ] Implement descending time order insertion
- [ ] Add auto-numbering system
- [ ] Handle different message types in sheets

### Phase 4: Google Drive Integration (Week 4)
**Duration:** 5-7 days

#### 4.1 Google Drive API Setup
- [ ] Set up Google Drive API client
- [ ] Implement file upload functionality
- [ ] Create folder management system

#### 4.2 Folder Structure Management
```swift
struct GoogleDriveService {
    func ensureDailyFolderExists() async throws -> String
    func ensureSenderFolderExists(senderName: String, date: Date) async throws -> String
    func uploadMediaFile(_ data: Data, fileName: String, senderName: String, date: Date) async throws -> String
    func createShareableLink(fileId: String) async throws -> String
}
```

#### 4.3 Media File Handling
- [ ] Implement media file download from LINE
- [ ] Create daily folder structure: `/Root/yyyy_MM_dd/sender/`
- [ ] Add file naming and organization
- [ ] Implement shareable link generation

#### 4.4 File Upload Pipeline
- [ ] Handle different media types (image, video, audio, file)
- [ ] Implement file size validation
- [ ] Add upload progress tracking
- [ ] Create error handling for failed uploads

### Phase 5: Integration & Testing (Week 5)
**Duration:** 5-7 days

#### 5.1 End-to-End Integration
- [ ] Connect all components in main workflow
- [ ] Implement message processing pipeline
- [ ] Add comprehensive error handling
- [ ] Create logging and monitoring

#### 5.2 Main Workflow Implementation
```swift
struct MessageProcessor {
    func processIncomingMessage(_ lineMessage: LineMessage) async throws {
        // 1. Parse and validate message
        // 2. Save to database queue
        // 3. Process media files (if any)
        // 4. Update Google Sheets
        // 5. Mark as processed
    }
}
```

#### 5.3 Testing Strategy
- [ ] Unit tests for each service
- [ ] Integration tests for API endpoints
- [ ] End-to-end tests with mock LINE webhooks
- [ ] Performance testing for concurrent messages

#### 5.4 Error Handling & Recovery
- [ ] Implement retry mechanisms
- [ ] Add dead letter queue for failed messages
- [ ] Create monitoring and alerting
- [ ] Add graceful degradation

### Phase 6: Deployment & Production (Week 6)
**Duration:** 3-5 days

#### 6.1 Production Setup
- [ ] Create Docker configuration
- [ ] Set up production environment
- [ ] Configure SSL certificates
- [ ] Set up monitoring and logging

#### 6.2 Deployment Configuration
```dockerfile
# Dockerfile
FROM swift:5.9 as build
WORKDIR /app
COPY . .
RUN swift build -c release

FROM swift:5.9-slim
WORKDIR /app
COPY --from=build /app/.build/release/Run ./
EXPOSE 8080
CMD ["./Run", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
```

#### 6.3 Production Monitoring
- [ ] Set up health check endpoints
- [ ] Configure application metrics
- [ ] Add error tracking (Sentry)
- [ ] Create operational dashboards

---

## 📁 Project Structure

```
line-bot-server/
├── Sources/
│   └── App/
│       ├── Controllers/
│       │   ├── LineWebhookController.swift
│       │   └── HealthController.swift
│       ├── Models/
│       │   ├── Message.swift
│       │   └── ProcessedMessage.swift
│       ├── Services/
│       │   ├── LineService.swift
│       │   ├── GoogleSheetsService.swift
│       │   ├── GoogleDriveService.swift
│       │   └── MessageProcessor.swift
│       ├── Middleware/
│       │   └── LineSignatureMiddleware.swift
│       ├── configure.swift
│       └── routes.swift
├── Tests/
├── Resources/
│   └── google-credentials.json
├── Package.swift
├── Dockerfile
└── .env
```

---

## 🔧 Configuration Requirements

### Environment Variables
```bash
# LINE Configuration
LINE_CHANNEL_SECRET=your_channel_secret
LINE_CHANNEL_ACCESS_TOKEN=your_channel_access_token

# Google Configuration
GOOGLE_SERVICE_ACCOUNT_EMAIL=your_service_account@project.iam.gserviceaccount.com
GOOGLE_PRIVATE_KEY=your_private_key
GOOGLE_SHEETS_SPREADSHEET_ID=your_spreadsheet_id
GOOGLE_DRIVE_ROOT_FOLDER_ID=your_root_folder_id

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/linebot

# Server
PORT=8080
HOST=0.0.0.0
```

### Google API Setup
1. Create Google Cloud Project
2. Enable Google Sheets API and Google Drive API
3. Create Service Account with appropriate permissions
4. Share Google Sheet and Drive folder with service account email

### LINE Bot Setup
1. Create LINE Developer account
2. Create new Messaging API channel
3. Configure webhook URL: `https://your-domain.com/webhook/line`
4. Set bot to join groups automatically

---

## 🧪 Testing Strategy

### Unit Tests
- [ ] LINE message parsing
- [ ] Google Sheets operations
- [ ] Google Drive operations
- [ ] Message processing logic

### Integration Tests
- [ ] Webhook endpoint with LINE signature verification
- [ ] End-to-end message processing
- [ ] Database operations
- [ ] API rate limiting

### Load Testing
- [ ] Concurrent message processing
- [ ] Large file uploads
- [ ] Database performance under load
- [ ] Memory usage optimization

---

## 📊 Monitoring & Observability

### Metrics to Track
- Messages processed per minute
- Media files uploaded per day
- Google API quota usage
- Error rates and types
- Response times for each service

### Logging Strategy
- Structured logging with correlation IDs
- Separate log levels for different components
- Error tracking with stack traces
- Performance metrics logging

---

## 🚀 Deployment Checklist

### Pre-deployment
- [ ] All tests passing
- [ ] Environment variables configured
- [ ] Google APIs enabled and configured
- [ ] LINE webhook URL updated
- [ ] SSL certificate installed
- [ ] Database migrations run

### Post-deployment
- [ ] Health check endpoint responding
- [ ] LINE webhook receiving messages
- [ ] Google Sheets being updated
- [ ] Media files uploading to Drive
- [ ] Monitoring dashboards active
- [ ] Error tracking configured

---

## 🔄 Maintenance & Updates

### Regular Tasks
- Monitor Google API quotas
- Check LINE webhook health
- Review error logs
- Update dependencies
- Backup database

### Scaling Considerations
- Horizontal scaling with load balancer
- Database connection pooling
- Message queue for high throughput
- CDN for media file delivery

---

## 📚 Resources & Documentation

### Official Documentation
- [Vapor Documentation](https://docs.vapor.codes/)
- [LINE Messaging API](https://developers.line.biz/en/docs/messaging-api/)
- [Google Sheets API](https://developers.google.com/sheets/api)
- [Google Drive API](https://developers.google.com/drive/api)

### Community Resources
- Vapor Discord server
- LINE Developer Community
- Google Cloud Community

---

## ⚠️ Risk Mitigation

### Technical Risks
- **Google API Rate Limits:** Implement exponential backoff and queuing
- **LINE Webhook Failures:** Add retry mechanism and monitoring
- **Database Connection Issues:** Use connection pooling and health checks
- **File Upload Failures:** Implement chunked uploads and resume capability

### Operational Risks
- **Service Account Permissions:** Regular permission audits
- **Data Loss:** Implement backup strategies
- **Security:** Regular security updates and audits
- **Compliance:** Ensure GDPR compliance for message storage

---

This development plan provides a structured approach to building the LINE bot using Swift Vapor, with clear phases, deliverables, and considerations for production deployment. 