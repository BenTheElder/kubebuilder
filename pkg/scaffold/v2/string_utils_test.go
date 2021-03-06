/*
Copyright 2019 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package v2

import (
	"bytes"
	"io/ioutil"
	"testing"
)

type insertStrTest struct {
	input    string
	marker   string
	str      string
	expected string
	got      string
}

func TestInsertStrBelowMarker(t *testing.T) {

	tests := []insertStrTest{
		{
			input: `
v1beta1.AddToScheme(scheme)
// +kubebuilder:scaffold:apis-add-scheme
`,
			marker: "+kubebuilder:scaffold:apis-add-scheme",
			str:    "v1.AddToScheme(scheme)\n",
			expected: `
v1beta1.AddToScheme(scheme)
v1.AddToScheme(scheme)
// +kubebuilder:scaffold:apis-add-scheme
`,
		},
		{
			// string with literal format
			input: `
v1beta1.AddToScheme(scheme)
// +kubebuilder:scaffold:apis-add-scheme
`,
			marker: "+kubebuilder:scaffold:apis-add-scheme",
			str: `v1.AddToScheme(scheme)
`,
			expected: `
v1beta1.AddToScheme(scheme)
v1.AddToScheme(scheme)
// +kubebuilder:scaffold:apis-add-scheme
`,
		},
	}

	for _, test := range tests {
		result, err := insertStrings(bytes.NewBufferString(test.input), test.marker, test.str)
		if err != nil {
			t.Errorf("error %v", err)
		}

		b, err := ioutil.ReadAll(result)
		if err != nil {
			t.Errorf("error: %v", err)
		}

		if string(b) != test.expected {
			t.Errorf("got: %s and wanted: %s", string(b), test.expected)
		}
	}

}
