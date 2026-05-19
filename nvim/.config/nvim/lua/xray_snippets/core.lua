local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

return {
    s({ trig = "xr-cfg-empty", name = "Xray empty config" }, {
        t({
            "{",
            '  "log": {',
            '    "loglevel": "',
        }),
        i(1, "warning"),
        t({
            '"',
            "  },",
            '  "dns": {',
            '    "servers": [',
            '      "',
        }),
        i(2, "1.1.1.1"),
        t({
            '"',
            "    ],",
            '    "queryStrategy": "',
        }),
        i(3, "UseIP"),
        t({
            '"',
            "  },",
            '  "routing": {',
            '    "domainStrategy": "',
        }),
        i(4, "AsIs"),
        t({
            '",',
            '    "rules": []',
            "  },",
            '  "inbounds": [',
            "    ",
        }),
        i(5, "{}"),
        t({
            "",
            "  ],",
            '  "outbounds": [',
            "    ",
        }),
        i(6, "{}"),
        t({
            "",
            "  ]",
            "}",
        }),
    }),

    s({ trig = "xr-log", name = "Xray log object" }, {
        t({
            '"log": {',
            '  "loglevel": "',
        }),
        i(1, "warning"),
        t({
            '",',
            '  "access": "',
        }),
        i(2, "none"),
        t({
            '",',
            '  "error": "',
        }),
        i(3, "none"),
        t({
            '",',
            '  "dnsLog": ',
        }),
        i(4, "false"),
        t({
            ",",
            '  "maskAddress": "',
        }),
        i(5, "half"),
        t({
            '"',
            "}",
        }),
    }),

    s({ trig = "xr-dns-basic", name = "Xray DNS object" }, {
        t({
            '"dns": {',
            '  "servers": [',
            '    "',
        }),
        i(1, "1.1.1.1"),
        t({
            '"',
            "  ],",
            '  "queryStrategy": "',
        }),
        i(2, "UseIP"),
        t({
            '",',
            '  "tag": "',
        }),
        i(3, "dns-in"),
        t({
            '"',
            "}",
        }),
    }),

    s({ trig = "xr-dns-server", name = "Xray DNS server object" }, {
        t({
            "{",
            '  "address": "',
        }),
        i(1, "https://1.1.1.1/dns-query"),
        t({
            '",',
            '  "port": ',
        }),
        i(2, "443"),
        t({
            ",",
            '  "domains": [',
            '    "',
        }),
        i(3, "geosite:geolocation-!cn"),
        t({
            '"',
            "  ],",
            '  "expectIPs": [',
            '    "',
        }),
        i(4, "geoip:!cn"),
        t({
            '"',
            "  ]",
            "}",
        }),
    }),

    s({ trig = "xr-routing", name = "Xray routing object" }, {
        t({
            '"routing": {',
            '  "domainStrategy": "',
        }),
        i(1, "AsIs"),
        t({
            '",',
            '  "domainMatcher": "',
        }),
        i(2, "hybrid"),
        t({
            '",',
            '  "rules": [',
            "    ",
        }),
        i(3, "{}"),
        t({
            "",
            "  ],",
            '  "balancers": []',
            "}",
        }),
    }),

    s({ trig = "xr-rule-domain", name = "Xray routing domain rule" }, {
        t({
            "{",
            '  "type": "field",',
            '  "domain": [',
            '    "',
        }),
        i(1, "geosite:category-ads-all"),
        t({
            '"',
            "  ],",
            '  "outboundTag": "',
        }),
        i(2, "block"),
        t({
            '"',
            "}",
        }),
    }),

    s({ trig = "xr-rule-ip", name = "Xray routing IP rule" }, {
        t({
            "{",
            '  "type": "field",',
            '  "ip": [',
            '    "',
        }),
        i(1, "geoip:private"),
        t({
            '"',
            "  ],",
            '  "outboundTag": "',
        }),
        i(2, "direct"),
        t({
            '"',
            "}",
        }),
    }),

    s({ trig = "xr-rule-catchall", name = "Xray routing catch-all rule" }, {
        t({
            "{",
            '  "type": "field",',
            '  "network": "tcp,udp",',
            '  "outboundTag": "',
        }),
        i(1, "proxy"),
        t({
            '"',
            "}",
        }),
    }),

    s({ trig = "xr-balancer", name = "Xray routing balancer object" }, {
        t({
            "{",
            '  "tag": "',
        }),
        i(1, "proxy-balancer"),
        t({
            '",',
            '  "selector": [',
            '    "',
        }),
        i(2, "proxy"),
        t({
            '"',
            "  ],",
            '  "strategy": {',
            '    "type": "',
        }),
        i(3, "random"),
        t({
            '"',
            "  }",
            "}",
        }),
    }),

    s({ trig = "xr-observatory", name = "Xray observatory object" }, {
        t({
            '"observatory": {',
            '  "subjectSelector": [',
            '    "',
        }),
        i(1, "proxy"),
        t({
            '"',
            "  ],",
            '  "probeURL": "',
        }),
        i(2, "https://www.gstatic.com/generate_204"),
        t({
            '",',
            '  "probeInterval": "',
        }),
        i(3, "1m"),
        t({
            '"',
            "}",
        }),
    }),

    s({ trig = "xr-policy", name = "Xray policy object" }, {
        t({
            '"policy": {',
            '  "levels": {',
            '    "0": {',
            '      "handshake": ',
        }),
        i(1, "4"),
        t({
            ",",
            '      "connIdle": ',
        }),
        i(2, "300"),
        t({
            ",",
            '      "uplinkOnly": ',
        }),
        i(3, "2"),
        t({
            ",",
            '      "downlinkOnly": ',
        }),
        i(4, "5"),
        t({
            ",",
            '      "statsUserUplink": ',
        }),
        i(5, "false"),
        t({
            ",",
            '      "statsUserDownlink": ',
        }),
        i(6, "false"),
        t({
            "",
            "    }",
            "  },",
            '  "system": {',
            '    "statsInboundUplink": ',
        }),
        i(7, "false"),
        t({
            ",",
            '    "statsInboundDownlink": ',
        }),
        i(8, "false"),
        t({
            ",",
            '    "statsOutboundUplink": ',
        }),
        i(9, "false"),
        t({
            ",",
            '    "statsOutboundDownlink": ',
        }),
        i(10, "false"),
        t({
            "",
            "  }",
            "}",
        }),
    }),

    s({ trig = "xr-fakedns", name = "Xray FakeDNS object" }, {
        t({
            '"fakedns": [',
            "  {",
            '    "ipPool": "',
        }),
        i(1, "198.18.0.0/15"),
        t({
            '",',
            '    "poolSize": ',
        }),
        i(2, "65535"),
        t({
            "",
            "  }",
            "]",
        }),
    }),

    s({ trig = "xr-version", name = "Xray version object" }, {
        t({
            '"version": {',
            '  "min": "',
        }),
        i(1, "1.8.0"),
        t({
            '",',
            '  "max": "',
        }),
        i(2, "1.99.0"),
        t({
            '"',
            "}",
        }),
    }),
}
