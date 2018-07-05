# gcloud-config-gen

Generate config from gcloud instance data, in a loop

Will get data from `gcloud compute instances describe`, run it through a jinja2 template, sleep 60 seconds, and repeat. Optionally, if it causes the output file to change, send a HUP signal to another container


## Example

haproxy.jinja2:

```jinja2
...
backend web
...
{%  for inst in instances %}
  server web_{{ inst.name }} {{ inst.networkInterfaces[0].networkIP }}:80 check
{% endfor %}
```

docker-compose.yml:

```yaml
...
  haproxy-config-gen:
    restart: always
    image: nafg/gcloud-config-gen

    volumes:

      # Mount the docker socket if you want to send a HUP signal to another container
      - /var/run/docker.sock:/var/run/docker.sock

      # Mount the template file

      - ./haproxy.jinja2:/haproxy.jinja2
      # Mount the output file (also mount it in another container if desired)
      - ./haproxy.cfg:/haproxy.cfg

    environment:
      # Command to output instance URIs
      GET_INSTANCES: 'gcloud compute instance-groups managed list-instances app --zone us-east1-b --filter=currentAction=NONE --format="get(instance)"'

      # Template file
      SRC: /haproxy.jinja2

      # Output file
      TARGET: /haproxy.cfg

      # If specified, whenever the contents (via md5 hash) of $TARGET are changed, send a HUP signal to this container
      CONTAINER_NAME: haproxy
```
