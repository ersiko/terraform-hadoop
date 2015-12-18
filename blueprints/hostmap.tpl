{
  "blueprint" : "testclus",
  "default_password" : "{{ var_ambari_password }}",
  "host_groups" :[
    { 
      "name":"client_host_group",
      "hosts":[
{% for host in (resp_hosts.content|from_json)['items'] %}
{% if loop.index == loop.length %}
    {
      "name":"nn_host_group",
      "hosts":[{"fqdn":"{{ (host)['Hosts']['host_name'] }}"}]
    }
{% elif loop.index == loop.length -1 %}
    {
      "name":"hive_host_group",
      "hosts":[{"fqdn":"{{ (host)['Hosts']['host_name'] }}"}]
    },
{% elif loop.index == loop.length -2 %}
    {
      "name":"rm_host_group",
      "hosts":[{"fqdn":"{{ (host)['Hosts']['host_name'] }}"}]
    },
{% elif loop.index == loop.length -3 %}
      {"fqdn":"{{ (host)['Hosts']['host_name'] }}"}]
    },
{% elif loop.index < loop.length -3 %}
      {"fqdn":"{{ (host)['Hosts']['host_name'] }}"},
{% endif %}
{% endfor %}
  ]
}
