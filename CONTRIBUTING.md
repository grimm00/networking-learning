# Contributing to Networking Learning Project

Thank you for your interest in contributing to the Networking Learning Project! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Documentation](#documentation)
- [Testing](#testing)
- [Release Process](#release-process)

## Code of Conduct

This project follows a code of conduct that ensures a welcoming environment for all contributors. By participating, you agree to uphold this code.

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. We pledge to:

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what's best for the community
- Show empathy towards other community members
- Accept constructive criticism gracefully
- Take responsibility for our mistakes and learn from them

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, trolling, or discriminatory language
- Personal attacks or political discussions
- Public or private harassment
- Publishing others' private information without permission
- Other unprofessional conduct

## Getting Started

### Prerequisites

- Python 3.8 or later
- Git
- Docker (for containerized development)
- Basic understanding of networking concepts

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/networking-learning.git
   cd networking-learning
   ```

3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/original-owner/networking-learning.git
   ```

## Development Setup

### Local Development

```bash
# Install dependencies
./install.sh

# Activate virtual environment
source venv/bin/activate

# Install development dependencies
pip install pytest black flake8 mypy

# Run tests
pytest tests/

# Format code
black scripts/

# Lint code
flake8 scripts/
```

### Containerized Development

```bash
# Start containerized environment
./container-practice.sh start

# Enter development container
./container-practice.sh enter

# Install development dependencies in container
pip install pytest black flake8 mypy

# Run tests
pytest tests/
```

## Contributing Guidelines

### Types of Contributions

We welcome several types of contributions:

#### 🐛 Bug Fixes
- Fix bugs in existing tools and scripts
- Improve error handling and edge cases
- Enhance cross-platform compatibility

#### ✨ New Features
- Add new networking analysis tools
- Implement additional protocol analyzers
- Create new educational modules
- Add GUI interfaces for existing tools

#### 📚 Documentation
- Improve existing documentation
- Add tutorials and examples
- Translate documentation to other languages
- Create video tutorials

#### 🧪 Testing
- Add unit tests for existing code
- Improve test coverage
- Add integration tests
- Performance testing

#### 🎓 Educational Content
- Add new learning modules
- Create hands-on exercises
- Develop troubleshooting scenarios
- Design network simulation labs

### Coding Standards

#### Python Code
- Follow PEP 8 style guidelines
- Use type hints for function parameters and return values
- Write docstrings for all functions and classes
- Use meaningful variable and function names
- Handle exceptions gracefully

```python
def analyze_interface(interface_name: str) -> Optional[InterfaceInfo]:
    """
    Analyze a network interface and return detailed information.
    
    Args:
        interface_name: Name of the interface to analyze
        
    Returns:
        InterfaceInfo object with interface details, or None if analysis fails
        
    Raises:
        ValueError: If interface_name is invalid
    """
    if not interface_name:
        raise ValueError("Interface name cannot be empty")
    
    try:
        # Implementation here
        pass
    except Exception as e:
        logger.error(f"Failed to analyze interface {interface_name}: {e}")
        return None
```

#### Shell Scripts
- Use `#!/bin/bash` shebang
- Set `set -e` for error handling
- Use meaningful variable names
- Add comments explaining complex logic
- Follow consistent indentation (4 spaces)

```bash
#!/bin/bash

# Network interface troubleshooting script
# Analyzes interface status and provides diagnostic information

set -e

INTERFACE_NAME="${1:-eth0}"
LOG_FILE="/tmp/interface-troubleshoot.log"

# Function to check interface status
check_interface_status() {
    local interface="$1"
    echo "Checking interface: $interface"
    
    if ip link show "$interface" >/dev/null 2>&1; then
        echo "✅ Interface $interface exists"
        return 0
    else
        echo "❌ Interface $interface not found"
        return 1
    fi
}
```

#### Documentation
- Use Markdown format
- Follow consistent formatting
- Include code examples
- Add diagrams where helpful
- Keep language clear and concise

### File Organization

#### Project Structure
```
networking-learning/
├── scripts/           # Python and shell scripts
├── 01-basics/        # Basic networking concepts
├── 02-protocols/     # Network protocols
├── 03-docker-networks/ # Container networking
├── 04-network-analysis/ # Network monitoring
├── 05-security/      # Network security
├── 06-advanced/      # Advanced topics
├── tests/            # Test files
├── docs/             # Additional documentation
└── admin/            # Administrative documentation
```

#### Naming Conventions
- **Files**: Use kebab-case (e.g., `interface-analyzer.py`)
- **Directories**: Use kebab-case (e.g., `network-interfaces/`)
- **Functions**: Use snake_case (e.g., `analyze_interface()`)
- **Classes**: Use PascalCase (e.g., `InterfaceAnalyzer`)
- **Constants**: Use UPPER_CASE (e.g., `DEFAULT_TIMEOUT`)

## Pull Request Process

### Before Submitting

1. **Test your changes**:
   ```bash
   # Run all tests
   ./test-installation.sh
   
   # Test specific functionality
   python3 scripts/interface-analyzer.py --help
   ```

2. **Check code quality**:
   ```bash
   # Format code
   black scripts/
   
   # Lint code
   flake8 scripts/
   
   # Type checking
   mypy scripts/
   ```

3. **Update documentation**:
   - Update README.md if adding new features
   - Add docstrings to new functions
   - Update CHANGELOG.md

### Pull Request Guidelines

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Write clean, well-documented code
   - Add tests for new functionality
   - Update documentation as needed

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: Add new interface analysis feature"
   ```

4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request**:
   - Use a descriptive title
   - Provide detailed description
   - Link any related issues
   - Include screenshots if applicable

### Commit Message Format

Use conventional commit messages:

```
type(scope): description

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(interface): Add IPv6 support to interface analyzer
fix(dns): Resolve timeout issues in DNS resolution
docs(readme): Update installation instructions for macOS
test(analyzer): Add unit tests for interface detection
```

## Issue Reporting

### Bug Reports

When reporting bugs, please include:

1. **Environment information**:
   - Operating system and version
   - Python version
   - Docker version (if applicable)

2. **Steps to reproduce**:
   - Clear, numbered steps
   - Expected behavior
   - Actual behavior

3. **Error messages**:
   - Full error output
   - Stack traces if applicable

4. **Additional context**:
   - Screenshots if helpful
   - Related issues or discussions

### Feature Requests

When requesting features, please include:

1. **Problem description**:
   - What problem does this solve?
   - Why is this feature needed?

2. **Proposed solution**:
   - How should this work?
   - Any specific requirements?

3. **Alternatives considered**:
   - What other solutions were considered?
   - Why is this approach preferred?

4. **Additional context**:
   - Use cases and examples
   - Related features or tools

## Documentation

### Writing Documentation

- **Clear and concise**: Use simple language
- **Examples**: Include code examples and use cases
- **Structure**: Use consistent formatting and organization
- **Accuracy**: Ensure information is current and correct
- **Accessibility**: Make documentation accessible to all users

### Documentation Types

- **README files**: Project and module overviews
- **API documentation**: Function and class documentation
- **Tutorials**: Step-by-step learning guides
- **Troubleshooting**: Common issues and solutions
- **Architecture**: Technical design and implementation

## Testing

### Test Types

#### Unit Tests
- Test individual functions and methods
- Use pytest framework
- Aim for high code coverage
- Test edge cases and error conditions

```python
import pytest
from scripts.interface_analyzer import InterfaceAnalyzer

def test_interface_detection():
    analyzer = InterfaceAnalyzer()
    interfaces = analyzer.get_interface_list()
    assert isinstance(interfaces, list)
    assert len(interfaces) > 0

def test_invalid_interface():
    analyzer = InterfaceAnalyzer()
    result = analyzer.get_interface_info("nonexistent")
    assert result is None
```

#### Integration Tests
- Test complete workflows
- Test tool interactions
- Test cross-platform compatibility

#### Performance Tests
- Test tool execution time
- Test memory usage
- Test with large datasets

### Running Tests

```bash
# Run all tests
pytest tests/

# Run specific test file
pytest tests/test_interface_analyzer.py

# Run with coverage
pytest --cov=scripts tests/

# Run in container
docker exec net-practice pytest /tests/
```

## Release Process

### Version Numbering

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

1. **Update version numbers**:
   - Update `VERSION` file
   - Update `package.json`
   - Update `CHANGELOG.md`

2. **Run full test suite**:
   ```bash
   ./test-installation.sh
   pytest tests/
   ```

3. **Update documentation**:
   - Update README.md
   - Update installation instructions
   - Update API documentation

4. **Create release**:
   - Create git tag
   - Push to repository
   - Create GitHub release

### Release Commands

```bash
# Update version
echo "1.1.0" > VERSION

# Create tag
git tag -a v1.1.0 -m "Release version 1.1.0"

# Push tag
git push origin v1.1.0

# Create release (GitHub CLI)
gh release create v1.1.0 --title "Version 1.1.0" --notes "See CHANGELOG.md"
```

## Getting Help

### Community Support

- **GitHub Issues**: For bug reports and feature requests
- **Discussions**: For questions and general discussion
- **Documentation**: Check existing documentation first

### Development Help

- **Code Review**: Ask for code review on pull requests
- **Mentoring**: Experienced contributors can mentor newcomers
- **Pair Programming**: Collaborate on complex features

## Recognition

Contributors will be recognized in:

- **CHANGELOG.md**: Listed for each release
- **README.md**: Contributor section
- **GitHub**: Contributor statistics and profiles

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to the Networking Learning Project! Your contributions help make networking education more accessible and effective for everyone.
