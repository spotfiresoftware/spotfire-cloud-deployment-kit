# {{- define "spotfire-common.fluenbit-configuration.tsnm.forward.fluentbit.conf" -}}
[SERVICE]
    Daemon          off
    Flush           1
    Log_Level       warn
    Parsers_File    tsnm.parsers.fluentbit.conf

    # For monitoring
    # See https://docs.fluentbit.io/manual/administration/monitoring
    HTTP_Server     On
    HTTP_Listen     0.0.0.0
    HTTP_PORT       2020

    # For backpressure and buffering
    # see https://docs.fluentbit.io/manual/administration/buffering-and-storage
    # storage.path      /path/to/file/storage
    # storage.metrics   On

@INCLUDE tsnm.tail.fluentbit.conf
@INCLUDE tsnm.podannotations.fluentbit.conf

[OUTPUT]
    Name                forward
    Match               tsnm.*

    # For load balancing and failover
    # see https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/upstream-servers
    # Upstream          tss.upstream.fluentbit.conf

    # See above for buffering and backpressure
    # storage.type              filesystem
    # storage.total_limit_size  10M

    # For detailed information
    # see https://docs.fluentbit.io/manual/pipeline/outputs/forward
    Host                ${FLUENTBIT_FORWARD_HOST}
    Port                ${FLUENTBIT_FORWARD_PORT}
# {{- end -}}
