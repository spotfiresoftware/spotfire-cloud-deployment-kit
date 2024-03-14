# {{- define "spotfire-common.fluenbit-configuration.tsnm.parsers.fluentbit.conf" -}}
[PARSER]
    Name           tsnm.standardlog
    Format         regex

    Regex          /^(?<Level>\S+) (?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3}(\+|-)\d{4}) \[(?<ThreadInfo>[^\]]*)\] (?<Logger>[^:]+): (?<Message>.*)/

    Time_Key       Timestamp
    Time_Format    %Y-%m-%dT%H:%M:%S,%L%z

[PARSER]
    Name           tsnm.performancemonitoringlog
    Format         regex

    Regex          /^(?<ServerName>[^;]*);(?<ServerId>[^;]*);(?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3}(\+|-)\d{4});(?<CounterCategory>[^;]*);(?<CounterName>[^;]*);(?<CounterInstance>[^;]*);(?<Value>.*)$/

    Time_Key       Timestamp
    Time_Format    %Y-%m-%dT%H:%M:%S,%L%z

    Types          Value:float

[PARSER]
    Name           tsnm.servicestdout
    Format         regex

    Regex          /^(?<Level>\S+) (?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3}(\+|-)\d{4}) \[(?<ThreadInfo>[^\]]*)\] (?<ServiceId>\S+): (?<Message>.*)/

    Time_Key       Timestamp
    Time_Format    %Y-%m-%dT%H:%M:%S,%L%z

[PARSER]
    Name            tsnm.logline
    Format          regex

    Regex           /^(?<Message>.*)/

[PARSER]
    Name            filename.serviceid
    Format          regex

    Regex           /(?<ServiceId>[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}).*(log|txt).*/

[PARSER]
    Name            worker.debuglog
    Format          regex

    Regex           /^(?<Level>[^;]+);(?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3}[^;]+);(?<UtcTimestampString>\d{4}-\d{2}-\d{2}\s*\d{2}:\d{2}:\d{2},\d{3});(?<ServiceId>[^;]*);(?<InstanceId>[^;]*);(?<Thread>[^;]*);(((?<User>.+) (?<WAT>WAT \d+))|(?<User>[^;]*));((?<SessionId>[^;]*);){0,1}(?<Logger>[^;]*);"(?<Message>.+)/

    Time_Key       Timestamp
    Time_Format    %Y-%m-%dT%H:%M:%S,%L%z

[PARSER]
    Name            worker.performancemonitoring
    Format          regex

    Regex           /^(?<Level>[^;]+);(?<HostName>[^;]+);(?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3}[^;]+);(?<UtcTimestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3});(?<CounterCategory>[^;]*);(?<CounterName>[^;]*);(?<CounterInstance>[^;]*);(?<Value>[^;]*);(?<InstanceId>[^;]*);(?<ServiceId>.*)$/

    Time_Key        Timestamp
    Time_Format     %Y-%m-%dT%H:%M:%S,%L%z
    Types           Value:float

[PARSER]
    Name            worker.timings
    Format          regex

    Regex           /^(?<Level>[^;]+);(?<HostName>[^;]+);(?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3}[^;]+);(?<UtcTimestampString>\d{4}-\d{2}-\d{2}\s*\d{2}:\d{2}:\d{2},\d{3});(?<EndTimeString>\d{4}-\d{2}-\d{2}\s*\d{2}:\d{2}:\d{2},\d{3});(?<Duration>[^;]+);(?<SessionId>[^;]*);(?<IPAddress>[^;]*);(?<UserName>[^;]*);(?<Operation>[^;]*);(?<AnalysisId>[^;]*);(?<Argument>[^;]*);(?<Status>[^;]*);(?<InstanceId>[^;]*);(?<ServiceId>.*)$/

    Time_Key        Timestamp
    Time_Format     %Y-%m-%dT%H:%M:%S,%L%z
    Types           Duration:float

[PARSER]
    Name            worker.audit
    Format          regex

    Regex           /^(?<Level>[^;]+);(?<HostName>[^;]*);(?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3}[^;]+);(?<UtcTimestampString>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3});(?<SessionId>[^;]*);(?<IPAddress>[^;]*);(?<UserName>[^;]*);(?<Operation>[^;]*);(?<AnalysisId>[^;]*);(?<Argument>[^;]*);(?<Status>[^;]*);(?<InstanceId>[^;]*);(?<ServiceId>[^;]*)$/

    Time_Key        Timestamp
    Time_Format     %Y-%m-%dT%H:%M:%S,%L%z

[PARSER]
    Name           datafunctionservices.standardlog
    Format         regex

    Regex          /^(?<Level>\S+) (?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3}\s{0,1}(\+|-)\d{4}) \[(?<ThreadInfo>[^\]]*)\] (?<Logger>[^:]+): (?<Message>.*)/

    Time_Key       Timestamp
    Time_Format    %Y-%m-%dT%H:%M:%S,%L%z
# {{- end -}}
