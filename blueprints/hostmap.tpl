{
  "blueprint" : "testclus",
  "default_password" : "admin",
  "host_groups" :[
    { 
      "name":"client_host_group",
      "hosts":[
        {"fqdn":"{{ (resp_hosts.content|from_json)['items'].0['Hosts']['host_name'] }}"},
        {"fqdn":"{{ (resp_hosts.content|from_json)['items'].1['Hosts']['host_name'] }}"},
        {"fqdn":"{{ (resp_hosts.content|from_json)['items'].2['Hosts']['host_name'] }}"}]
    },
    {
      "name":"nn_host_group",
      "hosts":[{"fqdn":"{{ (resp_hosts.content|from_json)['items'].3['Hosts']['host_name'] }}"}]
    },
    {
      "name":"hive_host_group",
      "hosts":[{"fqdn":"{{ (resp_hosts.content|from_json)['items'].4['Hosts']['host_name'] }}"}]
    },
    {
      "name":"rm_host_group",
      "hosts":[{"fqdn":"{{ (resp_hosts.content|from_json)['items'].5['Hosts']['host_name'] }}"}]
    }
  ]
}
