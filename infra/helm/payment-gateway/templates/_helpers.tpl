
{{- define "payment-gateway.name" -}}payment-gateway{{- end -}}
{{- define "payment-gateway.fullname" -}}{{ include "payment-gateway.name" . }}-{{ .Release.Name }}{{- end -}}
