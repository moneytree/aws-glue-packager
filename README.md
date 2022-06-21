# aws-glue-packager

Utility script to package AWS Glue jobs

## Usage

Download the `package-glue-job.sh` script from GitHub and store it locally, then make it executable.

```sh
curl -O https://raw.githubusercontent.com/moneytree/aws-glue-packager/main/package-glue-job.sh
chmod +x package-glue-job.sh
```

Then invoke it with the path to your Glue script's entry point (the initial .py file).
The name of the directory in which this .py file exists will be used as the Job name,
which only impacts the output folder's name.

```sh
./package-glue-job.sh ~/MyProject/glue-jobs/my-etl/main.py
```

The result will be contained inside a `./glue-dist/` directory.

## What does it package?

Given a main python file it will create a wheel file which contain the following:
- Pipfile dependencies from a Pipfile in the same directory as the main file.
- Other python files in the same directory as the main file.
- Any packages discoverable by [setuptools find_namespace_packages](https://setuptools.pypa.io/en/latest/userguide/package_discovery.html#finding-namespace-packages) from the same directory as the main file.

Afterwards it will create a wheel file with a name like `deps-1.0-py3-none-any.whl`, but this name may vary depending on the python version and platforms the dependencies support.


## Using wheel packages in AWS Glue jobs
To use the package first upload it to S3. Then include the s3 url as a parameter to your glue job.
The parameter is different depending on if the job is a python shell or a glue ETL job.

**Python Shell Parameter:** `--extra-py-files`

**Glue ETL Parameter:** `--additional-python-modules`

## Disclaimer

This has been tested on macOS. Your mileage may vary.
