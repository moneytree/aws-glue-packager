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
rm -rf "$DIST_PATH/.workspace/*"

# Copy src to workspace and move to workspace

rsync -a -L "$JOB_DIR/" "$DIST_PATH/.workspace/"
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
    pip install -q -r requirements.txt --no-deps -t .
else
    echo "No Pipfile found, assuming no external dependencies are being used."
fi

# Create Wheel Package

echo "* Creting setup.py file"
cat >setup.py <<EOL
from setuptools import setup, find_namespace_packages
import glob, os

# The the current filename without the extension.
def get_current_py_module():
    current_file_name = os.path.basename(__file__)
    return os.path.splitext(current_file_name)[0]


# Returns the filename of other .py files in the current directory without the extensions.
def find_py_modules():
    cwd = os.getcwd()
    file_paths = glob.glob(cwd + "/*.py")
    file_names = [os.path.basename(file_path) for file_path in file_paths]
    py_modules = [os.path.splitext(file_name)[0] for file_name in file_names]
    py_modules.remove(get_current_py_module())
    return py_modules

setup(
    name="deps",
    version="1.0",
    packages=find_namespace_packages(),
    py_modules=find_py_modules(),
)
EOL

echo "* Performing wheel setup"
python setup.py bdist_wheel
echo "* Moving wheel files out of workspace"
mv dist/* ..

# Cleanup

popd > /dev/null # out of workspace

rm -rf .workspace

# Done

popd > /dev/null # out of $DIST_PATH

echo
echo "Packaging completed:"
echo
ls -1 $DIST_PATH/*
echo
echo "You should now upload all files in $DIST_PATH to S3"
echo
