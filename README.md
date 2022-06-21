# aws-glue-packager

Utility script to package AWS Glue jobs

## Usage

Download the `package-glue-job.sh` script from GitHub and store it locally, then make it executable.

```sh
curl -O https://raw.githubusercontent.com/moneytree/aws-glue-packager/main/package-glue-job.sh
chmod +x package-glue-job.sh
```

Then invoke it with the path to your Glue script's entry point (the main .py file).
The name of the directory in which this .py file exists will be used as the Job name,
which only impacts the output folder's name.

```sh
./package-glue-job.sh ~/MyProject/glue-jobs/my-etl/main.py
```

The result will be contained inside a `./glue-dist/` directory.

## What does it package?

Given a main python file it will create a Wheel package file which contains the following:

- If a Pipfile is present in the main .py file's directory, its dependencies.
- Other .py files from the main .py file's directory.
- Any packages discoverable by [setuptools find_namespace_packages](https://setuptools.pypa.io/en/latest/userguide/package_discovery.html#finding-namespace-packages) from the main .py file's directory.

The Wheel package will have a filename like `deps-1.0-py3-none-any.whl`. This name will vary depending on the Python version
and platforms your dependencies support.


## Using the Wheel package in your AWS Glue job

To use the package first upload it to S3. Then include the S3 object URI as a parameter to your Glue job.
The parameter is different depending on the type of Glue job this is.

* If the job type is `pythonshell`, use `--extra-py-files`.
* If the job type is `glueetl`, use `--additional-python-modules`.

## Disclaimer

This has been tested on macOS. Your mileage may vary.
