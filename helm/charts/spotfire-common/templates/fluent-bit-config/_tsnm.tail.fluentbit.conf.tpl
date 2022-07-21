# {{- define "spotfire-common.fluenbit-configuration.tsnm.tail.fluentbit.conf" -}}
#
# TSNM logs
#
[INPUT]
    Name                tail
    Alias               tsnm.nmlog
    Tag                 tsnm.nmlog

    Multiline           on
    Multiline_Flush     1
    Parser_Firstline    tsnm.standardlog

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}nm.log*
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

[INPUT]
    Name                tail
    Alias               tsnm.jettylog
    Tag                 tsnm.jettylog

    Multiline           on
    Multiline_Flush     1
    Parser_Firstline    tsnm.standardlog

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}jetty.log*
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

[INPUT]
    Name                tail
    Alias               tsnm.performancemonitoring
    Tag                 tsnm.performancemonitoring

    parser              tsnm.performancemonitoringlog

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}performance.monitoring.log*
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

[INPUT]
    Name                tail
    Alias               tsnm.servicestdout
    Tag                 tsnm.servicestdout

    parser              tsnm.servicestdout

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}service-*-stdout.log*
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

#
# Services logs
#
[INPUT]
    Name                tail
    Alias               tsnm.worker.serviceconfig
    Tag                 tsnm.worker.serviceconfig

    parser              tsnm.logline

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}ServiceConfig.*.txt
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

    Path_Key            LogFilePath

[FILTER]
    Name                parser
    Alias               tsnm.serviceconfig
    Match               tsnm.serviceconfig

    Reserve_Data        on
    Parser              filename.serviceid
    key_name            LogFilePath
    Preserve_Key        off


[INPUT]
    Name                tail
    Alias               tsnm.worker.debug
    Tag                 tsnm.worker.debug

    Multiline           on
    Multiline_Flush     1
    Parser_Firstline    worker.debuglog

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}Spotfire.Dxp.Worker.Host.Debug.*.log
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

[INPUT]
    Name                tail
    Alias               tsnm.worker.performancemonitoring
    Tag                 tsnm.worker.performancemonitoring

    parser              worker.performancemonitoring

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}PerformanceCounterLog.*.txt
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

[INPUT]
    Name                tail
    Alias               tsnm.worker.timings
    Tag                 tsnm.worker.timings

    parser              worker.timings

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}TimingLog.*.txt
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

[INPUT]
    Name                tail
    Alias               tsnm.worker.audit
    Tag                 tsnm.worker.audit

    parser              worker.audit

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}AuditLog.*.txt
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

[INPUT]
    Name                tail
    Alias               tsnm.datafunctionservices.terr
    Tag                 tsnm.datafunctionservices.terr

    Multiline           on
    Multiline_Flush     1
    Parser_Firstline    datafunctionservices.standardlog

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}terr-service*.log*
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB

[INPUT]
    Name                tail
    Alias               tsnm.datafunctionservices.python
    Tag                 tsnm.datafunctionservices.python

    Multiline           on
    Multiline_Flush     1
    Parser_Firstline    datafunctionservices.standardlog

    Path                ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}python-service*.log*
    Db                  ${TSNM_HOME}${FILE_SEPARATOR}logs${FILE_SEPARATOR}tsnm.fluentbit.db

    Read_from_Head      True
    Buffer_Max_Size     64KB
# {{- end -}}
