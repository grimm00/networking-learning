---
description: Global development rules for Networking Learning Project
globs: ["**/*"]
alwaysApply: true
---

# Global Development Rules for Networking Learning Project

## 🎯 Project Context & Philosophy

**Why these rules exist**: This is an educational networking project designed to teach practical networking concepts through hands-on exercises. The rules ensure consistency, maintainability, and educational value while supporting cross-platform compatibility.

## 📋 Core Development Principles

### 1. Educational-First Design
**Rule**: All code, documentation, and tools must prioritize learning and understanding over complexity.

**Reasoning**: 
- This is a learning project, not a production system
- Students need to understand what they're doing and why
- Complex implementations obscure learning objectives
- Clear, well-documented code teaches best practices

**Implementation**:
- Extensive comments explaining networking concepts
- Step-by-step documentation with expected outputs
- Progressive complexity from basic to advanced
- Real-world examples and practical scenarios

### 2. Cross-Platform Compatibility
**Rule**: All tools and scripts must work on macOS, Linux, and Windows (WSL2).

**Reasoning**:
- Students use different operating systems
- Containerized environment provides consistency
- Platform-specific commands need fallbacks
- Educational value shouldn't be limited by OS choice

**Implementation**:
- Dynamic command detection (`ip` vs `ifconfig`)
- Platform-specific parsing logic
- Graceful fallbacks for missing tools
- Clear documentation of platform differences

### 3. Container-First Architecture
**Rule**: All networking tools and exercises run in containerized environments.

**Reasoning**:
- Provides safe learning environment
- Ensures consistent behavior across platforms
- Allows privileged networking operations
- Prevents interference with host system

**Implementation**:
- Docker Compose for orchestration
- Privileged containers with NET_ADMIN capabilities
- Isolated networks for different modules
- Consistent tool availability across environments

## 🛠️ Code Quality Standards

### 4. Comprehensive Documentation
**Rule**: Every script, tool, and module must have extensive documentation explaining networking concepts.

**Reasoning**:
- Students learn from well-documented code
- Documentation serves as learning material
- Reduces maintenance burden
- Enables self-directed learning

**Implementation**:
- Detailed docstrings explaining networking concepts
- README files with learning objectives
- Inline comments explaining complex operations
- Expected outputs and troubleshooting guides

### 5. Error Handling and User Feedback
**Rule**: All tools must provide clear, educational error messages and progress feedback.

**Reasoning**:
- Students learn from understanding failures
- Clear feedback reduces frustration
- Educational context helps learning
- Debugging skills are important for networking

**Implementation**:
- Descriptive error messages with solutions
- Progress indicators for long-running operations
- Educational context for common issues
- Troubleshooting guides and diagnostic tools

### 6. Modular and Reusable Design
**Rule**: All tools must be modular, reusable, and follow consistent patterns.

**Reasoning**:
- Reduces code duplication
- Enables easy addition of new modules
- Consistent user experience across tools
- Easier maintenance and updates

**Implementation**:
- Centralized tools in `scripts/` directory
- Symbolic links in modules for easy access
- Consistent command-line interfaces
- Shared utility functions and patterns

## 📁 Project Organization Rules

### 7. Centralized Tool Management
**Rule**: All executable tools must be in the `scripts/` directory with symbolic links in modules.

**Reasoning**:
- Single source of truth for all tools
- Easy maintenance and updates
- Consistent tool availability
- Prevents duplication and version conflicts

**Implementation**:
- All Python and shell scripts in `scripts/`
- Symbolic links: `modules/*/tool.py -> ../../../scripts/tool.py`
- Validation script checks link integrity
- Consistent naming and structure

### 8. Module Independence
**Rule**: Each learning module must be self-contained and independently functional.

**Reasoning**:
- Students can focus on specific topics
- Modules can be developed independently
- Easier to add new modules
- Clear learning progression

**Implementation**:
- Each module has its own README and documentation
- Module-specific Docker configurations
- Independent port allocations
- Self-contained learning objectives

### 9. Output Organization
**Rule**: All tools must save output to organized directories, never cluttering the project root.

**Reasoning**:
- Keeps project directory clean and professional
- Easy to find and manage generated files
- Prevents accidental commits of output files
- Better organization for learning materials

**Implementation**:
- Default output to `output/` directory
- Tool-specific subdirectories when needed
- `.gitignore` excludes output directories
- Clear documentation of output locations

## 🔧 Technical Implementation Rules

### 10. Python Script Standards
**Rule**: All Python scripts must follow PEP 8, include type hints, and have comprehensive docstrings.

**Reasoning**:
- Teaches good Python practices
- Type hints improve code understanding
- Comprehensive docstrings serve as learning material
- Consistent code style across project

**Implementation**:
```python
#!/usr/bin/env python3
"""
Tool Name - Brief Description
Comprehensive explanation of networking concepts and tool purpose.
"""

import argparse
from typing import Dict, List, Any, Optional

class ToolClass:
    """Class docstring explaining networking concepts."""
    
    def method(self, param: str) -> bool:
        """Method docstring with networking context."""
        pass
```

