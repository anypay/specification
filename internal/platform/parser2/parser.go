package parser2

import (
	"fmt"
	"html/template"
	"os"
	"path"
	"path/filepath"

	"github.com/pkg/errors"
	"gopkg.in/yaml.v2"
)

// NewSchema creates a Schema from a directory.
func NewSchema(path string) (*Schema, error) {

	// 1. Resulting Schema
	schemaFilePath := filepath.Join(path, "schema.yaml")
	var result Schema
	if err := unmarshalFile(schemaFilePath, &result); err != nil {
		return nil, err
	}

	// 2. Schema Messages
	var messages []Message
	for _, spath := range result.MessagePaths {
		messageFilePath := filepath.Join(path, spath+".yaml")
		var message Message
		unmarshalFile(messageFilePath, &message)
		postProcessFields(message.Fields, result.FieldAliases)
		messages = append(messages, message)
	}
	result.Messages = messages

	// 3. Schema Field Types
	var fieldTypes []FieldType
	for _, spath := range result.FieldTypePaths {
		typeFilePath := filepath.Join(path, spath+".yaml")
		var fieldType FieldType
		unmarshalFile(typeFilePath, &fieldType)
		postProcessFields(fieldType.Fields, result.FieldAliases)
		fieldTypes = append(fieldTypes, fieldType)
	}
	result.FieldTypes = fieldTypes

	return &result, nil
}

// postProcessFields applies defaults, attaches alias information and detects compound fields.
func postProcessFields(fields []Field, aliases []Field) {
	for i, field := range fields {
		if field.IsList() && field.Size == 0 {
			fields[i].Size = 1
		}
		for _, alias := range aliases {
			if alias.Name == field.Type {
				fields[i].IsAlias = true
				fields[i].AliasField = &alias
				break
			}
		}
		if !field.IsPrimitive() {
			fields[i].IsCompoundType = true
		}
	}
}

// unmarshalFile
func unmarshalFile(filename string, v interface{}) error {
	file, err := os.Open(filename)
	if err != nil {
		return errors.Wrap(err, fmt.Sprintf("Failed to open file %s", filename))
	}

	// Decode message from yaml
	decoder := yaml.NewDecoder(file)

	if err := decoder.Decode(v); err != nil {
		return errors.Wrap(err, fmt.Sprintf("Failed to yaml unmarshal file %s", filename))
	}

	return nil
}

// TemplateToFile renders a template to a file
func TemplateToFile(distPath string, data interface{}, inFile, outFile string) {
	f, err := os.Create(outFile)
	if err != nil {
		panic(err)
	}

	tmplFuncs := MakeTemplateFuncs()

	tmpl := template.Must(template.New(path.Base(inFile)).Funcs(tmplFuncs).ParseFiles(inFile))

	if err := tmpl.Execute(f, data); err != nil {
		panic(err)
	}
}
