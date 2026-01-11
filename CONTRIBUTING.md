# Contributing to FastAPI Cloud Deploy

Thank you for your interest in contributing! This document outlines the process and guidelines.

## Getting Started

1. **Fork and clone** the repository
2. **Create a feature branch**: `git checkout -b feature/your-feature`
3. **Install dev dependencies**: `make install-deps && make install-hooks`

## Development Workflow

### Running Tests
```bash
make test
```

### Linting and Formatting
```bash
# Check formatting and linting
make lint

# Auto-format code
make format
```

### Pre-commit Hooks
Pre-commit hooks are installed to catch issues before commit:
```bash
make install-hooks
```

To bypass hooks (not recommended):
```bash
git commit --no-verify
```

## Code Style

- **Python**: Black (line length: 100), isort
- **Terraform**: terraform fmt, tflint, tfsec
- **YAML**: yamllint (via pre-commit)

## Submitting Changes

1. **Ensure all tests pass**: `make test`
2. **Ensure linting passes**: `make lint`
3. **Format your code**: `make format`
4. **Write a clear commit message**
5. **Push to your fork** and submit a pull request

## PR Guidelines

- Link related issues
- Include a clear description of changes
- Add tests for new functionality
- Update documentation as needed
- Keep commits focused and logical

## Reporting Issues

Please use GitHub Issues to report bugs or suggest features. Include:
- Clear description of the issue
- Steps to reproduce (for bugs)
- Expected vs. actual behavior
- Environment details (Python version, OS, etc.)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
