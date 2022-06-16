# aws-glue-packager

Utility script to package AWS Glue jobs

# Usage

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

# Disclaimer

This has been tested on macOS. Your mileage may vary.
