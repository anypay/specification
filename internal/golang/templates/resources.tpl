package protocol

import (
	"github.com/pkg/errors"
	yaml "gopkg.in/yaml.v2"
)

type CurrencyType struct {
	Name              string
	Label             string
	Symbol            string
	Fractions         uint64
	FractionalUnit    string `yaml:"fractional_unit"`
	Polity            string
	MonetaryAuthority string `yaml:"monetary_authority"`
}

var currencies map[string]CurrencyType

func GetCurrencies() (map[string]CurrencyType, error) {
	if currencies != nil {
		return currencies, nil
	}

	load := struct {
		Values map[string]CurrencyType
	}{}

	if err := yaml.Unmarshal([]byte(yamlCurrencies), &load); err != nil {
		return nil, errors.Wrap(err, "Failed to unmarshal currencies yaml")
	}

	currencies = load.Values
	return currencies, nil
}

type EntityType struct {
	Name              string
	Label             string
	Symbol            string
}

var entities map[string]EntityType

func GetEntities() (map[string]EntityType, error) {
	if entities != nil {
		return entities, nil
	}

	load := struct {
		Values map[string]EntityType
	}{}

	if err := yaml.Unmarshal([]byte(yamlEntities), &load); err != nil {
		return nil, errors.Wrap(err, "Failed to unmarshal entities yaml")
	}

	entities = load.Values
	return entities, nil
}

type Polity struct {
	Name          string
	States        map[string]string
	Flag          string
	FiscalYear    string `yaml:"fractional_unit"`
	GovFiscalYear string `yaml:"gov_fiscal_year"`
}

var polities map[string]Polity

func GetPolities() (map[string]Polity, error) {
	if polities != nil {
		return polities, nil
	}

	load := struct {
		Values map[string]Polity
	}{}

	if err := yaml.Unmarshal([]byte(yamlPolities), &load); err != nil {
		return nil, errors.Wrap(err, "Failed to unmarshal polities yaml")
	}

	polities = load.Values
	return polities, nil
}

type MessageType struct {
	Name string
}

var messages map[uint16]MessageType

func GetMessages() (map[uint16]MessageType, error) {
	if messages != nil {
		return messages, nil
	}

	load := struct {
		Values map[uint16]MessageType
	}{}

	if err := yaml.Unmarshal([]byte(yamlMessages), &load); err != nil {
		return nil, errors.Wrap(err, "Failed to unmarshal messages yaml")
	}

	messages = load.Values
	return messages, nil
}

type RoleType struct {
	Name string
}

var roles map[uint8]RoleType

func GetRoles() (map[uint8]RoleType, error) {
	if roles != nil {
		return roles, nil
	}

	load := struct {
		Values map[uint8]RoleType
	}{}

	if err := yaml.Unmarshal([]byte(yamlRoles), &load); err != nil {
		return nil, errors.Wrap(err, "Failed to unmarshal roles yaml")
	}

	roles = load.Values
	return roles, nil
}

{{range .}}
{{comment (print .Name " - " .Metadata.Description) "//"}}
var yaml{{ .Name }} = `
{{ .Data }}
`
{{ end }}