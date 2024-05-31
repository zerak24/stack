{{- define "app.kongpluginingress" -}}
{{- $fullname := $.Values.general.fullName }}
{{- $kongplugins := list -}}
{{- $finalRoutes := $.Values.kongIngress.routeMap }}
{{- range $finalRoutes -}}
{{- range .plugins -}}
{{- $kongplugins = printf "%s-%s-%s" $fullname . "cors-plugin" | append $kongplugins -}}
{{- end -}}
{{- end -}}
{{- join "," $kongplugins }}
{{- end -}}
