# {{- define "spotfire-common.fluenbit-configuration.tsnm.stdout.fluentbit.conf" -}}
[SERVICE]
    Daemon          off
    Flush           1
    Log_Level       debug
    Parsers_File    tsnm.parsers.fluentbit.conf
    HTTP_Server     On

@INCLUDE tsnm.tail.fluentbit.conf
@INCLUDE tsnm.podannotations.fluentbit.conf

[OUTPUT]
    Name                stdout
    Match               tsnm.*
# {{- end -}}
