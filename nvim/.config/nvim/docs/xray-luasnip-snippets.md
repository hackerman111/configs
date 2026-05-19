# Xray LuaSnip snippets

Этот набор сниппетов помогает быстро собирать Xray-core JSON/JSONC конфиги в Neovim. Сниппеты подключены к filetype `xray`, а также доступны из `json` и `jsonc` через `luasnip.filetype_extend`.

## Использование

1. Открой Xray конфиг, например `config.json` или `config.jsonc`.
2. Набери trigger, например `xr-cfg-client-vless-reality`.
3. Нажми `<Tab>`, чтобы развернуть сниппет и переходить по полям.
4. Перед запуском или рестартом Xray проверь итоговый конфиг:

```bash
xray run -test -c config.json
```

## Основные trigger группы

- `xr-cfg-*`: полные шаблоны конфигов.
- `xr-in-*`: inbound объекты.
- `xr-out-*`: outbound объекты.
- `xr-stream-*`: `streamSettings` и transport/security блоки.
- `xr-rule-*`: routing rules.
- `xr-user-*`: reusable user/client элементы.

## Секреты и ключи

Сниппеты намеренно не генерируют реальные секреты. Значения в шаблонах нужно заменить перед использованием.

Полезные команды Xray:

```bash
xray uuid
xray x25519
xray x25519 -i "server-private-key"
```

Для TLS-шаблонов укажи реальные `certificateFile` и `keyFile`. Для REALITY-шаблонов замени `privateKey`, `password`/public key, `shortIds`, `serverName` и `target`.

## Проверка набора сниппетов

Из каталога `~/.config/nvim`:

```bash
nvim --headless -u init.lua "+luafile tests/xray_luasnip_spec.lua" +qa
xray run -test -c tests/fixtures/xray/server-vless-reality.json
xray run -test -c tests/fixtures/xray/client-vless-reality.json
xray run -test -c tests/fixtures/xray/server-vless-tls-fallback.json
```
