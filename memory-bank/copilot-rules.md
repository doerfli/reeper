# Copilot Rules: Reeper

## General Guidance

- Always read all memory bank files before starting any task
- Document all significant changes in `activeContext.md` and `progress.md`
- Update this file with new project rules, patterns, or security requirements

## Security

- Never commit secrets or credentials to version control
- Use environment variables for all sensitive data
- If a secret is committed, treat as a security incident and rotate credentials
- Use secret scanning tools before pushing code

## Project Patterns

- Use Rails RESTful conventions for all resources
- Use Active Storage for file attachments
- Use Auth0 for authentication; do not implement local password storage
- Use Docker for all deployments
- Use Tailwind CSS for all UI styling
- **Development workflow:** Use `bin/dev` to start Rails server, plus `yarn build:css --watch` and `yarn build --watch` for asset building
- **RESTful design:** Prefer standard controller actions (GET, POST, PATCH, DELETE) over custom actions when possible
- **Internationalization:** Always use locale files (`config/locales/en.yml` and `config/locales/de.yml`) for all user-facing text. Never hardcode text in views or controllers. Use `t('key')` or `I18n.t('key')` without default values.

## Workflow

- Always update the memory bank after major changes or upgrades
- Document current focus and next steps in `activeContext.md`
- Document what works and what’s left in `progress.md`
- Keep `projectbrief.md`, `productContext.md`, `systemPatterns.md`, and `techContext.md` up to date

## Evolving Patterns

- Standardize on latest stable Ruby and Rails versions
- Use manual Ruby install in devcontainer for flexibility
- Prefer minimal, maintainable dependencies
- Review and update documentation regularly
