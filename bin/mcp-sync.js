// Remplace la cle mcpServers de ~/.claude.json par celle du repo (source unique).
// Repli de `jq` pour Windows, ou jq n'est presque jamais installe.
const fs = require("fs");
const [state, src] = process.argv.slice(2);
const c = JSON.parse(fs.readFileSync(state, "utf8"));
c.mcpServers = JSON.parse(fs.readFileSync(src, "utf8")).mcpServers;
fs.writeFileSync(state, JSON.stringify(c, null, 2));
