#!/bin/bash

source ./create-monorepo.sh

rm -rf $base_base_dir $base_dir $base_dir_tests $env_folder __pycache__ .coverage .pytest_cache && rm $reqs $main $startup $dockerfile $setup_cfg $gitignore $dockerignore
rm app.py