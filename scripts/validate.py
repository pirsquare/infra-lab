#!/usr/bin/env python3
"""Helper script to validate app configuration."""

import sys
import json

def validate_config():
    """Validate that all required environment variables are set."""
    import os
    
    required_vars = ["PYTHONUNBUFFERED", "PYTHONDONTWRITEBYTECODE"]
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if not missing_vars:
        print("✓ All configuration checks passed")
        return True
    
    print("✗ Configuration validation failed:")
    for var in missing_vars:
        print(f"  - Missing: {var}")
    return False

if __name__ == "__main__":
    sys.exit(0 if validate_config() else 1)
