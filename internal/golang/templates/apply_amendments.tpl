

{{- define "ApplyAmendmentField" -}}
    {{- if .IsList }}
        switch operation {
        case 0: // Modify
            if len(fip) != 2 { // includes list index
                return fmt.Errorf("Amendment field index path incorrect depth for modify {{ .Name }} : %v",
                    fip)
            }
            if int(fip[1]) >= len(a.{{ .Name }}) {
                return fmt.Errorf("Amendment element index out of range for modify {{ .Name }} : %d", fip[1])
            }

            {{- if .IsCompoundType }}
            a.{{ .Name }}[fip[1]].Reset()
            return a.{{ .Name }}[fip[1]].ApplyAmendment(fip[2:], operation, data)
            {{- else if eq .BaseType "fixedchar" "varchar" }}
            a.{{ .Name }}[fip[1]] = string(data)
            {{- else if eq .BaseType "bin" }}
            if len(data) != {{ .Size }} {
                return fmt.Errorf("bin size wrong : got %d, want %d", len(data), {{ .Size }})
            }
            copy(a.{{ .Name }}[fip[1]], data)
            {{- else if eq .BaseType "varbin" }}
            a.{{ .Name }}[fip[1]] = data
            {{- else if eq .BaseType "uint" }}
            if len(fip) > 1 {
                return fmt.Errorf("Amendment field index path too deep for {{ .Name }} : %v", fip)
            }
            if len(data) != {{ .BaseSize }} {
                return fmt.Errorf("{{ .Name }} amendment value is wrong size : %d", len(data))
            }
            buf := bytes.NewBuffer(data)
            if err := binary.Read(buf, binary.LittleEndian, &a.{{ .Name }}[fip[1]]); err != nil {
                return fmt.Errorf("{{ .Name }} amendment value failed to deserialize : %s", err)
            }
            {{- else if eq .BaseType "bool" }}
			if len(fip) > 1 {
				return fmt.Errorf("Amendment field index path too deep for {{ .Name }} : %v", fip)
			}
			if len(data) != 1 {
				return fmt.Errorf("{{ .Name }} amendment value is wrong size : %d", len(data))
			}
			buf := bytes.NewBuffer(data)
			if err := binary.Read(buf, binary.LittleEndian, &a.{{ .Name }}[fip[1]]); err != nil {
				return fmt.Errorf("{{ .Name }} amendment value failed to deserialize : %s", err)
			}
            {{- end }}

        case 1: // Add element
            if len(fip) > 1 {
                return fmt.Errorf("Amendment field index path too deep for add {{ .Name }} : %v",
                    fip)
            }

            {{- if .IsCompoundType }}
            newValue := &{{ .GoSingularType }}{}
            if len(data) != 0 { // Leave default values if data is empty
                if err := proto.Unmarshal(data, newValue); err != nil {
                    return fmt.Errorf("Amendment addition to {{ .Name }} failed to deserialize : %s",
                        err)
                }
            }
            {{- else if eq .BaseType "fixedchar" "varchar" }}
            newValue := string(data)
            {{- else if eq .BaseType "bin" }}
            if len(data) != {{ .Size }} {
                return fmt.Errorf("bin size wrong : got %d, want %d", len(data), {{ .Size }})
            }
            var newValue [{{ .BaseSize }}]byte
            copy(newValue, data)
            a.{{ .Name }} = append(a.{{ .Name }}, newValue)
            {{- else if eq .BaseType "varbin" }}
            newValue := data
            {{- else if eq .BaseType "uint" "bool" }}
            if len(fip) > 1 {
                return fmt.Errorf("Amendment field index path too deep for {{ .Name }} : %v", fip)
            }
            if len(data) != {{ .BaseSize }} {
                return fmt.Errorf("{{ .Name }} amendment value is wrong size : %d", len(data))
            }
            buf := bytes.NewBuffer(data)
            var newValue {{ .GoSingularType }}
            if err := binary.Read(buf, binary.LittleEndian, &newValue); err != nil {
                return fmt.Errorf("{{ .Name }} amendment value failed to deserialize : %s", err)
            }
            {{- end }}
            a.{{ .Name }} = append(a.{{ .Name }}, newValue)

        case 2: // Delete element
            if len(fip) != 2 { // includes list index
                return fmt.Errorf("Amendment field index path incorrect depth for delete {{ .Name }} : %v",
                    fip)
            }
            if int(fip[1]) >= len(a.{{ .Name }}) {
                return fmt.Errorf("Amendment element index out of range for delete {{ .Name }} : %d", fip[1])
            }

            // Remove item from list
            a.{{ .Name }} = append(a.{{ .Name }}[:fip[1]], a.{{ .Name }}[fip[1]+1:]...)
        }
    {{- else }}
        {{- if gt (len .BaseResource) 0 }}
        if {{ .BaseResource }}Data(a.{{ .Name }}) == nil {
            return fmt.Errorf("{{ .BaseResource }} resource value not defined : %v", a.{{ .Name }})
        }
        {{- end }}
        {{- if .IsCompoundType }}
        return a.{{ .Name }}.ApplyAmendment(fip[1:], operation, data)
        {{- else if eq .BaseType "fixedchar" "varchar" }}
        a.{{ .Name }} = string(data)
        {{- else if eq .BaseType "bin" }}
        if len(data) != {{ .Size }} {
            return fmt.Errorf("bin size wrong : got %d, want %d", len(data), {{ .Size }})
        }
        copy(a.{{ .Name }}, data)
        {{- else if eq .BaseType "varbin" }}
        a.{{ .Name }} = data
        {{- else if eq .BaseType "uint" }}
        if len(fip) > 1 {
            return fmt.Errorf("Amendment field index path too deep for {{ .Name }} : %v", fip)
        }
        if len(data) != {{ .BaseSize }} {
            return fmt.Errorf("{{ .Name }} amendment value is wrong size : %d", len(data))
        }
        buf := bytes.NewBuffer(data)
        if err := binary.Read(buf, binary.LittleEndian, &a.{{ .Name }}); err != nil {
            return fmt.Errorf("{{ .Name }} amendment value failed to deserialize : %s", err)
        }
        {{- else if eq .BaseType "bool" }}
        if len(fip) > 1 {
            return fmt.Errorf("Amendment field index path too deep for {{ .Name }} : %v", fip)
        }
        if len(data) != 1 {
            return fmt.Errorf("{{ .Name }} amendment value is wrong size : %d", len(data))
        }
        buf := bytes.NewBuffer(data)
        if err := binary.Read(buf, binary.LittleEndian, &a.{{ .Name }}); err != nil {
            return fmt.Errorf("{{ .Name }} amendment value failed to deserialize : %s", err)
        }
        {{- end }}
    {{- end }}
{{- end }}
