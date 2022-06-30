#!/bin/bash

FULL_JOB_PATH=$1

if [[ "$FULL_JOB_PATH" != *.py ]]
then
    echo "Expected job-path to end with .py"
    exit 1
fi

JOB_DIR=$(dirname "$FULL_JOB_PATH")
JOB_NAME=$(basename "$JOB_DIR")
JOB_SCRIPT=$(basename "$FULL_JOB_PATH")
DIST_PATH="./glue-dist/$JOB_NAME"

echo
echo "Job located at: $JOB_DIR"
echo "Job name: $JOB_NAME"
echo "Entry point: $JOB_SCRIPT"
echo "Output path: $DIST_PATH"
echo

# Prep

rm -rf "$DIST_PATH"
mkdir -p "$DIST_PATH/.workspace"

# Copy src to workspace and move to workspace

echo "* Copying source files from $JOB_DIR to $DIST_PATH/.workspace"

cp -LR "$JOB_DIR/." "$DIST_PATH/.workspace/"

pushd "$DIST_PATH" > /dev/null
pushd ".workspace" > /dev/null

# Move main job file

echo "* Copying $JOB_SCRIPT as-is"

mv "$JOB_SCRIPT" ..

# Download external dependencies

if [[ -f Pipfile ]]
then
    echo "* Downloading external dependencies"

    echo "Creating requirements.txt"
    pipenv requirements > requirements.txt

    echo "Installing dependencies..."
    python -m pip install -q -r requirements.txt --no-deps -t .
else
    echo "No Pipfile found, assuming no external dependencies are being used."
fi

# Create Wheel Package

echo "* Creating Wheel package"

read -r -d '' CMD <<EOF
from setuptools import setup, find_namespace_packages
from glob import glob
from os.path import basename, splitext

# Returns the filename of all .py files in the current directory without their extensions.
def find_py_modules():
    file_paths = glob("*.py")
    file_names = [basename(file_path) for file_path in file_paths]
    py_modules = [splitext(file_name)[0] for file_name in file_names]
    return py_modules

setup(
    name="deps",
    version="1.0",
    packages=find_namespace_packages(),
    py_modules=find_py_modules(),
    setup_requires=['wheel'],
)
EOF

python -c "$CMD" -q bdist_wheel --dist-dir .. || exit 2

# Cleanup

popd > /dev/null # out of workspace

rm -rf .workspace

# Done

popd > /dev/null # out of $DIST_PATH

echo
echo "Packaging completed:"
echo
ls -1 "$DIST_PATH"/*
echo
echo "You should now upload all files in $DIST_PATH to S3"
echo
