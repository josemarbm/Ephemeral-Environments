{{/*
Expand the name of the chart.
*/}}
{{- define "Ephemeral-Environments.name" -}}
{{- default (lower .Chart.Name) .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "Ephemeral-Environments.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "Ephemeral-Environments.labels" -}}
{{ include "Ephemeral-Environments.selectorLabels" . }}
helm.sh/chart: {{ include "Ephemeral-Environments.chart" . }}
app.kubernetes.io/version: {{ default .Chart.AppVersion .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "Ephemeral-Environments.selectorLabels" -}}
app: {{ include "Ephemeral-Environments.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "Ephemeral-Environments.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "Ephemeral-Environments.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
