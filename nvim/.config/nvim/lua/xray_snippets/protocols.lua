local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local s = ls.snippet
local i = ls.insert_node

local function snippet(trigger, name, body, nodes)
    return s({ trig = trigger, name = name }, fmta(body, nodes or {}))
end

return {
    snippet("xr-in-socks", "Xray SOCKS inbound", [[{
  "tag": "<>",
  "listen": "<>",
  "port": <>,
  "protocol": "socks",
  "settings": {
    "auth": "<>",
    "udp": <>
  },
  "sniffing": {
    "enabled": true,
    "destOverride": [
      "http",
      "tls",
      "quic"
    ]
  }
}]], {
        i(1, "socks-in"),
        i(2, "127.0.0.1"),
        i(3, "1080"),
        i(4, "noauth"),
        i(5, "true"),
    }),

    snippet("xr-in-http", "Xray HTTP inbound", [[{
  "tag": "<>",
  "listen": "<>",
  "port": <>,
  "protocol": "http",
  "settings": {
    "timeout": <>
  }
}]], {
        i(1, "http-in"),
        i(2, "127.0.0.1"),
        i(3, "8080"),
        i(4, "300"),
    }),

    snippet("xr-in-mixed", "Xray mixed inbound", [[{
  "tag": "<>",
  "listen": "<>",
  "port": <>,
  "protocol": "mixed",
  "settings": {
    "auth": "<>",
    "udp": <>
  },
  "sniffing": {
    "enabled": true,
    "destOverride": [
      "http",
      "tls",
      "quic"
    ]
  }
}]], {
        i(1, "mixed-in"),
        i(2, "127.0.0.1"),
        i(3, "10808"),
        i(4, "noauth"),
        i(5, "true"),
    }),

    snippet("xr-in-vless", "Xray VLESS inbound", [[{
  "tag": "<>",
  "listen": "<>",
  "port": <>,
  "protocol": "vless",
  "settings": {
    "clients": [
      {
        "id": "<>",
        "flow": "<>"
      }
    ],
    "decryption": "none",
    "fallbacks": [
      <>
    ]
  },
  "streamSettings": <>
}]], {
        i(1, "vless-in"),
        i(2, "0.0.0.0"),
        i(3, "443"),
        i(4, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(5, "xtls-rprx-vision"),
        i(6, "{}"),
        i(7, "{}"),
    }),

    snippet("xr-in-trojan", "Xray Trojan inbound", [[{
  "tag": "<>",
  "listen": "<>",
  "port": <>,
  "protocol": "trojan",
  "settings": {
    "clients": [
      {
        "password": "<>",
        "email": "<>"
      }
    ]
  },
  "streamSettings": <>
}]], {
        i(1, "trojan-in"),
        i(2, "0.0.0.0"),
        i(3, "443"),
        i(4, "change-me"),
        i(5, "user@example.com"),
        i(6, "{}"),
    }),

    snippet("xr-in-vmess", "Xray VMess inbound", [[{
  "tag": "<>",
  "listen": "<>",
  "port": <>,
  "protocol": "vmess",
  "settings": {
    "clients": [
      {
        "id": "<>",
        "alterId": 0,
        "email": "<>"
      }
    ]
  },
  "streamSettings": <>
}]], {
        i(1, "vmess-in"),
        i(2, "0.0.0.0"),
        i(3, "443"),
        i(4, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(5, "user@example.com"),
        i(6, "{}"),
    }),

    snippet("xr-in-shadowsocks", "Xray Shadowsocks inbound", [[{
  "tag": "<>",
  "listen": "<>",
  "port": <>,
  "protocol": "shadowsocks",
  "settings": {
    "method": "<>",
    "password": "<>",
    "network": "<>"
  }
}]], {
        i(1, "ss-in"),
        i(2, "0.0.0.0"),
        i(3, "8388"),
        i(4, "2022-blake3-aes-128-gcm"),
        i(5, "change-me"),
        i(6, "tcp,udp"),
    }),

    snippet("xr-in-tunnel", "Xray dokodemo/tunnel inbound", [[{
  "tag": "<>",
  "listen": "<>",
  "port": <>,
  "protocol": "dokodemo-door",
  "settings": {
    "network": "<>",
    "followRedirect": <>
  },
  "streamSettings": {
    "sockopt": {
      "tproxy": "<>"
    }
  }
}]], {
        i(1, "tproxy-in"),
        i(2, "127.0.0.1"),
        i(3, "12345"),
        i(4, "tcp,udp"),
        i(5, "true"),
        i(6, "tproxy"),
    }),

    snippet("xr-in-tun", "Xray TUN inbound", [[{
  "tag": "<>",
  "protocol": "tun",
  "settings": {
    "interfaceName": "<>",
    "mtu": <>,
    "address": [
      "<>"
    ]
  }
}]], {
        i(1, "tun-in"),
        i(2, "tun0"),
        i(3, "1500"),
        i(4, "172.19.0.1/30"),
    }),

    snippet("xr-out-freedom", "Xray freedom outbound", [[{
  "tag": "<>",
  "protocol": "freedom",
  "settings": {
    "domainStrategy": "<>"
  }
}]], {
        i(1, "direct"),
        i(2, "AsIs"),
    }),

    snippet("xr-out-blackhole", "Xray blackhole outbound", [[{
  "tag": "<>",
  "protocol": "blackhole",
  "settings": {
    "response": {
      "type": "<>"
    }
  }
}]], {
        i(1, "block"),
        i(2, "none"),
    }),

    snippet("xr-out-dns", "Xray DNS outbound", [[{
  "tag": "<>",
  "protocol": "dns"
}]], {
        i(1, "dns-out"),
    }),

    snippet("xr-out-vless", "Xray VLESS outbound", [[{
  "tag": "<>",
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
            "flow": "<>"
          }
        ]
      }
    ]
  },
  "streamSettings": <>
}]], {
        i(1, "proxy"),
        i(2, "example.com"),
        i(3, "443"),
        i(4, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(5, "xtls-rprx-vision"),
        i(6, "{}"),
    }),

    snippet("xr-out-trojan", "Xray Trojan outbound", [[{
  "tag": "<>",
  "protocol": "trojan",
  "settings": {
    "servers": [
      {
        "address": "<>",
        "port": <>,
        "password": "<>"
      }
    ]
  },
  "streamSettings": <>
}]], {
        i(1, "proxy"),
        i(2, "example.com"),
        i(3, "443"),
        i(4, "change-me"),
        i(5, "{}"),
    }),

    snippet("xr-out-vmess", "Xray VMess outbound", [[{
  "tag": "<>",
  "protocol": "vmess",
  "settings": {
    "vnext": [
      {
        "address": "<>",
        "port": <>,
        "users": [
          {
            "id": "<>",
            "alterId": 0,
            "security": "<>"
          }
        ]
      }
    ]
  },
  "streamSettings": <>
}]], {
        i(1, "proxy"),
        i(2, "example.com"),
        i(3, "443"),
        i(4, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(5, "auto"),
        i(6, "{}"),
    }),

    snippet("xr-out-shadowsocks", "Xray Shadowsocks outbound", [[{
  "tag": "<>",
  "protocol": "shadowsocks",
  "settings": {
    "servers": [
      {
        "address": "<>",
        "port": <>,
        "method": "<>",
        "password": "<>"
      }
    ]
  }
}]], {
        i(1, "proxy"),
        i(2, "example.com"),
        i(3, "8388"),
        i(4, "2022-blake3-aes-128-gcm"),
        i(5, "change-me"),
    }),

    snippet("xr-out-socks", "Xray SOCKS upstream outbound", [[{
  "tag": "<>",
  "protocol": "socks",
  "settings": {
    "servers": [
      {
        "address": "<>",
        "port": <>
      }
    ]
  }
}]], {
        i(1, "socks-upstream"),
        i(2, "127.0.0.1"),
        i(3, "1080"),
    }),

    snippet("xr-out-http", "Xray HTTP upstream outbound", [[{
  "tag": "<>",
  "protocol": "http",
  "settings": {
    "servers": [
      {
        "address": "<>",
        "port": <>
      }
    ]
  }
}]], {
        i(1, "http-upstream"),
        i(2, "127.0.0.1"),
        i(3, "8080"),
    }),

    snippet("xr-out-wireguard", "Xray WireGuard outbound", [[{
  "tag": "<>",
  "protocol": "wireguard",
  "settings": {
    "secretKey": "<>",
    "address": [
      "<>"
    ],
    "peers": [
      {
        "publicKey": "<>",
        "endpoint": "<>:<>"
      }
    ]
  }
}]], {
        i(1, "warp"),
        i(2, "private-key"),
        i(3, "172.16.0.2/32"),
        i(4, "public-key"),
        i(5, "engage.cloudflareclient.com"),
        i(6, "2408"),
    }),

    snippet("xr-user-vless", "Xray VLESS user", [[{
  "id": "<>",
  "flow": "<>"
}]], {
        i(1, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(2, "xtls-rprx-vision"),
    }),

    snippet("xr-user-vmess", "Xray VMess user", [[{
  "id": "<>",
  "alterId": 0,
  "email": "<>"
}]], {
        i(1, "ea2ac847-0bf6-4576-8fbb-ec0e139b42ad"),
        i(2, "user@example.com"),
    }),

    snippet("xr-user-trojan", "Xray Trojan user", [[{
  "password": "<>",
  "email": "<>"
}]], {
        i(1, "change-me"),
        i(2, "user@example.com"),
    }),

    snippet("xr-user-http", "Xray HTTP user", [[{
  "user": "<>",
  "pass": "<>"
}]], {
        i(1, "user"),
        i(2, "password"),
    }),

    snippet("xr-user-socks", "Xray SOCKS user", [[{
  "user": "<>",
  "pass": "<>"
}]], {
        i(1, "user"),
        i(2, "password"),
    }),

    snippet("xr-client-shadowsocks", "Xray Shadowsocks client/server item", [[{
  "address": "<>",
  "port": <>,
  "method": "<>",
  "password": "<>"
}]], {
        i(1, "example.com"),
        i(2, "8388"),
        i(3, "2022-blake3-aes-128-gcm"),
        i(4, "change-me"),
    }),
}
