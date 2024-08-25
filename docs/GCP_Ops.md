# Logging Agent Configuration

Logs are send to the GCP Logging service with the Ops Agent that is installed on the VM

Configuration for the agent can be found in `/etc/google-cloud-ops-agent/config.yaml`.

The agent is managed as a service by systemctl: `google-cloud-ops-agent-fluent-bit.service`

STDOUT and STDERR ogs from containers are written to `/var/lib/docker/containers/$CONTAINER_ID/$CONTAINER_ID.log` by the docker daemon.

To push these container logs to the GCP logging service the following config section needs to be added:

```
logging:
  receivers:
    medusa_docker:
      type: files
      include_paths: [/var/lib/docker/containers/*/*.log]
      record_log_file_path: true
      wildcard_refresh_interval: 10s
  processors:
    combined_log_extract:
      type: parse_regex
      regex: '^(?<remote_host>\S+) (?<identity>\S+) (?<remote_user>\S+) \[(?<time_local>[^\]]+)\] \\"(?<request>[^"]+)\\" (?<status>\S+) (?<bytes_sent>\S+) \\"(?<http_referer>[^"]+)\\" \\"(?<http_user_agent>[^"]+)\\"'
  service:
    pipelines:
      default_pipeline:
        receivers:
        - medusa_docker
        processors:
        - combined_log_extract

```

`record_log_file_path` is required as without it it would be hard to filter log entries by container.

Default logging config can be found [here](https://cloud.google.com/logging/docs/agent/ops-agent/configuration#default) and an example of file-based logging can be found [here](https://cloud.google.com/logging/docs/agent/ops-agent/configuration#logging-receiver-examples).

Field extraction is added to regex group matches using `?<field_name>` in each group


## TODO

- Parse timestamp with parse_json processor - need to find out which ISO time format Medusa uses
- Make it easier to filter by container name, not container ID
- Update logging so it captures the client IP that is being proxied by cloudflare