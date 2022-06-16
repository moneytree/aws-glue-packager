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

rsync -a -L "$JOB_DIR/" "$DIST_PATH/.workspace/"
pushd "$DIST_PATH" > /dev/null
pushd ".workspace" > /dev/null

# Move main job file

echo "* Copying $JOB_SCRIPT as-is"
mv "$JOB_SCRIPT" ..

# Copy other Python files to deps.zip

OTHER_PY_FILES=$(find  -L . -name '*.py')

if [[ -n "$OTHER_PY_FILES" ]]
then
    echo "* Archiving other .py files into deps.zip"

    zip -q -r -9 deps.zip $OTHER_PY_FILES
    mv deps.zip ..
else
    echo "No other .py files found for packaging."
fi

# Copy external dependencies to packages.zip

if [[ -f Pipfile ]]
then
    echo "* Archiving external dependencies into packages.zip"

    echo "Creating requirements.txt"
    pipenv requirements > requirements.txt

    echo "Installing dependencies..."
    mkdir packages
    pip install -q -r requirements.txt --no-deps -t packages

    pushd packages > /dev/null

    # clean up artifacts
    find . -type d -name __pycache__ -exec rm -rf "{}" \+
    rm -rf *.dist-info

    # compress to zip
    zip -q -r -9 packages.zip *
    mv packages.zip ../..

    popd > /dev/null # out of packages
else
    echo "No Pipfile found, assuming no external dependencies are being used."
fi

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
