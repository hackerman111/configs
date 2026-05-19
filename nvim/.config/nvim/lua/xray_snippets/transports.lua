local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local s = ls.snippet
local i = ls.insert_node

local function snippet(trigger, name, body, nodes)
    return s({ trig = trigger, name = name }, fmta(body, nodes or {}))
end

return {
    snippet("xr-stream-raw-none", "Xray raw stream without security", [["streamSettings": {
  "network": "raw",
  "security": "none"
}]]),

    snippet("xr-stream-raw-tls-client", "Xray raw TLS client stream", [["streamSettings": {
  "network": "raw",
  "security": "tls",
  "tlsSettings": {
    "serverName": "<>",
    "fingerprint": "<>"
  }
}]], {
        i(1, "example.com"),
        i(2, "chrome"),
    }),

    snippet("xr-stream-raw-tls-server", "Xray raw TLS server stream", [["streamSettings": {
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
}]], {
        i(1, "/etc/ssl/xray/fullchain.pem"),
        i(2, "/etc/ssl/xray/privkey.pem"),
    }),

    snippet("xr-stream-raw-reality-client", "Xray raw REALITY client stream", [["streamSettings": {
  "network": "raw",
  "security": "reality",
  "realitySettings": {
    "serverName": "<>",
    "fingerprint": "<>",
    "password": "<>",
    "shortId": "<>",
    "spiderX": "<>"
  }
}]], {
        i(1, "www.microsoft.com"),
        i(2, "chrome"),
        i(3, "server-public-key"),
        i(4, "0123456789abcdef"),
        i(5, "/"),
    }),

    snippet("xr-stream-raw-reality-server", "Xray raw REALITY server stream", [["streamSettings": {
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
}]], {
        i(1, "www.microsoft.com:443"),
        i(2, "www.microsoft.com"),
        i(3, "server-private-key"),
        i(4, "0123456789abcdef"),
    }),

    snippet("xr-stream-ws-tls", "Xray WebSocket TLS stream", [["streamSettings": {
  "network": "websocket",
  "security": "tls",
  "tlsSettings": {
    "serverName": "<>"
  },
  "wsSettings": {
    "path": "<>",
    "headers": {
      "Host": "<>"
    }
  }
}]], {
        i(1, "example.com"),
        i(2, "/ws"),
        i(3, "example.com"),
    }),

    snippet("xr-stream-grpc-tls", "Xray gRPC TLS stream", [["streamSettings": {
  "network": "grpc",
  "security": "tls",
  "tlsSettings": {
    "serverName": "<>"
  },
  "grpcSettings": {
    "serviceName": "<>",
    "multiMode": false
  }
}]], {
        i(1, "example.com"),
        i(2, "xray"),
    }),

    snippet("xr-stream-httpupgrade-tls", "Xray HTTPUpgrade TLS stream", [["streamSettings": {
  "network": "httpupgrade",
  "security": "tls",
  "tlsSettings": {
    "serverName": "<>"
  },
  "httpupgradeSettings": {
    "path": "<>",
    "host": "<>"
  }
}]], {
        i(1, "example.com"),
        i(2, "/upgrade"),
        i(3, "example.com"),
    }),

    snippet("xr-stream-sockopt-mark", "Xray stream sockopt mark", [["streamSettings": {
  "sockopt": {
    "mark": <>
  }
}]], {
        i(1, "255"),
    }),

    snippet("xr-stream-sockopt-tproxy", "Xray stream sockopt tproxy", [["streamSettings": {
  "sockopt": {
    "tproxy": "<>",
    "mark": <>
  }
}]], {
        i(1, "tproxy"),
        i(2, "255"),
    }),

    snippet("xr-tls-client", "Xray TLS client settings", [["tlsSettings": {
  "serverName": "<>",
  "fingerprint": "<>",
  "allowInsecure": false
}]], {
        i(1, "example.com"),
        i(2, "chrome"),
    }),

    snippet("xr-tls-server-cert", "Xray TLS server certificate settings", [["tlsSettings": {
  "certificates": [
    {
      "certificateFile": "<>",
      "keyFile": "<>"
    }
  ]
}]], {
        i(1, "/etc/ssl/xray/fullchain.pem"),
        i(2, "/etc/ssl/xray/privkey.pem"),
    }),

    snippet("xr-reality-client", "Xray REALITY client settings", [["realitySettings": {
  "serverName": "<>",
  "fingerprint": "<>",
  "password": "<>",
  "shortId": "<>",
  "spiderX": "<>"
}]], {
        i(1, "www.microsoft.com"),
        i(2, "chrome"),
        i(3, "server-public-key"),
        i(4, "0123456789abcdef"),
        i(5, "/"),
    }),

    snippet("xr-reality-server", "Xray REALITY server settings", [["realitySettings": {
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
}]], {
        i(1, "www.microsoft.com:443"),
        i(2, "www.microsoft.com"),
        i(3, "server-private-key"),
        i(4, "0123456789abcdef"),
    }),

    snippet("xr-reality-limit-fallback", "Xray REALITY limit fallback", [[{
  "name": "<>",
  "alpn": "<>",
  "path": "<>",
  "dest": "<>",
  "xver": 0
}]], {
        i(1, "fallback"),
        i(2, "h2"),
        i(3, "/"),
        i(4, "127.0.0.1:8443"),
    }),

    snippet("xr-sockopt-basic", "Xray basic sockopt", [["sockopt": {
  "mark": <>,
  "tcpFastOpen": false
}]], {
        i(1, "255"),
    }),

    snippet("xr-sockopt-tproxy", "Xray tproxy sockopt", [["sockopt": {
  "tproxy": "<>",
  "mark": <>
}]], {
        i(1, "tproxy"),
        i(2, "255"),
    }),

    snippet("xr-sniffing", "Xray sniffing object", [["sniffing": {
  "enabled": true,
  "destOverride": [
    "http",
    "tls",
    "quic"
  ],
  "routeOnly": <>
}]], {
        i(1, "false"),
    }),

    snippet("xr-fallback", "Xray fallback object", [[{
  "name": "<>",
  "alpn": "<>",
  "path": "<>",
  "dest": "<>",
  "xver": 0
}]], {
        i(1, "example.com"),
        i(2, "h2"),
        i(3, "/"),
        i(4, "127.0.0.1:8443"),
    }),

    snippet("xr-stream-xhttp-review-docs", "Xray XHTTP stream schema review stub", [["streamSettings": {
  "network": "xhttp"
}]]),
}
