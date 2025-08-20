# Project Brief: Reeper

## Project Overview

**Reeper** is a self-hosted recipe management web application built with Ruby on Rails. It provides users with a comprehensive platform to store, organize, and manage their recipes with features like image attachments, tagging, search functionality, and OCR capabilities.

## Core Requirements

### Functional Requirements
1. **Recipe Management**: Create, read, update, delete recipes with rich text support
2. **Image Handling**: Attach multiple images to recipes with OCR text extraction
3. **Tagging System**: Organize recipes with tags and filtering capabilities
4. **Search Functionality**: Full-text search across recipes and tags
5. **User Authentication**: Secure login via Auth0 integration
6. **Responsive Design**: Mobile-friendly interface using Tailwind CSS
7. **Data Persistence**: PostgreSQL database for reliable data storage
8. **File Storage**: AWS S3 integration for image storage

### Technical Requirements
1. **Ruby on Rails 8.x**: Modern Rails framework with latest features
2. **Ruby 3.4.5**: Latest stable Ruby version for performance and security
3. **PostgreSQL**: Robust database with full-text search capabilities
4. **Docker Support**: Containerized deployment for easy hosting
5. **OCR Integration**: Text extraction from recipe images using Tesseract
6. **Responsive UI**: Tailwind CSS for modern, mobile-first design

## Project Goals

### Primary Goals
- Provide a reliable, self-hosted alternative to commercial recipe managers
- Ensure data ownership and privacy for users
- Support rich recipe content with images and formatted text
- Enable efficient recipe discovery through search and tags

### Success Metrics
- Stable performance with large recipe collections
- Fast search and filtering responses
- Reliable image upload and OCR processing
- Seamless user experience across devices
- Easy deployment and maintenance

## Project Scope

### In Scope
- Recipe CRUD operations with rich text support
- Multi-image attachments per recipe
- OCR text extraction from images
- Tag-based organization and filtering
- Full-text search functionality
- Auth0 authentication integration
- AWS S3 file storage
- Responsive web interface
- Docker containerization
- Database backup/restore capabilities

### Out of Scope
- Mobile native applications
- Real-time collaboration features
- Third-party recipe import/export
- Social sharing features
- Recipe scaling/conversion tools
- Meal planning functionality

## Target Users

### Primary Users
- Home cooks who want to digitize their recipe collections
- Users seeking privacy and data ownership
- Technical users comfortable with self-hosting

### User Personas
1. **The Digital Organizer**: Wants to convert physical recipe cards to digital format
2. **The Privacy-Conscious Cook**: Prefers self-hosted solutions over cloud services
3. **The Tech-Savvy Chef**: Comfortable with Docker deployment and maintenance

## Constraints

### Technical Constraints
- Self-hosted deployment requirement
- Ruby/Rails technology stack
- PostgreSQL database dependency
- AWS S3 for file storage
- Docker containerization

### Resource Constraints
- Single developer maintenance
- Community-driven development
- Limited third-party service dependencies

## Project Timeline

This is an ongoing maintenance project with regular updates for:
- Ruby/Rails version upgrades
- Security patches
- Dependency updates
- Bug fixes and minor enhancements

## Success Criteria

1. **Reliability**: Zero data loss, stable performance
2. **Usability**: Intuitive interface, fast response times
3. **Maintainability**: Clean code, automated testing, clear documentation
4. **Security**: Secure authentication, protected data storage
5. **Scalability**: Handles hundreds of recipes efficiently
