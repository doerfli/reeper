# Active Context: Reeper

## Current Focus (as of August 18, 2025)

- **Ruby Upgrade:** Project has been upgraded to Ruby 3.4.5 (see recent commits and merged PR #657)
- **Dependency Updates:** All dependencies are being kept up to date for security and compatibility
- **Docker/Devcontainer:** Devcontainer and Dockerfile updated for new Ruby version and manual install
- **Auth0 Integration:** Authentication flow stable, no recent changes
- **General Maintenance:** Ongoing bug fixes, minor enhancements, and dependency bumps

## Recent Changes

- Merged feature branch `feature/ruby-345` into `main`
- Updated `.ruby-version` to 3.4.5
- Updated Dockerfile, devcontainer, and GitHub Actions for Ruby 3.4.5
- Updated Gemfile.lock for new Ruby version

## Next Steps

- Monitor for issues with Ruby 3.4.5 in production
- Continue dependency and security updates
- Plan for Rails 8.x upgrade if not already complete
- Review and improve documentation

## Active Decisions

- Standardize on Ruby 3.4.5 for all environments
- Use manual Ruby install in devcontainer for flexibility
- Continue using Auth0 for authentication
- **Development setup:** Requires `bin/dev` + separate `yarn build:css --watch` and `yarn build --watch` processes