### 11. Shell Script Standards
**Rule**: All shell scripts must be POSIX-compliant, include error handling, and provide user feedback.

**Reasoning**:
- POSIX compliance ensures cross-platform compatibility
- Error handling prevents confusing failures
- User feedback improves learning experience
- Consistent script patterns across project

**Implementation**:
```bash
#!/bin/bash
set -e  # Exit on error

# Colors for user feedback
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Functions for consistent feedback
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
```

### 12. Docker Configuration Standards
**Rule**: All Docker configurations must be minimal, secure, and well-documented.

**Reasoning**:
- Minimal images reduce attack surface
- Security is important for networking tools
- Documentation helps students understand containerization
- Consistent patterns across modules

**Implementation**:
- Use official base images when possible
- Document all exposed ports and capabilities
- Include health checks where appropriate
- Clear documentation of container purposes

## 🧪 Testing and Validation Rules

### 13. Comprehensive Validation
**Rule**: All changes must pass comprehensive validation before commit.

**Reasoning**:
- Prevents broken installations
- Ensures cross-platform compatibility
- Validates symbolic links and references
- Maintains project integrity

**Implementation**:
- Run `./bin/validate-installation.sh` before commits
- Test on multiple platforms
- Validate all symbolic links
- Check documentation links and references

### 14. Backward Compatibility
**Rule**: Changes must maintain backward compatibility with existing functionality.

**Reasoning**:
- Students may have existing setups
- Breaking changes disrupt learning
- Gradual evolution is better than revolution
- Maintains trust in project stability

**Implementation**:
- Test existing functionality after changes
- Provide migration guides for major changes
- Deprecate features gradually
- Clear communication of breaking changes

## 📚 Documentation Rules

### 15. Educational Context
**Rule**: All documentation must include educational context explaining networking concepts.

**Reasoning**:
- Documentation serves as learning material
- Students need to understand the "why" not just the "how"
- Context helps retention and understanding
- Builds comprehensive networking knowledge

**Implementation**:
- Explain networking concepts in documentation
- Provide expected outputs and examples
- Include troubleshooting guides
- Link to relevant networking standards and RFCs

### 16. Progressive Learning
**Rule**: Documentation must support progressive learning from basic to advanced concepts.

**Reasoning**:
- Students have different skill levels
- Building knowledge incrementally is most effective
- Advanced topics need foundational understanding
- Clear progression prevents confusion

**Implementation**:
- Clear learning objectives for each module
- Prerequisites and dependencies documented
- Progressive complexity within modules
- Clear learning path through project

## 🚀 Deployment and Maintenance Rules

### 17. Automated Installation
**Rule**: Project must support one-command installation across all platforms.

**Reasoning**:
- Reduces barrier to entry for students
- Ensures consistent setup across platforms
- Reduces support burden
- Professional project presentation

**Implementation**:
- Cross-platform installation script
- Automated dependency checking
- Clear installation instructions
- Validation of successful installation

### 18. Version Management
**Rule**: All releases must follow semantic versioning with comprehensive changelogs.

**Reasoning**:
- Clear communication of changes
- Enables students to track project evolution
- Professional project management
- Facilitates contribution and feedback

**Implementation**:
- Semantic versioning (MAJOR.MINOR.PATCH)
- Comprehensive changelog for each release
- Clear release notes
- Tagged releases in Git

## 🔍 Quality Assurance Rules

### 19. Code Review Standards
**Rule**: All code changes must be reviewed for educational value, technical correctness, and documentation quality.

**Reasoning**:
- Ensures educational value is maintained
- Prevents technical errors from reaching students
- Maintains documentation quality
- Builds confidence in project reliability

**Implementation**:
- Review for educational context
- Test functionality across platforms
- Validate documentation completeness
- Check for security best practices

### 20. Continuous Improvement
**Rule**: Project must continuously evolve based on user feedback and educational best practices.

**Reasoning**:
- Educational needs change over time
- User feedback improves project quality
- Technology evolves and project should adapt
- Continuous improvement ensures long-term value

**Implementation**:
- Regular feedback collection
- Issue tracking and resolution
- Regular updates to tools and documentation
- Community contribution guidelines

---

## 🎯 Rule Application Guidelines

### When to Apply These Rules
- **Always**: For all code, documentation, and configuration changes
- **Before Commits**: Run validation and check compliance
- **During Development**: Use as checklist for quality assurance
- **For New Contributors**: Provide as onboarding guide

### How to Use These Rules
1. **Read the reasoning**: Understand why each rule exists
2. **Apply consistently**: Use rules as checklist for all work
3. **Question and improve**: Suggest improvements to rules
4. **Document exceptions**: When rules don't apply, document why

### Rule Evolution
- Rules should evolve with project needs
- Regular review and updates based on experience
- Community input on rule effectiveness
- Clear process for rule changes

---

**Remember**: These rules exist to create the best possible learning experience for networking students while maintaining a professional, maintainable codebase. Every rule has a specific educational or technical purpose that supports the project's mission.
