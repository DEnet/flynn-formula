{% from "flynn/map.jinja" import flynn as flynn_map with context %}

ufw-flynn-http:
  ufw.allowed:
    - protocol: tcp
    - to_port: http
    - require:
      - pkg: ufw

ufw-flynn-https:
  ufw.allowed:
    - protocol: tcp
    - to_port: https
    - require:
      - pkg: ufw

ufw-flynn-git-ssh:
  ufw.allowed:
    - protocol: tcp
    - to_port: "2222"
    - require:
      - pkg: ufw

ufw-flynn-user-ports:
  ufw.allowed:
    - protocol: tcp
    - to_port: "3000:3500"
    - require:
      - pkg: ufw

ufw-flynn-interface-flannel:
  ufw.allowed:
    - interface: 'flannel.1'
    - require:
      - pkg: ufw

ufw-flynn-interface-lo:
  ufw.allowed:
    - interface: 'lo'
    - require:
      - pkg: ufw

ufw-flynn-interface-flynnbr0:
  ufw.allowed:
    - interface: 'flynnbr0'
    - require:
      - pkg: ufw

ufw-flynn-interface-vnet:
  ufw.allowed:
    - interface: 'vnet+'
    - require:
      - pkg: ufw

# Flynn peers
{%- set local_interfaces = salt['mine.get'](grains['id'], 'network.interfaces')[grains['id']] %}
{%- set selector = salt['pillar.get']('flynn:ufw:peers_glob', '*') %}

{%- for interface in ['eth0', 'eth1'] %}
  {%- set to_addr = local_interfaces[interface]['inet'][0]['address'] %}
  {%- for host, interfaces in salt['mine.get'](selector, 'network.interfaces').iteritems() %}
    {%- if host != grains['id'] %}
      {%- set from_addr = interfaces[interface]['inet'][0]['address'] %}
ufw-flynn-peer-{{ host }}-{{ from_addr }}-to-{{ to_addr }}:
  ufw.allowed:
    - from_addr: {{ from_addr }}
    - to_addr: {{ to_addr }}
    - require:
      - pkg: ufw
    {%- endif %}
  {%- endfor %}
{%- endfor %}
