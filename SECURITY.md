# Security Policy

## Supported Versions

We provide security updates for the following versions of fontconfig-py:

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |
| 0.4.x   | :white_check_mark: |
| 0.3.x   | :x:                |
| < 0.3   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue in fontconfig-py, please report it responsibly.

### How to Report

**Please use GitHub Security Advisories for private vulnerability reporting:**

1. Go to the [Security Advisories page](https://github.com/kyamagu/fontconfig-py/security/advisories/new)
2. Click "Report a vulnerability"
3. Provide detailed information about the vulnerability

### What to Include

When reporting a security vulnerability, please include:

- A clear description of the vulnerability
- Steps to reproduce the issue
- Affected versions of fontconfig-py
- Potential impact and severity assessment
- Any suggested fixes or mitigations (if available)
- Your contact information for follow-up questions

### What to Expect

- **Initial Response**: We aim to acknowledge your report within 48 hours
- **Status Updates**: We will keep you informed about our progress in addressing the issue
- **Fix Timeline**: We will work to release a security patch as quickly as possible, depending on the complexity and severity of the issue
- **Credit**: With your permission, we will acknowledge your contribution in the security advisory and CHANGELOG

### Disclosure Policy

- Please do not publicly disclose the vulnerability until we have had a chance to address it
- We will coordinate the disclosure timeline with you
- Once a fix is released, we will publish a security advisory on GitHub
- The vulnerability details will be included in the project's CHANGELOG

## Security Update Process

When a security vulnerability is confirmed:

1. We will develop and test a fix
2. A new version will be released with the security patch
3. A GitHub Security Advisory will be published
4. The fix will be documented in the CHANGELOG
5. Users will be notified through:
   - GitHub Security Advisories (if they have notifications enabled)
   - Release notes on the GitHub repository
   - PyPI release announcement

## Dependency Security

### Bundled Libraries

fontconfig-py statically links the following third-party libraries:

- **fontconfig**: Font configuration and matching library
- **freetype**: Font rendering engine

We monitor security advisories for these dependencies and update them in our releases when security issues are identified.

### Updating Dependencies

If you discover a security vulnerability in our bundled dependencies (fontconfig or freetype):

1. Report it through GitHub Security Advisories (as described above)
2. We will update the affected library and release a new version
3. The update will be documented in the CHANGELOG

### Automated Dependency Updates

We use Dependabot to monitor and update dependencies automatically. Security updates for GitHub Actions and Python dependencies are prioritized and reviewed promptly.

## Security Best Practices

When using fontconfig-py:

- Always use the latest version to benefit from security updates
- Be cautious when processing untrusted font files
- Follow the principle of least privilege when running applications that use fontconfig-py
- Keep your Python environment and system libraries up to date

## Questions or Concerns

If you have questions about this security policy or general security concerns (not specific vulnerabilities), please open an issue on the [GitHub repository](https://github.com/kyamagu/fontconfig-py/issues).

For private security-related communications, please use GitHub Security Advisories rather than email to ensure proper tracking and coordination.
