#!/usr/bin/env python
## --global-option=build_ext --global-option="--slurm=/usr/slurm/"
from setuptools import setup, find_packages, find_namespace_packages
from subprocess import run
from distutils.command.build import build
import os


class CustomBuild(build):
    def run(self):
        generate_cwl()
        super().run()


def generate_cwl():
    with open(
        os.path.join(
            os.path.dirname(__file__),
            "bulkrnaseq/static_files/cwl_files/bcl2fastq_transform.cwl",
        ),
        "w",
    ) as outfile:
        run(
            [
                "cwltool",
                "--pack",
                os.path.join(
                    os.path.dirname(os.path.dirname(__file__)),
                    "bcl_fastq/transform.cwl",
                ),
            ],
            stdout=outfile,
            check=True,
        )
    with open(
        os.path.join(
            os.path.dirname(__file__),
            "bulkrnaseq/static_files/cwl_files/joint_variantcall.cwl",
        ),
        "w",
    ) as outfile:
        run(
            [
                "cwltool",
                "--pack",
                os.path.join(
                    os.path.dirname(os.path.dirname(__file__)),
                    "bulkrnaseq/subworkflows/jointvariantcall.cwl",
                ),
            ],
            stdout=outfile,
            check=True,
        )
    with open(
        os.path.join(
            os.path.dirname(__file__),
            "bulkrnaseq/static_files/cwl_files/star_align_transform.cwl",
        ),
        "w",
    ) as outfile:
        run(
            [
                "cwltool",
                "--pack",
                os.path.join(
                    os.path.dirname(os.path.dirname(__file__)),
                    "star_align/transform.cwl",
                ),
            ],
            stdout=outfile,
            check=True,
        )
    with open(
        os.path.join(
            os.path.dirname(__file__),
            "bulkrnaseq/static_files/cwl_files/generate_star_etl.cwl",
        ),
        "w",
    ) as outfile:
        run(
            [
                "cwltool",
                "--pack",
                os.path.join(
                    os.path.dirname(os.path.dirname(__file__)),
                    "generate_star_genome/etl.cwl",
                ),
            ],
            stdout=outfile,
            check=True,
        )
    with open(
        os.path.join(
            os.path.dirname(__file__), "bulkrnaseq/static_files/cwl_files/metrics.cwl"
        ),
        "w",
    ) as outfile:
        run(
            [
                "cwltool",
                "--pack",
                os.path.join(
                    os.path.dirname(os.path.dirname(__file__)),
                    "bulkrnaseq/subworkflows/metrics.cwl",
                ),
            ],
            stdout=outfile,
            check=True,
        )


setup(
    name="bulkrnaseq",
    author="Jeremiah H. Savage, Jifeng Qian",
    description="run an rna-seq project",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
    ],
    include_package_data=True,
    entry_points={"console_scripts": ["bulkrnaseq=bulkrnaseq.__main__:main"]},
    setuptools_git_versioning={
        "enabled": True,
    },
    setup_requires=["setuptools-git-versioning<2"],
    cmdclass={"build": CustomBuild},
)
