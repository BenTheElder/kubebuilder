#!/usr/bin/env bash
# Copyright 2018 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

source common.sh

function test_init_project {
  header_text "performing init project"
  kubebuilder init --domain example.com <<< "n"
}

function test_make_project {
  header_text "running make in project"
  make
}

function test_create_api_controller {
  header_text "performing creating api and controller"
  kubebuilder create api --group insect --version v1beta1 --kind Bee --namespaced false <<EOF
y
y
EOF
}

function test_create_namespaced_api_controller {
  header_text "performing creating namespaced api and controller"
  kubebuilder create api --group insect --version v1beta1 --kind Bee --namespaced true <<EOF
y
y
EOF
}

function test_create_api_only {
  header_text "performing creating api only"
  kubebuilder create api --group insect --version v1beta1 --kind Bee --namespaced false <<EOF
y
n
EOF
}

function test_create_namespaced_api_only {
  header_text "performing creating api only"
  kubebuilder create api --group insect --version v1beta1 --kind Bee --namespaced true <<EOF
y
n
EOF
}

function test_create_skip {
  header_text "performing creating but skipping everything"
  kubebuilder create api --group insect --version v1beta1 --kind Bee <<EOF
n
n
EOF
}

function test_create_coretype_controller {
  header_text "performing creating coretype controller"
  kubebuilder create api --group apps --version v1 --kind Deployment --namespaced false <<EOF
n
y
EOF
}

function test_create_namespaced_coretype_controller {
  header_text "performing creating coretype controller"
  kubebuilder create api --group apps --version v1 --kind Deployment --namespaced true <<EOF
n
y
EOF
}

function test_project {
  project_dir=$1
  version=$2
  header_text "performing tests in dir $project_dir for project version v$version"
  cd test/$project_dir
  tar -zxf ../vendor.v$version.tgz
  make
  rm -rf ./vendor && rm -f Gopkg.lock
  cd -
}

prepare_staging_dir
fetch_tools
build_kb

setup_envs

prepare_testdir_under_gopath
test_init_project
cache_project

prepare_testdir_under_gopath
dump_project
test_make_project

prepare_testdir_under_gopath
dump_project
test_create_api_controller

prepare_testdir_under_gopath
dump_project
test_create_namespaced_api_controller

prepare_testdir_under_gopath
dump_project
test_create_api_only

prepare_testdir_under_gopath
dump_project
test_create_namespaced_api_only

prepare_testdir_under_gopath
dump_project
test_create_coretype_controller

prepare_testdir_under_gopath
dump_project
test_create_namespaced_coretype_controller

cd ${go_workspace}/src/sigs.k8s.io/kubebuilder

go test ./cmd/... ./pkg/...

# test project v1
test_project project 1

# test project v2
test_project project_v2 2

exit $rc
