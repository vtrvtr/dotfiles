#!/usr/bin/env python3
"""Test file to check Pyrefly diagnostics"""

def add(a, b):
    """Add two numbers"""
    # This should trigger a type checking diagnostic if strict mode is enabled
    return a + b

def main():
    # Intentional type error - passing string to a function expecting numbers
    result = add("hello", 5)

    # Undefined variable - should trigger diagnostic
    print(undefined_variable)

    # Missing return type annotation
    value = get_value()

if __name__ == "__main__":
    main()