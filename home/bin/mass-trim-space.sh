#!/bin/bash
find $1 -name "*.py" -exec sed -i -e 's/[ \t]*$//' {} \;
