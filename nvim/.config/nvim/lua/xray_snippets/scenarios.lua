local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local s = ls.snippet
local i = ls.insert_node

local function snippet(trigger, name, body, nodes)
    return s({ trig = trigger, name = name }, fmta(body, nodes or {}))
end

return {
    snippet("xr-cfg-server-vless-reality", "Xray server VLESS REALITY config", [[{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "vless-reality-in",
      "listen": "0.0.0.0",
      "port": <>,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "<>",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "raw",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "target": "<>",
          "xver": 0,
          "serverNames": [
            "<>"
          ],
          "privateKey": "<>",
          "shortIds": [
            "<>"
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom"
    },
    {
      "tag": "block",
      "protocol": "blackhole"
    }
  ]
}]], {
        i(1, "443"),
        i(2, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(3, "www.microsoft.com:443"),
        i(4, "www.microsoft.com"),
        i(5, "server-private-key"),
        i(6, "0123456789abcdef"),
    }),

    snippet("xr-cfg-client-vless-reality", "Xray client VLESS REALITY config", [[{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "socks-in",
      "listen": "127.0.0.1",
      "port": 1080,
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "<>",
            "port": <>,
            "users": [
              {
                "id": "<>",
                "encryption": "none",
                "flow": "xtls-rprx-vision"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "raw",
        "security": "reality",
        "realitySettings": {
          "serverName": "<>",
          "fingerprint": "chrome",
          "password": "<>",
          "shortId": "<>",
          "spiderX": "/"
        }
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom"
    },
    {
      "tag": "block",
      "protocol": "blackhole"
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": [
          "10.0.0.0/8",
          "172.16.0.0/12",
          "192.168.0.0/16",
          "127.0.0.0/8"
        ],
        "outboundTag": "direct"
      }
    ]
  }
}]], {
        i(1, "server.example.com"),
        i(2, "443"),
        i(3, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(4, "www.microsoft.com"),
        i(5, "server-public-key"),
        i(6, "0123456789abcdef"),
    }),

    snippet("xr-cfg-server-vless-tls-fallback", "Xray server VLESS TLS fallback config", [[{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "vless-tls-in",
      "listen": "0.0.0.0",
      "port": <>,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "<>",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": "<>"
          }
        ]
      },
      "streamSettings": {
        "network": "raw",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "<>",
              "keyFile": "<>"
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom"
    },
    {
      "tag": "block",
      "protocol": "blackhole"
    }
  ]
}]], {
        i(1, "443"),
        i(2, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(3, "127.0.0.1:8443"),
        i(4, "/etc/ssl/xray/fullchain.pem"),
        i(5, "/etc/ssl/xray/privkey.pem"),
    }),

    snippet("xr-cfg-client-tproxy-advanced", "Xray advanced transparent proxy config", [[{
  "log": {
    "loglevel": "warning"
  },
  "dns": {
    "servers": [
      "1.1.1.1",
      "8.8.8.8"
    ],
    "queryStrategy": "UseIP"
  },
  "inbounds": [
    {
      "tag": "tproxy-in",
      "listen": "127.0.0.1",
      "port": <>,
      "protocol": "dokodemo-door",
      "settings": {
        "network": "tcp,udp",
        "followRedirect": true
      },
      "streamSettings": {
        "sockopt": {
          "tproxy": "tproxy",
          "mark": <>
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ],
        "routeOnly": false
      }
    },
    {
      "tag": "dns-in",
      "listen": "127.0.0.1",
      "port": <>,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "1.1.1.1",
        "port": 53,
        "network": "tcp,udp"
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "<>",
            "port": <>,
            "users": [
              {
                "id": "<>",
                "encryption": "none",
                "flow": "xtls-rprx-vision"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "sockopt": {
          "mark": <>
        }
      }
    },
    {
      "tag": "dns-out",
      "protocol": "dns"
    },
    {
      "tag": "direct",
      "protocol": "freedom"
    },
    {
      "tag": "block",
      "protocol": "blackhole"
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "dns-in"
        ],
        "outboundTag": "dns-out"
      },
      {
        "type": "field",
        "ip": [
          "10.0.0.0/8",
          "172.16.0.0/12",
          "192.168.0.0/16"
        ],
        "outboundTag": "direct"
      }
    ]
  }
}]], {
        i(1, "12345"),
        i(2, "255"),
        i(3, "1053"),
        i(4, "server.example.com"),
        i(5, "443"),
        i(6, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(7, "255"),
    }),
}
