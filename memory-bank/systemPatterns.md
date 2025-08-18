# System Patterns: Reeper

## Architecture Overview

### System Architecture
Reeper follows a **traditional Rails MVC architecture** with modern enhancements for file storage, authentication, and deployment.

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Browser   │◄──►│   Rails App      │◄──►│   PostgreSQL    │
│                 │    │   (Puma Server)  │    │   Database      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │   AWS S3         │
                       │   File Storage   │
                       └──────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │   Auth0          │
                       │   Authentication │
                       └──────────────────┘
```

### Core Components

1. **Rails Application**: Main application server handling HTTP requests
2. **PostgreSQL Database**: Primary data store for recipes, users, tags
3. **AWS S3 Storage**: External file storage for recipe images
4. **Auth0 Service**: External authentication provider
5. **Tesseract OCR**: Image text extraction service
6. **Docker Container**: Deployment packaging and runtime environment

## Design Patterns

### Model Layer Patterns

#### Active Record Pattern
- **Recipe Model**: Central entity with rich text and image attachments
- **Tag Model**: Simple entity with many-to-many relationship to recipes
- **User Model**: Minimal user entity, primary data from Auth0

#### Rich Text Integration
```ruby
class Recipe < ApplicationRecord
  has_rich_text :instructions 
  has_rich_text :ingredients
  has_many_attached :recipe_images
  has_and_belongs_to_many :tags
end
```

#### File Attachment Pattern
- **Active Storage**: Rails-native file attachments
- **Multiple Images**: Recipe can have multiple attached images
- **Cloud Storage**: S3 backend for production deployments

### Controller Layer Patterns

#### Security Concern Pattern
```ruby
module Secured
  extend ActiveSupport::Concern
  included do
    before_action :logged_in_using_omniauth?
  end
end
```

#### RESTful Resource Pattern
- Standard Rails REST conventions for recipes, tags, images
- Nested resources for recipe images
- Custom actions for filtering and search

#### Session-Based Authentication
- Auth0 user data stored in Rails session
- No local password management
- Redirect-based login flow

### View Layer Patterns

#### Component-Based Partials
- Shared navigation component
- Reusable form components
- Consistent styling patterns

#### Responsive Design
- **Tailwind CSS**: Utility-first CSS framework
- **Mobile-First**: Responsive breakpoints
- **Touch-Friendly**: Large tap targets for mobile

### Data Layer Patterns

#### Search and Filtering
- **Text Search**: PostgreSQL full-text search capabilities
- **Tag Filtering**: Many-to-many relationship queries
- **Pagination**: Kaminari gem for efficient pagination

#### Image Processing
- **Active Storage Variants**: Automatic image resizing
- **OCR Integration**: Tesseract for text extraction
- **Background Processing**: Async image processing

## Technical Decisions

### Language and Framework
- **Ruby 3.4.5**: Latest stable Ruby version
- **Rails 8.x**: Modern Rails with current features
- **PostgreSQL**: Robust database with full-text search
- **Rationale**: Mature ecosystem, developer productivity, community support

### Frontend Strategy
- **Traditional Rails Views**: Server-rendered HTML with Turbo
- **Tailwind CSS**: Utility-first styling for rapid development
- **Minimal JavaScript**: Progressive enhancement approach
- **Rationale**: Simplicity, SEO-friendly, fast development

### Authentication Strategy
- **Auth0 Integration**: External authentication provider
- **Session-Based**: Traditional Rails session management
- **No Local Users**: Delegate identity management to Auth0
- **Rationale**: Security expertise, reduces maintenance burden

### File Storage Strategy
- **AWS S3**: Cloud storage for production
- **Active Storage**: Rails-native file attachment API
- **Local Storage**: Development and testing
- **Rationale**: Scalability, reliability, cost-effectiveness

### Deployment Strategy
- **Docker Containers**: Standardized deployment packaging
- **Docker Compose**: Local development and simple production
- **Environment Variables**: Configuration management
- **Rationale**: Consistency, portability, ease of deployment

## Component Relationships

### Core Domain Models
```
User ──┐
        │
        ▼
    Recipe ◄──► Tag (many-to-many)
        │
        ▼
    RecipeImage (attachments)
```

### Authentication Flow
```
1. User visits app
2. Redirect to Auth0 login
3. Auth0 callback with user data
4. Create/update local User record
5. Store user info in session
6. Redirect to main app
```

### Recipe Creation Flow
```
1. User creates recipe with form
2. Rich text content processed
3. Images uploaded to S3
4. OCR processing for image text
5. Tags created/associated
6. Recipe saved to database
```

## Integration Patterns

### External Service Integration

#### Auth0 Integration
- **OmniAuth Strategy**: Rails middleware integration
- **Callback Handling**: User creation and session management
- **Logout Flow**: Clear session and redirect to Auth0 logout

#### AWS S3 Integration
- **Active Storage**: Rails-native S3 adapter
- **Credentials**: Environment variable configuration
- **Bucket Configuration**: Regional deployment support

#### OCR Integration
- **Tesseract**: Command-line OCR tool
- **RTesseract Gem**: Ruby wrapper for Tesseract
- **Image Processing**: Automatic text extraction from uploads
- **Editable Storage**: OCR results saved to editable `ocr_text` field on Recipe model
- **Latest First**: New OCR results are prepended (most recent on top)
- **User Control**: Users can edit, delete old OCR content, and copy/paste into rich text fields
- **Timestamped Results**: Each OCR operation includes timestamp for reference

### Database Patterns

#### Migration Strategy
- **Version Control**: All schema changes in migrations
- **Data Integrity**: Foreign key constraints where appropriate
- **Indexing**: Performance optimization for search queries

#### Query Optimization
- **Eager Loading**: Includes for N+1 query prevention
- **Scopes**: Named query patterns for common operations
- **Pagination**: Limit query results for performance

## Security Patterns

### Authentication Security
- **External Provider**: Delegate to Auth0 expertise
- **Session Management**: Rails-standard session handling
- **CSRF Protection**: Rails built-in CSRF tokens

### Data Security
- **Environment Variables**: Sensitive configuration externalized
- **S3 Access Control**: IAM-based bucket permissions
- **Database Security**: Connection encryption and access control

### Application Security
- **Parameter Filtering**: Sensitive data excluded from logs
- **Input Validation**: Rails parameter strong typing
- **XSS Protection**: Rails built-in output escaping

## Performance Patterns

### Database Performance
- **Query Optimization**: Efficient includes and joins
- **Indexing Strategy**: Database indexes for common queries
- **Connection Pooling**: Rails connection management

### File Storage Performance
- **CDN Delivery**: S3 CloudFront integration potential
- **Image Variants**: Optimized sizes for different contexts
- **Lazy Loading**: Defer image loading where appropriate

### Caching Strategy
- **Fragment Caching**: Cache expensive view fragments
- **HTTP Caching**: Browser caching headers
- **Database Query Cache**: Rails query caching
